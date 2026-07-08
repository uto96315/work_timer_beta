import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/user_profile.dart';
import '../models/workplace.dart';

/// Schedules recurring "clock-in/clock-out time is coming up" local
/// notifications based on the workplace's schedule and the user's
/// notification preferences.
///
/// Notification ids are `weekday * 10 + slot`, where `slot` is 0 for the
/// clock-in reminder and 1 for the clock-out reminder, so each weekday's
/// pair of notifications can be individually replaced/cancelled.
class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channelId = 'shift_reminders';
  static const _channelName = 'シフトの通知';

  Future<void> init() async {
    tz_data.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  int _id(int weekday, int slot) => weekday * 10 + slot;

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

  tz.TZDateTime _nextInstanceOf(DateTime time, int weekday) {
    var scheduled = tz.TZDateTime.from(time, tz.local);
    final now = tz.TZDateTime.now(tz.local);
    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Cancels all previously scheduled reminders, then reschedules them from
  /// scratch based on the current workplace hours and notification prefs.
  /// Safe to call every time either changes.
  Future<void> syncSchedule(Workplace? workplace, UserProfile profile) async {
    await _plugin.cancelAll();
    if (workplace == null || !profile.notificationsEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final now = DateTime.now();
    for (var weekday = 1; weekday <= 7; weekday++) {
      if (workplace.holidayWeekdays.contains(weekday)) continue;

      if (profile.notifyClockInReminder) {
        await _plugin.zonedSchedule(
          id: _id(weekday, 0),
          title: '出勤予定の時間です',
          body: '${workplace.startTime} 出勤予定です。忘れずに打刻しましょう。',
          scheduledDate: _nextInstanceOf(_timeToday(now, workplace.startTime), weekday),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
      if (profile.notifyClockOutReminder) {
        await _plugin.zonedSchedule(
          id: _id(weekday, 1),
          title: '退勤予定の時間です',
          body: '${workplace.endTime} 退勤予定です。お疲れ様でした。',
          scheduledDate: _nextInstanceOf(_timeToday(now, workplace.endTime), weekday),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }
}
