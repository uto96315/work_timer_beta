import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workplace.dart';
import '../providers/auth_providers.dart';
import '../providers/firebase_providers.dart';
import 'time_field.dart';

/// Create/edit form for a [Workplace]. Shared between the settings screen
/// and the onboarding flow's setup step.
class WorkplaceForm extends ConsumerStatefulWidget {
  const WorkplaceForm({
    super.key,
    required this.workplace,
    this.onSaved,
    this.showNameField = true,
  });

  final Workplace? workplace;
  final VoidCallback? onSaved;

  /// The onboarding flow skips the workplace name to keep first setup short;
  /// it can be filled in later from the settings screen.
  final bool showNameField;

  @override
  ConsumerState<WorkplaceForm> createState() => _WorkplaceFormState();
}

class _WorkplaceFormState extends ConsumerState<WorkplaceForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _wageController;
  late final TextEditingController _breakController;
  late final TextEditingController _overtimeController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late TimeOfDay _breakStartTime;

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
    _breakStartTime = _parseTime(w?.breakStartTime) ?? const TimeOfDay(hour: 12, minute: 0);
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final repo = ref.read(workplaceRepositoryProvider);
    final existing = widget.workplace;
    final now = DateTime.now();
    final name = _nameController.text.trim().isEmpty ? null : _nameController.text.trim();

    if (existing == null) {
      await repo.create(
        uid,
        Workplace(
          id: '',
          name: name,
          hourlyWage: int.parse(_wageController.text),
          startTime: _formatTime(_startTime),
          endTime: _formatTime(_endTime),
          breakMinutes: int.parse(_breakController.text),
          breakStartTime: _formatTime(_breakStartTime),
          overtimeRatePercent: int.parse(_overtimeController.text),
          createdAt: now,
        ),
      );
    } else {
      await repo.update(
        uid,
        existing.copyWith(
          name: name,
          hourlyWage: int.parse(_wageController.text),
          startTime: _formatTime(_startTime),
          endTime: _formatTime(_endTime),
          breakMinutes: int.parse(_breakController.text),
          breakStartTime: _formatTime(_breakStartTime),
          overtimeRatePercent: int.parse(_overtimeController.text),
        ),
      );
    }

    if (mounted) {
      widget.onSaved?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.showNameField) ...[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '勤務先名（任意）'),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _wageController,
            decoration: const InputDecoration(labelText: '時給（円）'),
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || int.tryParse(v) == null) ? '数値を入力してください' : null,
          ),
          const SizedBox(height: 20),
          TimeField(
            label: '始業時刻',
            icon: Icons.wb_sunny_outlined,
            value: _startTime,
            onChanged: (t) => setState(() => _startTime = t),
          ),
          const SizedBox(height: 12),
          TimeField(
            label: '終業時刻（定時）',
            icon: Icons.bedtime_outlined,
            value: _endTime,
            onChanged: (t) => setState(() => _endTime = t),
          ),
          const SizedBox(height: 12),
          TimeField(
            label: '休憩開始',
            icon: Icons.restaurant_outlined,
            value: _breakStartTime,
            onChanged: (t) => setState(() => _breakStartTime = t),
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
            decoration: const InputDecoration(
              labelText: '残業時の時給アップ率（%）',
              helperText: '定時を過ぎたら時給が何%増えるか。目安は25%（法律上の最低ライン）',
              helperMaxLines: 2,
            ),
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
