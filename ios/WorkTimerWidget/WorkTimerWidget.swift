//
//  WorkTimerWidget.swift
//  WorkTimerWidget
//
//  Shows today's earnings, shift progress, and remaining time. Data is
//  written by the Flutter app (via the home_widget plugin) into the shared
//  App Group's UserDefaults; this extension never talks to Firebase itself.
//

import AppIntents
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
    let isOnBreak: Bool

    static func compute(_ snapshot: WorkSnapshot, asOf now: Date) -> WorkStats {
        let isOnBreak = snapshot.extraBreaks.last?.end == nil && !snapshot.extraBreaks.isEmpty
        guard snapshot.hasWorkplace else {
            return WorkStats(totalYen: 0, progress: 0, remainingLabel: "未設定", isWorking: false, isFinished: false, isOvertime: false, isOnBreak: false)
        }
        guard let clockIn = snapshot.clockIn else {
            return WorkStats(totalYen: 0, progress: 0, remainingLabel: "出勤前", isWorking: false, isFinished: false, isOvertime: false, isOnBreak: false)
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
            isOvertime: isOvertime,
            isOnBreak: isOnBreak
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

/// Mirrors `PixelColors` in `pixel_ui.dart` — the flat, hard-edged palette
/// used across the app's pixel-art theme (Design B).
private enum PixelColors {
    static let ink = Color(red: 0x2E / 255, green: 0x2A / 255, blue: 0x26 / 255)
    static let cream = Color(red: 0xFB / 255, green: 0xF3 / 255, blue: 0xDE / 255)
    static let panel = Color(red: 0xFF / 255, green: 0xFD / 255, blue: 0xF6 / 255)
    static let mint = Color(red: 0x5F / 255, green: 0xBE / 255, blue: 0x99 / 255)
    static let orange = Color(red: 0xF2 / 255, green: 0xA5 / 255, blue: 0x59 / 255)
    static let sand = Color(red: 0xED / 255, green: 0xE0 / 255, blue: 0xBE / 255)
}

private let neutralText = PixelColors.ink.opacity(0.55)

/// Applies the app's pixel-art display font, `DotGothic16`, registered via
/// this extension's own Info.plist (`UIAppFonts`) since app extensions load
/// fonts independently of the host app.
private func pixelFont(_ size: CGFloat) -> Font {
    .custom("DotGothic16-Regular", size: size)
}

/// The static idle frame cropped from the app's puppy sprite sheet
/// (`pet_sprite_widget.dart`); widgets can't run the Flame animation, so a
/// single frame stands in for the pet, rendered without interpolation to
/// keep its pixel edges crisp.
private struct PixelPetView: View {
    var size: CGFloat = 32

    var body: some View {
        Image("PetIdle")
            .interpolation(.none)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }
}

/// A blocky, stepped meter — a strip of solid pips instead of a smooth
/// gradient bar — mirroring `PixelMeter` in `pixel_ui.dart`.
private struct PixelMeter: View {
    let value: Double
    var segments: Int = 10
    var height: CGFloat = 8

    var body: some View {
        let filled = Int((value.clamped(to: 0...1) * Double(segments)).rounded())
        HStack(spacing: 2) {
            ForEach(0..<segments, id: \.self) { index in
                Rectangle()
                    .fill(index < filled ? Color.white : Color.white.opacity(0.25))
            }
        }
        .padding(2)
        .frame(height: height)
        .overlay(Rectangle().strokeBorder(Color.white.opacity(0.6), lineWidth: 1))
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(range.upperBound, max(range.lowerBound, self))
    }
}

/// A square-bordered, hard-shadowed button matching `PixelButton` in
/// `pixel_ui.dart` — flat fill, ink border, and a solid offset block behind
/// it standing in for elevation (WidgetKit buttons ignore ButtonStyles, so
/// this is hand-drawn from two stacked shapes rather than a real shadow).
private struct PixelWidgetButton<I: AppIntent>: View {
    let title: String
    let intent: I
    var filled = true

    var body: some View {
        Button(intent: intent) {
            Text(title)
                .font(pixelFont(12))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(filled ? PixelColors.panel : Color.white.opacity(0.18))
        .foregroundStyle(filled ? PixelColors.ink : .white)
        .overlay(Rectangle().strokeBorder(filled ? PixelColors.ink : .white, lineWidth: 2))
    }
}

struct WorkTimerWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family

    @ViewBuilder
    var body: some View {
        let stats = WorkStats.compute(entry.snapshot, asOf: entry.date)

        if !entry.snapshot.hasWorkplace || entry.snapshot.clockIn == nil {
            VStack(alignment: .leading, spacing: 6) {
                PixelPetView(size: 28)
                Spacer()
                Text(stats.remainingLabel)
                    .font(pixelFont(14))
                    .foregroundStyle(neutralText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .containerBackground(PixelColors.cream, for: .widget)
        } else {
            // Flat fill, no gradient — matches the app's EarningsHeroCard
            // panel colors (mint while on schedule, orange in overtime).
            let fill = stats.isOvertime ? PixelColors.orange : PixelColors.mint
            let earnings = yenFormatter.string(from: NSNumber(value: stats.totalYen)) ?? "¥0"

            Group {
                if family == .systemMedium, #available(iOS 17, *) {
                    // 犬　給与　　退勤ボタン
                    // 　　残り時間　休憩ボタン
                    HStack(alignment: .center, spacing: 12) {
                        PixelPetView(size: 40)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(earnings)
                                .font(pixelFont(22))
                                .foregroundStyle(.white)
                                .minimumScaleFactor(0.7)
                                .lineLimit(1)
                            Text(stats.remainingLabel)
                                .font(pixelFont(12))
                                .foregroundStyle(.white.opacity(0.85))
                        }

                        Spacer(minLength: 8)

                        if stats.isFinished {
                            Text("退勤済み")
                                .font(pixelFont(12))
                                .foregroundStyle(.white.opacity(0.85))
                        } else {
                            VStack(spacing: 6) {
                                PixelWidgetButton(title: "退勤", intent: ClockOutIntent())
                                PixelWidgetButton(
                                    title: stats.isOnBreak ? "休憩終了" : "休憩",
                                    intent: ToggleBreakIntent(),
                                    filled: stats.isOnBreak
                                )
                            }
                            .frame(width: 96)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            PixelPetView(size: 16)
                            Text(stats.isFinished ? "退勤済み" : "勤務中")
                                .font(pixelFont(11))
                        }
                        .foregroundStyle(.white.opacity(0.85))

                        Text(earnings)
                            .font(pixelFont(20))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)

                        Spacer(minLength: 2)

                        PixelMeter(value: stats.progress)

                        HStack {
                            Text("\(Int(stats.progress * 100))%")
                            Spacer()
                            Text(stats.remainingLabel)
                        }
                        .font(pixelFont(11))
                        .foregroundStyle(.white.opacity(0.85))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
            }
            .containerBackground(fill, for: .widget)
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
