import 'dart:math' as math;

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
import '../../util/affection.dart';
import '../../util/earnings_calculator.dart';
import '../../util/home_snapshot.dart';
import '../../util/pet_age.dart';
import '../../util/pet_stage.dart';
import '../../util/schedule_blocks.dart';
import '../../widgets/dog_track.dart' show AddBreakButton, ExtraBreakButton;
import '../../widgets/home_cards.dart';
import '../../widgets/pet_sprite_widget.dart';
import '../../widgets/pixel_ui.dart';

final _timeFormat = DateFormat('HH:mm');

/// Home screen redesign ("Design B") — the day's schedule is a vertical list
/// instead of a horizontal scrolling track, and elapsed time is struck
/// through with a hand-drawn marker mark instead of just changing an icon/
/// color. The pet lives in a dedicated card up top instead of walking along
/// the track. Otherwise has the same feature set as the original design
/// (clock in/out, breaks, weekly/monthly stats) — see [HomeScreen].
class HomeContentB extends ConsumerWidget {
  const HomeContentB({
    super.key,
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
  final Future<void> Function(TimeEntry, Workplace, {DateTime? clockOutTime})
  onClockOut;
  final Future<void> Function(TimeEntry, Workplace) onUndoClockOut;
  final Future<void> Function(TimeEntry, String) onStartExtraBreak;
  final Future<void> Function(TimeEntry, String) onEndExtraBreak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(secondTickerProvider).value ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entriesAsync = ref.watch(entriesForDateProvider(today));
    final profile = ref.watch(userProfileProvider).value;

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
      data: (todayEntries) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onAutoClockInCheck(workplace, todayEntries);
          if (profile != null && profile.petBornAt == null) {
            final uid = ref.read(currentUidProvider);
            if (uid != null) {
              ref.read(userProfileRepositoryProvider).setPetBornAtNow(uid);
            }
          }
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
        final blocks = snapshot.blocks;
        final isOnExtraBreak =
            activeEntry != null &&
            activeEntry.extraBreaks.isNotEmpty &&
            activeEntry.extraBreaks.last.end == null;
        final hasScheduledBreak = blocks.any(
          (b) => b.isBreak && !b.isExtraBreak,
        );

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(entriesForDateProvider);
            ref.invalidate(entriesInRangeProvider);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              _PetHeaderCard(
                totalFood: profile?.totalFood ?? 0,
                affectionPoints: profile?.affectionPoints ?? 0,
                lastWorkedDate: profile?.lastWorkedDate,
                petBornAt: profile?.petBornAt,
                now: now,
              ),
              const SizedBox(height: 10),
              if (snapshot.isRestDay)
                const HolidayRestCard()
              else ...[
                EarningsHeroCard(
                  totalYen: snapshot.todayTotals.totalYen,
                  isOvertime: snapshot.todayTotals.overtimeSeconds > 0,
                  untilEnd: snapshot.untilEnd,
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
                      : () =>
                            onUndoClockOut(lastFinishedEntry, workplace),
                ),
                if (snapshot.shouldFreezeOvertime && activeEntry != null) ...[
                  const SizedBox(height: 10),
                  OvertimePromptCard(
                    onApprove: () => ref
                        .read(overtimeApprovalProvider.notifier)
                        .approve(activeEntry.id),
                    onClockOut: () => onClockOut(
                      activeEntry,
                      workplace,
                      clockOutTime: snapshot.scheduledEnd,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                if (blocks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'まだ今日の勤務時間がありません',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  )
                else
                  PixelPanel(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        for (var i = 0; i < blocks.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          _ScheduleRow(block: blocks[i], seed: i),
                        ],
                      ],
                    ),
                  ),
                if (!hasScheduledBreak && todayEntry != null) ...[
                  const SizedBox(height: 10),
                  AddBreakButton(
                    onPressed: () =>
                        onEditBreakStart(todayEntry, workplace, today),
                  ),
                ],
                if (activeEntry != null) ...[
                  const SizedBox(height: 10),
                  ExtraBreakButton(
                    isOnBreak: isOnExtraBreak,
                    onPressed: isOnExtraBreak
                        ? () => onEndExtraBreak(activeEntry, workplace.id)
                        : () => onStartExtraBreak(activeEntry, workplace.id),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: '今週',
                      value: yenFormat.format(snapshot.weekTotals.totalYen),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      label: '今月',
                      value: yenFormat.format(snapshot.monthTotals.totalYen),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StatTile(
                label: '今月の残業',
                value:
                    '${snapshot.monthTotals.overtimeSeconds ~/ 3600}時間'
                    '${(snapshot.monthTotals.overtimeSeconds % 3600) ~/ 60}分',
                accentColor: snapshot.overtimeAccentColor,
                caption: snapshot.overtimeCaption,
              ),
              if (workplace.salaryType == SalaryType.monthly) ...[
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final unpaidYen = unpaidOvertimeYen(
                      workplace: workplace,
                      periodOvertimeSeconds: snapshot.monthTotals.overtimeSeconds,
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

class _PetHeaderCard extends StatelessWidget {
  const _PetHeaderCard({
    required this.totalFood,
    required this.affectionPoints,
    required this.lastWorkedDate,
    required this.petBornAt,
    required this.now,
  });

  final int totalFood;
  final int affectionPoints;
  final String? lastWorkedDate;
  final DateTime? petBornAt;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stage = stageFor(totalFood);
    final stageIndex = petStages.indexOf(stage);
    final nextNeeded = foodToNextStage(totalFood);
    // Progress toward the next stage — how "full" the pet is from food
    // earned by working. Permanent/never decreases, unlike affection below.
    final fullness = nextNeeded == null
        ? 1.0
        : 1 -
              (nextNeeded /
                  (petStages[stageIndex + 1].minFood - stage.minFood));
    // Recent-engagement meter: rises with consecutive days worked, decays
    // the longer it's been since lastWorkedDate — distinct from the
    // lifetime, always-growing pet stage above.
    final affection = displayedAffection(
      rawPoints: affectionPoints,
      lastWorkedDate: lastWorkedDate,
      now: now,
    );

    final ageLabel = petBornAt == null ? '0歳0ヶ月' : petAgeLabel(petBornAt!, now);

    return PixelPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const PetSpriteView(size: 88),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'ラブラドール',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ageLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 92,
                      child: Text(
                        'なつき度',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: scheme.outline),
                      ),
                    ),
                    Expanded(
                      child: PixelMeter(
                        value: affection / affectionMax,
                        color: PixelColors.rose,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      affectionLabel(affection),
                      style: TextStyle(fontSize: 11, color: scheme.outline),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SizedBox(
                      width: 92,
                      child: Text(
                        'お腹の空き具合',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: scheme.outline),
                      ),
                    ),
                    Expanded(
                      child: PixelMeter(
                        value: fullness,
                        color: PixelColors.mint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.block, required this.seed});

  final ScheduleBlock block;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDone = block.state == BlockState.done;
    final isCurrent = block.state == BlockState.inProgress;
    final label =
        '${_timeFormat.format(block.start)} 〜 ${_timeFormat.format(block.end)}';

    final dotColor = isCurrent
        ? scheme.primary
        : isDone
        ? scheme.outline
        : scheme.outlineVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            color: dotColor,
          ),
          const SizedBox(width: 14),
          _MarkerStrike(
            active: isDone,
            seed: seed,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isDone ? scheme.onSurfaceVariant : scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: block.isBreak
                  ? PixelTag(
                      label: block.isExtraBreak ? '一時休憩' : '休憩',
                      color: scheme.tertiary,
                    )
                  : block.isOvertime
                  ? PixelTag(label: '残業', color: Colors.orange.shade700)
                  : isCurrent
                  ? PixelTag(label: '勤務中', color: scheme.primary)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlays a hand-drawn, marker-style strikethrough across [child] when
/// [active] — used to mark elapsed schedule blocks as "done" without
/// changing their text, matching the ballpoint-crossed-out look of a
/// handwritten to-do list rather than a clean typographic strikethrough.
///
/// [seed] fixes the jitter/roughness so repeated rebuilds (this ticks every
/// second while a shift is live) don't make the mark visibly redraw.
class _MarkerStrike extends StatelessWidget {
  const _MarkerStrike({
    required this.child,
    required this.active,
    required this.seed,
  });

  final Widget child;
  final bool active;
  final int seed;

  @override
  Widget build(BuildContext context) {
    if (!active) return child;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: CustomPaint(painter: _MarkerStrikePainter(seed: seed)),
        ),
      ],
    );
  }
}

class _MarkerStrikePainter extends CustomPainter {
  _MarkerStrikePainter({required this.seed});

  final int seed;

  static const _markerColor = Color(0xFFE04E39);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final midY = size.height * 0.55;
    double jitter() => (random.nextDouble() - 0.5) * size.height * 0.22;

    // Two overlapping passes at slightly different weights/alphas fake the
    // uneven ink coverage of a felt-tip marker.
    for (final layer in [
      (width: 4.0, alpha: 0.55),
      (width: 7.0, alpha: 0.16),
    ]) {
      final paint = Paint()
        ..color = _markerColor.withValues(alpha: layer.alpha)
        ..strokeWidth = layer.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(-2, midY + jitter());
      const segments = 4;
      for (var i = 1; i <= segments; i++) {
        final x = -2 + (size.width + 4) * i / segments;
        path.lineTo(x, midY + jitter());
      }
      canvas.drawPath(path, paint);
    }

    // Little overshoot flicks at each end, like a marker lifting off.
    final flickPaint = Paint()
      ..color = _markerColor.withValues(alpha: 0.35)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-3, midY - 4), Offset(5, midY), flickPaint);
    canvas.drawLine(
      Offset(size.width - 5, midY),
      Offset(size.width + 3, midY - 4),
      flickPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MarkerStrikePainter oldDelegate) =>
      oldDelegate.seed != seed;
}
