import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/time_entry.dart';
import '../../models/workplace.dart';
import '../../providers/time_entry_providers.dart';
import '../../providers/workplace_providers.dart';
import '../../util/earnings_calculator.dart';

final _yenFormat = NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0);

class MonthlySummaryScreen extends ConsumerWidget {
  const MonthlySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workplaceAsync = ref.watch(primaryWorkplaceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('月次サマリー')),
      body: workplaceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (workplace) {
          if (workplace == null) {
            return const Center(child: Text('勤務先が未設定です'));
          }
          final now = DateTime.now();
          final entries = ref.watch(
            entriesInRangeProvider(DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 1)),
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

class _Summary extends StatelessWidget {
  const _Summary({required this.workplace, required this.entries});

  final Workplace workplace;
  final List<TimeEntry> entries;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final closed = entries.where((e) => e.clockOut != null).toList();
    final totalSeconds = closed.fold<int>(
      0,
      (sum, e) => sum + e.clockOut!.difference(e.clockIn).inSeconds - e.breakMinutes * 60,
    );
    final totals = sumEarnings(workplace: workplace, entries: closed, now: now);
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final overtimeHours = totals.overtimeSeconds ~/ 3600;
    final overtimeMinutes = (totals.overtimeSeconds % 3600) ~/ 60;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryCard(label: '今月の実働時間', value: '$hours時間$minutes分'),
        const SizedBox(height: 12),
        _SummaryCard(label: '今月の本来の稼ぎ', value: _yenFormat.format(totals.totalYen)),
        const SizedBox(height: 12),
        _SummaryCard(label: '今月の残業時間', value: '$overtimeHours時間$overtimeMinutes分'),
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
