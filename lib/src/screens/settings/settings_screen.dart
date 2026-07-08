import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/workplace.dart';
import '../../providers/auth_providers.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/workplace_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workplaceAsync = ref.watch(primaryWorkplaceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: workplaceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (workplace) => _WorkplaceForm(workplace: workplace),
      ),
    );
  }
}

class _WorkplaceForm extends ConsumerStatefulWidget {
  const _WorkplaceForm({required this.workplace});

  final Workplace? workplace;

  @override
  ConsumerState<_WorkplaceForm> createState() => _WorkplaceFormState();
}

class _WorkplaceFormState extends ConsumerState<_WorkplaceForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _wageController;
  late final TextEditingController _breakController;
  late final TextEditingController _overtimeController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    final w = widget.workplace;
    _nameController = TextEditingController(text: w?.name ?? '');
    _wageController = TextEditingController(text: w?.hourlyWage.toString() ?? '');
    _breakController = TextEditingController(text: w?.breakMinutes.toString() ?? '60');
    _overtimeController =
        TextEditingController(text: w?.overtimeRatePercent.toString() ?? '25');
    _startTime = _parseTime(w?.startTime) ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = _parseTime(w?.endTime) ?? const TimeOfDay(hour: 18, minute: 0);
  }

  TimeOfDay? _parseTime(String? hhmm) {
    if (hhmm == null) return null;
    final parts = hhmm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _nameController.dispose();
    _wageController.dispose();
    _breakController.dispose();
    _overtimeController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final repo = ref.read(workplaceRepositoryProvider);
    final existing = widget.workplace;
    final now = DateTime.now();

    if (existing == null) {
      await repo.create(
        uid,
        Workplace(
          id: '',
          name: _nameController.text,
          hourlyWage: int.parse(_wageController.text),
          startTime: _formatTime(_startTime),
          endTime: _formatTime(_endTime),
          breakMinutes: int.parse(_breakController.text),
          overtimeRatePercent: int.parse(_overtimeController.text),
          createdAt: now,
        ),
      );
    } else {
      await repo.update(
        uid,
        existing.copyWith(
          name: _nameController.text,
          hourlyWage: int.parse(_wageController.text),
          startTime: _formatTime(_startTime),
          endTime: _formatTime(_endTime),
          breakMinutes: int.parse(_breakController.text),
          overtimeRatePercent: int.parse(_overtimeController.text),
        ),
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存しました')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '勤務先名'),
            validator: (v) => (v == null || v.isEmpty) ? '入力してください' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _wageController,
            decoration: const InputDecoration(labelText: '時給（円）'),
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || int.tryParse(v) == null) ? '数値を入力してください' : null,
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('始業時刻'),
            trailing: Text(_formatTime(_startTime)),
            onTap: () => _pickTime(true),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('終業時刻（定時）'),
            trailing: Text(_formatTime(_endTime)),
            onTap: () => _pickTime(false),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _breakController,
            decoration: const InputDecoration(labelText: '休憩時間（分）'),
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || int.tryParse(v) == null) ? '数値を入力してください' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _overtimeController,
            decoration: const InputDecoration(labelText: '残業割増率（%）'),
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || int.tryParse(v) == null) ? '数値を入力してください' : null,
          ),
          const SizedBox(height: 32),
          FilledButton(onPressed: _save, child: const Text('保存')),
        ],
      ),
    );
  }
}
