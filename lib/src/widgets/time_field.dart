import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Opens a bottom sheet with a scrolling wheel time picker
/// (CupertinoDatePicker), much faster to operate than the stock Material
/// time picker dialog for this app's most common input: shift times.
Future<TimeOfDay?> showCupertinoTimePicker(BuildContext context, TimeOfDay initial) async {
  var picked = initial;
  var confirmed = false;
  final now = DateTime.now();
  final initialDateTime = DateTime(now.year, now.month, now.day, initial.hour, initial.minute);

  await showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
                TextButton(
                  onPressed: () {
                    confirmed = true;
                    Navigator.of(context).pop();
                  },
                  child: const Text('決定'),
                ),
              ],
            ),
            SizedBox(
              height: 216,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                minuteInterval: 5,
                initialDateTime: initialDateTime,
                onDateTimeChanged: (dt) {
                  picked = TimeOfDay(hour: dt.hour, minute: dt.minute);
                },
              ),
            ),
          ],
        ),
      );
    },
  );

  return confirmed ? picked : null;
}

/// A large, tappable time picker card for forms (start/end/break times).
class TimeField extends StatelessWidget {
  const TimeField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final picked = await showCupertinoTimePicker(context, value);
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Text(
              _formatTime(value),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: scheme.outline, size: 20),
          ],
        ),
      ),
    );
  }
}
