//
//  WorkTimerWidget.swift
//  WorkTimerWidget
//
//  Shows today's earnings, shift progress, and remaining time. Data is
//  written by the Flutter app (via the home_widget plugin) into the shared
//  App Group's UserDefaults; this extension never talks to Firebase itself.
//

import WidgetKit
import SwiftUI

private let appGroupId = "group.com.jp.worktimer.widget"

/// Raw shift data as shared by the Flutter app for "today". Times are
/// stored as seconds-since-epoch so the widget can recompute earnings at
/// any point in its timeline without the app needing to be running.
struct WorkSnapshot {
    let hasWorkplace: Bool
    let hourlyWage: Int
    let overtimeRatePercent: Int
    let breakMinutes: Int
    let scheduledStart: Date
    let scheduledEnd: Date
    let clockIn: Date?
    let clockOut: Date?

    static let placeholder = WorkSnapshot(
        hasWorkplace: true,
        hourlyWage: 1200,
        overtimeRatePercent: 25,
        breakMinutes: 60,
        scheduledStart: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!,
        scheduledEnd: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!,
        clockIn: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()),
        clockOut: nil
    )

    static func load() -> WorkSnapshot {
        let defaults = UserDefaults(suiteName: appGroupId)
        guard defaults?.bool(forKey: "hasWorkplace") == true else {
            return WorkSnapshot(
                hasWorkplace: false,
                hourlyWage: 0,
                overtimeRatePercent: 0,
                breakMinutes: 0,
                scheduledStart: Date(),
                scheduledEnd: Date(),
                clockIn: nil,
                clockOut: nil
            )
        }
        func date(_ key: String) -> Date? {
            guard let seconds = defaults?.object(forKey: key) as? Double else { return nil }
            return Date(timeIntervalSince1970: seconds)
        }
        return WorkSnapshot(
            hasWorkplace: true,
            hourlyWage: defaults?.integer(forKey: "hourlyWage") ?? 0,
            overtimeRatePercent: defaults?.integer(forKey: "overtimeRatePercent") ?? 0,
            breakMinutes: defaults?.integer(forKey: "breakMinutes") ?? 0,
            scheduledStart: date("scheduledStartEpoch") ?? Date(),
            scheduledEnd: date("scheduledEndEpoch") ?? Date(),
            clockIn: date("clockInEpoch"),
            clockOut: date("clockOutEpoch")
        )
    }
}

/// Earnings/progress derived from a [WorkSnapshot] as of a specific instant
/// (`asOf`), mirroring the calculation in the Flutter app's
/// `earnings_calculator.dart` closely enough for an at-a-glance widget.
struct WorkStats {
    let totalYen: Double
    let progress: Double
    let remainingLabel: String
    let isWorking: Bool
    let isFinished: Bool

    static func compute(_ snapshot: WorkSnapshot, asOf now: Date) -> WorkStats {
        guard snapshot.hasWorkplace else {
            return WorkStats(totalYen: 0, progress: 0, remainingLabel: "未設定", isWorking: false, isFinished: false)
        }
        guard let clockIn = snapshot.clockIn else {
            return WorkStats(totalYen: 0, progress: 0, remainingLabel: "出勤前", isWorking: false, isFinished: false)
        }

        let isWorking = snapshot.clockOut == nil
        let isFinished = !isWorking
        let workedEnd = snapshot.clockOut ?? now
        let breakSeconds = Double(snapshot.breakMinutes * 60)

        let regularWindowEnd = min(workedEnd, snapshot.scheduledEnd)
        let regularSeconds = max(0, regularWindowEnd.timeIntervalSince(clockIn) - breakSeconds)
        let overtimeSeconds = max(0, workedEnd.timeIntervalSince(snapshot.scheduledEnd))

        let regularRate = Double(snapshot.hourlyWage) / 3600
        let overtimeRate = Double(snapshot.hourlyWage) * (1 + Double(snapshot.overtimeRatePercent) / 100) / 3600
        let totalYen = regularRate * regularSeconds + overtimeRate * overtimeSeconds

        let effectiveStart = min(clockIn, snapshot.scheduledStart)
        let totalWindow = max(1, snapshot.scheduledEnd.timeIntervalSince(effectiveStart) - breakSeconds)
        let elapsedWindow = max(0, regularWindowEnd.timeIntervalSince(effectiveStart) - breakSeconds)
        let progress = min(1, max(0, elapsedWindow / totalWindow))

        let remainingSeconds = max(0, snapshot.scheduledEnd.timeIntervalSince(now))
        let remainingMinutes = Int(remainingSeconds) / 60
        let hours = remainingMinutes / 60
        let minutes = remainingMinutes % 60
        let remainingLabel = isFinished
            ? "お疲れ様でした"
            : (progress >= 1 ? "本日終了" : (hours > 0 ? "あと\(hours)時間\(minutes)分" : "あと\(minutes)分"))

        return WorkStats(
            totalYen: totalYen,
            progress: progress,
            remainingLabel: remainingLabel,
            isWorking: isWorking,
            isFinished: isFinished
        )
    }
}

struct WorkEntry: TimelineEntry {
    let date: Date
    let snapshot: WorkSnapshot
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WorkEntry {
        WorkEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (WorkEntry) -> Void) {
        completion(WorkEntry(date: Date(), snapshot: .load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WorkEntry>) -> Void) {
        let snapshot = WorkSnapshot.load()
        let now = Date()
        var entries: [WorkEntry] = []
        // A refresh every 15 minutes for the next 3 hours is enough to keep
        // the progress/earnings readout feeling live without exceeding
        // WidgetKit's refresh budget.
        for minuteOffset in stride(from: 0, to: 180, by: 15) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: now) ?? now
            entries.append(WorkEntry(date: entryDate, snapshot: snapshot))
        }
        let refreshAt = Calendar.current.date(byAdding: .minute, value: 180, to: now) ?? now
        completion(Timeline(entries: entries, policy: .after(refreshAt)))
    }
}

private let yenFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = "¥"
    formatter.maximumFractionDigits = 0
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter
}()

struct WorkTimerWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        let stats = WorkStats.compute(entry.snapshot, asOf: entry.date)
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: stats.isFinished ? "checkmark.circle.fill" : (stats.isWorking ? "clock.fill" : "clock"))
                    .foregroundStyle(Color(red: 0.05, green: 0.56, blue: 0.52))
                    .font(.caption)
                Text(stats.isFinished ? "退勤済み" : (stats.isWorking ? "勤務中" : "未出勤"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(entry.snapshot.hasWorkplace ? (yenFormatter.string(from: NSNumber(value: stats.totalYen)) ?? "¥0") : "-")
                .font(.title2.bold())
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            ProgressView(value: stats.progress)
                .tint(Color(red: 0.05, green: 0.56, blue: 0.52))
            HStack {
                Text("\(Int(stats.progress * 100))%")
                Spacer()
                Text(stats.remainingLabel)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct WorkTimerWidget: Widget {
    let kind: String = "WorkTimerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WorkTimerWidgetEntryView(entry: entry)
                .containerBackground(.white, for: .widget)
        }
        .configurationDisplayName("仕事タイマー")
        .description("今日の進捗と稼いだ金額を表示します。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    WorkTimerWidget()
} timeline: {
    WorkEntry(date: .now, snapshot: .placeholder)
}
