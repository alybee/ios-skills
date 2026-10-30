# App Store Connect specs, as met in practice (October 2026)

Sources — re-check them, the slots change with each hardware generation:
- Screenshots: <https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications>
- Header and search results: <https://developer.apple.com/help/app-store-connect/reference/app-information/creative-assets-specifications>
- Creative guidance: <https://developer.apple.com/app-store/asset-best-practices/>

## Screenshots

- Up to 10 per device size and language. PNG or JPEG, **no alpha channel**, exact pixel size.
- A language without its own set falls back to another one; a device size without its own set is scaled
  down from a larger one.

| Slot | Sizes (portrait) | Notes |
|---|---|---|
| iPhone 6.9" | 1320×2868, 1290×2796, 1260×2736 | Long the main slot; **not offered** in App Store Connect in Oct 2026 |
| iPhone 6.3" / 6.1" ("iPhone with Dynamic Island, medium display") | 1206×2622, 1179×2556 | The **required** iPhone slot in Oct 2026 |
| iPad 13" | 2064×2752, 2048×2732 | Required if the app runs on iPad |
| iPhone Duo outer display | 1398×2034 (or 2034×1398) | |
| iPhone Duo inner display | 2007×2853 (or **2853×2007**) | The app runs in landscape when unfolded |

- **The 6.9" export does not fit the 6.3" slot.** The ratios are the same (0.4603 vs 0.4600), so scale it:
  `sips -z 2622 1206 in.png --out out.png` — no visible distortion. Keep both sets.
- **iPhone Duo**: the spec page lists both displays without saying one or both; App Store Connect offers
  either. Optional today, **required from April 2027** for apps built with the iOS 27.1 SDK or later.
  Providing it adds an "optimized for iPhone Duo" badge. Prefer the inner display: it shows what is
  specific to the device (columns on each side of the fold, two-pane details).
- Mac: an iPad app is offered on Apple silicon Macs ("Designed for iPad") without extra screenshots.

## Product page header

| Kind | Ratio | Size | Other |
|---|---|---|---|
| Image | 21:9 | 3840×1646 | PNG/JPEG, no alpha (also 16:9 5244×2950, PNG only) |
| Video | 21:9 | 3840×1646 | 30 or 60 fps, 5–30 s, .mov/.m4v/.mp4 |

Videos loop, autoplay muted (people can unmute on the product page). The poster frame is **picked in App
Store Connect from the uploaded video**: no separate still is needed.

## Search results asset

3:2, 1920×1280 to 3840×2560 (also 16:9 5244×2950, PNG only), image or video with the same video rules,
always muted. **It replaces the up-to-three screenshots shown in search.** Make one only if it explains
the app better than the screenshots do; ask first.

## Content rules (both)

No prices, discounts, URLs, ©, unverifiable claims, other platforms' logos or Apple awards. 4+ age
rating. Localise any text. Keep the key art in the safe area (see header-video.md).
