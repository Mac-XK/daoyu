import SwiftUI

extension View {
    /// `onChange(of:_:)`'s two-argument form is iOS 17. Below it SwiftUI's one-argument form
    /// runs, and the old value is handed in as the new one: every Hex call site ignores the
    /// old value.
    @ViewBuilder
    func onChangeCompat<V: Equatable>(of value: V, _ action: @escaping (V, V) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            onChange(of: value) { previous, next in action(previous, next) }
        } else {
            onChange(of: value) { next in action(next, next) }
        }
    }

    /// The `initial:` form is iOS 17 as well; below it the first read happens on appear.
    @ViewBuilder
    func onChangeCompat<V: Equatable>(of value: V, initial: Bool, _ action: @escaping (V, V) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            onChange(of: value, initial: initial) { previous, next in action(previous, next) }
        } else if initial {
            onChange(of: value) { next in action(next, next) }
                .onAppear { action(value, value) }
        } else {
            onChange(of: value) { next in action(next, next) }
        }
    }
}
