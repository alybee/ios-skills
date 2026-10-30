# Slides: composition, copy, export

Templates: `templates/slides.html`, `templates/export.swift`.

## The page

One local HTML page shows every slide of every language, with a device switch. Each slide is a box at
the export's size in CSS px, shown with `zoom` in the preview and at `zoom: 1` in export mode:

| Device | CSS px | Scale | PNG |
|---|---|---|---|
| iPhone 6.9" | 440×956 | 3× | 1320×2868 (scale to 1206×2622 for the 6.3" slot) |
| iPad 13" | 1032×1376 | 2× | 2064×2752 |
| iPhone Duo inner, landscape | 951×669 | 3× | 2853×2007 |

- Copy the app's theme colours into CSS tokens; reuse its mascot and illustrations, converted from the
  asset catalog with `sips -s format png -Z 1400 in.pdf --out out.png` (larger for big formats).
- Fonts: a simple, friendly, readable family (e.g. Fredoka). Themed display fonts read badly at store size.
- Each device gets its own layout, not a scaled iPhone: the iPad frame has even bezels and smaller corner
  radii; a device frame may run off the bottom edge when the app's large-screen UI looks too small at full
  height (accept the crop, check what it hides).
- Wide slides break titles mid-phrase: narrow the title box rather than adding device-specific breaks.
- Ideas that worked: a gradient in the app's colours, the device straight (tilts were rejected), a
  mascot in the corner with a comic speech bubble (white, coloured border, tail drawn with `::before` and
  `::after`), mirrored on alternate slides so two mascots face each other across the gallery and talk.
- A decoration straddling two slides is drawn twice, once per slide, with offsets that add up to the
  slide width: each slide clips on its own.
- Image paths: captures live outside the marketing folder; a language without its own captures names the
  one it borrows (`screens: "en"`), with a fallback in `onerror`.

## Copy and localisation

- Titles: one idea each, the story in order. Forced breaks (`\n`) belong in the copy, per language.
- Same register as the app (tu/du/tú). **Gender-neutral** wording: avoid adjectives agreeing with the
  reader ("Tanné", "Stufo", "Gesetzloser") unless the developer prefers the idiom.
- Similar lengths across languages; French and German run long. A shorter idiom beats a literal
  translation ("Schon wieder was verloren?" for "Tired of losing your stuff?").
- Typography: French uses a non-breaking space before `! ? : ;`; Quebec French has **no** space before
  `! ?` and keeps one before `:`. Use non-breaking hyphens in compounds that must not split
  (`hors‑la‑loi`). A colon must never start a line.
- Regional variants are separate copies (fr-CA next to fr), reviewed by a native speaker; flag colloquial
  choices.

## Export to PNG

A Swift script loads the page in a `WKWebView` (WebKit ships with macOS: no Chrome, no npm) and, for each
language and slide, calls a JS `render(languages, slide, device)` then `takeSnapshot` with
`snapshotWidth` = the pixel width. It redraws the snapshot into an opaque `CGContext`
(`CGImageAlphaInfo.noneSkipLast`) at the exact size, so the PNG has no alpha.

- Drive the page through `evaluateJavaScript`: `loadFileURL` refuses a query string.
- `loadFileURL(_:allowingReadAccessTo:)` must cover the captures folder, or they render as broken images.
- **Hide scrollbars in export mode** (`overflow: hidden` and `::-webkit-scrollbar { display: none }`):
  with a mouse plugged in, macOS draws a legacy scrollbar — a white strip down the right of every PNG.
- Wait for the web font before the first snapshot (no load event for it; a few seconds) and ~1 s after
  each re-render for images to decode.
- An optional slide number re-exports one slide after a capture changes.
- Export-mode CSS must out-rank the device classes (`.slide.ipad { zoom }` beats `body.export .slide`).
