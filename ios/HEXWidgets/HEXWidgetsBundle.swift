import SwiftUI
import WidgetKit

@main
struct HEXWidgetsBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 16.1, *) {
            HexDictationLiveActivity()
        }
        if #available(iOS 18.0, *) {
            HexDictationControl()
        }
    }
}
