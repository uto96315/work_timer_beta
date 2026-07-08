import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employment_type.dart';
import '../models/industry.dart';
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
    this.showOptionalDetails = true,
  });

  final Workplace? workplace;
  final VoidCallback? onSaved;

  /// The onboarding flow skips industry/employment type to keep first setup
  /// short; they can be filled in later from the settings screen.
  final bool showOptionalDetails;

  @override
  ConsumerState<WorkplaceForm> createState() => _WorkplaceFormState();
}

class _WorkplaceFormState extends ConsumerState<WorkplaceForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _wageController;
  late final TextEditingController _breakController;
  late final TextEditingController _overtimeController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late TimeOfDay _breakStartTime;
  Industry? _industry;
  EmploymentType? _employmentType;

  @override
  void initState() {
    super.initState();
    final w = widget.workplace;
    _wageController = TextEditingController(text: w?.hourlyWage.toString() ?? '');
    _breakController = TextEditingController(text: w?.breakMinutes.toString() ?? '60');
    _overtimeController =
        TextEditingController(text: w?.overtimeRatePercent.toString() ?? '25');
    _startTime = _parseTime(w?.startTime) ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = _parseTime(w?.endTime) ?? const TimeOfDay(hour: 18, minute: 0);
    _breakStartTime = _parseTime(w?.breakStartTime) ?? const TimeOfDay(hour: 12, minute: 0);
    _industry = w?.industry;
    _employmentType = w?.employmentType;
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

    if (existing == null) {
      await repo.create(
        uid,
        Workplace(
          id: '',
          industry: _industry,
          employmentType: _employmentType,
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
          industry: _industry,
          employmentType: _employmentType,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showOptionalDetails) ...[
            DropdownButtonFormField<Industry?>(
              initialValue: _industry,
              decoration: const InputDecoration(labelText: '業種（任意）'),
              items: [
                const DropdownMenuItem(value: null, child: Text('未設定')),
                for (final industry in Industry.values)
                  DropdownMenuItem(value: industry, child: Text(industry.label)),
              ],
              onChanged: (v) => setState(() => _industry = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EmploymentType?>(
              initialValue: _employmentType,
              decoration: const InputDecoration(labelText: '雇用形態（任意）'),
              items: [
                const DropdownMenuItem(value: null, child: Text('未設定')),
                for (final type in EmploymentType.values)
                  DropdownMenuItem(value: type, child: Text(type.label)),
              ],
              onChanged: (v) => setState(() => _employmentType = v),
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
