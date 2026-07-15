import '../models/salary_type.dart';
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
  int extraBreakSeconds = 0,
}) {
  final scheduledEnd = scheduledEndOverride ?? _dayAt(clockIn, workplace.endTime);
  final breakSeconds = breakMinutes * 60;

  final regularWindowEnd = now.isBefore(scheduledEnd) ? now : scheduledEnd;
  final regularSecondsRaw = regularWindowEnd.difference(clockIn).inSeconds - breakSeconds;

  var overtimeSeconds = now.isAfter(scheduledEnd)
      ? now.difference(scheduledEnd).inSeconds
      : 0;

  // Ad-hoc breaks are mainly taken during overtime, so come out of it
  // first; any leftover (e.g. one taken during regular hours) spills into
  // the regular window instead.
  final fromOvertime = extraBreakSeconds.clamp(0, overtimeSeconds);
  overtimeSeconds -= fromOvertime;
  final regularSeconds =
      (regularSecondsRaw - (extraBreakSeconds - fromOvertime)).clamp(0, 1 << 31);

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
  final endMarker = entry.clockOut ?? now;
  final extraBreakSeconds = entry.extraBreaks.fold<int>(0, (sum, b) {
    final end = b.end ?? endMarker;
    return sum + end.difference(b.start).inSeconds.clamp(0, 1 << 31);
  });
  return calculateLiveEarnings(
    workplace: workplace,
    clockIn: entry.clockIn,
    breakMinutes: entry.breakMinutes,
    now: endMarker,
    scheduledEndOverride: entry.scheduledEndOverride,
    extraBreakSeconds: extraBreakSeconds,
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

/// The legally-correct base hourly rate for unpaid-overtime purposes:
/// base monthly salary (excluding any fixed overtime allowance) divided by
/// contracted (non-overtime) monthly hours.
///
/// Deliberately distinct from [Workplace.hourlyWage], which for monthly
/// salaries is a blended average (including the fixed overtime allowance)
/// used only for the motivational live counter. Mixing the two would water
/// down the base rate and understate any unpaid overtime — see docs/ISSUES.md.
/// Returns null for hourly workplaces or incomplete monthly setup.
double? baseHourlyWage(Workplace workplace) {
  if (workplace.salaryType != SalaryType.monthly) return null;
  final base = workplace.baseMonthlySalary;
  final hours = workplace.standardMonthlyHours;
  if (base == null || hours == null || hours <= 0) return null;
  return base / hours;
}

/// Unpaid overtime pay for a monthly-salary workplace, given the total
/// overtime already worked in the current pay period (e.g. [monthTotals]
/// from [sumEarnings]). Overtime up to [Workplace.fixedOvertimeHours] is
/// already covered by the fixed overtime allowance; only the excess is
/// unpaid.
///
/// Returns 0 for hourly workplaces, or if no overtime exceeds the fixed
/// allowance.
double unpaidOvertimeYen({
  required Workplace workplace,
  required int periodOvertimeSeconds,
}) {
  final rate = baseHourlyWage(workplace);
  if (rate == null) return 0;
  final fixedSeconds = ((workplace.fixedOvertimeHours ?? 0) * 3600).round();
  final excessSeconds = periodOvertimeSeconds - fixedSeconds;
  if (excessSeconds <= 0) return 0;
  final overtimeRate = rate * (1 + workplace.overtimeRatePercent / 100);
  return overtimeRate * excessSeconds / 3600;
}
