//
//  WidgetIntents.swift
//
//  Behind the WorkTimerWidget's 退勤/休憩 buttons. A widget extension can't
//  reach Firestore itself (importing the `home_widget`/Firebase Flutter
//  plugin modules isn't possible from an App Extension target — Apple's
//  toolchain refuses to resolve them there since they aren't built
//  extension-safe), so these intents can't write the real record directly.
//
//  Instead they optimistically rewrite the same shared UserDefaults fields
//  WorkTimerWidget.swift reads for display (so the widget reflects the tap
//  instantly) and bump a small pending-action counter/flag. The Flutter app
//  drains that queue and performs the actual Firestore write the next time
//  it's opened or resumed — see applyPendingWidgetActions in
//  lib/src/services/widget_pending_action_service.dart.
//

import AppIntents
import Foundation
import WidgetKit

private let widgetAppGroupId = "group.com.jp.worktimer.widget"

private func withSharedDefaults(_ body: (UserDefaults) -> Void) {
    guard let defaults = UserDefaults(suiteName: widgetAppGroupId) else { return }
    body(defaults)
    WidgetCenter.shared.reloadAllTimelines()
}

@available(iOS 17, *)
struct ClockOutIntent: AppIntent {
    static var title: LocalizedStringResource = "退勤する"

    func perform() async throws -> some IntentResult {
        withSharedDefaults { defaults in
            guard defaults.object(forKey: "clockOutEpoch") == nil else { return }
            let now = Date().timeIntervalSince1970
            defaults.set(now, forKey: "clockOutEpoch")
            defaults.set(now, forKey: "pendingClockOutRequestedAtEpoch")
        }
        return .result()
    }
}

@available(iOS 17, *)
struct ToggleBreakIntent: AppIntent {
    static var title: LocalizedStringResource = "休憩する"

    func perform() async throws -> some IntentResult {
        withSharedDefaults { defaults in
            var breaks: [[String: Any?]] = []
            if let json = defaults.string(forKey: "extraBreaksJson"),
               let data = json.data(using: .utf8),
               let list = try? JSONSerialization.jsonObject(with: data) as? [[String: Any?]] {
                breaks = list
            }

            let now = Date().timeIntervalSince1970
            if let lastIndex = breaks.indices.last,
               breaks[lastIndex]["end"] == nil || breaks[lastIndex]["end"] is NSNull {
                breaks[lastIndex]["end"] = now
            } else {
                breaks.append(["start": now, "end": NSNull()])
            }

            if let data = try? JSONSerialization.data(withJSONObject: breaks),
               let json = String(data: data, encoding: .utf8) {
                defaults.set(json, forKey: "extraBreaksJson")
            }
            defaults.set(defaults.integer(forKey: "pendingBreakToggleCount") + 1, forKey: "pendingBreakToggleCount")
        }
        return .result()
    }
}
