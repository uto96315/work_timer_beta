import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/time_entry.dart';
import '../../models/workplace.dart';
import '../../providers/auth_providers.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/time_entry_providers.dart';
import '../../providers/workplace_providers.dart';
import '../../util/earnings_calculator.dart';
import '../../util/schedule_blocks.dart';
import '../../widgets/time_field.dart';

final _yenFormat = NumberFormat.currency(
  locale: 'ja_JP',
  symbol: '¥',
  decimalDigits: 0,
);
final _timeFormat = DateFormat('HH:mm');

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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _autoClockInTriggered = false;

  void _maybeAutoClockIn(Workplace workplace, List<TimeEntry> todayEntries) {
    if (_autoClockInTriggered || todayEntries.isNotEmpty) return;
    final now = DateTime.now();
    final scheduledStart = _timeToday(now, workplace.startTime);
    if (now.isBefore(scheduledStart)) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    _autoClockInTriggered = true;
    ref
        .read(timeEntryRepositoryProvider)
        .autoClockIn(uid, workplace.id, scheduledStart);
  }

  Future<void> _editClockIn(TimeEntry entry, Workplace workplace) async {
    final currentTime = TimeOfDay(
      hour: entry.clockIn.hour,
      minute: entry.clockIn.minute,
    );
    final picked = await showCupertinoTimePicker(context, currentTime);
    if (picked == null) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final newClockIn = DateTime(
      entry.clockIn.year,
      entry.clockIn.month,
      entry.clockIn.day,
      picked.hour,
      picked.minute,
    );
    await ref
        .read(timeEntryRepositoryProvider)
        .correct(uid, workplace.id, entry, newClockIn: newClockIn);

    // Only ask about the end time when the start actually moved — otherwise
    // this fires on every no-op confirmation of the same time.
    if (newClockIn.hour == entry.clockIn.hour &&
        newClockIn.minute == entry.clockIn.minute) {
      return;
    }
    if (!mounted) return;
    final shouldShiftEnd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退勤予定の確認'),
        content: const Text('出勤時間を変更しました。退勤予定時間も変更しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('そのまま'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('変更する'),
          ),
        ],
      ),
    );
    if (shouldShiftEnd != true) return;
    if (!mounted) return;

    final defaultEnd = _timeToday(newClockIn, workplace.endTime);
    final currentEnd = entry.scheduledEndOverride ?? defaultEnd;
    final currentEndTime = TimeOfDay(
      hour: currentEnd.hour,
      minute: currentEnd.minute,
    );
    final pickedEnd = await showCupertinoTimePicker(context, currentEndTime);
    if (pickedEnd == null) return;
    final newEnd = DateTime(
      newClockIn.year,
      newClockIn.month,
      newClockIn.day,
      pickedEnd.hour,
      pickedEnd.minute,
    );
    final isDefaultEnd =
        pickedEnd.hour == defaultEnd.hour && pickedEnd.minute == defaultEnd.minute;
    await ref
        .read(timeEntryRepositoryProvider)
        .setScheduledEnd(
          uid,
          workplace.id,
          entry.id,
          isDefaultEnd ? null : newEnd,
        );
  }

  Future<void> _editBreakStart(
    TimeEntry entry,
    Workplace workplace,
    DateTime day,
  ) async {
    final defaultBreakStart = _timeToday(day, workplace.breakStartTime);
    final current = entry.breakStartOverride ?? defaultBreakStart;
    final currentTime = TimeOfDay(hour: current.hour, minute: current.minute);
    final picked = await showCupertinoTimePicker(context, currentTime);
    if (picked == null) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final newBreakStart = DateTime(
      day.year,
      day.month,
      day.day,
      picked.hour,
      picked.minute,
    );
    final isDefault =
        newBreakStart.hour == defaultBreakStart.hour &&
        newBreakStart.minute == defaultBreakStart.minute;
    await ref
        .read(timeEntryRepositoryProvider)
        .setBreakStart(
          uid,
          workplace.id,
          entry.id,
          isDefault ? null : newBreakStart,
        );
  }

  Future<void> _clockOut(String workplaceId, String entryId) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await ref
        .read(timeEntryRepositoryProvider)
        .clockOut(uid, workplaceId, entryId);
  }

  Future<void> _undoClockOut(String workplaceId, String entryId) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await ref
        .read(timeEntryRepositoryProvider)
        .undoClockOut(uid, workplaceId, entryId);
  }

  Future<void> _startExtraBreak(TimeEntry entry, String workplaceId) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await ref
        .read(timeEntryRepositoryProvider)
        .startExtraBreak(uid, workplaceId, entry);
  }

  Future<void> _endExtraBreak(TimeEntry entry, String workplaceId) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await ref
        .read(timeEntryRepositoryProvider)
        .endExtraBreak(uid, workplaceId, entry);
  }

  @override
  Widget build(BuildContext context) {
    final workplaceAsync = ref.watch(primaryWorkplaceProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: workplaceAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('エラー: $e')),
          data: (workplace) {
            if (workplace == null) {
              return const _NoWorkplaceMessage();
            }
            return _HomeContent(
              workplace: workplace,
              onAutoClockInCheck: _maybeAutoClockIn,
              onEditClockIn: _editClockIn,
              onEditBreakStart: _editBreakStart,
              onClockOut: _clockOut,
              onUndoClockOut: _undoClockOut,
              onStartExtraBreak: _startExtraBreak,
              onEndExtraBreak: _endExtraBreak,
            );
          },
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({
    required this.workplace,
    required this.onAutoClockInCheck,
    required this.onEditClockIn,
    required this.onEditBreakStart,
    required this.onClockOut,
    required this.onUndoClockOut,
    required this.onStartExtraBreak,
    required this.onEndExtraBreak,
  });

  final Workplace workplace;
  final void Function(Workplace, List<TimeEntry>) onAutoClockInCheck;
  final Future<void> Function(TimeEntry, Workplace) onEditClockIn;
  final Future<void> Function(TimeEntry, Workplace, DateTime) onEditBreakStart;
  final Future<void> Function(String, String) onClockOut;
  final Future<void> Function(String, String) onUndoClockOut;
  final Future<void> Function(TimeEntry, String) onStartExtraBreak;
  final Future<void> Function(TimeEntry, String) onEndExtraBreak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(secondTickerProvider).value ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayEntriesAsync = ref.watch(entriesForDateProvider(today));

    return todayEntriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
      data: (todayEntries) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onAutoClockInCheck(workplace, todayEntries);
        });

        final activeEntry = todayEntries
            .where((e) => e.clockOut == null)
            .firstOrNull;
        // Matches buildDaySchedule's single-shift-per-day assumption: the
        // entry a break-start override attaches to.
        final todayEntry = todayEntries.firstOrNull;
        TimeEntry? lastFinishedEntry;
        for (final e in todayEntries) {
          if (e.clockOut == null) continue;
          if (lastFinishedEntry == null ||
              e.clockOut!.isAfter(lastFinishedEntry.clockOut!)) {
            lastFinishedEntry = e;
          }
        }
        final blocks = buildDaySchedule(
          workplace: workplace,
          day: today,
          entriesToday: todayEntries,
          now: now,
        );
        final todayTotals = sumEarnings(
          workplace: workplace,
          entries: todayEntries,
          now: now,
        );

        final weekday = today.weekday;
        final weekStart = today.subtract(Duration(days: weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        final weekEntries =
            ref.watch(entriesInRangeProvider(weekStart, weekEnd)).value ??
            const [];
        final weekTotals = sumEarnings(
          workplace: workplace,
          entries: weekEntries,
          now: now,
        );

        final monthStart = DateTime(today.year, today.month, 1);
        final monthEnd = DateTime(today.year, today.month + 1, 1);
        final monthEntries =
            ref.watch(entriesInRangeProvider(monthStart, monthEnd)).value ??
            const [];
        final monthTotals = sumEarnings(
          workplace: workplace,
          entries: monthEntries,
          now: now,
        );

        final scheduledEnd =
            todayEntry?.scheduledEndOverride ?? _timeToday(today, workplace.endTime);
        final untilEnd = scheduledEnd.difference(now);

        final monthOvertimeHours = monthTotals.overtimeSeconds / 3600;
        // 過労死ラインの目安（複数月平均80時間）と、36協定の一般的な上限
        // （月45時間）を基準に色分けし、負担が増えていることに気づけるようにする。
        final Color? overtimeAccentColor = monthOvertimeHours >= 80
            ? Colors.red.shade600
            : monthOvertimeHours >= 45
            ? Colors.orange.shade800
            : null;
        final overtimeCaption = monthOvertimeHours >= 80
            ? '過労死ラインの目安を超えています'
            : monthOvertimeHours >= 45
            ? '36協定の上限目安（月45時間）に近づいています'
            : null;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            const _Greeting(),
            const SizedBox(height: 10),
            _EarningsHeroCard(
              totalYen: todayTotals.totalYen,
              isOvertime: todayTotals.overtimeSeconds > 0,
              untilEnd: untilEnd,
              isWorking: activeEntry != null,
              hasFinishedToday:
                  activeEntry == null && lastFinishedEntry != null,
              scheduledStartLabel: workplace.startTime,
              activeEntry: activeEntry,
              onEditClockIn: activeEntry == null
                  ? null
                  : () => onEditClockIn(activeEntry, workplace),
              onClockOut: activeEntry == null
                  ? null
                  : () => onClockOut(workplace.id, activeEntry.id),
              onUndoClockOut: lastFinishedEntry == null
                  ? null
                  : () => onUndoClockOut(workplace.id, lastFinishedEntry!.id),
            ),
            const SizedBox(height: 10),
            _DayTimeline(
              blocks: blocks,
              onEditBreakStart: todayEntry == null
                  ? null
                  : () => onEditBreakStart(todayEntry, workplace, today),
              onStartExtraBreak: activeEntry == null
                  ? null
                  : () => onStartExtraBreak(activeEntry, workplace.id),
              onEndExtraBreak: activeEntry == null
                  ? null
                  : () => onEndExtraBreak(activeEntry, workplace.id),
              isOnExtraBreak: activeEntry != null &&
                  activeEntry.extraBreaks.isNotEmpty &&
                  activeEntry.extraBreaks.last.end == null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: '今週',
                    value: _yenFormat.format(weekTotals.totalYen),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    label: '今月',
                    value: _yenFormat.format(monthTotals.totalYen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _StatTile(
              label: '今月の残業',
              value:
                  '${monthTotals.overtimeSeconds ~/ 3600}時間${(monthTotals.overtimeSeconds % 3600) ~/ 60}分',
              icon: null,
              accentColor: overtimeAccentColor,
              caption: overtimeCaption,
            ),
          ],
        );
      },
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateLabel = DateFormat('M月d日(E)', 'ja_JP').format(now);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              dateLabel,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EarningsHeroCard extends StatelessWidget {
  const _EarningsHeroCard({
    required this.totalYen,
    required this.isOvertime,
    required this.untilEnd,
    required this.isWorking,
    required this.hasFinishedToday,
    required this.scheduledStartLabel,
    required this.activeEntry,
    required this.onEditClockIn,
    required this.onClockOut,
    required this.onUndoClockOut,
  });

  final double totalYen;
  final bool isOvertime;
  final Duration untilEnd;
  final bool isWorking;
  final bool hasFinishedToday;
  final String scheduledStartLabel;
  final TimeEntry? activeEntry;
  final VoidCallback? onEditClockIn;
  final VoidCallback? onClockOut;
  final VoidCallback? onUndoClockOut;

  Future<void> _handleClockOutPressed(BuildContext context) async {
    final overtime = untilEnd.isNegative;
    if (!overtime) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('退勤の確認'),
          content: const Text('退勤時間前ですが退勤してよろしいでしょうか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('退勤する'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    onClockOut?.call();
  }

  @override
  Widget build(BuildContext context) {
    // While working, the remaining/overtime duration is already shown by the
    // day timeline's progress header, so this label only covers the states
    // that timeline doesn't: before clock-in and after clock-out.
    final statusLabel = !isWorking && hasFinishedToday
        ? 'お疲れ様でした。'
        : !isWorking
        ? '出勤予定：$scheduledStartLabel'
        : null;

    final entry = activeEntry;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isOvertime
              ? [const Color(0xFFFF8A5C), const Color(0xFFE85D3D)]
              : [const Color(0xFF19C3A6), const Color(0xFF0D8F84)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                (isOvertime ? const Color(0xFFE85D3D) : const Color(0xFF0D8F84))
                    .withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (statusLabel != null) ...[
            Text(
              statusLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            '今日稼いだお金',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _yenFormat.format(totalYen),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          if (entry != null) ...[
            const SizedBox(height: 10),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 10),
            Row(
              children: [
                // const Icon(Icons.login_rounded, size: 16, color: Colors.white),
                // const SizedBox(width: 6),
                Text(
                  '出勤 ${_timeFormat.format(entry.clockIn)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (entry.isAutoClockedIn) ...[
                  // const SizedBox(width: 4),
                  const Text(
                    '（自動）',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
                IconButton(
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  onPressed: onEditClockIn,
                  visualDensity: VisualDensity.compact,
                ),
                Spacer(),
                FilledButton(
                  onPressed: onClockOut == null
                      ? null
                      : () => _handleClockOutPressed(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0D8F84),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('退勤する'),
                ),
              ],
            ),
          ],
          if (entry == null &&
              !isWorking &&
              hasFinishedToday &&
              onUndoClockOut != null) ...[
            const SizedBox(height: 10),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onUndoClockOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70),
                  shape: const StadiumBorder(),
                ),
                child: const Text('退勤を取り消す'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayTimeline extends StatelessWidget {
  const _DayTimeline({
    required this.blocks,
    this.onEditBreakStart,
    this.onStartExtraBreak,
    this.onEndExtraBreak,
    this.isOnExtraBreak = false,
  });

  final List<ScheduleBlock> blocks;
  final VoidCallback? onEditBreakStart;
  final VoidCallback? onStartExtraBreak;
  final VoidCallback? onEndExtraBreak;
  final bool isOnExtraBreak;

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      // No schedule blocks left to show (e.g. an extremely late clock-in
      // pushed the start past the scheduled end) — still offer a way to log
      // a break instead of hiding the whole card.
      if (onEditBreakStart == null && onStartExtraBreak == null) {
        return const SizedBox.shrink();
      }
      return Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (onEditBreakStart != null)
                _AddBreakButton(onPressed: onEditBreakStart!),
              if (onStartExtraBreak != null) ...[
                if (onEditBreakStart != null) const SizedBox(height: 8),
                _ExtraBreakButton(
                  isOnBreak: isOnExtraBreak,
                  onPressed: isOnExtraBreak ? onEndExtraBreak : onStartExtraBreak,
                ),
              ],
            ],
          ),
        ),
      );
    }

    var totalSeconds = 0;
    var elapsedSeconds = 0;
    var overtimeElapsedSeconds = 0;
    var hasOvertimeBlock = false;
    for (final block in blocks) {
      final blockSeconds = block.end.difference(block.start).inSeconds;
      totalSeconds += blockSeconds;
      var doneSeconds = 0;
      if (block.state == BlockState.done) {
        doneSeconds = blockSeconds;
      } else if (block.state == BlockState.inProgress) {
        doneSeconds = (blockSeconds * block.progress).round();
      }
      elapsedSeconds += doneSeconds;
      if (block.isOvertime) {
        hasOvertimeBlock = true;
        overtimeElapsedSeconds += doneSeconds;
      }
    }
    final overallProgress = totalSeconds == 0
        ? 0.0
        : (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
    final remaining = Duration(
      seconds: (totalSeconds - elapsedSeconds).clamp(0, totalSeconds),
    );
    final hasBreak = blocks.any((b) => b.isBreak && !b.isExtraBreak);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _TimelineProgressHeader(
            progress: overallProgress,
            remaining: remaining,
            isOvertime: hasOvertimeBlock,
            overtimeElapsed: Duration(seconds: overtimeElapsedSeconds),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Column(
              children: [
                for (var i = 0; i < blocks.length; i++)
                  _BlockRow(
                    block: blocks[i],
                    isLast: i == blocks.length - 1,
                    onEditBreakStart: blocks[i].isBreak && !blocks[i].isExtraBreak
                        ? onEditBreakStart
                        : null,
                  ),
              ],
            ),
          ),
          // Late clock-ins can push the default break time out of the
          // timeline entirely (schedule_blocks only shows a break at or
          // after the actual clock-in), so surface a way to add one back.
          if (!hasBreak && onEditBreakStart != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 16, 10),
              child: _AddBreakButton(onPressed: onEditBreakStart!),
            ),
          // Always available while clocked in, so an ad-hoc break (most
          // commonly taken during overtime) can be logged at any time —
          // not just when the scheduled break is missing.
          if (onStartExtraBreak != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 16, 10),
              child: _ExtraBreakButton(
                isOnBreak: isOnExtraBreak,
                onPressed: isOnExtraBreak ? onEndExtraBreak : onStartExtraBreak,
              ),
            ),
        ],
      ),
    );
  }
}

class _AddBreakButton extends StatelessWidget {
  const _AddBreakButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('休憩を追加'),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

/// Starts/stops an ad-hoc break on top of the scheduled one — the primary
/// way to log a break taken during overtime, when there's no more schedule
/// left to attach one to.
class _ExtraBreakButton extends StatelessWidget {
  const _ExtraBreakButton({required this.isOnBreak, required this.onPressed});

  final bool isOnBreak;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (isOnBreak) {
      return Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.play_arrow_rounded, size: 18),
          label: const Text('休憩を終える'),
          style: FilledButton.styleFrom(
            backgroundColor: scheme.tertiary,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.free_breakfast_outlined, size: 18),
        label: const Text('休憩に入る'),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class _TimelineProgressHeader extends StatelessWidget {
  const _TimelineProgressHeader({
    required this.progress,
    required this.remaining,
    required this.isOvertime,
    required this.overtimeElapsed,
  });

  final double progress;
  final Duration remaining;
  final bool isOvertime;
  final Duration overtimeElapsed;

  String get _remainingLabel {
    if (progress >= 1) return '本日のスケジュール終了';
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    if (h <= 0) return 'あと$m分';
    return 'あと$h時間$m分';
  }

  String get _overtimeLabel {
    final h = overtimeElapsed.inHours;
    final m = overtimeElapsed.inMinutes % 60;
    return h <= 0 ? '残業 $m分' : '残業 $h時間$m分';
  }

  @override
  Widget build(BuildContext context) {
    if (isOvertime) {
      return Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF8A5C), Color(0xFFE85D3D)],
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            const Text(
              '残業中',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              _overtimeLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    final percent = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF19C3A6), Color(0xFF0D8F84)],
        ),
      ),
      child: Row(
        children: [
          Text(
            '$percent%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _remainingLabel,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockRow extends StatelessWidget {
  const _BlockRow({
    required this.block,
    required this.isLast,
    this.onEditBreakStart,
  });

  final ScheduleBlock block;
  final bool isLast;
  final VoidCallback? onEditBreakStart;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label =
        '${_timeFormat.format(block.start)} 〜 ${_timeFormat.format(block.end)}';
    final isDone = block.state == BlockState.done;
    final isInProgress = block.state == BlockState.inProgress;
    final overtimeColor = Colors.orange.shade800;
    final accentColor = block.isBreak
        ? (block.isExtraBreak ? Colors.deepOrange.shade400 : scheme.tertiary)
        : (block.isOvertime ? overtimeColor : scheme.primary);
    final lineColor = isDone
        ? accentColor.withValues(alpha: 0.5)
        : scheme.outlineVariant;

    const rowHeight = 22.0;

    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 20,
              child: Column(
                children: [
                  SizedBox(
                    height: rowHeight,
                    child: Center(
                      child: _StateDot(
                        isDone: isDone,
                        isInProgress: isInProgress,
                        color: accentColor,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(child: Container(width: 2, color: lineColor)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SizedBox(
                  height: rowHeight,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isDone
                                ? scheme.onSurfaceVariant.withValues(alpha: 0.6)
                                : block.state == BlockState.upcoming
                                ? scheme.onSurfaceVariant
                                : null,
                            fontWeight: isInProgress ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                      if (block.isOvertime && !block.isBreak) ...[
                        _RowBadge(
                          label: '残業',
                          color: isDone
                              ? overtimeColor.withValues(alpha: 0.6)
                              : overtimeColor,
                        ),
                      ],
                      if (block.isBreak) ...[
                        _RowBadge(
                          label: '休憩',
                          color: isDone
                              ? accentColor.withValues(alpha: 0.6)
                              : accentColor,
                        ),
                        if (onEditBreakStart != null)
                          IconButton(
                            icon: Icon(
                              Icons.edit_rounded,
                              size: 16,
                              color: scheme.onSurfaceVariant,
                            ),
                            onPressed: onEditBreakStart,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowBadge extends StatelessWidget {
  const _RowBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// A checkmark-slot dot that pulses outward while its block is in progress,
/// reading as "this is happening live right now".
class _StateDot extends StatefulWidget {
  const _StateDot({
    required this.isDone,
    required this.isInProgress,
    required this.color,
  });

  final bool isDone;
  final bool isInProgress;
  final Color color;

  @override
  State<_StateDot> createState() => _StateDotState();
}

class _StateDotState extends State<_StateDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isInProgress) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _StateDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isInProgress && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isInProgress && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDone) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: 0.55),
        ),
        child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
      );
    }
    if (!widget.isInProgress) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 2,
          ),
        ),
      );
    }
    return SizedBox(
      width: 18,
      height: 18,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.6 + t,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.color, width: 2),
                    ),
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    this.icon,
    this.accentColor,
    this.caption,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? accentColor;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = accentColor ?? scheme.primary;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 15, color: accent),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: 2),
              Text(
                caption!,
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoWorkplaceMessage extends StatelessWidget {
  const _NoWorkplaceMessage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'まだ勤務先が設定されていません。\n設定タブから時給や勤務時間を登録してください。',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
