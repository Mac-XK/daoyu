import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

@available(iOS 16.1, *)
struct HexDictationLiveActivity: Widget {
    /// `ActivityViewContext.isStale` arrived in iOS 16.2; before it, an activity Hex hasn't
    /// updated still reads live.
    static func isStale(_ context: ActivityViewContext<HexDictationActivityAttributes>) -> Bool {
        if #available(iOS 16.2, *) { return context.isStale }
        return false
    }

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HexDictationActivityAttributes.self) { context in
            LockScreenBanner(state: context.state, isStale: Self.isStale(context))
                .activityBackgroundTint(Color(red: 0x11 / 255.0, green: 0x13 / 255.0, blue: 0x16 / 255.0))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            let isRecording = !Self.isStale(context) && context.state.stage == .recording
            let isCooling = !Self.isStale(context) && context.state.stage == .transcribing
            return DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    LockScreenBanner(state: context.state, isStale: Self.isStale(context))
                }
            } compactLeading: {
                HexDotMatrixBadge(columns: 9, rows: 5, pitch: 2.2, cooling: isCooling)
                    .padding(.leading, 2)
            } compactTrailing: {
                if isRecording {
                    Text(timerInterval: context.state.startedAt...Date.distantFuture, countsDown: false)
                        .font(.system(size: 13, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(HexTheme.warmPearl)
                        .frame(maxWidth: 44, alignment: .trailing)
                        .padding(.trailing, 3)
                } else {
                    Image(systemName: isCooling ? "ellipsis" : "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isCooling ? HexTheme.agentBlue : HexTheme.textBase)
                        .padding(.trailing, 4)
                }
            } minimal: {
                HexDotMatrixBadge(columns: 7, rows: 5, pitch: 2.1, cooling: isCooling)
            }
            .keylineTint(isRecording ? HexTheme.warmPearl : HexTheme.agentBlue)
        }
    }
}

private struct LockScreenBanner: View {
    let state: HexDictationActivityAttributes.ContentState
    let isStale: Bool

    private var activeStage: HexDictationActivityAttributes.Stage {
        isStale ? .copied : state.stage
    }

    var body: some View {
        HStack(spacing: 12) {
            if activeStage == .copied {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(HexTheme.success)
                    .frame(width: 28, height: 28)
                    .background(HexTheme.layer02, in: Circle())
                Text("Copied")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(HexTheme.textBase)
            } else {
                HexDotMatrixBadge(
                    columns: activeStage == .recording ? 25 : 19,
                    rows: 7,
                    pitch: 2.5,
                    cooling: activeStage == .transcribing
                )

                if activeStage == .recording {
                    Text(timerInterval: state.startedAt...Date.distantFuture, countsDown: false)
                        .font(.system(size: 13, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(HexTheme.textMuted)
                }
            }

            Spacer(minLength: 8)

            if activeStage == .recording {
                // Interactive Live Activity buttons need iOS 17 (`Button(intent:)`);
                // an iOS 16 banner shows the state without them.
                if #available(iOS 17.0, *) {
                    DictationControls()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

/// Banner controls: Finish and Cancel, drawn only where `Button(intent:)` exists.
@available(iOS 17.0, *)
private struct DictationControls: View {
    var body: some View {
        HStack(spacing: 6) {
            Button(intent: CancelHexDictationIntent()) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(HexTheme.textMuted)
                    .frame(width: 34, height: 34)
                    .background(HexTheme.layer02, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Cancel")

            Button(intent: StopHexDictationIntent()) {
                Text("Done")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(HexTheme.textContrast)
                    .padding(.horizontal, 14)
                    .frame(height: 34)
                    .background(HexTheme.bgContrast, in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Finish dictation")
        }
    }
}
