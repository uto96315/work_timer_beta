import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/time_entry.dart';
import '../../models/workplace.dart';
import '../../providers/auth_providers.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/workplace_providers.dart';
import '../../util/earnings_calculator.dart';

final _yenFormat = NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0);

class MonthlySummaryScreen extends ConsumerWidget {
  const MonthlySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUidProvider);
    final workplaceAsync = ref.watch(primaryWorkplaceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('月次サマリー')),
      body: workplaceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (workplace) {
          if (workplace == null || uid == null) {
            return const Center(child: Text('勤務先が未設定です'));
          }
          final entries = ref.watch(
            _monthEntriesProvider((uid: uid, workplaceId: workplace.id, month: DateTime.now())),
          );
          return entries.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('エラー: $e')),
            data: (list) => _Summary(workplace: workplace, entries: list),
          );
        },
      ),
    );
  }
}

final _monthEntriesProvider = StreamProvider.family<List<TimeEntry>,
    ({String uid, String workplaceId, DateTime month})>((ref, args) {
  return ref
      .watch(timeEntryRepositoryProvider)
      .watchEntriesForMonth(args.uid, args.workplaceId, args.month);
});

class _Summary extends StatelessWidget {
  const _Summary({required this.workplace, required this.entries});

  final Workplace workplace;
  final List<TimeEntry> entries;

  @override
  Widget build(BuildContext context) {
    final closed = entries.where((e) => e.clockOut != null).toList();
    final totalSeconds = closed.fold<int>(
      0,
      (sum, e) => sum + e.clockOut!.difference(e.clockIn).inSeconds - e.breakMinutes * 60,
    );
    final totalYen = closed.fold<double>(
      0,
      (sum, e) => sum +
          calculateLiveEarnings(
            workplace: workplace,
            clockIn: e.clockIn,
            breakMinutes: e.breakMinutes,
            now: e.clockOut!,
          ).totalYen,
    );
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryCard(label: '今月の実働時間', value: '$hours時間$minutes分'),
        const SizedBox(height: 12),
        _SummaryCard(label: '今月の本来の稼ぎ', value: _yenFormat.format(totalYen)),
        const SizedBox(height: 12),
        _SummaryCard(label: '記録日数', value: '${closed.length}日'),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
