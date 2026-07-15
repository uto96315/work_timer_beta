import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/salary_type.dart';
import '../../models/time_entry.dart';
import '../../models/workplace.dart';
import '../../providers/auth_providers.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/time_entry_providers.dart';
import '../../providers/user_profile_providers.dart';
import '../../providers/workplace_providers.dart';
import '../../util/earnings_calculator.dart';
import '../../util/pet_stage.dart';
import '../../util/schedule_blocks.dart';
import '../../widgets/dog_track.dart';
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
    if (workplace.holidayWeekdays.contains(now.weekday)) return;
    final scheduledStart = _timeToday(now, workplace.startTime);
    if (now.isBefore(scheduledStart)) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    _autoClockInTriggered = true;
    ref
        .read(timeEntryRepositoryProvider)
        .autoClockIn(uid, workplace.id, scheduledStart, workplace.breakMinutes);
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
        pickedEnd.hour == defaultEnd.hour &&
        pickedEnd.minute == defaultEnd.minute;
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

  Future<void> _clockOut(TimeEntry entry, Workplace workplace) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await ref
        .read(timeEntryRepositoryProvider)
        .clockOut(uid, workplace.id, entry.id);
    final foodEarned = _foodForEntry(entry, workplace);
    await ref.read(userProfileRepositoryProvider).addFood(uid, foodEarned);
  }

  Future<void> _undoClockOut(TimeEntry entry, Workplace workplace) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await ref
        .read(timeEntryRepositoryProvider)
        .undoClockOut(uid, workplace.id, entry.id);
    final foodEarned = _foodForEntry(entry, workplace);
    await ref.read(userProfileRepositoryProvider).addFood(uid, -foodEarned);
  }

  /// 1 food per full hour actually worked (excluding breaks), matching how
  /// the dog track's food stops are laid out.
  int _foodForEntry(TimeEntry entry, Workplace workplace) {
    final result = calculateEntryEarnings(
      workplace: workplace,
      entry: entry,
      now: DateTime.now(),
    );
    return (result.regularSeconds + result.overtimeSeconds) ~/ 3600;
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
  final Future<void> Function(TimeEntry, Workplace) onClockOut;
  final Future<void> Function(TimeEntry, Workplace) onUndoClockOut;
  final Future<void> Function(TimeEntry, String) onStartExtraBreak;
  final Future<void> Function(TimeEntry, String) onEndExtraBreak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(secondTickerProvider).value ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayEntriesAsync = ref.watch(entriesForDateProvider(today));
    final totalFood = ref.watch(userProfileProvider).value?.totalFood ?? 0;

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
        final autoOvertimeEnabled =
            ref.watch(userProfileProvider).value?.autoOvertimeEnabled ?? false;
        final overtimeApprovedIds = ref.watch(overtimeApprovalProvider);

        final scheduledEnd =
            todayEntry?.scheduledEndOverride ??
            _timeToday(today, workplace.endTime);
        final untilEnd = scheduledEnd.difference(now);
        final isPastScheduledEnd =
            activeEntry != null && now.isAfter(scheduledEnd);
        final overtimeApproved =
            activeEntry != null && overtimeApprovedIds.contains(activeEntry.id);
        // Freezes the live count at the scheduled end instead of racking up
        // overtime automatically, until the user opts in via the prompt card
        // below (or the setting is enabled).
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

        final weekday = today.weekday;
        final weekStart = today.subtract(Duration(days: weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        final weekEntries =
            ref.watch(entriesInRangeProvider(weekStart, weekEnd)).value ??
            const [];
        final weekTotals = sumEarnings(
          workplace: workplace,
          entries: weekEntries,
          now: earningsNow,
        );

        final monthStart = DateTime(today.year, today.month, 1);
        final monthEnd = DateTime(today.year, today.month + 1, 1);
        final monthEntries =
            ref.watch(entriesInRangeProvider(monthStart, monthEnd)).value ??
            const [];
        final monthTotals = sumEarnings(
          workplace: workplace,
          entries: monthEntries,
          now: earningsNow,
        );

        final isHoliday = workplace.holidayWeekdays.contains(today.weekday);
        final isRestDay = isHoliday && todayEntries.isEmpty;

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

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(primaryWorkplaceProvider);
            ref.invalidate(entriesForDateProvider);
            ref.invalidate(entriesInRangeProvider);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              const _Greeting(),
              const SizedBox(height: 10),
              if (isRestDay)
                const _HolidayRestCard()
              else ...[
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
                      : () => onClockOut(activeEntry, workplace),
                  onUndoClockOut: lastFinishedEntry == null
                      ? null
                      : () => onUndoClockOut(lastFinishedEntry!, workplace),
                ),
                if (shouldFreezeOvertime) ...[
                  const SizedBox(height: 10),
                  _OvertimePromptCard(
                    onApprove: () => ref
                        .read(overtimeApprovalProvider.notifier)
                        .approve(activeEntry.id),
                    onClockOut: () => onClockOut(activeEntry, workplace),
                  ),
                ],
                const SizedBox(height: 10),
                DogTrack(
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
                  isOnExtraBreak:
                      activeEntry != null &&
                      activeEntry.extraBreaks.isNotEmpty &&
                      activeEntry.extraBreaks.last.end == null,
                ),
              ],
              const SizedBox(height: 10),
              _PetStatusCard(totalFood: totalFood),
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
              if (workplace.salaryType == SalaryType.monthly) ...[
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final unpaidYen = unpaidOvertimeYen(
                      workplace: workplace,
                      periodOvertimeSeconds: monthTotals.overtimeSeconds,
                    );
                    return _StatTile(
                      label: '見込み残業を超えた分（未払いの可能性）',
                      value: _yenFormat.format(unpaidYen),
                      icon: unpaidYen > 0 ? Icons.warning_amber_rounded : null,
                      accentColor: unpaidYen > 0
                          ? Colors.orange.shade800
                          : null,
                      caption: unpaidYen > 0
                          ? '固定残業手当を超えて働いた分は別途支払われるべきです'
                          : null,
                    );
                  },
                ),
              ],
            ],
          ),
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

/// Shows the pet's current growth stage and cumulative food earned from
/// worked hours — the long-term payoff behind the daily dog track.
class _PetStatusCard extends StatelessWidget {
  const _PetStatusCard({required this.totalFood});

  final int totalFood;

  @override
  Widget build(BuildContext context) {
    final stage = stageFor(totalFood);
    final toNext = foodToNextStage(totalFood);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(stage.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    toNext == null ? '最終形態まで育った！' : '次の姿まで🦴あと$toNext個',
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '🦴 $totalFood',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
          ],
        ),
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

/// Shown instead of the earnings hero + dog track on a day marked as a
/// holiday in [Workplace.holidayWeekdays], as long as nothing was actually
/// clocked in — work time simply isn't tracked on a day off.
class _HolidayRestCard extends StatelessWidget {
  const _HolidayRestCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EBEC)),
      ),
      child: const Column(
        children: [
          Text('😴', style: TextStyle(fontSize: 40)),
          SizedBox(height: 10),
          Text(
            '今日はお休みです',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            'ゆっくり休んで、また明日から一緒に頑張ろう🐶',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Shown once the scheduled end time passes while "残業の自動化" is off — the
/// live count has frozen at that point, and this asks whether to keep
/// counting (for this shift only) or clock out now.
class _OvertimePromptCard extends StatelessWidget {
  const _OvertimePromptCard({
    required this.onApprove,
    required this.onClockOut,
  });

  final VoidCallback onApprove;
  final VoidCallback onClockOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '定時になりました',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          const Text(
            '残業を記録しますか？計測はここで一旦止まっています。',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onClockOut,
                  child: const Text('退勤する'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onApprove,
                  child: const Text('残業を記録する'),
                ),
              ),
            ],
          ),
        ],
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
