# Product page header video

Templates: `templates/header.html`, `templates/header-export.swift`.

## Content

- Most apps put a logo on a colour. Something alive and on-brand reads better: the app's own scene
  artwork with one or two slow motions (drifting clouds, a rolling tumbleweed). No mascot, no text: the
  App Store draws the icon, name and Get button over it.
- One clear idea, slow motion (Apple warns against quick cuts), and a **seamless loop**: every motion
  completes a whole number of cycles per loop (clouds slide by one pattern period, an object crosses once,
  hops divide the loop evenly).
- Pick a loop of 20 s: long enough to be calm, short enough to render quickly.

## Safe area — learned on device

- **Keep the top ~35 % free of anything that matters.** On iPhone the header runs under the status bar
  and the Dynamic Island; back and share buttons sit on the sides, a play button in the centre; the sides
  are cropped to roughly the middle 70 %. On iPad the top is cropped.
- Elements lowered into the middle band may cross the scene's own features (a mesa): fade them out
  before it with a CSS mask rather than letting them pass in front.
- Check in App Store Connect's preview and on a real iPhone and iPad.

## Rendering

- The page draws the scene at time `t` with a pure function `frame(t)` — no CSS animations, no
  `requestAnimationFrame` during export. A browser preview plays it live.
- A Swift script calls `exportFrame(t)` for each of `fps × seconds` frames, snapshots it, redraws it
  opaque and appends it to an `AVAssetWriter` (H.264, ~40 Mb/s, `.mov`, no audio track). Frames are
  drawn at their exact time, so a slow snapshot never drops one. 600 frames at 3840×1646 take about a
  minute. No ffmpeg needed.
- Verify with `AVURLAsset`: size, fps, duration, codec, no audio; extract frames at 0, mid and end with
  `AVAssetImageGenerator` and compare the last to the first.
- No still to export: App Store Connect picks the poster frame from the video. Keep one strong frame in
  the loop for it.

## Artwork pitfalls

- Render vector artwork from its PDF at the target size (`sips -s format png -Z 2700 in.pdf`).
- An artwork narrower than 21:9: extend it with a **stretched 2-px column of the image itself**. CSS
  colours sampled from the image never match once WebKit applies the image's colour profile.
- Crop with `CGImage.cropping(to:)`: `sips --cropOffset 0 0` does not crop at the origin.
- Draw the scene in one coordinate system and scale it (`transform: scale`) for another ratio, so the
  motion code is shared.

## Search results asset

3:2, up to 3840×2560, image or video. It **replaces the screenshots in search results**, which usually
show more. If the developer still wants one: the same scene, the first slide's title and one screen of
the app in a device frame, kept clear of the scene's main shape — one file per language.
