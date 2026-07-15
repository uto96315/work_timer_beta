import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/monthly_payment.dart';
import '../../models/workplace.dart';
import '../../providers/auth_providers.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/monthly_payment_providers.dart';
import '../../providers/time_entry_providers.dart';
import '../../providers/workplace_providers.dart';
import '../../util/earnings_calculator.dart';
import '../../widgets/monthly_pay_chart.dart';
import '../../widgets/settings_ui.dart';
import 'month_entries_screen.dart';

final _yenFormat = NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0);
final _monthKeyFormat = DateFormat('yyyy-MM');
final _monthLabelFormat = DateFormat('M月');
final _monthTitleFormat = DateFormat('yyyy年M月');

/// Upper bound on how many months to show even for a long-tenured workplace,
/// so the list doesn't grow unbounded.
const _maxMonthsShown = 12;

/// Month starts from the workplace's creation month (never earlier — there's
/// no point showing months before the user started recording) through the
/// current, in-progress month, most recent last.
List<DateTime> _recordedMonthStarts(Workplace workplace) {
  final now = DateTime.now();
  final thisMonth = DateTime(now.year, now.month, 1);
  final createdMonth = DateTime(workplace.createdAt.year, workplace.createdAt.month, 1);
  final monthsSinceStart =
      (thisMonth.year - createdMonth.year) * 12 + (thisMonth.month - createdMonth.month) + 1;
  final count = monthsSinceStart.clamp(1, _maxMonthsShown);
  return List.generate(count, (i) => DateTime(thisMonth.year, thisMonth.month - i, 1))
      .reversed
      .toList();
}

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workplaceAsync = ref.watch(primaryWorkplaceProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: workplaceAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('エラー: $e')),
          data: (workplace) {
            if (workplace == null) {
              return const Center(child: Text('先に勤務先を登録してください'));
            }
            return _RecordsContent(workplace: workplace);
          },
        ),
      ),
    );
  }
}

class _RecordsContent extends ConsumerWidget {
  const _RecordsContent({required this.workplace});

  final Workplace workplace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final monthStarts = _recordedMonthStarts(workplace);
    final paymentsAsync = ref.watch(monthlyPaymentsProvider);
    final paymentsByMonth = <String, MonthlyPayment>{
      for (final p in paymentsAsync.value ?? const <MonthlyPayment>[]) p.id: p,
    };

    final rows = <_MonthRow>[];
    for (final monthStart in monthStarts) {
      final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 1);
      final entries =
          ref.watch(entriesInRangeProvider(monthStart, monthEnd)).value ?? const [];
      final calcNow = now.isBefore(monthEnd) ? now : monthEnd;
      // What the accumulated clock-in/out data adds up to so far this month
      // — not the configured salary, which stays flat regardless of
      // attendance and would misrepresent a partly-worked month.
      final totals = sumEarnings(workplace: workplace, entries: entries, now: calcNow);
      final monthKey = _monthKeyFormat.format(monthStart);
      rows.add(
        _MonthRow(
          monthStart: monthStart,
          monthKey: monthKey,
          expectedYen: totals.totalYen,
          overtimeSeconds: totals.overtimeSeconds,
          payment: paymentsByMonth[monthKey],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: MonthlyPayChart(
              points: [
                for (final r in rows)
                  MonthlyPayPoint(
                    label: _monthLabelFormat.format(r.monthStart),
                    expectedYen: r.expectedYen,
                    actualYen: r.payment?.receivedAmount.toDouble(),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final row in rows.reversed) ...[
          _MonthCard(workplace: workplace, row: row),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _MonthRow {
  const _MonthRow({
    required this.monthStart,
    required this.monthKey,
    required this.expectedYen,
    required this.overtimeSeconds,
    required this.payment,
  });

  final DateTime monthStart;
  final String monthKey;
  final double expectedYen;
  final int overtimeSeconds;
  final MonthlyPayment? payment;

  double? get diffYen =>
      payment == null ? null : expectedYen - payment!.receivedAmount;
}

class _MonthCard extends ConsumerWidget {
  const _MonthCard({required this.workplace, required this.row});

  final Workplace workplace;
  final _MonthRow row;

  Future<void> _editPayment(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<_PaymentInput>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _PaymentEditSheet(row: row),
    );
    if (result == null) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await ref.read(monthlyPaymentRepositoryProvider).upsert(
      uid,
      workplace.id,
      MonthlyPayment(
        id: row.monthKey,
        workplaceId: workplace.id,
        receivedAmount: result.amount,
        amountType: result.amountType,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diff = row.diffYen;
    final overtimeHours = row.overtimeSeconds ~/ 3600;
    final overtimeMinutes = (row.overtimeSeconds % 3600) ~/ 60;

    return SettingsSection(
      icon: Icons.calendar_month_outlined,
      title: _monthTitleFormat.format(row.monthStart),
      children: [
        _InfoLine(label: '想定給与', value: _yenFormat.format(row.expectedYen)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _InfoLine(label: '残業時間', value: '$overtimeHours時間$overtimeMinutes分'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      MonthEntriesScreen(workplace: workplace, monthStart: row.monthStart),
                ),
              ),
              child: const Text('記録を修正'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (row.payment == null)
          OutlinedButton.icon(
            onPressed: () => _editPayment(context, ref),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('実際に受け取った金額を記録する'),
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: _InfoLine(
                  label:
                      '実際の受取額（${row.payment!.amountType == PaymentAmountType.gross ? '総支給' : '手取り'}）',
                  value: _yenFormat.format(row.payment!.receivedAmount),
                ),
              ),
              IconButton(
                onPressed: () => _editPayment(context, ref),
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
            ],
          ),
          if (diff != null && diff > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange.shade800),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '未払いの可能性: ${_yenFormat.format(diff)}',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PaymentInput {
  const _PaymentInput({required this.amount, required this.amountType});
  final int amount;
  final PaymentAmountType amountType;
}

class _PaymentEditSheet extends StatefulWidget {
  const _PaymentEditSheet({required this.row});

  final _MonthRow row;

  @override
  State<_PaymentEditSheet> createState() => _PaymentEditSheetState();
}

class _PaymentEditSheetState extends State<_PaymentEditSheet> {
  late final TextEditingController _controller;
  late PaymentAmountType _amountType;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.row.payment?.receivedAmount.toString() ?? '',
    );
    _amountType = widget.row.payment?.amountType ?? PaymentAmountType.net;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = int.tryParse(_controller.text);
    if (amount == null) return;
    Navigator.of(context).pop(_PaymentInput(amount: amount, amountType: _amountType));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${_monthTitleFormat.format(widget.row.monthStart)}の受取額',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '金額',
              suffixText: '円',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<PaymentAmountType>(
            segments: const [
              ButtonSegment(value: PaymentAmountType.net, label: Text('手取り')),
              ButtonSegment(value: PaymentAmountType.gross, label: Text('総支給')),
            ],
            selected: {_amountType},
            onSelectionChanged: (s) => setState(() => _amountType = s.first),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _submit, child: const Text('保存')),
        ],
      ),
    );
  }
}
