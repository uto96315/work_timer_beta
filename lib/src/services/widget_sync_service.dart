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
      await HomeWidget.saveWidgetData<int>('breakMinutes', workplace.breakMinutes);
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
    }
    await HomeWidget.updateWidget(iOSName: iOSWidgetName);
  }
}
