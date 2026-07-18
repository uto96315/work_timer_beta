import 'package:flutter/material.dart';

import '../models/time_entry.dart';
import '../models/workplace.dart';
import 'earnings_calculator.dart';
import 'schedule_blocks.dart';

/// Everything the home screen needs to render a day, computed once and
/// shared between the two home screen designs — keeps the overtime/holiday/
/// earnings rules in one place instead of duplicated per design.
class HomeSnapshot {
  const HomeSnapshot({
    required this.blocks,
    required this.activeEntry,
    required this.todayEntry,
    required this.lastFinishedEntry,
    required this.untilEnd,
    required this.scheduledEnd,
    required this.shouldFreezeOvertime,
    required this.todayTotals,
    required this.weekTotals,
    required this.monthTotals,
    required this.isRestDay,
    required this.overtimeAccentColor,
    required this.overtimeCaption,
  });

  final List<ScheduleBlock> blocks;
  final TimeEntry? activeEntry;
  final TimeEntry? todayEntry;
  final TimeEntry? lastFinishedEntry;
  final Duration untilEnd;
  final DateTime scheduledEnd;
  final bool shouldFreezeOvertime;
  final EarningsTotals todayTotals;
  final EarningsTotals weekTotals;
  final EarningsTotals monthTotals;
  final bool isRestDay;
  final Color? overtimeAccentColor;
  final String? overtimeCaption;
}

HomeSnapshot buildHomeSnapshot({
  required Workplace workplace,
  required List<TimeEntry> todayEntries,
  required List<TimeEntry> weekEntries,
  required List<TimeEntry> monthEntries,
  required DateTime today,
  required DateTime now,
  required bool autoOvertimeEnabled,
  required Set<String> overtimeApprovedIds,
}) {
  final activeEntry = todayEntries.where((e) => e.clockOut == null).firstOrNull;
  // Matches buildDaySchedule's single-shift-per-day assumption: the entry a
  // break-start override attaches to.
  final todayEntry = todayEntries.firstOrNull;
  TimeEntry? lastFinishedEntry;
  for (final e in todayEntries) {
    if (e.clockOut == null) continue;
    if (lastFinishedEntry == null || e.clockOut!.isAfter(lastFinishedEntry.clockOut!)) {
      lastFinishedEntry = e;
    }
  }

  final scheduledEnd =
      todayEntry?.scheduledEndOverride ?? _timeToday(today, workplace.endTime);
  final untilEnd = scheduledEnd.difference(now);
  final isPastScheduledEnd = activeEntry != null && now.isAfter(scheduledEnd);
  final overtimeApproved =
      activeEntry != null && overtimeApprovedIds.contains(activeEntry.id);
  // Freezes the live count at the scheduled end instead of racking up
  // overtime automatically, until the user opts in via the prompt card below
  // (or the setting is enabled).
  final shouldFreezeOvertime =
      isPastScheduledEnd && !autoOvertimeEnabled && !overtimeApproved;
  final earningsNow = shouldFreezeOvertime ? scheduledEnd : now;

  final blocks = buildDaySchedule(
    workplace: workplace,
    day: today,
    entriesToday: todayEntries,
    now: earningsNow,
  );
  final todayTotals = sumEarnings(
    workplace: workplace,
    entries: todayEntries,
    now: earningsNow,
  );
  final weekTotals = sumEarnings(
    workplace: workplace,
    entries: weekEntries,
    now: earningsNow,
  );
  final monthTotals = sumEarnings(
    workplace: workplace,
    entries: monthEntries,
    now: earningsNow,
  );

  final isHoliday = workplace.holidayWeekdays.contains(today.weekday);
  final isRestDay = isHoliday && todayEntries.isEmpty;

  final monthOvertimeHours = monthTotals.overtimeSeconds / 3600;
  // 過労死ラインの目安（複数月平均80時間）と、36協定の一般的な上限（月45時間）を
  // 基準に色分けし、負担が増えていることに気づけるようにする。
  final overtimeAccentColor = monthOvertimeHours >= 80
      ? Colors.red.shade600
      : monthOvertimeHours >= 45
      ? Colors.orange.shade800
      : null;
  final overtimeCaption = monthOvertimeHours >= 80
      ? '過労死ラインの目安を超えています'
      : monthOvertimeHours >= 45
      ? '36協定の上限目安（月45時間）に近づいています'
      : null;

  return HomeSnapshot(
    blocks: blocks,
    activeEntry: activeEntry,
    todayEntry: todayEntry,
    lastFinishedEntry: lastFinishedEntry,
    untilEnd: untilEnd,
    scheduledEnd: scheduledEnd,
    shouldFreezeOvertime: shouldFreezeOvertime,
    todayTotals: todayTotals,
    weekTotals: weekTotals,
    monthTotals: monthTotals,
    isRestDay: isRestDay,
    overtimeAccentColor: overtimeAccentColor,
    overtimeCaption: overtimeCaption,
  );
}

DateTime _timeToday(DateTime day, String hhmm) {
  final parts = hhmm.split(':');
  return DateTime(
    day.year,
    day.month,
    day.day,
    int.parse(parts[0]),
    int.parse(parts[1]),
  );
}
