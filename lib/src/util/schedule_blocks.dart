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
  });

  final DateTime start;
  final DateTime end;
  final bool isBreak;
  final BlockState state;

  /// 0..1, only meaningful when [state] is [BlockState.inProgress].
  final double progress;
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
/// at the edges of the shift and the break), for rendering as a
/// checklist-style daily timeline.
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

  BlockState workState(DateTime blockStart, DateTime blockEnd) {
    if (clockIn == null) return BlockState.upcoming;
    if (!blockEnd.isAfter(workedEnd!)) return BlockState.done;
    if (blockStart.isBefore(workedEnd)) return BlockState.inProgress;
    return BlockState.upcoming;
  }

  BlockState timeState(DateTime blockStart, DateTime blockEnd) {
    if (!now.isBefore(blockEnd)) return BlockState.done;
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
  while (cursor.isBefore(end)) {
    if (cursor == breakStart) {
      final state = timeState(breakStart, breakEnd);
      blocks.add(ScheduleBlock(
        start: breakStart,
        end: breakEnd,
        isBreak: true,
        state: state,
        progress: state == BlockState.inProgress ? progressWithin(breakStart, breakEnd, now) : 0,
      ));
      cursor = breakEnd;
      continue;
    }

    var blockEnd = _nextHourBoundary(cursor);
    if (breakStart.isAfter(cursor) && breakStart.isBefore(blockEnd)) {
      blockEnd = breakStart;
    }
    if (blockEnd.isAfter(end)) blockEnd = end;

    final state = workState(cursor, blockEnd);
    blocks.add(ScheduleBlock(
      start: cursor,
      end: blockEnd,
      isBreak: false,
      state: state,
      progress: state == BlockState.inProgress ? progressWithin(cursor, blockEnd, workedEnd!) : 0,
    ));
    cursor = blockEnd;
  }
  return blocks;
}
