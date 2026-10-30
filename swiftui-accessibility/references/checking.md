# How to check

## VoiceOver on a device

The ear is the instrument. A dump of the accessibility tree taken with VoiceOver off showed screens clean
that VoiceOver still announced wrongly. Ask the developer to swipe through each screen and listen for:
order, anything read twice, anything decorative announced, values and counts in each language, focus on
arrival, nothing reachable behind an overlay.

## Accessibility Inspector

- Trustworthy on hit areas and on most contrast pairs.
- **False positive:** "Dynamic Type font sizes are unsupported" on SwiftUI. It reads the font size stored
  in each element's accessibility label, so every combined or relabelled element is flagged while the
  text scales. Judge Dynamic Type on screen.

## The same audit in UI tests

`XCUIApplication().performAccessibilityAudit()` (iOS 17+) runs the Inspector's audit in a UI test, so a
regression fails a test. Visit every screen in one test and audit each.

- Filter a false positive by the **identifier** of the element that owns it, matched by frame: the audit
  reports the text node inside a combined element, which carries no identifier. Never filter by label,
  which changes with the language.
- Write the reason next to each filtered entry.
- Measure a contrast flag on the screenshot before calling it false.

## Simulator settings

No need to open the Settings app:

```bash
xcrun simctl ui <device> content_size accessibility-extra-large   # back with: large
xcrun simctl ui <device> increase_contrast enabled                # back with: disabled
xcrun simctl ui <device> appearance dark                          # back with: light
```

Reduce Motion and Reduce Transparency have no `simctl ui` switch: use Accessibility Inspector's settings
panel, or the Settings app.

## Previews

Previews at `.dynamicTypeSize(.accessibility3)` are a first look, not the check: they do not show the real
screen's width, safe area or scrolling.

## App Store Accessibility Nutrition Labels

`.accessibility3` is a sound bar beyond its own merit: body text there is 40 pt against 17 pt, 235 %,
above the 200 % the *Larger Text* criterion asks before an app may declare it. Declare a feature only
once every common task passes with it.
