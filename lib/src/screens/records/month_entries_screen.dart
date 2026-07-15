import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/time_entry.dart';
import '../../models/workplace.dart';
import '../../providers/auth_providers.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/time_entry_providers.dart';
import '../../widgets/time_field.dart';

final _dayFormat = DateFormat('M/d(E)', 'ja_JP');
final _timeFormat = DateFormat('HH:mm');
final _monthTitleFormat = DateFormat('yyyy年M月');

/// Lists a month's worked shifts so the user can correct clock-in/out times
/// recorded in error — e.g. forgot to clock out, or a wrong auto clock-in.
/// Corrections go through [TimeEntryRepository.correct], which flags the
/// entry as modified and preserves the original times.
class MonthEntriesScreen extends ConsumerWidget {
  const MonthEntriesScreen({
    super.key,
    required this.workplace,
    required this.monthStart,
  });

  final Workplace workplace;
  final DateTime monthStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 1);
    final entriesAsync = ref.watch(entriesInRangeProvider(monthStart, monthEnd));

    return Scaffold(
      appBar: AppBar(title: Text('${_monthTitleFormat.format(monthStart)}の記録')),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('この月の記録はありません'));
          }
          final sorted = [...entries]..sort((a, b) => a.clockIn.compareTo(b.clockIn));
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _EntryCard(workplace: workplace, entry: sorted[i]),
          );
        },
      ),
    );
  }
}

class _EntryCard extends ConsumerWidget {
  const _EntryCard({required this.workplace, required this.entry});

  final Workplace workplace;
  final TimeEntry entry;

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<_EntryEdit>(
      context: context,
      showDragHandle: true,
      builder: (context) => _EntryEditSheet(entry: entry),
    );
    if (result == null) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await ref.read(timeEntryRepositoryProvider).correct(
      uid,
      workplace.id,
      entry,
      newClockIn: result.clockIn,
      newClockOut: result.clockOut,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final day = DateTime.parse(entry.date);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _dayFormat.format(day),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (entry.isModified) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '修正済み',
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_timeFormat.format(entry.clockIn)} 〜 '
                    '${entry.clockOut == null ? '未退勤' : _timeFormat.format(entry.clockOut!)}',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _edit(context, ref),
              icon: const Icon(Icons.edit_outlined, size: 18),
              tooltip: '記録を修正',
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryEdit {
  const _EntryEdit({required this.clockIn, required this.clockOut});
  final DateTime clockIn;
  final DateTime? clockOut;
}

class _EntryEditSheet extends StatefulWidget {
  const _EntryEditSheet({required this.entry});

  final TimeEntry entry;

  @override
  State<_EntryEditSheet> createState() => _EntryEditSheetState();
}

class _EntryEditSheetState extends State<_EntryEditSheet> {
  late TimeOfDay _clockIn;
  TimeOfDay? _clockOut;

  @override
  void initState() {
    super.initState();
    _clockIn = TimeOfDay.fromDateTime(widget.entry.clockIn);
    _clockOut = widget.entry.clockOut == null
        ? null
        : TimeOfDay.fromDateTime(widget.entry.clockOut!);
  }

  Future<void> _pickClockIn() async {
    final picked = await showCupertinoTimePicker(context, _clockIn);
    if (picked != null) setState(() => _clockIn = picked);
  }

  Future<void> _pickClockOut() async {
    final picked = await showCupertinoTimePicker(
      context,
      _clockOut ?? _clockIn,
    );
    if (picked != null) setState(() => _clockOut = picked);
  }

  DateTime _combine(TimeOfDay t) {
    final day = DateTime.parse(widget.entry.date);
    return DateTime(day.year, day.month, day.day, t.hour, t.minute);
  }

  void _submit() {
    Navigator.of(context).pop(
      _EntryEdit(
        clockIn: _combine(_clockIn),
        clockOut: _clockOut == null ? null : _combine(_clockOut!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final day = DateTime.parse(widget.entry.date);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${_dayFormat.format(day)}の記録を修正',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _TimeRow(label: '出勤', time: _clockIn, onTap: _pickClockIn),
          const SizedBox(height: 10),
          _TimeRow(
            label: '退勤',
            time: _clockOut,
            placeholder: '未退勤（タップして設定）',
            onTap: _pickClockOut,
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _submit, child: const Text('保存')),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.time,
    required this.onTap,
    this.placeholder,
  });

  final String label;
  final TimeOfDay? time;
  final String? placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
            Text(
              time == null ? (placeholder ?? '未設定') : time!.format(context),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
