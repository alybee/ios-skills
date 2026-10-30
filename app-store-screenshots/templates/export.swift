// Renders every slide of slides.html to an App Store Connect PNG: exact pixel size, no alpha channel.
//
//   xcrun swift AppStore/marketing/export.swift iphone [slide]
//
// Writes AppStore/marketing/export/<device>/<language>/NN.png. WebKit ships with macOS, so no browser or
// npm package is needed.

import AppKit
import WebKit

struct Device {
    let page: String
    let points: CGSize // the slide's CSS size
    let pixels: CGSize // what App Store Connect expects
}

let devices = [
    "iphone": Device(page: "slides.html", points: CGSize(width: 440, height: 956), pixels: CGSize(width: 1320, height: 2868)),
    "ipad": Device(page: "slides.html", points: CGSize(width: 1032, height: 1376), pixels: CGSize(width: 2064, height: 2752)),
    "duo": Device(page: "slides.html", points: CGSize(width: 951, height: 669), pixels: CGSize(width: 2853, height: 2007)),
]
// CONFIG: the keys of COPY in slides.html, and the number of slides.
let languages = ["en", "fr"]
let slideCount = 6

let arguments = CommandLine.arguments
guard (2 ... 3).contains(arguments.count), let device = devices[arguments[1]] else {
    print("usage: export.swift <\(devices.keys.sorted().joined(separator: "|"))> [slide]")
    exit(1)
}

let slides = arguments.count == 3 ? Int(arguments[2]).map { [$0] } ?? [] : Array(1 ... slideCount)
let deviceName = arguments[1]

let folder = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
let page = folder.appendingPathComponent(device.page)

let app = NSApplication.shared
let web = WKWebView(frame: CGRect(origin: .zero, size: device.points))
let window = NSWindow(contentRect: web.frame, styleMask: [.borderless], backing: .buffered, defer: false)
window.contentView = web

/// Draws the snapshot into an opaque bitmap of the exact size: App Store Connect refuses an alpha channel.
func writeOpaquePNG(_ image: NSImage, to url: URL) throws {
    let width = Int(device.pixels.width), height = Int(device.pixels.height)
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil),
          let context = CGContext(
              data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
              space: CGColorSpace(name: CGColorSpace.sRGB)!,
              bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
          )
    else { throw CocoaError(.fileWriteUnknown) }
    context.interpolationQuality = .high
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let output = context.makeImage() else { throw CocoaError(.fileWriteUnknown) }
    let rep = NSBitmapImageRep(cgImage: output)
    try rep.representation(using: .png, properties: [:])?.write(to: url)
}

var jobs = languages.flatMap { language in slides.map { (language, $0) } }

func next() {
    guard !jobs.isEmpty else { exit(0) }
    let (language, slide) = jobs.removeFirst()

    web.evaluateJavaScript("render(['\(language)'], \(slide), '\(deviceName)')")

    // Long enough for the screenshots to decode after the re-render.
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        let config = WKSnapshotConfiguration()
        config.rect = CGRect(origin: .zero, size: device.points)
        config.snapshotWidth = NSNumber(value: Double(device.pixels.width))
        web.takeSnapshot(with: config) { image, error in
            let out = folder.appendingPathComponent("export/\(deviceName)/\(language)")
            try? FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
            let file = out.appendingPathComponent(String(format: "%02d.png", slide))
            if let image {
                do {
                    try writeOpaquePNG(image, to: file)
                    print("✓ \(deviceName)/\(language)/\(file.lastPathComponent)")
                } catch {
                    print("✘ \(file.path): \(error)")
                }
            } else {
                print("✘ \(language) \(slide): \(error?.localizedDescription ?? "no image")")
            }
            next()
        }
    }
}

web.loadFileURL(page, allowingReadAccessTo: folder.deletingLastPathComponent())
// Long enough for the page and its web font to load; there is no load event for the font.
DispatchQueue.main.asyncAfter(deadline: .now() + 3) { next() }
app.run()
