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

/// Splits the workday into hour-sized blocks (shorter at the edges of the
/// break), for rendering as a checklist-style daily timeline.
List<ScheduleBlock> buildDaySchedule({
  required Workplace workplace,
  required DateTime day,
  required List<TimeEntry> entriesToday,
  required DateTime now,
}) {
  final start = _dayAt(day, workplace.startTime);
  final end = _dayAt(day, workplace.endTime);
  final breakStart = _dayAt(day, workplace.breakStartTime);
  final breakEnd = breakStart.add(Duration(minutes: workplace.breakMinutes));

  // Assumes a single continuous shift per day (MVP), which is the common
  // case; a worked block only counts as "done" if it falls within
  // [clockIn, clockOut ?? now].
  final activeEntry = entriesToday.isEmpty ? null : entriesToday.first;
  final clockIn = activeEntry?.clockIn;
  final workedEnd = activeEntry == null ? null : (activeEntry.clockOut ?? now);

  BlockState workState(DateTime blockStart, DateTime blockEnd) {
    if (clockIn == null || workedEnd == null || blockStart.isBefore(clockIn)) {
      return BlockState.upcoming;
    }
    if (!blockEnd.isAfter(workedEnd)) return BlockState.done;
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

    var blockEnd = cursor.add(const Duration(hours: 1));
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
