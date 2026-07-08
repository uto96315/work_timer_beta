import '../models/time_entry.dart';
import '../models/workplace.dart';

enum BlockState { done, inProgress, upcoming }

class ScheduleBlock {
  const ScheduleBlock({
    required this.start,
    required this.end,
    required this.isBreak,
    required this.state,
    this.progress = 0,
    this.isOvertime = false,
    this.isExtraBreak = false,
  });

  final DateTime start;
  final DateTime end;
  final bool isBreak;
  final BlockState state;

  /// 0..1, only meaningful when [state] is [BlockState.inProgress].
  final double progress;

  /// True once this block starts at or after the scheduled end ("teiji") —
  /// i.e. it represents unscheduled overtime rather than the planned shift.
  final bool isOvertime;

  /// True for an ad-hoc break the user started/stopped live (see
  /// [TimeEntry.extraBreaks]), as opposed to the workplace's single
  /// scheduled break.
  final bool isExtraBreak;
}

class _BreakWindow {
  const _BreakWindow(this.start, this.end, {required this.isExtra});

  final DateTime start;
  final DateTime end;
  final bool isExtra;
}

DateTime _dayAt(DateTime day, String hhmm) {
  final parts = hhmm.split(':');
  return DateTime(day.year, day.month, day.day, int.parse(parts[0]), int.parse(parts[1]));
}

/// Rounds up to the next clock-hour boundary (e.g. 8:40 -> 9:00), so blocks
/// read as "8:40〜9:00〜10:00" instead of "8:40〜9:40〜10:40".
DateTime _nextHourBoundary(DateTime t) {
  if (t.minute == 0 && t.second == 0) return t.add(const Duration(hours: 1));
  return DateTime(t.year, t.month, t.day, t.hour + 1);
}

/// Splits the workday into blocks aligned to clock-hour boundaries (shorter
/// at the edges of the shift and any breaks), for rendering as a
/// checklist-style daily timeline. Once the actual worked time (or "now",
/// while still clocked in) passes the scheduled end, blocks keep being
/// generated into that overtime — flagged via [ScheduleBlock.isOvertime] —
/// instead of stopping at the original schedule.
List<ScheduleBlock> buildDaySchedule({
  required Workplace workplace,
  required DateTime day,
  required List<TimeEntry> entriesToday,
  required DateTime now,
}) {
  final scheduledStart = _dayAt(day, workplace.startTime);
  final defaultEnd = _dayAt(day, workplace.endTime);

  // Assumes a single continuous shift per day (MVP), which is the common
  // case; a worked block only counts as "done" if it falls within
  // [clockIn, clockOut ?? now].
  final activeEntry = entriesToday.isEmpty ? null : entriesToday.first;
  final clockIn = activeEntry?.clockIn;
  final workedEnd = activeEntry == null ? null : (activeEntry.clockOut ?? now);

  // Editing the clock-in time can shift the whole shift later or earlier;
  // let the user shift the expected end time to match instead of always
  // anchoring to the workplace default.
  final overrideEnd = activeEntry?.scheduledEndOverride;
  final end = (overrideEnd != null && overrideEnd.isAfter(scheduledStart))
      ? overrideEnd
      : defaultEnd;

  // Once actual worked time runs past the scheduled end, keep the timeline
  // going instead of cutting it off at `end`.
  final effectiveEnd = (workedEnd != null && workedEnd.isAfter(end)) ? workedEnd : end;

  // The user can shift today's break start away from the workplace default;
  // fall back to the default if the override no longer fits the shift.
  final defaultBreakStart = _dayAt(day, workplace.breakStartTime);
  final breakDuration = Duration(minutes: workplace.breakMinutes);
  final overrideBreakStart = activeEntry?.breakStartOverride;
  final breakStart =
      overrideBreakStart != null &&
          !overrideBreakStart.isBefore(scheduledStart) &&
          !overrideBreakStart.add(breakDuration).isAfter(end)
      ? overrideBreakStart
      : defaultBreakStart;
  final breakEnd = breakStart.add(breakDuration);

  // The timeline only shows time actually worked (or, before clocking in,
  // the default schedule preview) — time before an actual late clock-in
  // simply isn't part of the timeline, rather than showing as "missed".
  final start = clockIn ?? scheduledStart;

  final breakWindows = <_BreakWindow>[
    if (breakEnd.isAfter(breakStart)) _BreakWindow(breakStart, breakEnd, isExtra: false),
    for (final b in activeEntry?.extraBreaks ?? const <ExtraBreak>[])
      if ((b.end ?? workedEnd ?? b.start).isAfter(b.start))
        _BreakWindow(b.start, b.end ?? workedEnd ?? b.start, isExtra: true),
  ]..sort((a, b) => a.start.compareTo(b.start));

  // Whether the shift is still open, i.e. `workedEnd` is the live "now"
  // rather than a fixed clock-out — a block ending exactly at `workedEnd`
  // is still ongoing in that case, not finished.
  final isShiftOpen = activeEntry != null && activeEntry.clockOut == null;

  BlockState workState(DateTime blockStart, DateTime blockEnd) {
    if (clockIn == null) return BlockState.upcoming;
    final isDone =
        isShiftOpen ? blockEnd.isBefore(workedEnd!) : !blockEnd.isAfter(workedEnd!);
    if (isDone) return BlockState.done;
    if (blockStart.isBefore(workedEnd)) return BlockState.inProgress;
    return BlockState.upcoming;
  }

  BlockState timeState(DateTime blockStart, DateTime blockEnd) {
    if (blockEnd.isBefore(now)) return BlockState.done;
    if (now.isAfter(blockStart)) return BlockState.inProgress;
    return BlockState.upcoming;
  }

  double progressWithin(DateTime blockStart, DateTime blockEnd, DateTime marker) {
    final total = blockEnd.difference(blockStart).inSeconds;
    if (total <= 0) return 1;
    final elapsed = marker.difference(blockStart).inSeconds;
    return (elapsed / total).clamp(0, 1);
  }

  final blocks = <ScheduleBlock>[];
  var cursor = start;
  var breakIdx = 0;
  while (cursor.isBefore(effectiveEnd)) {
    if (breakIdx < breakWindows.length && !breakWindows[breakIdx].start.isAfter(cursor)) {
      final window = breakWindows[breakIdx];
      breakIdx++;
      final windowEnd = window.end.isAfter(effectiveEnd) ? effectiveEnd : window.end;
      if (windowEnd.isAfter(cursor)) {
        final state = timeState(cursor, windowEnd);
        blocks.add(ScheduleBlock(
          start: cursor,
          end: windowEnd,
          isBreak: true,
          isExtraBreak: window.isExtra,
          isOvertime: !cursor.isBefore(end),
          state: state,
          progress: state == BlockState.inProgress ? progressWithin(cursor, windowEnd, now) : 0,
        ));
        cursor = windowEnd;
        continue;
      }
    }

    var blockEnd = _nextHourBoundary(cursor);
    if (breakIdx < breakWindows.length &&
        breakWindows[breakIdx].start.isAfter(cursor) &&
        breakWindows[breakIdx].start.isBefore(blockEnd)) {
      blockEnd = breakWindows[breakIdx].start;
    }
    // Clamp to the scheduled end first so a block never straddles the
    // regular/overtime boundary, then to effectiveEnd for the final block.
    if (cursor.isBefore(end) && blockEnd.isAfter(end)) {
      blockEnd = end;
    } else if (blockEnd.isAfter(effectiveEnd)) {
      blockEnd = effectiveEnd;
    }

    final state = workState(cursor, blockEnd);
    blocks.add(ScheduleBlock(
      start: cursor,
      end: blockEnd,
      isBreak: false,
      isOvertime: !cursor.isBefore(end),
      state: state,
      progress: state == BlockState.inProgress ? progressWithin(cursor, blockEnd, workedEnd!) : 0,
    ));
    cursor = blockEnd;
  }
  return blocks;
}
