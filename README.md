# iOS skills

Skills for iOS development with SwiftUI, by [Alybee](https://alybee.fr). Each one comes out of real
work on shipping apps rather than from documentation alone: the rules are problems that actually
happened, with the fix that worked.

| Skill | What it does |
|---|---|
| [swiftui-adaptive-layout](swiftui-adaptive-layout/) | Audits and fixes the visual layout of SwiftUI apps on the foldable **iPhone Duo** (both displays, every pose), on iPad and in resizable windows. |
| [swiftui-accessibility](swiftui-accessibility/) | Audits and fixes the **accessibility** of a SwiftUI screen — VoiceOver, Voice Control, Dynamic Type, touch targets, contrast, motion — with the SwiftUI traps that make a fix go wrong. |
| [app-store-screenshots](app-store-screenshots/) | Produces the **App Store visuals** end to end: scripted raw screenshots, localised marketing slides, iPad and iPhone Duo variants, an animated product page header — at App Store Connect's exact sizes. |

## Install

Clone the repository and copy the skills you want into your skills directory:

```bash
git clone https://github.com/alybee/ios-skills /tmp/ios-skills
cp -R /tmp/ios-skills/swiftui-adaptive-layout /tmp/ios-skills/swiftui-accessibility \
  /tmp/ios-skills/app-store-screenshots ~/.claude/skills/
```

Use `~/.claude/skills/` for every project, or `.claude/skills/` at a project's root for that project
only. The agent picks a skill up from its description; you can also ask for it by name.

They work well alongside Apple's own skills (Xcode 27.1 or later), which cover the APIs:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcrun agent skills export --output-dir ~/.claude/skills
```

## Requirements

- Xcode 27.1 or later (the iPhone Duo simulator and SDK).
- SwiftUI apps. Some parts apply to UIKit, but nothing is tested there.
- Written and tested with Claude Code; the skills are plain Markdown and scripts, usable by any agent
  that reads skills.

## Contributing

Corrections are welcome, especially from anyone with a physical iPhone Duo or a different App Store
Connect setup: open an issue or a pull request, with what you saw and on which Xcode version.

## License

MIT — see [LICENSE](LICENSE).
