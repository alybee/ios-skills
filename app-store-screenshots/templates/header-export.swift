// Renders header.html: the product page header (3840×1646, 21:9) or the search results asset (3840×2560, 3:2).
//
//   xcrun swift AppStore/marketing/header-export.swift header <still|video>
//   xcrun swift AppStore/marketing/header-export.swift search <still|video> <language>
//
// Writes export/header/ or export/search/<language>/: still.png (opaque, at the exact size) or <layout>.mov, the 20 s loop,
// 30 fps, H.264, no audio. Frames are drawn one by one at their exact time, never played in real time, so a
// slow snapshot cannot drop one.

import AppKit
import AVFoundation
import WebKit

let heights = ["header": 823.0, "search": 1280.0]

let arguments = CommandLine.arguments
guard arguments.count >= 3, let height = heights[arguments[1]], ["still", "video"].contains(arguments[2]),
      arguments[1] == "header" || arguments.count == 4
else {
    print("usage: header-export.swift header <still|video> | search <still|video> <language>")
    exit(1)
}

let layout = arguments[1]
let isVideo = arguments[2] == "video"
let language = arguments.count == 4 ? arguments[3] : "en"
let points = CGSize(width: 1920, height: height)
let pixels = CGSize(width: 3840, height: height * 2)
let loopSeconds = 20, fps = 30

let folder = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
let app = NSApplication.shared
let web = WKWebView(frame: CGRect(origin: .zero, size: points))
let window = NSWindow(contentRect: web.frame, styleMask: [.borderless], backing: .buffered, defer: false)
window.contentView = web

func opaque(_ image: NSImage) -> CGImage? {
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil),
          let context = CGContext(
              data: nil, width: Int(pixels.width), height: Int(pixels.height), bitsPerComponent: 8, bytesPerRow: 0,
              space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
          )
    else { return nil }
    context.interpolationQuality = .high
    context.draw(cgImage, in: CGRect(origin: .zero, size: pixels))
    return context.makeImage()
}

let out = folder.appendingPathComponent(layout == "header" ? "export/header" : "export/search/\(language)")
try? FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)

/// Draws the scene at `seconds`, then snapshots it once WebKit has painted.
func render(at seconds: Double, then handle: @escaping (CGImage) -> Void) {
    web.evaluateJavaScript("exportFrame(\(seconds))") { _, _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let config = WKSnapshotConfiguration()
            config.rect = CGRect(origin: .zero, size: points)
            config.snapshotWidth = NSNumber(value: Double(pixels.width))
            web.takeSnapshot(with: config) { image, error in
                guard let image, let frame = opaque(image) else {
                    print("✘ \(seconds) s: \(error?.localizedDescription ?? "no image")")
                    exit(1)
                }
                handle(frame)
            }
        }
    }
}

func writeStill() {
    render(at: 0) { frame in
        let file = out.appendingPathComponent("still.png")
        try? NSBitmapImageRep(cgImage: frame).representation(using: .png, properties: [:])?.write(to: file)
        print("✓ \(file.path)")
        exit(0)
    }
}

func writeVideo() {
    let file = out.appendingPathComponent("\(layout).mov")
    try? FileManager.default.removeItem(at: file)
    let writer = try! AVAssetWriter(outputURL: file, fileType: .mov)
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: Int(pixels.width),
        AVVideoHeightKey: Int(pixels.height),
        AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 40_000_000],
    ])
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        kCVPixelBufferWidthKey as String: Int(pixels.width),
        kCVPixelBufferHeightKey as String: Int(pixels.height),
    ])
    writer.add(input)
    writer.startWriting()
    writer.startSession(atSourceTime: .zero)

    let total = loopSeconds * fps
    func append(_ index: Int) {
        guard index < total else {
            input.markAsFinished()
            writer.finishWriting {
                print("✓ \(file.path)")
                exit(writer.status == .completed ? 0 : 1)
            }
            return
        }
        render(at: Double(index) / Double(fps)) { frame in
            var buffer: CVPixelBuffer?
            CVPixelBufferPoolCreatePixelBuffer(nil, adaptor.pixelBufferPool!, &buffer)
            guard let buffer else { exit(1) }
            CVPixelBufferLockBaseAddress(buffer, [])
            let context = CGContext(
                data: CVPixelBufferGetBaseAddress(buffer), width: frame.width, height: frame.height,
                bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
            )
            context?.draw(frame, in: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            CVPixelBufferUnlockBaseAddress(buffer, [])

            while !input.isReadyForMoreMediaData {
                RunLoop.current.run(until: .now + 0.01)
            }
            adaptor.append(buffer, withPresentationTime: CMTime(value: CMTimeValue(index), timescale: CMTimeScale(fps)))
            if index % fps == 0 {
                print("  \(index / fps) s / \(loopSeconds) s")
            }
            append(index + 1)
        }
    }
    append(0)
}

// The parent folder too: the search layout shows a raw screen from AppStore/screenshots.
web.loadFileURL(folder.appendingPathComponent("header.html"), allowingReadAccessTo: folder.deletingLastPathComponent())
// Long enough for the page and its images to load; there is no load event to wait on here.
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    web.evaluateJavaScript("setup('\(layout)', '\(language)')")
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        isVideo ? writeVideo() : writeStill()
    }
}

app.run()
