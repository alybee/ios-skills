---
name: app-store-screenshots
description: "Produce the App Store visuals of an iOS app end to end: scripted raw screenshots from a UI test (every language, device and appearance), marketing slides composed in HTML and exported to exact-size PNGs without alpha, their localisation, the iPad and iPhone Duo variants, and the animated product page header video. Use when asked for App Store screenshots, 'marketshots', store slides, captures for App Store Connect, a product page header or search results video, or to adapt existing store visuals to another device, size or language; also when App Store Connect rejects a screenshot size. Not for the store's text (use app-store-copy) nor for fixing the app's own layout on a device (use swiftui-adaptive-layout)."
---

# App Store screenshots, slides and header video

Built from one real run (a SwiftUI app, three then six languages, iPhone, iPad, iPhone Duo, an animated
header). Every pitfall below cost at least one round trip; read the reference for a step before doing it.

| Step | Reference |
|---|---|
| Sizes, slots, required devices | [specs.md](references/specs.md) |
| Raw screens from a UI test | [raw-capture.md](references/raw-capture.md) |
| Slides, export, copy, localisation | [composition.md](references/composition.md) |
| Header video (and search results) | [header-video.md](references/header-video.md) |
| Ready-made scripts and pages | [templates/](templates/) |

## Ground rules

- **The developer decides; you propose.** One step at a time, validated before the next. A design choice
  is shown as an image or a page, not described.
- **Never degrade an asset to make it fit.** If a photo or illustration is the wrong size or crop, ask the
  developer for the right one and say which size you need. Do not re-crop or upscale.
- **Do not reopen a validated step.** Swap content inside the current step; a finished capture or layout
  stays finished unless the developer asks.
- **Look before you lay out.** Open one raw capture of a new device as an image before designing for it:
  pixel dimensions lie (the unfolded iPhone Duo stores a landscape screen in a portrait-sized file).
- **The developer runs the tests.** You write the UI test and the script, build them
  (`build-for-testing`), and hand over the exact command. You may run `simctl` and the export scripts.
- **Keep everything local.** The visuals contain the developer's photos and friends' faces: no upload,
  no published page, unless they ask.
- **Keep notes as you go** (`AppStore/skill-notes.md` or similar): every surprise there is a fix for
  this skill.

## Workflow

1. **Platforms.** Check where the app ships (`TARGETED_DEVICE_FAMILY`, Mac Catalyst, App Store Connect).
   iPad support makes the iPad 13" set mandatory. List the sizes from [specs.md](references/specs.md).
2. **Raw screens.** A UI test walks every screen worth showing and attaches screenshots; a script runs it
   per language, device and appearance and exports the PNGs. Demo data comes from a DEBUG seed, never
   typed through the UI. Start with one language on one iPhone. See [raw-capture.md](references/raw-capture.md).
3. **Pick the screens** with the developer: 5 to 7 that tell the app's story in order (the problem, the
   gesture, the result, the reminder, the reward). Note candidates for later.
4. **Three directions**, in the main language, on one HTML page: same screens, different tone and layout.
   Reuse the app's own colours, mascot and illustrations (convert them from the asset catalog). Give a
   recommendation and why.
5. **Iterate** on the chosen one, one change per round, re-rendered each time. Expect many small rounds on
   titles; keep forced line breaks in the copy itself.
6. **Localise** the titles and any speech bubbles: similar lengths across languages, the app's register
   (tu/du/tú), gender-neutral wording, each language's typography. Flag culture-specific choices. A
   language without its own app translation borrows another language's captures. See
   [composition.md](references/composition.md).
7. **Export** each device to exact-size PNGs without alpha (WebKit snapshot, Swift script). Check the
   size App Store Connect actually offers before declaring it done.
8. **Other devices.** iPad 13", then iPhone Duo if the app supports it: new raw captures, then a layout
   per device on the same page (a device switch), not a stretched copy of the iPhone one.
9. **Header video** (optional): an animated scene from the app's artwork, rendered frame by frame into a
   seamless loop. Ask before making a search results asset: it replaces the screenshots in search. See
   [header-video.md](references/header-video.md).
10. **Document** the commands in the project README (raw capture, slides, export, header).

## Before saying "done"

- Open the exported files, at least one per device and language family; check the right edge (a white
  scrollbar strip), the bubbles and titles (overflow, a colon alone on a line), and the device frame.
- `sips -g pixelWidth -g pixelHeight -g hasAlpha` on every set: exact size, `hasAlpha: no`.
- Say what was checked visually and what was not.
