import SwiftUI

/// Settings › 关于与支持: what this build is, where its source and channel live, and the
/// privacy, support, feedback and licence entries that used to sit at the bottom of home.
struct AboutPage: View {
    let dictation: DictationController
    @State private var showAcknowledgements = false

    private var version: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(short) (\(build))"
    }

    var body: some View {
        SettingsPageScaffold(title: "关于与支持") {
            VStack(spacing: 10) {
                DaoyuMarkView(size: 48)
                Text("刀语")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(HexTheme.textBase)
                Text("版本 \(version) · 基于 Hex 二次修改")
                    .font(.system(size: 13))
                    .foregroundStyle(HexTheme.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 18)
            .padding(.bottom, 8)

            SettingsSectionHeader(title: "源码与社区")
                .padding(.leading, 0)

            SettingsCard {
                Button {
                    SafariSheet.present(HexLinks.originalSource)
                } label: {
                    SettingsLinkLabel(
                        title: "原项目源码 · Hex",
                        icon: "chevron.left.forwardslash.chevron.right",
                        trailingIcon: "arrow.up.right"
                    )
                }
                .buttonStyle(.plain)

                SettingsDivider(leading: 50)

                Button {
                    SafariSheet.present(HexLinks.channel)
                } label: {
                    SettingsLinkLabel(
                        title: "刀语频道 · t.me/gyddpu",
                        icon: "paperplane",
                        trailingIcon: "arrow.up.right"
                    )
                }
                .buttonStyle(.plain)
            }

            SettingsSectionHeader(title: "帮助")
                .padding(.leading, 0)

            SettingsCard {
                Button {
                    SafariSheet.present(HexLinks.privacyPolicy)
                } label: {
                    SettingsLinkLabel(title: "隐私政策", icon: "hand.raised", trailingIcon: "arrow.up.right")
                }
                .buttonStyle(.plain)

                SettingsDivider(leading: 50)

                Button {
                    SafariSheet.present(HexLinks.support)
                } label: {
                    SettingsLinkLabel(title: "支持", icon: "questionmark.circle", trailingIcon: "arrow.up.right")
                }
                .buttonStyle(.plain)

                // Absent in a build without a report key (FeedbackRow).
                FeedbackRow(screen: "About", dictation: dictation, divider: true)
            }

            SettingsSectionHeader(title: "法律")
                .padding(.leading, 0)

            SettingsCard {
                Button {
                    showAcknowledgements = true
                } label: {
                    SettingsLinkLabel(title: "致谢", icon: "doc.text")
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showAcknowledgements) {
            AcknowledgementsView()
        }
    }
}
