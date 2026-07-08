import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_providers.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/time_entry_providers.dart';
import '../../providers/workplace_providers.dart';

final _yenFormat = NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workplaceAsync = ref.watch(primaryWorkplaceProvider);
    final activeEntryAsync = ref.watch(activeTimeEntryProvider);
    final earnings = ref.watch(liveEarningsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('仕事タイマー')),
      body: workplaceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (workplace) {
          if (workplace == null) {
            return const _NoWorkplaceMessage();
          }
          final activeEntry = activeEntryAsync.value;
          final isWorking = activeEntry != null;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isWorking ? '出勤中' : '未出勤',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  _yenFormat.format(earnings?.totalYen ?? 0),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: earnings?.isOvertime == true
                            ? Colors.deepOrange
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (earnings?.isOvertime == true)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('残業中', style: TextStyle(color: Colors.deepOrange)),
                  ),
                const SizedBox(height: 48),
                FilledButton(
                  onPressed: () => _onPunchPressed(context, ref, workplace.id, activeEntry?.id),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 56),
                    backgroundColor: isWorking ? Colors.redAccent : null,
                  ),
                  child: Text(isWorking ? '退勤する' : '出勤する', style: const TextStyle(fontSize: 18)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onPunchPressed(
    BuildContext context,
    WidgetRef ref,
    String workplaceId,
    String? openEntryId,
  ) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final repo = ref.read(timeEntryRepositoryProvider);
    if (openEntryId == null) {
      await repo.clockIn(uid, workplaceId);
    } else {
      await repo.clockOut(uid, workplaceId, openEntryId);
    }
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
