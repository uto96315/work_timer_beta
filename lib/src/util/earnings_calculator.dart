import '../models/time_entry.dart';
import '../models/workplace.dart';

/// Result of an earnings calculation for a single [TimeEntry], either live
/// (still clocked in) or finished.
class EarningsResult {
  const EarningsResult({
    required this.totalYen,
    required this.regularSeconds,
    required this.overtimeSeconds,
  });

  final double totalYen;
  final int regularSeconds;
  final int overtimeSeconds;

  bool get isOvertime => overtimeSeconds > 0;
  Duration get elapsedSeconds => Duration(seconds: regularSeconds + overtimeSeconds);
}

DateTime _dayAt(DateTime day, String hhmm) {
  final parts = hhmm.split(':');
  return DateTime(
    day.year,
    day.month,
    day.day,
    int.parse(parts[0]),
    int.parse(parts[1]),
  );
}

/// Computes earnings for a shift that started at [clockIn] and is either
/// still ongoing or ended at [now], applying the workplace's overtime rate
/// once the scheduled end time ("teiji") has passed.
EarningsResult calculateLiveEarnings({
  required Workplace workplace,
  required DateTime clockIn,
  required int breakMinutes,
  required DateTime now,
  DateTime? scheduledEndOverride,
}) {
  final scheduledEnd = scheduledEndOverride ?? _dayAt(clockIn, workplace.endTime);
  final breakSeconds = breakMinutes * 60;

  final regularWindowEnd = now.isBefore(scheduledEnd) ? now : scheduledEnd;
  final regularSeconds = (regularWindowEnd.difference(clockIn).inSeconds - breakSeconds)
      .clamp(0, 1 << 31);

  final overtimeSeconds = now.isAfter(scheduledEnd)
      ? now.difference(scheduledEnd).inSeconds
      : 0;

  final regularRate = workplace.hourlyWage / 3600;
  final overtimeRate =
      workplace.hourlyWage * (1 + workplace.overtimeRatePercent / 100) / 3600;

  final totalYen = regularRate * regularSeconds + overtimeRate * overtimeSeconds;

  return EarningsResult(
    totalYen: totalYen,
    regularSeconds: regularSeconds,
    overtimeSeconds: overtimeSeconds,
  );
}

/// Earnings for a single entry: uses [now] as the end time if the entry is
/// still open, otherwise its actual clockOut.
EarningsResult calculateEntryEarnings({
  required Workplace workplace,
  required TimeEntry entry,
  required DateTime now,
}) {
  return calculateLiveEarnings(
    workplace: workplace,
    clockIn: entry.clockIn,
    breakMinutes: entry.breakMinutes,
    now: entry.clockOut ?? now,
    scheduledEndOverride: entry.scheduledEndOverride,
  );
}

class EarningsTotals {
  const EarningsTotals({required this.totalYen, required this.overtimeSeconds});

  final double totalYen;
  final int overtimeSeconds;

  static const zero = EarningsTotals(totalYen: 0, overtimeSeconds: 0);
}

EarningsTotals sumEarnings({
  required Workplace workplace,
  required List<TimeEntry> entries,
  required DateTime now,
}) {
  var totalYen = 0.0;
  var overtimeSeconds = 0;
  for (final entry in entries) {
    final result = calculateEntryEarnings(workplace: workplace, entry: entry, now: now);
    totalYen += result.totalYen;
    overtimeSeconds += result.overtimeSeconds;
  }
  return EarningsTotals(totalYen: totalYen, overtimeSeconds: overtimeSeconds);
}
