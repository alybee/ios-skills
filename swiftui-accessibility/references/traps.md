# Traps

Each one cost at least one wrong fix on a shipping SwiftUI app (iOS 18 to 27).

## VoiceOver tree

- **Hiding a decorative image: two forms work, their combination does not.** `Image(name)` +
  `.accessibilityHidden(true)` works; `Image(decorative:)` alone works; `Image(decorative:)` +
  `.accessibilityHidden(true)` recreates the element it hides.
- **An image in a `.background` may stay in the tree**, whatever its declaration. In one case only a
  `Canvas` removed it — but a `Canvas` clips at its bounds. In another, the same construct did not
  surface. Check by ear.
- **An accessibility modifier on a container is never neutral**, `accessibilityHidden(false)` included.
  Do not add one "to be safe".
- **A `.contain` container is not a swipe stop.** Its label is only heard by touch exploration, so it
  never carries necessary information; its value is the Containers rotor.
- **A nested `.combine` reads everything twice.**
- **A paged `TabView` keeps its neighbours reachable.** Hide every page but the current one.
- **Text read from artwork** ("wanted", a word painted in an illustration) comes from VoiceOver's image
  analysis, a user setting, not from the code. Nothing to fix.

## Controls

- **A `Picker` with numeric tags announces the number.** The label goes on each option's `Text`, which
  also covers the open menu.
- **A `.frame(minHeight: 44)` placed after a `Button` enlarges the space around it, not the button.** The
  hit area and the audited frame stay the size of the text. Put the frame and `.contentShape` inside the
  label.

## Speech

- **Speech synthesis follows grammar the code does not know.** French reads a digit before a masculine
  noun as "une" ("1 prêt" → "une prêt"): spell the number out in the spoken label. Check counts and
  plurals by ear in every shipped language.

## Environment and previews

- **A modifier applied inside a view never reaches what that view has already resolved.** Its own
  `@Environment` and `@ScaledMetric` were handed down by its parent before its `body` ran, and a value
  frozen into an `AttributedString` upstream is further out of reach. The fix belongs **above** the
  reader: at the call site, or in a value the parent computes. Typical failure: a type-size cap that
  misses the view's own scaled metric; a colour scheme pinned on a view that changes only its children.
- **`preferredColorScheme(.dark)` in a preview proves nothing about a custom palette.** It flips the
  system chrome (status bar, keyboard, alerts); colours read from a custom environment theme stay in
  daylight unless the preview injects the dark theme itself.

## Lint

- **A custom "image without accessibility" lint rule only reads the image's own modifier chain.** A label
  on the enclosing `Button`, or a container set to `.accessibilityElement(children: .ignore)`, is
  invisible to it. Do not add a modifier to the image to silence it (see above): mark the line, reason
  included, on the line just above — `// swiftlint:disable:next <rule> - the Button carries the label`.
  SwiftLint ignores whatever follows ` - `; a reason on its own line would break `disable:next`.
