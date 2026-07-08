import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import '../models/time_entry.dart';
import '../models/workplace.dart';

DateTime _timeToday(DateTime day, String hhmm) {
  final parts = hhmm.split(':');
  return DateTime(
    day.year,
    day.month,
    day.day,
    int.parse(parts[0]),
    int.parse(parts[1]),
  );
}

double _epochSeconds(DateTime t) => t.millisecondsSinceEpoch / 1000;

/// Pushes today's shift data to the iOS home-screen widget via the shared
/// App Group, so it can show live progress/earnings without the app running
/// (see ios/WorkTimerWidget/WorkTimerWidget.swift for how it's consumed).
class WidgetSyncService {
  static const appGroupId = 'group.com.jp.worktimer.widget';
  static const iOSWidgetName = 'WorkTimerWidget';

  Future<void> init() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  Future<void> sync({required Workplace? workplace, required TimeEntry? entry}) async {
    if (workplace == null) {
      await HomeWidget.saveWidgetData<bool>('hasWorkplace', false);
    } else {
      final today = DateTime.now();
      final scheduledStart = _timeToday(today, workplace.startTime);
      final scheduledEnd = entry?.scheduledEndOverride ?? _timeToday(today, workplace.endTime);

      await HomeWidget.saveWidgetData<bool>('hasWorkplace', true);
      await HomeWidget.saveWidgetData<int>('hourlyWage', workplace.hourlyWage);
      await HomeWidget.saveWidgetData<int>('overtimeRatePercent', workplace.overtimeRatePercent);
      // The per-entry value, not the workplace default — matches what
      // earnings_calculator.dart actually subtracts (it was set to the
      // workplace's default break at clock-in time, but can be corrected
      // per-day independently of it).
      await HomeWidget.saveWidgetData<int>('breakMinutes', entry?.breakMinutes ?? workplace.breakMinutes);
      await HomeWidget.saveWidgetData<double>('scheduledStartEpoch', _epochSeconds(scheduledStart));
      await HomeWidget.saveWidgetData<double>('scheduledEndEpoch', _epochSeconds(scheduledEnd));
      final clockOut = entry?.clockOut;
      await HomeWidget.saveWidgetData<double?>(
        'clockInEpoch',
        entry == null ? null : _epochSeconds(entry.clockIn),
      );
      await HomeWidget.saveWidgetData<double?>(
        'clockOutEpoch',
        clockOut == null ? null : _epochSeconds(clockOut),
      );
      // Ad-hoc breaks started/stopped during the shift — earnings_calculator
      // deducts these on top of breakMinutes, so the widget needs them too
      // or it overstates earnings whenever one is taken (or ongoing).
      final extraBreaksJson = jsonEncode(
        (entry?.extraBreaks ?? const []).map((b) {
          return {
            'start': _epochSeconds(b.start),
            'end': b.end == null ? null : _epochSeconds(b.end!),
          };
        }).toList(),
      );
      await HomeWidget.saveWidgetData<String>('extraBreaksJson', extraBreaksJson);
    }
    await HomeWidget.updateWidget(iOSName: iOSWidgetName);
  }
}
