<div align="center">

# A Way Out

**Block distracting apps behind a physical NFC tag you already own — no proprietary hardware, no subscription.**

![Swift](https://img.shields.io/badge/Swift-5.0-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2017%2B-0071E3?logo=swift&logoColor=white)
![Core NFC](https://img.shields.io/badge/Core%20NFC-Tag%20Reader-1D1D1F?logo=apple&logoColor=white)
![Screen Time](https://img.shields.io/badge/Screen%20Time-FamilyControls-34C759?logo=apple&logoColor=white)
![Version](https://img.shields.io/badge/Version-1.0.0-blue)
![License](https://img.shields.io/badge/License-MIT-green)

</div>

---

## What is A Way Out?

A Way Out is an iOS app that puts your distracting apps behind a **physical key**. You pick the apps you want blocked, tap a real NFC tag against your phone, and they're gone — shielded by iOS itself. To get them back, you have to find that tag and tap it again.

That's the whole idea. Unblocking is not a button you can press in bed; it's an object you have to walk to. The friction is the feature. Leave the tag in a drawer, on your desk at work, or taped inside a cupboard, and your phone stops being a one-swipe escape hatch.

It's conceptually similar to [Brick](https://getbrick.com), with one difference that matters: **it works with any blank NFC tag**. No proprietary device to buy, no factory pairing, no waiting for shipping. A ¢50 NTAG sticker, a hotel key card, a transit card, a cheap keychain fob — if iOS can read its UID, A Way Out can use it.

| Brick | A Way Out |
|---|---|
| Requires purchasing a proprietary NFC device | Works with any blank NFC tag you already own |
| Tag is pre-paired at the factory | You pair your own tag in seconds |
| One device, one Brick | You choose which tag is the key |
| No tag reassignment | Reassign to a new tag at any time |

Nothing is written to your tag, and nothing leaves your phone. A Way Out reads the tag's hardware UID and stores it locally — so a tag you use for something else keeps working exactly as before.

---

## How it works

**1. Register a tag.** Tap **Assign Tag**, hold any NFC tag to the top of your iPhone. Its UID is saved locally on the device.

**2. Build a group.** Create named groups — *Social*, *Games*, *Doomscroll* — and pick the apps and categories in each one using the system app picker.

**3. Tap to block, tap to unblock.** Select the groups, hit **Block**, and tap your tag. iOS shields those apps immediately. The only way back is the same tag.

---

## Highlights

**Any tag, any format.** Reads ISO 14443 and ISO 15693 — MIFARE, ISO 7816, FeliCa, NFC-V. Reading the UID means the tag stays blank and reusable for whatever else you use it for.

**Grouped blocking.** Block your gaming apps for the week while leaving social media alone, or shield everything at once. Each group is toggled independently.

**Real iOS-level shielding.** Built on Apple's Screen Time framework (`FamilyControls` + `ManagedSettings`), so blocked apps are shielded by the system — not by a VPN profile, a DNS trick, or a focus mode you can dismiss.

**The right tag or nothing.** Scanning a different tag fails with a clear message. The key is the key.

**Nothing to sign up for.** No account, no server, no analytics, no network calls. Your tag UID and app groups live in `UserDefaults` on your device and nowhere else.

**Reassignable.** Lost the tag? Register a new one at any time from the tag screen.

---

## What's new

### v1.0.0 — first public release

- Register any blank NFC tag as your physical key (ISO 14443 / ISO 15693).
- Create, edit, and delete named app groups with the system app & category picker.
- Block and unblock groups independently with an NFC tap.
- System-level app shielding via Screen Time (`FamilyControls` + `ManagedSettings`).
- Wrong-tag detection with clear, non-cryptic error messages.
- Reassign your key tag at any time.
- Fully offline — no account, no backend, no tracking.
- Supports iPhone and iPad, light and dark mode, iOS 17 and later.

---

## Requirements

| | |
|---|---|
| Device | iPhone 7 or newer (Core NFC tag reading) |
| OS | iOS 17.0+ |
| Build | Xcode 15+, Swift 5.0 |
| Entitlements | `com.apple.developer.nfc.readersession.formats` (`TAG`, `PACE`), `com.apple.developer.family-controls` |
| Tag | Any NFC tag readable by iOS — nothing is written to it |

> **Note:** the Family Controls entitlement requires [approval from Apple](https://developer.apple.com/contact/request/family-controls-distribution) for App Store distribution. Development builds work with the standard capability enabled in Xcode.

---

## Build from source

```sh
git clone git@github.com:siarkonyar/a-way-out.git
cd a-way-out
open "A Way Out.xcodeproj"
```

Set your own development team and bundle identifier in **Signing & Capabilities**, then build to a physical device. NFC and Screen Time shielding do not work in the Simulator — you need real hardware and a real tag.

---

## Project structure

| File | Responsibility |
|---|---|
| `A Way Out/AppState.swift` | Single source of truth — persists the tag UID, app groups, and blocked state; applies `ManagedSettingsStore` shields |
| `A Way Out/NFCManager.swift` | `NFCTagReaderSession` wrapper; extracts the UID across MIFARE / ISO 7816 / ISO 15693 / FeliCa |
| `A Way Out/AppGroup.swift` | The group model — name plus a `FamilyActivitySelection` |
| `A Way Out/ContentView.swift` | Home screen — blocked-group overview and quick unblock tap |
| `A Way Out/AppGroupsView.swift` | Group list, multi-select, and the NFC-gated block/unblock action |
| `A Way Out/AppGroupCreationView.swift` | Create and edit groups with the system app picker |
| `A Way Out/TagAssignmentView.swift` | Register or reassign the key tag |

---

## Tech stack

| Layer | Technology |
|---|---|
| UI | SwiftUI (`NavigationStack`, materials, `@StateObject`) |
| NFC | [Core NFC](https://developer.apple.com/documentation/corenfc) — `NFCTagReaderSession`, ISO 14443 + ISO 15693 polling |
| Blocking | [FamilyControls](https://developer.apple.com/documentation/familycontrols) + [ManagedSettings](https://developer.apple.com/documentation/managedsettings) (Screen Time API) |
| State | `ObservableObject` + Combine, persisted to `UserDefaults` via `Codable` |
| Platform | iOS 17+, iPhone and iPad |

---

## Contributing

**Contributions are open to everyone.** No CLA, no gatekeeping, no "core team only" rule — if you want to make A Way Out better, the door is open.

Good places to start:

- **Report a bug or a tag that won't read.** Open an [issue](https://github.com/siarkonyar/a-way-out/issues) with your device model, iOS version, and the tag type if you know it. Tag-compatibility reports are genuinely useful.
- **Suggest a feature.** Scheduled blocking, shortcut integration, multiple key tags, widgets — say what you'd use and why.
- **Send a pull request.** Fork, branch, and open a PR against `main`.

A few things that make a PR easy to merge:

1. Keep it focused — one change per PR beats a grab bag.
2. Match the existing style: SwiftUI-first, small files, no force unwraps in new code, no third-party dependencies unless there's a real reason.
3. Say how you tested it. Since NFC and Screen Time can't run in the Simulator, note the device and iOS version you verified on.
4. Conventional commit messages (`feat:`, `fix:`, `refactor:`, `docs:`) keep the history readable.

Not sure whether an idea fits? Open an issue first and ask — that's cheaper than building the wrong thing.

---

## License

**MIT** — Copyright (c) 2026 Zafer Şiar Konyar. See [LICENSE](LICENSE).

Do whatever you want with it: use it, fork it, modify it, ship it, sell it. Keep the copyright notice and you're good. The license is deliberately permissive so anyone can contribute, adapt, or build on this without asking permission.

---

<div align="center">

Made by [Hercule](https://herculewebsite.pages.dev)

</div>
