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
              onClockOut: _clockOut,
              onUndoClockOut: _undoClockOut,
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
    required this.onClockOut,
    required this.onUndoClockOut,
  });

  final Workplace workplace;
  final void Function(Workplace, List<TimeEntry>) onAutoClockInCheck;
  final Future<void> Function(TimeEntry, Workplace) onEditClockIn;
  final Future<void> Function(String, String) onClockOut;
  final Future<void> Function(String, String) onUndoClockOut;

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

        final scheduledEnd = _timeToday(today, workplace.endTime);
        final untilEnd = scheduledEnd.difference(now);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            _Greeting(workplaceName: workplace.name ?? '仕事タイマー'),
            const SizedBox(height: 16),
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
            const SizedBox(height: 14),
            // Row(
            //   children: [
            //     Icon(Icons.calendar_today_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
            //     const SizedBox(width: 8),
            //     Text(
            //       '今日のスケジュール',
            //       style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 12),
            _DayTimeline(blocks: blocks),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: '今週',
                    value: _yenFormat.format(weekTotals.totalYen),
                    icon: Icons.calendar_view_week_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    label: '今月',
                    value: _yenFormat.format(monthTotals.totalYen),
                    icon: Icons.calendar_month_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _StatTile(
              label: '今月の残業',
              value:
                  '${monthTotals.overtimeSeconds ~/ 3600}時間${(monthTotals.overtimeSeconds % 3600) ~/ 60}分',
              icon: Icons.timelapse_rounded,
            ),
          ],
        );
      },
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.workplaceName});

  final String workplaceName;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateLabel = DateFormat('M月d日(E)', 'ja_JP').format(now);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // Text(
              //   workplaceName,
              //   style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              // ),
            ],
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

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h <= 0) return '$m分';
    return '$h時間$m分';
  }

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
    final overtime = untilEnd.isNegative;
    final statusLabel = !isWorking && hasFinishedToday
        ? 'お疲れ様でした。'
        : !isWorking
        ? '出勤予定：$scheduledStartLabel'
        : overtime
        ? '定時を${_formatDuration(-untilEnd)}過ぎています'
        : '定時まであと${_formatDuration(untilEnd)}';

    final entry = activeEntry;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isOvertime
              ? [const Color(0xFFFF8A5C), const Color(0xFFE85D3D)]
              : [const Color(0xFF19C3A6), const Color(0xFF0D8F84)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color:
                (isOvertime ? const Color(0xFFE85D3D) : const Color(0xFF0D8F84))
                    .withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon(
              //   overtime ? Icons.local_fire_department_rounded : Icons.schedule_rounded,
              //   color: Colors.white,
              //   size: 18,
              // ),
              // const SizedBox(width: 6),
              Text(
                statusLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '今日稼いだお金',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _yenFormat.format(totalYen),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          if (entry != null) ...[
            const SizedBox(height: 20),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
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
            const SizedBox(height: 20),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
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
  const _DayTimeline({required this.blocks});

  final List<ScheduleBlock> blocks;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          children: [
            for (var i = 0; i < blocks.length; i++)
              _BlockRow(block: blocks[i], isLast: i == blocks.length - 1),
          ],
        ),
      ),
    );
  }
}

class _BlockRow extends StatelessWidget {
  const _BlockRow({required this.block, required this.isLast});

  final ScheduleBlock block;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label =
        '${_timeFormat.format(block.start)} 〜 ${_timeFormat.format(block.end)}';
    final isDone = block.state == BlockState.done;
    final isInProgress = block.state == BlockState.inProgress;
    final lineColor = isDone ? scheme.primary : scheme.outlineVariant;

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
                  const SizedBox(height: 6),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone || isInProgress
                          ? scheme.primary
                          : Colors.white,
                      border: Border.all(
                        color: isInProgress ? scheme.primary : lineColor,
                        width: 2,
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
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: block.state == BlockState.upcoming
                              ? scheme.onSurfaceVariant
                              : null,
                          fontWeight: isInProgress ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                    if (block.isBreak)
                      Text(
                        '休憩',
                        style: TextStyle(
                          color: scheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else if (isInProgress)
                      SizedBox(
                        width: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: block.progress,
                            minHeight: 8,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 15, color: scheme.primary),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
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
