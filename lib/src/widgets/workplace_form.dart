import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/employment_type.dart';
import '../models/industry.dart';
import '../models/salary_type.dart';
import '../models/workplace.dart';
import '../providers/auth_providers.dart';
import '../providers/firebase_providers.dart';
import '../services/geofence_clock_trigger_service.dart';
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
  late final TextEditingController _baseSalaryController;
  late final TextEditingController _fixedOvertimeAllowanceController;
  late final TextEditingController _fixedOvertimeHoursController;
  late final TextEditingController _standardMonthlyHoursController;
  late final FocusNode _wageFocus;
  late final FocusNode _breakFocus;
  late final FocusNode _overtimeFocus;
  late final FocusNode _baseSalaryFocus;
  late final FocusNode _fixedOvertimeAllowanceFocus;
  late final FocusNode _fixedOvertimeHoursFocus;
  late final FocusNode _standardMonthlyHoursFocus;
  bool _fetchingLocation = false;
  double? _autoClockInLatitude;
  double? _autoClockInLongitude;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late TimeOfDay _breakStartTime;
  Industry? _industry;
  EmploymentType? _employmentType;
  late SalaryType _salaryType;
  int? _payday;
  late Set<int> _holidayWeekdays;

  bool get _isEditing => widget.workplace != null;

  @override
  void initState() {
    super.initState();
    final w = widget.workplace;
    _wageController = TextEditingController(text: w?.hourlyWage.toString() ?? '');
    _breakController = TextEditingController(text: w?.breakMinutes.toString() ?? '60');
    _overtimeController =
        TextEditingController(text: w?.overtimeRatePercent.toString() ?? '25');
    _baseSalaryController =
        TextEditingController(text: w?.baseMonthlySalary?.toString() ?? '');
    _fixedOvertimeAllowanceController =
        TextEditingController(text: w?.fixedOvertimeAllowance?.toString() ?? '0');
    _fixedOvertimeHoursController =
        TextEditingController(text: w?.fixedOvertimeHours?.toString() ?? '0');
    _standardMonthlyHoursController =
        TextEditingController(text: w?.standardMonthlyHours?.toString() ?? '');
    _autoClockInLatitude = w?.autoClockInLatitude;
    _autoClockInLongitude = w?.autoClockInLongitude;
    _startTime = _parseTime(w?.startTime) ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = _parseTime(w?.endTime) ?? const TimeOfDay(hour: 18, minute: 0);
    _breakStartTime = _parseTime(w?.breakStartTime) ?? const TimeOfDay(hour: 12, minute: 0);
    _industry = w?.industry;
    _employmentType = w?.employmentType;
    _salaryType = w?.salaryType ?? SalaryType.hourly;
    _payday = w?.payday;
    _holidayWeekdays = {...(w?.holidayWeekdays ?? const [])};

    _wageFocus = FocusNode()..addListener(() => _onFocusChange(_wageFocus));
    _breakFocus = FocusNode()..addListener(() => _onFocusChange(_breakFocus));
    _overtimeFocus = FocusNode()..addListener(() => _onFocusChange(_overtimeFocus));
    _baseSalaryFocus = FocusNode()..addListener(() => _onFocusChange(_baseSalaryFocus));
    _fixedOvertimeAllowanceFocus =
        FocusNode()..addListener(() => _onFocusChange(_fixedOvertimeAllowanceFocus));
    _fixedOvertimeHoursFocus =
        FocusNode()..addListener(() => _onFocusChange(_fixedOvertimeHoursFocus));
    _standardMonthlyHoursFocus =
        FocusNode()..addListener(() => _onFocusChange(_standardMonthlyHoursFocus));

    // Live-updates the derived hourly-wage preview as any monthly field
    // changes, without waiting for the field to lose focus (autosave).
    for (final c in [
      _baseSalaryController,
      _fixedOvertimeAllowanceController,
      _fixedOvertimeHoursController,
      _standardMonthlyHoursController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  /// Blended average hourly rate for the live counter: total monthly pay
  /// (base + fixed overtime allowance) spread over total expected hours
  /// (contracted + fixed overtime). Deliberately not the legally-correct
  /// base rate used for unpaid-overtime calculations — see
  /// `earnings_calculator.dart`'s `baseHourlyWage`.
  int? _monthlyEffectiveHourlyWage() {
    final base = int.tryParse(_baseSalaryController.text);
    final standardHours = double.tryParse(_standardMonthlyHoursController.text);
    if (base == null || standardHours == null || standardHours <= 0) return null;
    final allowance = int.tryParse(_fixedOvertimeAllowanceController.text) ?? 0;
    final fixedHours = double.tryParse(_fixedOvertimeHoursController.text) ?? 0;
    final totalHours = standardHours + fixedHours;
    if (totalHours <= 0) return null;
    return ((base + allowance) / totalHours).round();
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
    _baseSalaryController.dispose();
    _fixedOvertimeAllowanceController.dispose();
    _fixedOvertimeHoursController.dispose();
    _standardMonthlyHoursController.dispose();
    _wageFocus.dispose();
    _breakFocus.dispose();
    _overtimeFocus.dispose();
    _baseSalaryFocus.dispose();
    _fixedOvertimeAllowanceFocus.dispose();
    _fixedOvertimeHoursFocus.dispose();
    _standardMonthlyHoursFocus.dispose();
    super.dispose();
  }

  /// Registers the device's current GPS position as the auto clock-in/out
  /// geofence. Requests "always" location permission — required so the
  /// geofence can still fire while the app is backgrounded or terminated.
  Future<void> _registerCurrentLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      final granted = await GeofenceClockTriggerService().requestPermissions();
      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('位置情報の「常に許可」が必要です')),
        );
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _autoClockInLatitude = position.latitude;
        _autoClockInLongitude = position.longitude;
      });
      if (_isEditing) _autoSave();
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  Future<void> _clearAutoClockInLocation() async {
    setState(() {
      _autoClockInLatitude = null;
      _autoClockInLongitude = null;
    });
    if (_isEditing) _autoSave();
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

  bool get _isMonthly => _salaryType == SalaryType.monthly;

  /// For monthly salaries this is derived, not user-entered — see
  /// [_monthlyEffectiveHourlyWage].
  int _resolvedHourlyWage() =>
      _isMonthly ? (_monthlyEffectiveHourlyWage() ?? 0) : int.parse(_wageController.text);

  int? get _resolvedBaseMonthlySalary =>
      _isMonthly ? int.tryParse(_baseSalaryController.text) : null;

  int? get _resolvedFixedOvertimeAllowance =>
      _isMonthly ? (int.tryParse(_fixedOvertimeAllowanceController.text) ?? 0) : null;

  double? get _resolvedFixedOvertimeHours =>
      _isMonthly ? (double.tryParse(_fixedOvertimeHoursController.text) ?? 0) : null;

  double? get _resolvedStandardMonthlyHours =>
      _isMonthly ? double.tryParse(_standardMonthlyHoursController.text) : null;

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
          salaryType: _salaryType,
          hourlyWage: _resolvedHourlyWage(),
          baseMonthlySalary: _resolvedBaseMonthlySalary,
          fixedOvertimeAllowance: _resolvedFixedOvertimeAllowance,
          fixedOvertimeHours: _resolvedFixedOvertimeHours,
          standardMonthlyHours: _resolvedStandardMonthlyHours,
          startTime: _formatTime(_startTime),
          endTime: _formatTime(_endTime),
          breakMinutes: int.parse(_breakController.text),
          breakStartTime: _formatTime(_breakStartTime),
          overtimeRatePercent: int.parse(_overtimeController.text),
          payday: _payday,
          holidayWeekdays: _holidayWeekdays.toList()..sort(),
          autoClockInLatitude: _autoClockInLatitude,
          autoClockInLongitude: _autoClockInLongitude,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      await repo.update(
        uid,
        existing.copyWith(
          industry: _industry,
          employmentType: _employmentType,
          salaryType: _salaryType,
          hourlyWage: _resolvedHourlyWage(),
          baseMonthlySalary: _resolvedBaseMonthlySalary,
          fixedOvertimeAllowance: _resolvedFixedOvertimeAllowance,
          fixedOvertimeHours: _resolvedFixedOvertimeHours,
          standardMonthlyHours: _resolvedStandardMonthlyHours,
          startTime: _formatTime(_startTime),
          endTime: _formatTime(_endTime),
          breakMinutes: int.parse(_breakController.text),
          breakStartTime: _formatTime(_breakStartTime),
          overtimeRatePercent: int.parse(_overtimeController.text),
          payday: _payday,
          holidayWeekdays: _holidayWeekdays.toList()..sort(),
          autoClockInLatitude: _autoClockInLatitude,
          autoClockInLongitude: _autoClockInLongitude,
        ),
      );
    }
  }

  void _onPickerChanged(VoidCallback apply) {
    setState(apply);
    if (_isEditing) _autoSave();
  }

  void _toggleHoliday(int weekday) {
    setState(() {
      if (_holidayWeekdays.contains(weekday)) {
        _holidayWeekdays.remove(weekday);
      } else {
        _holidayWeekdays.add(weekday);
      }
    });
    if (_isEditing) _autoSave();
  }

  List<Widget> _buildMonthlySalaryFields() {
    final effectiveWage = _monthlyEffectiveHourlyWage();
    return [
      SettingsAmountField(
        label: '基本給',
        controller: _baseSalaryController,
        focusNode: _baseSalaryFocus,
        suffixText: '円',
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        validator: (v) => (v == null || int.tryParse(v) == null) ? '数値を入力してください' : null,
        helperText:
            '固定残業手当を除いた月額。通勤手当・住宅手当なども除く。'
            '給与明細に固定残業代の内訳が書かれていない場合は、月給の全額をここに入力してください',
      ),
      const SizedBox(height: 10),
      SettingsAmountField(
        label: '月平均所定労働時間',
        controller: _standardMonthlyHoursController,
        focusNode: _standardMonthlyHoursFocus,
        suffixText: '時間',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        validator: (v) =>
            (v == null || double.tryParse(v) == null || double.parse(v) <= 0)
            ? '数値を入力してください'
            : null,
        helperText: '残業を含まない、契約上の月間労働時間。目安は160〜173時間',
      ),
      const SizedBox(height: 10),
      SettingsAmountField(
        label: '固定残業手当',
        controller: _fixedOvertimeAllowanceController,
        focusNode: _fixedOvertimeAllowanceFocus,
        suffixText: '円',
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        validator: (v) => (v == null || int.tryParse(v) == null) ? '数値を入力してください' : null,
        helperText: 'みなし残業代・固定残業代がなければ0円',
      ),
      const SizedBox(height: 10),
      SettingsAmountField(
        label: '見込み残業時間',
        controller: _fixedOvertimeHoursController,
        focusNode: _fixedOvertimeHoursFocus,
        suffixText: '時間',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        validator: (v) => (v == null || double.tryParse(v) == null) ? '数値を入力してください' : null,
        helperText: '固定残業手当に含まれる残業時間。これを超えた分が未払いの可能性ありとして計算されます',
      ),
      const SizedBox(height: 10),
      _ReadOnlyValueRow(
        label: '実質時給（表示用）',
        value: effectiveWage == null ? '—' : '¥$effectiveWage',
      ),
      const SizedBox(height: 10),
    ];
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
          SettingsPickerRow<SalaryType>(
            label: '給与形態',
            value: _salaryType,
            options: SalaryType.values,
            labelOf: (v) => v.label,
            onChanged: (v) => _onPickerChanged(() => _salaryType = v),
          ),
          const SizedBox(height: 10),
          if (_isMonthly) ..._buildMonthlySalaryFields() else ...[
            SettingsAmountField(
              label: '時給',
              controller: _wageController,
              focusNode: _wageFocus,
              suffixText: '円',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              validator: (v) =>
                  (v == null || int.tryParse(v) == null) ? '数値を入力してください' : null,
            ),
            const SizedBox(height: 10),
          ],
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
          const SizedBox(height: 10),
          SettingsPickerRow<int?>(
            label: '給料日',
            value: _payday,
            options: [null, ...List.generate(31, (i) => i + 1)],
            labelOf: (v) => v == null ? _unset : '$v日',
            onChanged: (v) => _onPickerChanged(() => _payday = v),
          ),
          const SizedBox(height: 10),
          _HolidayWeekdaysField(
            selected: _holidayWeekdays,
            onToggle: _toggleHoliday,
          ),
          const SizedBox(height: 10),
          _AutoClockInLocationField(
            hasLocation: _autoClockInLatitude != null,
            fetching: _fetchingLocation,
            onRegister: _registerCurrentLocation,
            onClear: _clearAutoClockInLocation,
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

/// A non-interactive row matching [SettingsPickerRow]'s look, for showing a
/// derived value (e.g. the monthly-salary effective hourly wage) that the
/// user can't edit directly.
class _ReadOnlyValueRow extends StatelessWidget {
  const _ReadOnlyValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

const _weekdayLabels = ['月', '火', '水', '木', '金', '土', '日'];

/// Multi-select weekday chips for [Workplace.holidayWeekdays] (ISO weekday
/// numbers, 1=Mon..7=Sun) — days the app should treat as off, skipping
/// auto clock-in and daily work tracking.
class _HolidayWeekdaysField extends StatelessWidget {
  const _HolidayWeekdaysField({required this.selected, required this.onToggle});

  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('定休日', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _weekdayLabels.length; i++)
              FilterChip(
                label: Text(_weekdayLabels[i]),
                selected: selected.contains(i + 1),
                onSelected: (_) => onToggle(i + 1),
                selectedColor: scheme.primary.withValues(alpha: 0.16),
                checkmarkColor: scheme.primary,
              ),
          ],
        ),
      ],
    );
  }
}

/// Registers/clears the GPS geofence used for [Workplace.autoClockInLatitude]
/// / [Workplace.autoClockInLongitude] — auto clock-in/out on arrival/departure
/// from this location, even while the app is backgrounded or terminated.
class _AutoClockInLocationField extends StatelessWidget {
  const _AutoClockInLocationField({
    required this.hasLocation,
    required this.fetching,
    required this.onRegister,
    required this.onClear,
  });

  final bool hasLocation;
  final bool fetching;
  final VoidCallback onRegister;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('自動打刻用の位置（GPS）', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(
                hasLocation
                    ? '登録済み — この場所に着いたら自動で出勤、離れたら自動で退勤を記録します'
                    : '未登録 — 職場にいる状態でボタンを押すと現在地を登録します',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (hasLocation)
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.location_off_outlined),
            tooltip: '自動打刻の位置登録を解除',
          ),
        IconButton(
          onPressed: fetching ? null : onRegister,
          icon: fetching
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          tooltip: '現在地を登録',
        ),
      ],
    );
  }
}
