import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employment_type.dart';
import '../models/industry.dart';
import '../models/workplace.dart';
import '../providers/auth_providers.dart';
import '../providers/firebase_providers.dart';
import 'settings_ui.dart';
import 'time_field.dart';

const _unset = '未設定';

/// Create/edit form for a [Workplace]. Shared between the settings screen
/// and the onboarding flow's setup step.
///
/// When editing an existing workplace, every field saves itself immediately
/// (on picker selection or once a text field loses focus) — there's no
/// separate save button to press. Creating a brand new workplace still uses
/// an explicit submit button, since required fields start out empty/invalid.
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
  late final FocusNode _wageFocus;
  late final FocusNode _breakFocus;
  late final FocusNode _overtimeFocus;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late TimeOfDay _breakStartTime;
  Industry? _industry;
  EmploymentType? _employmentType;

  bool get _isEditing => widget.workplace != null;

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

    _wageFocus = FocusNode()..addListener(() => _onFocusChange(_wageFocus));
    _breakFocus = FocusNode()..addListener(() => _onFocusChange(_breakFocus));
    _overtimeFocus = FocusNode()..addListener(() => _onFocusChange(_overtimeFocus));
  }

  void _onFocusChange(FocusNode node) {
    if (!node.hasFocus) _autoSave();
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
    _wageFocus.dispose();
    _breakFocus.dispose();
    _overtimeFocus.dispose();
    super.dispose();
  }

  /// Used while editing an existing workplace — silently does nothing if a
  /// text field is currently invalid, since there's no submit button to
  /// surface the error against.
  Future<void> _autoSave() async {
    if (!_isEditing) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _persist();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await _persist();
    if (mounted) widget.onSaved?.call();
  }

  Future<void> _persist() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final repo = ref.read(workplaceRepositoryProvider);
    final existing = widget.workplace;

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
          createdAt: DateTime.now(),
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
  }

  void _onPickerChanged(VoidCallback apply) {
    setState(apply);
    if (_isEditing) _autoSave();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SettingsSection(
        icon: Icons.storefront_outlined,
        title: '勤務先',
        children: [
          if (widget.showOptionalDetails) ...[
            SettingsPickerRow<Industry?>(
              label: '業種',
              value: _industry,
              options: [null, ...Industry.values],
              labelOf: (v) => v?.label ?? _unset,
              onChanged: (v) => _onPickerChanged(() => _industry = v),
            ),
            const SizedBox(height: 10),
            SettingsPickerRow<EmploymentType?>(
              label: '雇用形態',
              value: _employmentType,
              options: [null, ...EmploymentType.values],
              labelOf: (v) => v?.label ?? _unset,
              onChanged: (v) => _onPickerChanged(() => _employmentType = v),
            ),
            const SizedBox(height: 10),
          ],
          SettingsAmountField(
            label: '時給',
            controller: _wageController,
            focusNode: _wageFocus,
            suffixText: '円',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            validator: (v) => (v == null || int.tryParse(v) == null) ? '数値を入力してください' : null,
          ),
          const SizedBox(height: 10),
          TimeField(
            label: '始業時刻',
            icon: Icons.wb_sunny_outlined,
            value: _startTime,
            onChanged: (t) => _onPickerChanged(() => _startTime = t),
          ),
          const SizedBox(height: 10),
          TimeField(
            label: '終業時刻（定時）',
            icon: Icons.bedtime_outlined,
            value: _endTime,
            onChanged: (t) => _onPickerChanged(() => _endTime = t),
          ),
          const SizedBox(height: 10),
          TimeField(
            label: '休憩開始',
            icon: Icons.restaurant_outlined,
            value: _breakStartTime,
            onChanged: (t) => _onPickerChanged(() => _breakStartTime = t),
          ),
          const SizedBox(height: 10),
          SettingsAmountField(
            label: '休憩時間',
            controller: _breakController,
            focusNode: _breakFocus,
            suffixText: '分',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            validator: (v) => (v == null || int.tryParse(v) == null) ? '数値を入力してください' : null,
          ),
          const SizedBox(height: 10),
          SettingsAmountField(
            label: '残業時の時給アップ率',
            controller: _overtimeController,
            focusNode: _overtimeFocus,
            suffixText: '%',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            validator: (v) => (v == null || int.tryParse(v) == null) ? '数値を入力してください' : null,
            helperText: '定時を過ぎたら時給が何%増えるか。目安は25%（法律上の最低ライン）',
          ),
          if (!_isEditing) ...[
            const SizedBox(height: 20),
            FilledButton(onPressed: _submit, child: const Text('登録する')),
          ],
        ],
      ),
    );
  }
}
