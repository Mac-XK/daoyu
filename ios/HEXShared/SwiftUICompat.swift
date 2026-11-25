import SwiftUI

extension View {
    /// `scrollBounceBehavior` is iOS 16.4; before it the list bounces as it always did.
    @ViewBuilder
    func scrollBounceBehaviorCompat() -> some View {
        if #available(iOS 16.4, *) {
            scrollBounceBehavior(.basedOnSize)
        } else {
            self
        }
    }

    /// `presentationBackground` is iOS 16.4; a sheet below it keeps the system background.
    @ViewBuilder
    func presentationBackgroundCompat<S: ShapeStyle>(_ style: S) -> some View {
        if #available(iOS 16.4, *) {
            presentationBackground(style)
        } else {
            self
        }
    }

    /// `listSectionSpacing` is iOS 17; below it the list keeps its own spacing.
    @ViewBuilder
    func listSectionSpacingCompat(_ spacing: CGFloat) -> some View {
        if #available(iOS 17.0, *) {
            listSectionSpacing(spacing)
        } else {
            self
        }
    }
}

extension View {
    /// `scrollClipDisabled` is iOS 17; before it the list keeps clipping its content.
    @ViewBuilder
    func scrollClipDisabledCompat() -> some View {
        if #available(iOS 17.0, *) {
            scrollClipDisabled()
        } else {
            self
        }
    }
}
