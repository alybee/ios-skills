---
name: swiftui-accessibility
description: "Audit and fix the accessibility of a SwiftUI screen: VoiceOver (labels, values, hints, grouping, focus, reading order), Voice Control, Dynamic Type up to accessibility sizes, touch targets, WCAG contrast, Reduce Motion, Reduce Transparency and Increase Contrast. Use before shipping a screen, when closing a milestone that changed UI, when VoiceOver reads something wrong or twice, when a decorative image is still announced, when a layout breaks at large text sizes, when Accessibility Inspector or performAccessibilityAudit reports issues, or when preparing the App Store Accessibility Nutrition Labels. Not for layout on iPhone Duo, iPad or resizable windows (use swiftui-adaptive-layout)."
---

# SwiftUI accessibility audit

The checklist is the easy part. What costs time is that SwiftUI's accessibility tree does not behave the
way the code reads: a modifier added "to be safe" creates an element, two ways of hiding an image cancel
each other out, a tree dump looks clean while VoiceOver still reads it wrong. Every trap in
[traps.md](references/traps.md) was hit on a shipping app and cost at least one wrong fix.

## Ground rules

- **The ear is the instrument.** A dump of the accessibility tree, taken with VoiceOver off, shows
  screens clean that VoiceOver still announces wrongly. Static reading of the code finds candidates;
  only VoiceOver on a device confirms them. Say which findings were confirmed and which are suspected.
- **One fix at a time, re-checked.** Fix what the audit found, one change, then check that one thing
  again. No preventive sweep of screens that passed: an accessibility modifier is never neutral, and
  sweeps are where regressions come from.
- **Fix above the reader.** A modifier inside a view does not reach what that view already resolved from
  its parent (environment, `@ScaledMetric`). The fix belongs at the call site.
- **Nothing silenced to pass a lint.** If a rule flags an image whose label is carried by its container,
  mark that line with the reason; do not add a modifier to the image.

## Workflow

1. **Scope.** The screen named by the user, or the views just written. Read the project's own
   accessibility notes first if it has some (a `docs/accessibility.md`, a section of `CLAUDE.md`): they
   override this skill where they differ.
2. **Read the code** against [checklist.md](references/checklist.md), section by section: VoiceOver,
   Dynamic Type, touch targets, contrast, motion/transparency/colour. Check every suspicious construct
   against [traps.md](references/traps.md) before proposing a fix.
3. **Check it running** when a simulator is available — see [checking.md](references/checking.md):
   accessibility-extra-large text, dark appearance, Increase Contrast, the Accessibility Inspector audit.
   VoiceOver itself is the developer's job on a device: give them what to listen for.
4. **Report**, most severe first. For each issue: where, what a user experiences, the fix. Then the
   overall level and the single most impactful fix:
   - **Blocking**: a control unreachable or unnamed, content lost at large sizes, text below 3:1.
   - **Needs work**: wrong order, redundant or unpronounceable announcements, missing value, contrast
     between 3:1 and 4.5:1 on body text, motion ignoring Reduce Motion.
   - **Good**: nothing above.
5. **Fix on request**, one issue at a time, and say what to re-check for each.

## Final checks

- [ ] Every finding says whether it was confirmed by ear/on screen or suspected from the code
- [ ] No fix adds a modifier to a container "to be safe"
- [ ] Dynamic Type was judged on screen at `.accessibility3`, not only in a preview
- [ ] Contrast was computed on the blended colour where an opacity is involved, in light and in dark
