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

final _yenFormat = NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0);
final _timeFormat = DateFormat('HH:mm');

DateTime _timeToday(DateTime day, String hhmm) {
  final parts = hhmm.split(':');
  return DateTime(day.year, day.month, day.day, int.parse(parts[0]), int.parse(parts[1]));
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
    ref.read(timeEntryRepositoryProvider).autoClockIn(uid, workplace.id, scheduledStart);
  }

  Future<void> _editClockIn(TimeEntry entry, Workplace workplace) async {
    final currentTime = TimeOfDay(hour: entry.clockIn.hour, minute: entry.clockIn.minute);
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
    await ref.read(timeEntryRepositoryProvider).clockOut(uid, workplaceId, entryId);
  }

  @override
  Widget build(BuildContext context) {
    final workplaceAsync = ref.watch(primaryWorkplaceProvider);

    return Scaffold(
      body: SafeArea(
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
  });

  final Workplace workplace;
  final void Function(Workplace, List<TimeEntry>) onAutoClockInCheck;
  final Future<void> Function(TimeEntry, Workplace) onEditClockIn;
  final Future<void> Function(String, String) onClockOut;

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

        final activeEntry = todayEntries.where((e) => e.clockOut == null).firstOrNull;
        final blocks = buildDaySchedule(
          workplace: workplace,
          day: today,
          entriesToday: todayEntries,
          now: now,
        );
        final todayTotals = sumEarnings(workplace: workplace, entries: todayEntries, now: now);

        final weekday = today.weekday;
        final weekStart = today.subtract(Duration(days: weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        final weekEntries = ref.watch(entriesInRangeProvider(weekStart, weekEnd)).value ?? const [];
        final weekTotals = sumEarnings(workplace: workplace, entries: weekEntries, now: now);

        final monthStart = DateTime(today.year, today.month, 1);
        final monthEnd = DateTime(today.year, today.month + 1, 1);
        final monthEntries = ref.watch(entriesInRangeProvider(monthStart, monthEnd)).value ?? const [];
        final monthTotals = sumEarnings(workplace: workplace, entries: monthEntries, now: now);

        final scheduledEnd = _timeToday(today, workplace.endTime);
        final untilEnd = scheduledEnd.difference(now);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _StatusBanner(untilEnd: untilEnd, isWorking: activeEntry != null),
            const SizedBox(height: 20),
            _EarningsHero(totalYen: todayTotals.totalYen, isOvertime: todayTotals.overtimeSeconds > 0),
            const SizedBox(height: 12),
            if (activeEntry != null)
              _ActiveEntryRow(
                entry: activeEntry,
                isAuto: activeEntry.isAutoClockedIn,
                onEdit: () => onEditClockIn(activeEntry, workplace),
                onClockOut: () => onClockOut(workplace.id, activeEntry.id),
              ),
            const SizedBox(height: 24),
            Text('今日のスケジュール', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _DayTimeline(blocks: blocks),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _StatTile(label: '今週', value: _yenFormat.format(weekTotals.totalYen))),
                const SizedBox(width: 12),
                Expanded(child: _StatTile(label: '今月', value: _yenFormat.format(monthTotals.totalYen))),
              ],
            ),
            const SizedBox(height: 12),
            _StatTile(
              label: '今月の残業',
              value: '${monthTotals.overtimeSeconds ~/ 3600}時間${(monthTotals.overtimeSeconds % 3600) ~/ 60}分',
              icon: Icons.timelapse,
            ),
          ],
        );
      },
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.untilEnd, required this.isWorking});

  final Duration untilEnd;
  final bool isWorking;

  @override
  Widget build(BuildContext context) {
    final isOvertime = untilEnd.isNegative;
    final label = !isWorking
        ? '本日の勤務前です'
        : isOvertime
            ? '定時を${_formatDuration(-untilEnd)}過ぎています'
            : '定時まであと${_formatDuration(untilEnd)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOvertime
            ? Colors.deepOrange.withValues(alpha: 0.12)
            : Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            isOvertime ? Icons.local_fire_department : Icons.schedule,
            color: isOvertime ? Colors.deepOrange : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h <= 0) return '$m分';
    return '$h時間$m分';
  }
}

class _EarningsHero extends StatelessWidget {
  const _EarningsHero({required this.totalYen, required this.isOvertime});

  final double totalYen;
  final bool isOvertime;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('今日稼いだお金', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          _yenFormat.format(totalYen),
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isOvertime ? Colors.deepOrange : Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }
}

class _ActiveEntryRow extends StatelessWidget {
  const _ActiveEntryRow({
    required this.entry,
    required this.isAuto,
    required this.onEdit,
    required this.onClockOut,
  });

  final TimeEntry entry;
  final bool isAuto;
  final VoidCallback onEdit;
  final VoidCallback onClockOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.login, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text('出勤 ${_timeFormat.format(entry.clockIn)}'),
        if (isAuto) ...[
          const SizedBox(width: 4),
          Text('（自動）', style: Theme.of(context).textTheme.bodySmall),
        ],
        IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: onEdit),
        const SizedBox(width: 12),
        OutlinedButton(onPressed: onClockOut, child: const Text('退勤する')),
      ],
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: blocks.map((b) => _BlockRow(block: b)).toList(),
        ),
      ),
    );
  }
}

class _BlockRow extends StatelessWidget {
  const _BlockRow({required this.block});

  final ScheduleBlock block;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = '${_timeFormat.format(block.start)} 〜 ${_timeFormat.format(block.end)}';
    final isDone = block.state == BlockState.done;
    final isInProgress = block.state == BlockState.inProgress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: isDone
                ? Icon(Icons.check_circle, color: scheme.primary, size: 20)
                : isInProgress
                    ? null
                    : Icon(Icons.circle_outlined, color: scheme.outlineVariant, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: block.state == BlockState.upcoming ? scheme.onSurfaceVariant : null,
                fontWeight: isInProgress ? FontWeight.bold : null,
              ),
            ),
          ),
          if (block.isBreak)
            Text('休憩', style: TextStyle(color: scheme.tertiary, fontWeight: FontWeight.bold))
          else if (isInProgress)
            SizedBox(
              width: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: block.progress, minHeight: 8),
              ),
            ),
        ],
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
                  Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                ],
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
