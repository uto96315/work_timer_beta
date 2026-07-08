import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/time_entry.dart';
import '../../providers/time_entry_providers.dart';
import '../../providers/workplace_providers.dart';

final _timeFormat = DateFormat('HH:mm');

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workplaceAsync = ref.watch(primaryWorkplaceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('記録一覧')),
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
            data: (list) {
              if (list.isEmpty) {
                return const Center(child: Text('まだ記録がありません'));
              }
              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) => _EntryTile(entry: list[list.length - 1 - index]),
              );
            },
          );
        },
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final TimeEntry entry;

  @override
  Widget build(BuildContext context) {
    final clockOut = entry.clockOut;
    return ListTile(
      title: Text(entry.date),
      subtitle: Text(
        '${_timeFormat.format(entry.clockIn)} 〜 ${clockOut == null ? '（勤務中）' : _timeFormat.format(clockOut)}',
      ),
      trailing: entry.isModified ? const Icon(Icons.edit_note, size: 20) : null,
    );
  }
}
