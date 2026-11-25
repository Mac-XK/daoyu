# iOS 16 floor: done at 16.2

Part of [Hex for iPhone](../README.md). Written 2026-11-25 against `dev`
(`e08fe94`), Xcode 27.2 / iOS 27.2 SDK, `xcodegen 2.48.0`.

**Status: builds and packages.** `IPHONEOS_DEPLOYMENT_TARGET` is 16.2 for the
app, the keyboard and the widgets. A Release arm64 device build succeeds and
`xcodebuild` writes `HEX.app`; the IPA built from it is
`ios16-ipa/HEXMobile-16.2-unsigned.ipa` (50 MB, unsigned).

Why 16.2 and not 16.0: Live Activities. `ActivityContent`, `Activity.update`
and `ActivityViewContext.isStale` are iOS 16.2, and the app's Live Activity and
the widget extension are built on them. Below 16.2 the widget extension has no
content at all, so a 16.0 or 16.1 floor means dropping `HEXWidgets` and the
Action Button / Control Center Live Activity with it.

## What the port changed

### Availability shims (new files)

| File | Covers |
| --- | --- |
| `HEXShared/MicrophonePermission.swift` | `AVAudioApplication` (iOS 17) over `AVAudioSession`; `MicrophonePermission` + `MicrophoneAccess` |
| `HEXShared/OnChangeCompat.swift` | `onChange(of:_:)` and its `initial:` form (iOS 17) |
| `HEXShared/SpringAnimationCompat.swift` | `UIView.animate(springDuration:bounce:…)` (iOS 17) |
| `HEXShared/ScrollAnchorCompat.swift` | `defaultScrollAnchor` (iOS 17) |
| `HEXShared/SwiftUICompat.swift` | `scrollBounceBehavior` (16.4), `presentationBackground` (16.4), `listSectionSpacing` (17), `scrollClipDisabled` (17) |

### State layer: Observation (iOS 17) → ObservableObject

`@Observable` is iOS 17 with no SwiftUI tracking below it, so the seven state
classes are now `ObservableObject` with `@Published` on the observed properties
(`@ObservationIgnored` properties stayed unpublished, and `@Published` was kept
out of the helper types in the same files):

`DictationController`, `KeyboardSetupMonitor`, `KeyboardSpeechPreparation`,
`KeyboardParakeetDownload`, `ParakeetUltraDownload`, `FeedbackSender`,
`TranslationSessionHost`.

At the call sites: `@Bindable` → `@ObservedObject`, `@State … = Controller()` →
`@StateObject`, every view that received one as `let` now takes
`@ObservedObject`, and all 31 `.onChange(of:)` uses go through
`onChangeCompat(of:)`.

### Translation (iOS 18) — the feature is off below 18

`LanguageAvailability`, `TranslationSession` and `TranslationError` are iOS 18.
`TranslationAvailability` is Hex's own status type, mapped from Apple's inside
`@available(iOS 18.0, *)`; `DictationTranslation` gates the error mapping, the
translation Settings row and the session host are 18-only, and below 18 a
dictation goes in as spoken (`TranslationEngine.hosted` stays nil, which the
pipeline already handles).

### FluidAudio (iOS 17) — vendored fork

Upstream 0.15.5 declares `.iOS(.v17)` and can't link below it. `Vendor/FluidAudio`
is that release with `Package.swift`'s platform changed to `.iOS(.v16)`; no
FluidAudio source changed. `project.yml` points the package at it. To go back to
upstream, restore the `url:`/`exactVersion:` pin — the app then needs iOS 17.

### App Shortcut strings (iOS 17)

`AppShortcuts.xcstrings` (String Catalog) fails validation below 17, so the
catalog is excluded from the target and `HEXMobile/AppShortcuts.strings` +
`HEXMobile/zh-Hans.lproj/AppShortcuts.strings` carry the first phrasing of each
key. The second phrasing per shortcut is lost on every OS.

### Core ML / UIKit

`MLModel.availableComputeDevices` (17) and `MLComputePlan` (17.4) are gated —
below them the load decides where the model runs and both readers answer "yes".
`registerForTraitChanges` (17) is gated with `traitCollectionDidChange` doing
the same work below it.

## Build the IPA

```sh
cd ios
scripts/fetch-cleanup-model.sh      # 25 MB CoreML model, not in git
xcodegen generate
xcodebuild -project HEXMobile.xcodeproj -scheme HEXMobile -configuration Release \
  -destination 'generic/platform=iOS' -derivedDataPath /tmp/hex-dev \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build

mkdir -p dist/Payload && cp -R /tmp/hex-dev/Build/Products/Release-iphoneos/HEX.app dist/Payload/
cd dist && zip -qry HEXMobile-16.2-unsigned.ipa Payload
```

The IPA is unsigned: Sideloadly, AltStore or Xcode re-sign it with a team of
your own. `project.yml` still names Anomaly's team (`5NZ4Q7NXJ4`); set
`DEVELOPMENT_TEAM` to yours before signing in Xcode. Signing with a free Apple
ID has no App Groups capability, so the keyboard can't read the speech model
Hex downloads (`group.anomaly.hex.mobile`): the app dictates, the keyboard's own
dictation needs a paid team.

## What is verified, and what isn't

- Verified: Release arm64 device build; Debug simulator build; the app launches
  and draws its onboarding (`simctl launch anomaly.hex.mobile` on iOS 27.2).
- Not verified: an actual iOS 16 device. No iOS 16 runtime is installed here, so
  the 16.2 code paths (`AVAudioSession` permission reads, `traitCollectionDidChange`
  palette updates, the non-spring animations, the pre-`MLComputePlan` load) are
  compiled but never executed. Parakeet on the Neural Engine at 16.2 is the
  riskiest of them.
- Not verified: translation on 18+, Live Activities, App Groups with a
  re-signed bundle.

## Branding in this build (刀语)

| What | Where |
| --- | --- |
| App name | `CFBundleDisplayName: 刀语` (`project.yml`), keyboard `刀语键盘`, widget `刀语` |
| Icon | `HEXMobile/Assets.xcassets/AppIcon.appiconset/icon-1024.png` (the Icon Composer bundle `app/AppIcon.icon` is no longer in the target) |
| Wordmark | `ContentView`'s header and navigation titles say 刀语 |
| Credits | Home shows "刀语 基于 Hex 二次修改" with 原项目源码 (`github.com/anomalyco/hex`) and 刀语频道 (`t.me/gyddpu`) |
| Copy | `Localizable.xcstrings` values rename Hex → 刀语 (91 values, keys unchanged so lookups still match); `zh-Hans/InfoPlist.strings` speaks 刀语 |

## Rebrand and settings redesign (刀语 build)

- Brand mark: `DaoyuMarkView` (`HEXShared/HexTheme.swift`) and `DaoyuMarkPath`
  (`FullKeyboard/FullKeyboardPalette.swift`) replace the concentric hexagons — 刀 as
  three strokes, the same geometry in SwiftUI and in the keyboard's Hex key.
- Home: a 「设置」 2 × 2 tile grid (`SettingsTile`, four `SettingsPage.homeTiles`) and an
  「应用」 card (关于与支持 / iOS 设置 / 重新运行设置).
- `Settings › 关于与支持` (`HEXMobile/Settings/AboutPage.swift`): version line, 源码与社区
  (original source, Telegram channel), 帮助 (privacy policy, support, feedback), 法律
  (acknowledgements). The privacy, support, feedback and licence rows left home.
