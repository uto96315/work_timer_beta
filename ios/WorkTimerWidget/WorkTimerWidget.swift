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

/// A single ad-hoc break the user started/stopped live during the shift
/// (`end` is nil while still ongoing), mirroring `ExtraBreak` in
/// `time_entry.dart`.
struct ExtraBreak {
    let start: Date
    let end: Date?
}

/// Raw shift data as shared by the Flutter app for "today". Times are
/// stored as seconds-since-epoch so the widget can recompute earnings at
/// any point in its timeline without the app needing to be running.
struct WorkSnapshot {
    let hasWorkplace: Bool
    let hourlyWage: Int
    let overtimeRatePercent: Int
    /// The entry's own break minutes (set from the workplace default at
    /// clock-in time), not the workplace's current default — matches what
    /// `earnings_calculator.dart` actually subtracts.
    let breakMinutes: Int
    let scheduledStart: Date
    let scheduledEnd: Date
    let clockIn: Date?
    let clockOut: Date?
    let extraBreaks: [ExtraBreak]

    static let placeholder = WorkSnapshot(
        hasWorkplace: true,
        hourlyWage: 1200,
        overtimeRatePercent: 25,
        breakMinutes: 60,
        scheduledStart: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!,
        scheduledEnd: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!,
        clockIn: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()),
        clockOut: nil,
        extraBreaks: []
    )

    private static let empty = WorkSnapshot(
        hasWorkplace: false,
        hourlyWage: 0,
        overtimeRatePercent: 0,
        breakMinutes: 0,
        scheduledStart: Date(),
        scheduledEnd: Date(),
        clockIn: nil,
        clockOut: nil,
        extraBreaks: []
    )

    static func load() -> WorkSnapshot {
        let defaults = UserDefaults(suiteName: appGroupId)
        guard defaults?.bool(forKey: "hasWorkplace") == true else { return .empty }

        func date(_ key: String) -> Date? {
            guard let seconds = defaults?.object(forKey: key) as? Double else { return nil }
            return Date(timeIntervalSince1970: seconds)
        }

        var extraBreaks: [ExtraBreak] = []
        if let json = defaults?.string(forKey: "extraBreaksJson"),
           let data = json.data(using: .utf8),
           let list = try? JSONSerialization.jsonObject(with: data) as? [[String: Any?]] {
            extraBreaks = list.compactMap { item in
                guard let start = item["start"] as? Double else { return nil }
                let end = item["end"] as? Double
                return ExtraBreak(
                    start: Date(timeIntervalSince1970: start),
                    end: end.map { Date(timeIntervalSince1970: $0) }
                )
            }
        }

        return WorkSnapshot(
            hasWorkplace: true,
            hourlyWage: defaults?.integer(forKey: "hourlyWage") ?? 0,
            overtimeRatePercent: defaults?.integer(forKey: "overtimeRatePercent") ?? 0,
            breakMinutes: defaults?.integer(forKey: "breakMinutes") ?? 0,
            scheduledStart: date("scheduledStartEpoch") ?? Date(),
            scheduledEnd: date("scheduledEndEpoch") ?? Date(),
            clockIn: date("clockInEpoch"),
            clockOut: date("clockOutEpoch"),
            extraBreaks: extraBreaks
        )
    }
}

/// Earnings/progress derived from a [WorkSnapshot] as of a specific instant
/// (`asOf`). Mirrors `calculateLiveEarnings`/`calculateEntryEarnings` in the
/// Flutter app's `earnings_calculator.dart` — keep these two in sync.
struct WorkStats {
    let totalYen: Double
    let progress: Double
    let remainingLabel: String
    let isWorking: Bool
    let isFinished: Bool
    let isOvertime: Bool

    static func compute(_ snapshot: WorkSnapshot, asOf now: Date) -> WorkStats {
        guard snapshot.hasWorkplace else {
            return WorkStats(totalYen: 0, progress: 0, remainingLabel: "未設定", isWorking: false, isFinished: false, isOvertime: false)
        }
        guard let clockIn = snapshot.clockIn else {
            return WorkStats(totalYen: 0, progress: 0, remainingLabel: "出勤前", isWorking: false, isFinished: false, isOvertime: false)
        }

        let isWorking = snapshot.clockOut == nil
        let isFinished = !isWorking
        let workedEnd = snapshot.clockOut ?? now
        let breakSeconds = Double(snapshot.breakMinutes * 60)

        let extraBreakSeconds = snapshot.extraBreaks.reduce(0.0) { sum, b in
            sum + max(0, (b.end ?? workedEnd).timeIntervalSince(b.start))
        }

        let regularWindowEnd = min(workedEnd, snapshot.scheduledEnd)
        let regularSecondsRaw = regularWindowEnd.timeIntervalSince(clockIn) - breakSeconds
        var overtimeSeconds = max(0, workedEnd.timeIntervalSince(snapshot.scheduledEnd))

        // Ad-hoc breaks are mainly taken during overtime, so come out of it
        // first; any leftover spills into the regular window — matches
        // earnings_calculator.dart exactly.
        let fromOvertime = min(max(0, extraBreakSeconds), overtimeSeconds)
        overtimeSeconds -= fromOvertime
        let regularSeconds = max(0, regularSecondsRaw - (extraBreakSeconds - fromOvertime))

        let regularRate = Double(snapshot.hourlyWage) / 3600
        let overtimeRate = Double(snapshot.hourlyWage) * (1 + Double(snapshot.overtimeRatePercent) / 100) / 3600
        let totalYen = regularRate * regularSeconds + overtimeRate * overtimeSeconds

        let effectiveStart = min(clockIn, snapshot.scheduledStart)
        let totalWindow = max(1, snapshot.scheduledEnd.timeIntervalSince(effectiveStart) - breakSeconds)
        let elapsedWindow = max(0, regularWindowEnd.timeIntervalSince(effectiveStart) - breakSeconds - extraBreakSeconds)
        let progress = min(1, max(0, elapsedWindow / totalWindow))

        let isOvertime = overtimeSeconds > 0
        let remainingSeconds = max(0, snapshot.scheduledEnd.timeIntervalSince(now))
        let remainingMinutes = Int(remainingSeconds) / 60
        let hours = remainingMinutes / 60
        let minutes = remainingMinutes % 60
        let overtimeMinutes = Int(overtimeSeconds) / 60
        let overtimeHours = overtimeMinutes / 60
        let overtimeMinutesRem = overtimeMinutes % 60

        let remainingLabel: String
        if isFinished {
            remainingLabel = "お疲れ様でした"
        } else if isOvertime {
            remainingLabel = overtimeHours > 0 ? "残業 \(overtimeHours)時間\(overtimeMinutesRem)分" : "残業 \(overtimeMinutesRem)分"
        } else if progress >= 1 {
            remainingLabel = "本日終了"
        } else {
            remainingLabel = hours > 0 ? "あと\(hours)時間\(minutes)分" : "あと\(minutes)分"
        }

        return WorkStats(
            totalYen: totalYen,
            progress: progress,
            remainingLabel: remainingLabel,
            isWorking: isWorking,
            isFinished: isFinished,
            isOvertime: isOvertime
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

// Matches the app's _EarningsHeroCard gradients exactly (home_screen.dart):
// teal while on schedule, orange once into overtime.
private let normalGradient = [Color(red: 0x19 / 255, green: 0xC3 / 255, blue: 0xA6 / 255),
                               Color(red: 0x0D / 255, green: 0x8F / 255, blue: 0x84 / 255)]
private let overtimeGradient = [Color(red: 0xFF / 255, green: 0x8A / 255, blue: 0x5C / 255),
                                 Color(red: 0xE8 / 255, green: 0x5D / 255, blue: 0x3D / 255)]
// Used only for the "no workplace yet" empty state, which has no earnings
// to show and so doesn't warrant the colored gradient treatment.
private let neutralBackground = Color(red: 0xF4 / 255, green: 0xF6 / 255, blue: 0xF7 / 255)
private let neutralText = Color(red: 0.45, green: 0.48, blue: 0.49)

struct WorkTimerWidgetEntryView: View {
    var entry: Provider.Entry

    @ViewBuilder
    var body: some View {
        let stats = WorkStats.compute(entry.snapshot, asOf: entry.date)

        if !entry.snapshot.hasWorkplace || entry.snapshot.clockIn == nil {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: "clock")
                    .foregroundStyle(neutralText)
                Spacer()
                Text(stats.remainingLabel)
                    .font(.subheadline.bold())
                    .foregroundStyle(neutralText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .containerBackground(neutralBackground, for: .widget)
        } else {
            let gradient = stats.isOvertime ? overtimeGradient : normalGradient

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: stats.isFinished ? "checkmark.circle.fill" : "clock.fill")
                        .font(.caption)
                    Text(stats.isFinished ? "退勤済み" : "勤務中")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white.opacity(0.85))

                Text(yenFormatter.string(from: NSNumber(value: stats.totalYen)) ?? "¥0")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Spacer(minLength: 2)

                ProgressView(value: stats.progress)
                    .tint(.white)
                    .background(Color.white.opacity(0.3))

                HStack {
                    Text("\(Int(stats.progress * 100))%")
                    Spacer()
                    Text(stats.remainingLabel)
                }
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.85))
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .containerBackground(
                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                for: .widget
            )
        }
    }
}

struct WorkTimerWidget: Widget {
    let kind: String = "WorkTimerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WorkTimerWidgetEntryView(entry: entry)
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
