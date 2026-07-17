import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/salary_type.dart';
import '../../models/time_entry.dart';
import '../../models/workplace.dart';
import '../../providers/auth_providers.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/time_entry_providers.dart';
import '../../providers/user_profile_providers.dart';
import '../../providers/workplace_providers.dart';
import '../../services/wifi_clock_trigger_service.dart';
import '../../util/earnings_calculator.dart';
import '../../util/home_snapshot.dart';
import '../../util/pet_stage.dart';
import '../../widgets/dog_track.dart';
import '../../widgets/home_cards.dart';
import '../../widgets/time_field.dart';
import 'home_design_b.dart';
import 'home_design_c.dart';

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

/// A/B design switcher for the home screen — temporary, for comparing the
/// current design against in-progress redesigns before picking a winner.
/// Remove once one design is settled on.
enum _HomeDesign {
  a('A'),
  b('B'),
  c('C');

  const _HomeDesign(this.label);
  final String label;
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _autoClockInTriggered = false;
  _HomeDesign _design = _HomeDesign.b;
  bool _showDesignIndicator = false;
  Timer? _designIndicatorTimer;
  double _dragDistance = 0;
  final _wifiClockTrigger = WifiClockTriggerService();
  String? _lastSeenSsid;

  @override
  void initState() {
    super.initState();
    _wifiClockTrigger.start(_handleWifiSsidChanged);
  }

  /// Auto clocks in/out when the device joins/leaves the workplace's
  /// registered Wi-Fi network (see [Workplace.autoClockInSsid]). Guarded by
  /// [_lastSeenSsid] so re-reads of the same network (e.g. a brief signal
  /// drop) don't repeatedly toggle the entry.
  void _handleWifiSsidChanged(String? ssid) {
    if (ssid == _lastSeenSsid) return;
    _lastSeenSsid = ssid;

    final workplace = ref.read(primaryWorkplaceProvider).value;
    final targetSsid = workplace?.autoClockInSsid;
    if (workplace == null || targetSsid == null || targetSsid.isEmpty) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    final activeEntry = ref.read(activeTimeEntryProvider).value;
    final now = DateTime.now();
    final onTargetNetwork = ssid == targetSsid;

    if (onTargetNetwork &&
        activeEntry == null &&
        !workplace.holidayWeekdays.contains(now.weekday)) {
      ref.read(timeEntryRepositoryProvider).clockIn(uid, workplace.id, workplace.breakMinutes);
      ref.read(userProfileRepositoryProvider).recordWorkedDay(uid, now);
    } else if (!onTargetNetwork && activeEntry != null) {
      _clockOut(activeEntry, workplace);
    }
  }

  void _swipeDesign(int direction) {
    final values = _HomeDesign.values;
    final nextIndex = (_design.index + direction) % values.length;
    setState(() {
      _design = values[(nextIndex + values.length) % values.length];
      _showDesignIndicator = true;
    });
    _designIndicatorTimer?.cancel();
    _designIndicatorTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showDesignIndicator = false);
    });
  }

  @override
  void dispose() {
    _designIndicatorTimer?.cancel();
    _wifiClockTrigger.dispose();
    super.dispose();
  }

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
    ref.read(userProfileRepositoryProvider).recordWorkedDay(uid, now);
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
        child: GestureDetector(
          // Temporary swipe-to-switch for comparing designs — replaces the
          // segmented button, which sat on top of the content. Comes out
          // with the rest of the switcher once a design is settled on.
          //
          // Reacts to drag distance, not just release velocity — a slow,
          // deliberate swipe has near-zero velocity at the end but should
          // still switch designs, not silently do nothing.
          onHorizontalDragUpdate: (details) =>
              _dragDistance += details.delta.dx,
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            final distance = _dragDistance;
            _dragDistance = 0;
            final triggerValue = velocity.abs() > 200 ? velocity : distance;
            if (triggerValue.abs() < 60) return;
            _swipeDesign(triggerValue < 0 ? 1 : -1);
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: workplaceAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('エラー: $e')),
                  data: (workplace) {
                    if (workplace == null) {
                      return const _NoWorkplaceMessage();
                    }
                    switch (_design) {
                      case _HomeDesign.b:
                        return HomeContentB(
                          workplace: workplace,
                          onAutoClockInCheck: _maybeAutoClockIn,
                          onEditClockIn: _editClockIn,
                          onEditBreakStart: _editBreakStart,
                          onClockOut: _clockOut,
                          onUndoClockOut: _undoClockOut,
                          onStartExtraBreak: _startExtraBreak,
                          onEndExtraBreak: _endExtraBreak,
                        );
                      case _HomeDesign.c:
                        return HomeContentC(workplace: workplace);
                      case _HomeDesign.a:
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
                    }
                  },
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _showDesignIndicator ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFE3E3E3,
                          ).withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _design.label,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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

        final weekday = today.weekday;
        final weekStart = today.subtract(Duration(days: weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        final weekEntries =
            ref.watch(entriesInRangeProvider(weekStart, weekEnd)).value ??
            const [];
        final monthStart = DateTime(today.year, today.month, 1);
        final monthEnd = DateTime(today.year, today.month + 1, 1);
        final monthEntries =
            ref.watch(entriesInRangeProvider(monthStart, monthEnd)).value ??
            const [];
        final autoOvertimeEnabled =
            ref.watch(userProfileProvider).value?.autoOvertimeEnabled ?? false;
        final overtimeApprovedIds = ref.watch(overtimeApprovalProvider);

        final snapshot = buildHomeSnapshot(
          workplace: workplace,
          todayEntries: todayEntries,
          weekEntries: weekEntries,
          monthEntries: monthEntries,
          today: today,
          now: now,
          autoOvertimeEnabled: autoOvertimeEnabled,
          overtimeApprovedIds: overtimeApprovedIds,
        );
        final activeEntry = snapshot.activeEntry;
        final todayEntry = snapshot.todayEntry;
        final lastFinishedEntry = snapshot.lastFinishedEntry;
        final untilEnd = snapshot.untilEnd;
        final shouldFreezeOvertime = snapshot.shouldFreezeOvertime;
        final blocks = snapshot.blocks;
        final todayTotals = snapshot.todayTotals;
        final weekTotals = snapshot.weekTotals;
        final monthTotals = snapshot.monthTotals;
        final isRestDay = snapshot.isRestDay;
        final overtimeAccentColor = snapshot.overtimeAccentColor;
        final overtimeCaption = snapshot.overtimeCaption;

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
              const Greeting(),
              const SizedBox(height: 10),
              if (isRestDay)
                const HolidayRestCard()
              else ...[
                EarningsHeroCard(
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
                      : () => onUndoClockOut(lastFinishedEntry, workplace),
                ),
                if (shouldFreezeOvertime && activeEntry != null) ...[
                  const SizedBox(height: 10),
                  OvertimePromptCard(
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
                    child: StatTile(
                      label: '今週',
                      value: yenFormat.format(weekTotals.totalYen),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      label: '今月',
                      value: yenFormat.format(monthTotals.totalYen),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StatTile(
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
                    return StatTile(
                      label: '見込み残業を超えた分（未払いの可能性）',
                      value: yenFormat.format(unpaidYen),
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
