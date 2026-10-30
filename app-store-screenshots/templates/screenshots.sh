#!/bin/bash
#
# Raw App Store screens: runs ScreenshotUITests on one simulator, in one language and one appearance, and
# exports its attachments as PNGs into AppStore/screenshots/raw/<language>/<device>/<appearance>/.
#
#   Scripts/screenshots.sh fr iphone light
#
# The status bar and the appearance are set here: a UI test can change neither. The simulator keeps both
# afterwards — `xcrun simctl status_bar <id> clear` undoes the first.
#
# Template: fill in the CONFIG block. `xcrun simctl list devices available` gives the simulator ids.

set -euo pipefail

# --- CONFIG -------------------------------------------------------------------------------------------
project="App/App.xcodeproj"           # relative to the repo root
scheme="App"
test_class="AppUITests/ScreenshotUITests"
derived_data=~/Library/Developer/Xcode/DerivedData/App-cli # kept outside the repo, never Xcode's own
iphone_simulator=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX        # e.g. the largest iPhone, latest iOS
ipad_simulator=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX          # iPad Pro 13-inch
duo_simulator=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX           # iPhone Duo (iOS 27.1+), or leave unused
locale_for() {                        # language → locale passed to the app
    case $1 in
        fr) echo fr_FR ;;
        en) echo en_US ;;
        es) echo es_ES ;;
        *) return 1 ;;
    esac
}
# ------------------------------------------------------------------------------------------------------

if [ $# -lt 3 ] || [ $# -gt 4 ]; then
    echo "usage: $0 <language> <iphone|ipad|duo> <light|dark> [test, e.g. testBoard]" >&2
    exit 1
fi

language=$1
device=$2
appearance=$3
# One test only replaces its own screens and keeps the others, hand-made ones included.
test=${4:-}

locale=$(locale_for "$language") || { echo "error: unknown language '$language'" >&2; exit 1; }

# By id: several simulators share each name, one per iOS runtime.
case $device in
    iphone) simulator=$iphone_simulator ;;
    ipad) simulator=$ipad_simulator ;;
    duo) simulator=$duo_simulator ;;
    *) echo "error: unknown device '$device'" >&2; exit 1 ;;
esac

case $appearance in
    light | dark) ;;
    *) echo "error: unknown appearance '$appearance'" >&2; exit 1 ;;
esac

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

root="$(cd "$(dirname "$0")/.." && pwd)"
output="$root/AppStore/screenshots/raw/$language/$device/$appearance"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
# Kept after the run, outside the repo: open it in Xcode to replay a failure.
result="$derived_data/screenshots-last-run.xcresult"
rm -rf "$result"

# Only Device Hub unfolds the Duo, by hand: the first run boots it and stops, the second one captures.
# Not grep -q: it exits on the first match, simctl dies of SIGPIPE, and pipefail reads that as "not booted".
if [ "$device" = duo ] && ! xcrun simctl list devices | grep "$simulator) (Booted)" >/dev/null; then
    xcrun simctl boot "$simulator"
    open "$DEVELOPER_DIR/../Applications/DeviceHub.app"
    echo "iPhone Duo started in Device Hub (the one marked as running). Unfold it, then run this command again."
    exit 0
fi

xcrun simctl boot "$simulator" 2>/dev/null || true
xcrun simctl bootstatus "$simulator" >/dev/null
xcrun simctl ui "$simulator" appearance "$appearance"
xcrun simctl status_bar "$simulator" override \
    --time "9:41" \
    --dataNetwork wifi --wifiMode active --wifiBars 3 \
    --cellularMode active --cellularBars 4 \
    --batteryState discharging --batteryLevel 100

echo "Running $test_class ($language, $device, $appearance)…"
# TEST_RUNNER_-prefixed variables reach the test process without the prefix. Not in parallel: that runs on
# clones of the simulator, which boot folded and ignore the appearance and status bar set above.
TEST_RUNNER_SCREENSHOT_LANGUAGE=$language \
TEST_RUNNER_SCREENSHOT_LOCALE=$locale \
    "$DEVELOPER_DIR/usr/bin/xcodebuild" test \
    -project "$root/$project" -scheme "$scheme" \
    -derivedDataPath "$derived_data" \
    -destination "platform=iOS Simulator,id=$simulator" \
    -only-testing:"$test_class${test:+/$test}" \
    -parallel-testing-enabled NO \
    -resultBundlePath "$result" 2>&1 \
    | grep -iE "test case .* (passed|failed)|TEST SUCCEEDED|TEST FAILED" || true

# xcodebuild's own output drops the assertion messages; the result bundle has them.
xcrun xcresulttool get test-results summary --path "$result" |
    jq -r '.testFailures[]? | "✘ \(.testName): \(.failureText)"'

xcrun xcresulttool export attachments --path "$result" --output-path "$work/attachments" >/dev/null

[ -z "$test" ] && rm -rf "$output"
mkdir -p "$output"

# Only the test's own "NN-name" screenshots: a failure adds its recording, spindump and event logs.
# Xcode suffixes each name with "_<n>_<UUID>"; the test's names use no underscore, so everything before the
# first one is the name given there.
jq -r '.[].attachments[]
    | select(.suggestedHumanReadableName | test("^[0-9]{2}-"))
    | "\(.exportedFileName)\t\(.suggestedHumanReadableName)"' \
    "$work/attachments/manifest.json" |
    while IFS=$'\t' read -r file name; do
        cp "$work/attachments/$file" "$output/${name%%_*}.png"
    done

count=$(find "$output" -name "*.png" | wc -l | tr -d ' ')
expected=$(grep -c 'snapshot("' "$root/$(dirname "$project")/${test_class%%/*}/${test_class##*/}.swift" 2>/dev/null || echo "?")
size=$(sips -g pixelWidth -g pixelHeight "$(find "$output" -name "*.png" | sort | head -1)" |
    awk '/pixel/ { print $2 }' | paste -sd x -)
echo "$count/$expected screenshots, $size px → $output"

if [ "$device" = duo ] && [ "$size" != 2006x2852 ]; then
    echo "warning: expected the inner display (2006x2852); unfold the Duo in Device Hub and run again" >&2
fi
