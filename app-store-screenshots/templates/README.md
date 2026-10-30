# Templates

Copied from a working project and stripped of its content. Every app-specific value is marked
`CONFIG`; the rest is the tested mechanics. Suggested layout in the app's repo:

```
Scripts/screenshots.sh                  # raw captures (run by the developer)
<UITests target>/ScreenshotUITests.swift
AppStore/screenshots/raw/<language>/<device>/<appearance>/NN-name.png
AppStore/marketing/slides.html          # slides, every language and device
AppStore/marketing/export.swift         # slides → PNG
AppStore/marketing/header.html          # animated header (and search results)
AppStore/marketing/header-export.swift  # header → .mov
AppStore/marketing/assets/              # illustrations converted from the asset catalog
AppStore/marketing/export/              # what goes to App Store Connect
```

| File | Fill in | Run |
|---|---|---|
| `screenshots.sh` | project, scheme, test class, DerivedData, simulator ids, locales | `Scripts/screenshots.sh <lang> <iphone\|ipad\|duo> <light\|dark> [test]` |
| `ScreenshotUITests.swift` | identifiers, launch flags (the app's DEBUG arguments), tests per launch state | through the script |
| `slides.html` | theme tokens, `COPY`, `SCREENS`, `assets/mascot.png`, layout per device | open in a browser |
| `export.swift` | `languages`, `slideCount` | `xcrun swift export.swift <iphone\|ipad\|duo> [slide]` |
| `header.html` | scene artwork (`assets/scene.png`, `assets/scene-edge.png`), its width and ground line, clouds, `TAGLINES` | open in a browser; `#header`, `#search-<lang>` |
| `header-export.swift` | nothing | `xcrun swift header-export.swift header <still\|video>` |

Notes:
- `screenshots.sh` expects to live one folder below the repo root (`Scripts/`).
- The app side is not templated: add the DEBUG launch flags the test passes (demo seed in memory,
  permission states, staged camera frame, held timers) — see `references/raw-capture.md`.
- The 6.3" iPhone set is the 6.9" export scaled: `sips -z 2622 1206 in.png --out out.png`.
- The layouts in `slides.html` and the geometry in `header.html` are one app's: expect to redesign them
  with the developer, not to ship them as is.
