import '../models/workplace.dart';

/// Result of a live earnings calculation for a single open [TimeEntry].
class EarningsResult {
  const EarningsResult({
    required this.totalYen,
    required this.isOvertime,
    required this.elapsedSeconds,
  });

  final double totalYen;
  final bool isOvertime;
  final Duration elapsedSeconds;
}

DateTime _todayAt(DateTime day, String hhmm) {
  final parts = hhmm.split(':');
  return DateTime(
    day.year,
    day.month,
    day.day,
    int.parse(parts[0]),
    int.parse(parts[1]),
  );
}

/// Computes today's live earnings for an entry that started at [clockIn] and
/// is still open at [now], applying the workplace's overtime rate once the
/// scheduled end time ("teiji") has passed.
EarningsResult calculateLiveEarnings({
  required Workplace workplace,
  required DateTime clockIn,
  required int breakMinutes,
  required DateTime now,
}) {
  final scheduledEnd = _todayAt(clockIn, workplace.endTime);
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
    isOvertime: overtimeSeconds > 0,
    elapsedSeconds: Duration(seconds: regularSeconds + overtimeSeconds),
  );
}
