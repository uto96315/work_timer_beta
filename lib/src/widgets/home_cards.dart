import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/time_entry.dart';
import 'pixel_ui.dart';

/// Shared formatters/widgets between the home screen designs — kept in one
/// place so both render the same earnings figures, warnings, and controls
/// instead of drifting apart.
final yenFormat = NumberFormat.currency(
  locale: 'ja_JP',
  symbol: '¥',
  decimalDigits: 0,
);
final homeTimeFormat = DateFormat('HH:mm');

class Greeting extends StatelessWidget {
  const Greeting({super.key});

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

/// The day's live earnings, with clock-in/out controls — the one place in
/// either design where a shift actually gets started, corrected, or ended.
class EarningsHeroCard extends StatelessWidget {
  const EarningsHeroCard({
    super.key,
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

    return PixelPanel(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: isOvertime ? PixelColors.orange : PixelColors.mint,
      borderWidth: 2,
      shadowOffset: 3,
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
            yenFormat.format(totalYen),
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
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '出勤 ${homeTimeFormat.format(entry.clockIn)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (entry.isAutoClockedIn) ...[
                        const Text(
                          '（自動）',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                      GestureDetector(
                        onTap: onEditClockIn,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.edit_rounded,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PixelButton(
                  onPressed: onClockOut == null
                      ? null
                      : () => _handleClockOutPressed(context),
                  color: Colors.white,
                  textColor: const Color(0xFF0D8F84),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              child: PixelButton(
                onPressed: onUndoClockOut,
                color: isOvertime ? PixelColors.orange : PixelColors.mint,
                textColor: Colors.white,
                borderColor: Colors.white70,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: const Text('退勤を取り消す'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
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

  /// Warm, toy-like brown instead of flat black — matches the mint/cream
  /// palette better than pure `onSurface` text would.
  static const _valueBrown = Color(0xFF6E5236);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = accentColor ?? scheme.primary;
    return PixelPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    border: Border.all(color: accent, width: 2),
                  ),
                  child: Icon(icon, size: 14, color: accent),
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
              color: accentColor ?? _valueBrown,
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
    );
  }
}

/// Shown instead of the earnings hero + schedule on a day marked as a
/// holiday in `Workplace.holidayWeekdays`, as long as nothing was actually
/// clocked in — work time simply isn't tracked on a day off.
class HolidayRestCard extends StatelessWidget {
  const HolidayRestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
class OvertimePromptCard extends StatelessWidget {
  const OvertimePromptCard({super.key, required this.onApprove, required this.onClockOut});

  final VoidCallback onApprove;
  final VoidCallback onClockOut;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFFFF3E0),
      borderColor: PixelColors.orangeDark,
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
                child: PixelButton(
                  onPressed: onClockOut,
                  color: const Color(0xFFFFF3E0),
                  textColor: PixelColors.ink,
                  child: const Center(child: Text('退勤する')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PixelButton(
                  onPressed: onApprove,
                  color: PixelColors.orange,
                  child: const Center(child: Text('残業を記録する')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
