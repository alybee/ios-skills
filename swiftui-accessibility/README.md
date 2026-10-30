# swiftui-accessibility

An agent skill that audits and fixes the accessibility of a SwiftUI screen: VoiceOver and Voice Control,
Dynamic Type up to accessibility sizes, touch targets, WCAG contrast, Reduce Motion, Reduce Transparency
and Increase Contrast.

The checklist is the easy part. The skill exists for the places where SwiftUI's accessibility tree does
not behave the way the code reads — each one a wrong fix that already happened on a shipping app:

- `Image(decorative:)` plus `.accessibilityHidden(true)` recreating the element it was meant to hide;
- an accessibility modifier added to a container "to be safe", changing what VoiceOver reads;
- a nested `.combine` reading everything twice, a paged `TabView` leaving its neighbours reachable;
- a `.frame(minHeight: 44)` after a `Button` enlarging the space around it, not the hit area;
- a type-size cap applied inside a view, missing the metric that view had already resolved;
- dark previews showing the day palette, and a tree dump looking clean while VoiceOver still read it wrong.

## What's inside

```
swiftui-accessibility/
├── SKILL.md                 # ground rules, 5-step audit, severity levels, final checks
└── references/
    ├── checklist.md         # VoiceOver, Dynamic Type, touch targets, contrast, motion
    ├── traps.md             # SwiftUI behaviours that cost a wrong fix, with the fix that worked
    └── checking.md          # by ear, Accessibility Inspector and its false positive, UI-test audit, simctl
```

## Use

> Audit the accessibility of the settings screen.

> VoiceOver reads the card title twice.

> The layout breaks at the largest text sizes.

> Can we declare Larger Text in the Accessibility Nutrition Labels?

The skill reads the code against the checklist, checks it running in the simulator when it can, and
reports issues most severe first with an overall level (Blocking / Needs work / Good). It fixes one
issue at a time, on request. VoiceOver on a device stays the developer's job: the skill says what to
listen for. A project's own accessibility notes, if any, take precedence.

## Status and limits

- SwiftUI only, iOS 18 to 27. Some rules apply to UIKit; nothing is tested there.
- Layout on iPhone Duo, iPad and resizable windows is covered by
  [swiftui-adaptive-layout](../swiftui-adaptive-layout/).

## License

MIT — see [LICENSE](../LICENSE).
