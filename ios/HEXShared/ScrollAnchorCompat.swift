import SwiftUI

extension View {
    /// `defaultScrollAnchor` arrived in iOS 17. Below it the list keeps its natural first-page
    /// position, which is where every Settings page starts anyway; only the snapshot fixtures
    /// ever asked for the bottom.
    @ViewBuilder
    func defaultScrollAnchorCompat(_ anchor: UnitPoint) -> some View {
        if #available(iOS 17.0, *) {
            defaultScrollAnchor(anchor)
        } else {
            self
        }
    }
}
