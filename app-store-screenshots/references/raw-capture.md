# Raw screens from a UI test

Never capture by hand: a script re-shoots everything when a seed, a screen or a translation changes, and
it will — several times. Templates: `templates/ScreenshotUITests.swift`, `templates/screenshots.sh`.

## The test

- One `XCTestCase` (e.g. `ScreenshotUITests`), **one test per launch state**: onboarding, main board, add
  flow, empty state… Each test launches the app with its own arguments and attaches screenshots named
  `NN-name` (two digits, a dash, no underscore — Xcode appends `_<n>_<UUID>` to names).
- Attach with `XCTAttachment(screenshot:)` and **`lifetime = .keepAlways`**, or Xcode drops the
  attachments of passing tests.
- Wait for an element (`isHittable`), then pause ~1 s before the capture: a hittable element can still be
  mid-animation, and no state says when a screen has settled.
- **Language and locale**: `TEST_RUNNER_SCREENSHOT_LANGUAGE=fr xcodebuild test …` reaches the test as
  `SCREENSHOT_LANGUAGE`; the test passes `-AppleLanguages (fr) -AppleLocale fr_FR` to the app.
- Element identifiers are mirrored in the test (a UI test cannot import the app target). Several cells
  sharing one identifier are picked by position, `matching(identifier:).element(boundBy:)`.
- Keep the marketing content the test types (a name, an object) in one `Content` enum next to the seed.

## DEBUG launch flags in the app

Everything the simulator cannot do, or that would make the run flaky, becomes a DEBUG-only launch
argument read from `UserDefaults` (a `-key value` argument lands in its argument domain):

| Need | Flag idea |
|---|---|
| Demo data, in memory, never synced | `-seedPreviewLoans YES` → an in-memory store with seeded rows and the profile name |
| Empty state | a flag that swaps in an empty in-memory store |
| Permission state without a system alert | `-cameraPermission granted\|notDetermined` |
| A camera in the simulator | `-cameraSession running` → the capture screen shows a staged photo (aspect-fill, like the video layer) |
| A feature the simulator lacks (on-device speech…) | `-dictationState idle` |
| A self-dismissing overlay | `-holdCelebration YES` → skip its timer |

- **Seed the state instead of typing it**: a profile name typed through a sheet cost several flaky runs;
  inserted by the seed it costs nothing. Drive the UI only for the screens you capture.
- **The argument domain outranks what the app writes**: `-hasCompletedOnboarding NO` keeps onboarding on
  screen even after "finish". Do not chain onboarding into the main screens; split the tests.
- **Permission states change screens**: "granted" may swap a pitch for its "already allowed" state with no
  skip button. Use the state each screen needs.
- **Timers**: an overlay that closes itself after ~1.4 s is missed on a slower device (iPad). Hold it with
  a flag rather than shortening the pause.
- A PDF photo asset needs *Preserve Vector Data*, or Xcode rasterises it at its page size and it blurs.
- Seed photos must match the story: if names or objects cannot match the photos, show neither.

## The script

- Arguments: language, device, appearance, and optionally **one test name** — re-running one test must
  only replace its own PNGs, so hand-made replacements survive.
- Target simulators **by id**: several share each name, one per runtime.
- A UI test cannot set the appearance or the status bar: `simctl ui <id> appearance light|dark` and
  `simctl status_bar <id> override --time 9:41 --dataNetwork wifi --wifiMode active --wifiBars 3
  --cellularMode active --cellularBars 4 --batteryState discharging --batteryLevel 100`
  (`charged` draws a charging bolt).
- **`-parallel-testing-enabled NO`**: parallel testing runs on *clones* of the simulator, which ignore the
  appearance and status bar you set (and boot the iPhone Duo folded).
- Keep the `.xcresult` outside the repo; print failures with
  `xcrun xcresulttool get test-results summary --path R | jq -r '.testFailures[]?'` — `xcodebuild`'s own
  output drops the assertion messages.
- Export: `xcrun xcresulttool export attachments --path R --output-path D` writes the files and a
  `manifest.json` (`exportedFileName`, `suggestedHumanReadableName`). **Filter by the `NN-` prefix**: a
  failure adds a recording, a spindump and event logs. Strip the suffix with `${name%%_*}`.
- Print `count/expected` (expected = `grep -c 'snapshot("'` in the test) and the pixel size.
- Shell traps: under `set -o pipefail`, `cmd | grep -q x` can fail although x matched (grep exits early,
  cmd dies of SIGPIPE) — use `grep x >/dev/null`. `xcodebuild` prints harmless
  `[MT] IDESchemeActionSDKRecord` lines on stderr: merge stderr before filtering.

## iPhone Duo

- No `simctl` command folds or unfolds it; only **Device Hub** does
  (`Xcode.app/Contents/Applications/DeviceHub.app`, or Xcode › Open Developer Tool). Make the script boot
  the right simulator, open Device Hub and stop on the first run; the developer unfolds it and runs again.
- **`XCUIScreen.main` is the outer display**, black while unfolded. Capture every `XCUIScreen.screens`
  and keep the one whose image size matches the app window (fallback: the largest).
- Unfolded, the app runs in **landscape**. The PNG is written 2006×2852 with an EXIF rotation: `sips`
  reports portrait, viewers and WebKit show landscape. Lay it out as landscape.
- The simulator captures 2006×2852, one pixel short of 2007×2853; the slide export renders the exact
  size anyway.
- `simctl io <id> screenshot` can hang on the Duo; do not rely on it to check the pose — ask.
