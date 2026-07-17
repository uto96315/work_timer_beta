import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../util/schedule_blocks.dart';
import 'dog_painter.dart';

final _timeFormat = DateFormat('HH:mm');

/// The day's schedule rendered as a track the dog runs along, eating one
/// piece of food per worked hour — replaces the old checklist-style
/// timeline with something that reads as "the dog is working through the
/// day with you" instead of a plain progress list.
class DogTrack extends StatelessWidget {
  const DogTrack({
    super.key,
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
                AddBreakButton(onPressed: onEditBreakStart!),
              if (onStartExtraBreak != null) ...[
                if (onEditBreakStart != null) const SizedBox(height: 8),
                ExtraBreakButton(
                  isOnBreak: isOnExtraBreak,
                  onPressed: isOnExtraBreak ? onEndExtraBreak : onStartExtraBreak,
                ),
              ],
            ],
          ),
        ),
      );
    }

    var elapsedSeconds = 0;
    var scheduledSeconds = 0;
    var overtimeElapsedSeconds = 0;
    var hasOvertimeBlock = false;
    for (final block in blocks) {
      final blockSeconds = block.end.difference(block.start).inSeconds;
      if (!block.isOvertime) scheduledSeconds += blockSeconds;
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
    // Percent is relative to the original scheduled shift, not the
    // overtime-extended total, so it can climb past 100% once overtime
    // starts instead of hovering at 100% forever.
    final progressPercent = scheduledSeconds == 0
        ? 0
        : ((elapsedSeconds / scheduledSeconds) * 100).round();
    final regularElapsedSeconds = elapsedSeconds - overtimeElapsedSeconds;
    final remaining = Duration(
      seconds: (scheduledSeconds - regularElapsedSeconds).clamp(0, scheduledSeconds),
    );
    final remainingFood = (remaining.inSeconds / 3600).ceil();
    final hasBreak = blocks.any((b) => b.isBreak && !b.isExtraBreak);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _TrackHeader(
            progressPercent: progressPercent,
            remaining: remaining,
            remainingFood: remainingFood,
            isOvertime: hasOvertimeBlock,
            overtimeElapsed: Duration(seconds: overtimeElapsedSeconds),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final block in blocks) _DogStop(block: block),
                ],
              ),
            ),
          ),
          // Late clock-ins can push the default break time out of the
          // timeline entirely (schedule_blocks only shows a break at or
          // after the actual clock-in), so surface a way to add one back.
          if (!hasBreak && onEditBreakStart != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 16, 10),
              child: AddBreakButton(onPressed: onEditBreakStart!),
            ),
          // Always available while clocked in, so an ad-hoc break (most
          // commonly taken during overtime) can be logged at any time —
          // not just when the scheduled break is missing.
          if (onStartExtraBreak != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 16, 10),
              child: ExtraBreakButton(
                isOnBreak: isOnExtraBreak,
                onPressed: isOnExtraBreak ? onEndExtraBreak : onStartExtraBreak,
              ),
            ),
        ],
      ),
    );
  }
}

class AddBreakButton extends StatelessWidget {
  const AddBreakButton({super.key, required this.onPressed});

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
class ExtraBreakButton extends StatelessWidget {
  const ExtraBreakButton({super.key, required this.isOnBreak, required this.onPressed});

  final bool isOnBreak;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (isOnBreak) {
      return Align(
        alignment: Alignment.centerLeft,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: scheme.tertiary,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
          child: const Text('休憩を終える'),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text('休憩に入る'),
      ),
    );
  }
}

class _TrackHeader extends StatelessWidget {
  const _TrackHeader({
    required this.progressPercent,
    required this.remaining,
    required this.remainingFood,
    required this.isOvertime,
    required this.overtimeElapsed,
  });

  final int progressPercent;
  final Duration remaining;
  final int remainingFood;
  final bool isOvertime;
  final Duration overtimeElapsed;

  String get _remainingLabel {
    if (progressPercent >= 100) return '本日のごはんは食べ終わったよ';
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final timeLabel = h <= 0 ? 'あと$m分' : 'あと$h時間$m分';
    return '$timeLabel（🦴あと$remainingFood個）';
  }

  String get _overtimeLabel {
    final h = overtimeElapsed.inHours;
    final m = overtimeElapsed.inMinutes % 60;
    return h <= 0 ? '残業 $m分' : '残業 $h時間$m分';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isOvertime
              ? const [Color(0xFFFF8A5C), Color(0xFFE85D3D)]
              : const [Color(0xFF19C3A6), Color(0xFF0D8F84)],
        ),
      ),
      child: isOvertime
          ? Row(
              children: [
                const Text(
                  '残業中も一緒に頑張るワン🐕',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  _overtimeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Text(
                  '$progressPercent%',
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
                      value: (progressPercent / 100).clamp(0.0, 1.0),
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

/// One stop on the track: a food (or nap, for breaks) icon that gets eaten
/// once its block is done, with the dog itself standing on whichever stop
/// is currently in progress.
class _DogStop extends StatelessWidget {
  const _DogStop({required this.block});

  final ScheduleBlock block;

  @override
  Widget build(BuildContext context) {
    final isDone = block.state == BlockState.done;
    final isInProgress = block.state == BlockState.inProgress;
    final label = _timeFormat.format(block.start).substring(0, 2);

    return SizedBox(
      width: 56,
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _StopIcon(block: block, isDone: isDone),
                if (isInProgress) AnimatedDog(sleeping: block.isBreak),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isInProgress ? FontWeight.bold : FontWeight.normal,
              color: isDone
                  ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StopIcon extends StatelessWidget {
  const _StopIcon({required this.block, required this.isDone});

  final ScheduleBlock block;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final isInProgress = block.state == BlockState.inProgress;
    if (block.isBreak) {
      // A nap spot instead of food — breaks aren't "eaten", just rested at.
      // While in progress the sleeping dog itself is drawn over this stop
      // instead, so there's nothing separate to show here.
      if (isInProgress) return const SizedBox.shrink();
      return Opacity(
        opacity: isDone ? 0.35 : 1,
        child: const Text('😴', style: TextStyle(fontSize: 22)),
      );
    }
    if (isDone) {
      return Opacity(
        opacity: 0.35,
        child: const Text('🐾', style: TextStyle(fontSize: 20)),
      );
    }
    // Upcoming, or in-progress and being nibbled away — fade the bone out
    // as this block's progress advances instead of an abrupt disappearance.
    final opacity = isInProgress ? (1 - block.progress).clamp(0.25, 1.0) : 1.0;
    return Opacity(
      opacity: opacity,
      child: const Text('🦴', style: TextStyle(fontSize: 22)),
    );
  }
}
