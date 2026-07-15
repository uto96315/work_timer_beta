import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../models/workplace.dart';
import '../../providers/time_entry_providers.dart';
import '../../providers/user_profile_providers.dart';
import '../../util/affection.dart';
import '../../util/pet_stage.dart';
import '../../util/schedule_blocks.dart';

final _timeFormat = DateFormat('HH:mm');

/// Home screen redesign ("Design B") being compared against the current
/// design ("Design A") via the switcher in [HomeScreen].
///
/// Biggest UX change from A: the day's schedule is a vertical list instead
/// of a horizontal scrolling track, and elapsed time is struck through with
/// a hand-drawn marker mark instead of just changing an icon/color. The pet
/// moves to a dedicated card up top instead of walking along the track.
class HomeContentB extends ConsumerWidget {
  const HomeContentB({super.key, required this.workplace});

  final Workplace workplace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(secondTickerProvider).value ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entriesAsync = ref.watch(entriesForDateProvider(today));
    final profile = ref.watch(userProfileProvider).value;

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
      data: (entries) {
        final blocks = buildDaySchedule(
          workplace: workplace,
          day: today,
          entriesToday: entries,
          now: now,
        );
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _PetHeaderCard(
                totalFood: profile?.totalFood ?? 0,
                affectionPoints: profile?.affectionPoints ?? 0,
                lastWorkedDate: profile?.lastWorkedDate,
                now: now,
              ),
            ),
            Expanded(
              child: blocks.isEmpty
                  ? Center(
                      child: Text(
                        'まだ今日の勤務時間がありません',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                      itemCount: blocks.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) =>
                          _ScheduleRow(block: blocks[i], seed: i),
                    ),
            ),
          ],
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
    required this.now,
  });

  final int totalFood;
  final int affectionPoints;
  final String? lastWorkedDate;
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

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: SvgPicture.asset('assets/dog_emoji/fluent_dog.svg'),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'コーギー',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        stage.name,
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
                        width: 76,
                        child: Text(
                          'なつき度',
                          style: TextStyle(fontSize: 11, color: scheme.outline),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: affection / affectionMax,
                            minHeight: 6,
                            backgroundColor: scheme.surfaceContainerHighest,
                          ),
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
                        width: 76,
                        child: Text(
                          'お腹の空き具合',
                          style: TextStyle(fontSize: 11, color: scheme.outline),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fullness,
                            minHeight: 6,
                            backgroundColor: scheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
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
          if (block.isBreak)
            _Tag(
              label: block.isExtraBreak ? '一時休憩' : '休憩',
              color: scheme.tertiary,
            )
          else if (block.isOvertime)
            _Tag(label: '残業', color: Colors.orange.shade700)
          else if (isCurrent)
            _Tag(label: '勤務中', color: scheme.primary),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
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
      (width: 7.0, alpha: 0.85),
      (width: 10.0, alpha: 0.3),
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
      ..color = _markerColor.withValues(alpha: 0.55)
      ..strokeWidth = 5
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
