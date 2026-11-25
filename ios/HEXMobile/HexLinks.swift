import SafariServices
import UIKit

/// Hex's web pages for the iPhone app, under one base so they can move to
/// `https://anoma.ly/hex` once the site's production deploy serves them (it 404s until then).
enum HexLinks {
    static let site = URL(string: "https://dev.anoma.ly/hex")!
    static let privacyPolicy = site.appending(path: "privacy")
    static let support = site.appending(path: "iphone")

    /// 刀语 is a modified build of Hex: the original author's source, and the channel this
    /// build comes from.
    static let originalSource = URL(string: "https://github.com/anomalyco/hex")!
    static let channel = URL(string: "https://t.me/gyddpu")!
}

/// Opens a web page in Safari inside Hex (`SFSafariViewController`), over whatever is showing.
@MainActor
enum SafariSheet {
    static func present(_ url: URL) {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        guard var top = scene?.keyWindow?.rootViewController else { return }
        while let presented = top.presentedViewController, !presented.isBeingDismissed {
            top = presented
        }
        let controller = SFSafariViewController(url: url)
        controller.overrideUserInterfaceStyle = .dark
        top.present(controller, animated: true)
    }
}
