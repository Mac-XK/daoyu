import UIKit

extension UIView {
    /// `animate(springDuration:bounce:initialSpringVelocity:…)` arrived in iOS 17. Below it the
    /// same critically damped spring (bounce 0) is asked for with UIKit's damping form, so the
    /// keyboard and the live words move the same way on every iOS Hex runs on.
    static func animateSpring(
        duration: TimeInterval,
        delay: TimeInterval = 0,
        options: UIView.AnimationOptions = [.beginFromCurrentState, .allowUserInteraction],
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        if #available(iOS 17.0, *) {
            UIView.animate(
                springDuration: duration,
                bounce: 0,
                initialSpringVelocity: 0,
                delay: delay,
                options: options,
                animations: animations,
                completion: completion
            )
        } else {
            UIView.animate(
                withDuration: duration,
                delay: delay,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: options,
                animations: animations,
                completion: completion
            )
        }
    }
}
