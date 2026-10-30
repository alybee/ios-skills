# app-store-screenshots

An agent skill that produces the **App Store visuals** of an iOS app end to end: raw screenshots from a
scripted UI test, marketing slides, their localisation, the iPad and **iPhone Duo** variants, and an
animated **product page header** video — all exported at App Store Connect's exact sizes, without alpha.

It comes out of one real run on a shipping SwiftUI app (six languages, iPhone, iPad, iPhone Duo, an
animated header), October 2026. Every rule in it is a round trip that already happened:

- App Store Connect no longer offering the 6.9" iPhone slot, and refusing 1320×2868 in the 6.3" one;
- a white strip down the right of every exported PNG — a legacy scrollbar, because a mouse was plugged in;
- the iPhone Duo refolding at every test run (parallel testing runs on clones of the simulator), then
  capturing a black screen (`XCUIScreen.main` is the outer display), then a squashed one (unfolded, the
  app runs in landscape, stored with an EXIF rotation);
- a launch argument that keeps onboarding on screen after "finish", because the argument domain outranks
  what the app writes;
- a celebration overlay missed on iPad because it closes itself before a slower device captures it;
- header clouds hidden under the Dynamic Island, and cropped on iPad;
- a search results video that quietly replaced the screenshots in search.

## What's inside

```
app-store-screenshots/
├── SKILL.md                     # ground rules, 10-step workflow, final checks
├── references/
│   ├── specs.md                 # sizes and slots as App Store Connect actually offers them
│   ├── raw-capture.md           # the UI test, DEBUG launch flags, the script, iPhone Duo
│   ├── composition.md           # slides in HTML, copy and localisation rules, export to PNG
│   └── header-video.md          # animated header: safe area, seamless loop, frame-by-frame rendering
└── templates/
    ├── README.md                # where each file goes, what to fill in, how to run it
    ├── screenshots.sh           # runs the UI test per language/device/appearance, exports the PNGs
    ├── ScreenshotUITests.swift  # skeleton: launch flags, captures, Duo screen picking
    ├── slides.html              # iPhone / iPad / Duo layouts, speech bubbles, device switch
    ├── export.swift             # slides → exact-size PNGs (WebKit, no browser, no npm)
    ├── header.html              # animated scene drawn by a pure frame(t)
    └── header-export.swift      # header → H.264 .mov with AVAssetWriter (no ffmpeg)
```

No dependency beyond Xcode and macOS: `xcodebuild`, `simctl`, `xcresulttool`, `sips`, WebKit and
AVFoundation through `xcrun swift`.

## Use

> Make the App Store screenshots for this app, in French and English.

> App Store Connect refuses my iPhone screenshots: wrong dimensions.

> Now the iPad 13" version, then the iPhone Duo.

> Can we make an animated header for the product page?

The skill works one validated step at a time: platforms, raw captures, screen choice, three visual
directions, iterations, localisation, export, other devices, header. The developer runs the UI tests;
the agent builds them, renders the slides and checks every export.

## Status and limits

- One app, one run, Xcode 27.1 RC simulators, App Store Connect as of October 2026. Slots and required
  sizes change with each hardware generation: `references/specs.md` links the sources to re-check.
- The templates are the tested mechanics with the app's content removed; the slide layouts and the
  header scene are one app's design, meant to be redesigned.
- iOS only (iPhone, iPad, iPhone Duo). No Mac, Apple TV, Apple Watch or Vision Pro sizes.

## License

MIT — see [LICENSE](../LICENSE).
