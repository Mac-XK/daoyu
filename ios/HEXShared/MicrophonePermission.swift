import AVFAudio

/// How the microphone permission reads on every iOS Hex runs on.
///
/// iOS 17 moved the question from `AVAudioSession` to `AVAudioApplication`; Hex asks
/// through this type so the app and the keyboard share one answer and one enum whose
/// cases match the old one (`.granted`, `.denied`, `.undetermined`), which keeps every
/// comparison at the call sites unchanged.
nonisolated enum MicrophonePermission: Sendable, Equatable {
    case undetermined
    case denied
    case granted
}

nonisolated enum MicrophoneAccess {
    /// The current permission, without asking.
    static var permission: MicrophonePermission {
        if #available(iOS 17.0, *) {
            return MicrophonePermission(AVAudioApplication.shared.recordPermission)
        }
        return MicrophonePermission(AVAudioSession.sharedInstance().recordPermission)
    }

    /// Shows the system prompt the first time; delivers the answer on the main queue's terms.
    static func request(_ completion: @escaping @Sendable (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission(completionHandler: completion)
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission(completion)
        }
    }
}

@available(iOS 17.0, *)
private extension MicrophonePermission {
    init(_ permission: AVAudioApplication.recordPermission) {
        switch permission {
        case .granted: self = .granted
        case .denied: self = .denied
        case .undetermined: self = .undetermined
        @unknown default: self = .undetermined
        }
    }
}

private extension MicrophonePermission {
    init(_ permission: AVAudioSession.RecordPermission) {
        switch permission {
        case .granted: self = .granted
        case .denied: self = .denied
        case .undetermined: self = .undetermined
        @unknown default: self = .undetermined
        }
    }
}
