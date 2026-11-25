# 刀语 (Daoyu)

刀语是 [Hex](https://github.com/anomalyco/hex) 的 iOS 二次修改版：本地离线语音听写，按住说话，松手把文字落到光标处。音频不出设备，转写全程在这台 iPhone 上完成。

- 上游项目（原作者）：**anomalyco/hex** — <https://github.com/anomalyco/hex>，MIT
- 频道：<https://t.me/gyddpu>
- 本仓库只包含 iOS 端（`ios/`）；桌面端（Rust）不在此仓库

## 与上游的差别

| 项 | 说明 |
| --- | --- |
| 系统门槛 | `IPHONEOS_DEPLOYMENT_TARGET` 从 18.0 降到 **16.2**（Live Activity 的 `ActivityContent` 就是 16.2），详见 [`ios/docs/BUILD.md`](ios/docs/BUILD.md) |
| 状态层 | 7 个 `@Observable` 类改为 `ObservableObject` + `@Published`，`@Bindable` → `@ObservedObject`，`@State` → `@StateObject` |
| 翻译 | 依赖 iOS 18 的 `LanguageAvailability` / `TranslationSession`，18 以下关闭（按原话粘贴） |
| Parakeet | 上游 FluidAudio 声明 `.iOS(.v17)`，这里用 `ios/Vendor/FluidAudio`（仅把平台改成 `.v16`，源码未改） |
| 兼容层 | 麦克风权限、spring 动画、`onChange`、`defaultScrollAnchor`、`scrollBounceBehavior`、`presentationBackground`、`listSectionSpacing`、`scrollClipDisabled`、`registerForTraitChanges`、`MLComputePlan` 等逐项加了回退 |
| 品牌 | 名称、图标、应用内标识换成刀语；首页设置改为磁贴分组；新增「关于与支持」页（源码、频道、隐私、反馈、致谢） |

## 构建

需要 Xcode 26+（本项目在 27.2 上验证）、[XcodeGen](https://github.com/yonaskolb/XcodeGen) 2.46+。

```sh
cd ios
scripts/fetch-cleanup-model.sh        # 25 MB CoreML 模型，不在仓库里
xcodegen generate
xcodebuild -project HEXMobile.xcodeproj -scheme HEXMobile \
  -configuration Release -destination 'generic/platform=iOS' \
  -derivedDataPath /tmp/hex-dev \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build

mkdir -p dist/Payload && cp -R /tmp/hex-dev/Build/Products/Release-iphoneos/HEX.app dist/Payload/
cd dist && zip -qry Daoyu-16.2-unsigned.ipa Payload
```

模拟器上跑：

```sh
xcodebuild -project HEXMobile.xcodeproj -scheme HEXMobile \
  -destination 'generic/platform=iOS Simulator' build
```

## 签名

`ios/project.yml` 的 `DEVELOPMENT_TEAM` 是空的，填上你自己的 Apple Developer team 再用 Xcode 或 Sideloadly / AltStore 签名安装。

主 app 与键盘扩展共享 `group.anomaly.hex.mobile`（App Group）来传语音模型：免费 Apple ID 没有 App Groups 能力，重签后键盘读不到模型，主 app 听写不受影响。付费账号无此问题。

## 目录

```
ios/
  HEXMobile/      主 app（SwiftUI）
  HEXKeyboard/    键盘扩展与听写条
  HEXShared/      两边共用：键盘引擎、布局、清理、主题
  HEXWidgets/     Live Activity 与控制中心组件（16.1+）
  HEXActivity/    ActivityKit 定义
  Vendor/         FluidAudio（iOS 16 平台 fork）
  docs/BUILD.md   iOS 16.2 移植、构建与验证记录
tests/fixtures/   测试用的固定数据
```

## 许可

MIT，见 [`LICENSE`](LICENSE)。原始版权归 Anomaly 与 Hex 贡献者所有；本仓库只是在其之上的二次修改。第三方数据与模型的许可见 [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) 与应用内「关于与支持 › 致谢」。
