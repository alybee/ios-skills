# Checklist

Walk it for each screen. A reasonable v1 bar: VoiceOver complete, Dynamic Type up to `.accessibility3`,
WCAG AA contrast, and Reduce Motion, Reduce Transparency and Increase Contrast respected.

## VoiceOver and Voice Control

- [ ] Every interactive element is announced with a name, and that name is the **visible text**: Voice
      Control drives the app by what the screen shows
- [ ] Interactive elements are `Button`s (or real controls), not `onTapGesture`: a gesture alone has no
      trait and no action
- [ ] State and position go in `accessibilityValue`; `accessibilityHint` says what happens, and only when
      the label leaves it ambiguous
- [ ] Nothing needed to understand the screen lives only in a hint: hints can be switched off
- [ ] Custom controls carry the right `accessibilityTraits` and an adjustable action where it applies
- [ ] Decorative images are out of the swipe order (see *traps.md* for the forms that work)
- [ ] What is read together is one element (`.combine`), never a combine inside a combine
- [ ] Reading order makes sense without seeing the screen
- [ ] Focus lands at the top of the screen on arrival
- [ ] Nothing the user cannot see is reachable: off-screen pages, content behind an overlay
- [ ] Nothing disappears on a timer while VoiceOver is on (`accessibilityVoiceOverEnabled`)
- [ ] Spoken copy is flat and pronounceable: no poster slogans, no stylised brand spellings, numbers in
      the grammatical form the sentence needs
- [ ] Gesture-only interactions (swipe, long press, drag) have an accessible alternative
      (`accessibilityAction`, a visible button)

## Dynamic Type

- [ ] Checked at `accessibility-extra-large` (`.accessibility3`) in the simulator, not only in a preview
- [ ] Text uses system styles (`.body`, `.title2`…) or `Font.custom(_:size:relativeTo:)`, never
      `Font.system(size:)` — a custom lint rule can enforce it
- [ ] Spacing and icon sizes that should grow use `@ScaledMetric`
- [ ] Nothing overlaps, nothing important truncates; content that no longer fits scrolls
- [ ] Rows that no longer fit side by side stack (`AnyLayout`, `ViewThatFits`)
- [ ] Decoration yields to content at accessibility sizes (`dynamicTypeSize.isAccessibilitySize`)
- [ ] Controls that cannot grow further cap their size explicitly (`dynamicTypeSize(...upTo)`), as a
      deliberate exception, not a blanket fix
- [ ] At ordinary sizes, the screen is unchanged

## Touch targets

- [ ] Every control is at least 44 × 44 pt, measured on the **button** itself: the frame and the
      `.contentShape` go inside its label

## Contrast

- [ ] Every text/background pair reaches 4.5:1 — 3:1 only for large text (24 pt regular, 19 pt bold) and
      for icons and control boundaries
- [ ] An `.opacity()` on a colour counts: compute the ratio on the blended colour
- [ ] Checked in light and in dark

## Motion, transparency, colour

- [ ] Animations read `accessibilityReduceMotion` and fall back to a crossfade or to nothing
- [ ] Hand-made translucency (an opacity scrim, a custom blur) reads `accessibilityReduceTransparency`;
      system materials adapt on their own
- [ ] No state is carried by colour alone: add a shape, a label or a stamp
- [ ] Nothing gets harder to read with Increase Contrast on (`colorSchemeContrast`)
