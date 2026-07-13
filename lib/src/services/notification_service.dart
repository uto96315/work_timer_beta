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

  /// Number of "still on overtime" reminders to schedule, past the
  /// weekday*10+1 clock-out reminder slot, spaced by
  /// [UserProfile.overtimeReminderIntervalHours]. Fixed at 3 occurrences —
  /// local notifications can't dynamically extend based on actual clock-out,
  /// so this is a reasonable cap rather than tracking the real shift length.
  static const _overtimeReminderCount = 3;

  /// Outside the 10-72 range used by [_id]'s weekday*10+slot scheme.
  static const _paydayId = 900;

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

  /// Next occurrence of [day] (1-31) at [time]'s hour/minute. Months shorter
  /// than [day] simply roll over into the next month (e.g. day 31 in April
  /// becomes May 1st), which is an acceptable approximation for a payday
  /// reminder rather than more elaborate "last day of month" clamping.
  tz.TZDateTime _nextInstanceOfDayOfMonth(DateTime time, int day) {
    var scheduled = tz.TZDateTime(tz.local, time.year, time.month, day, time.hour, time.minute);
    final now = tz.TZDateTime.now(tz.local);
    while (scheduled.isBefore(now)) {
      scheduled = tz.TZDateTime(tz.local, scheduled.year, scheduled.month + 1, day, time.hour, time.minute);
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
          title: profile.autoOvertimeEnabled ? '退勤予定の時間です' : '定時になりました',
          body: profile.autoOvertimeEnabled
              ? '${workplace.endTime} 退勤予定です。お疲れ様でした。'
              : '${workplace.endTime} になりました。残業を記録する場合はアプリを開いて確認しましょう。',
          scheduledDate: _nextInstanceOf(_timeToday(now, workplace.endTime), weekday),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
      final reminderInterval = profile.overtimeReminderIntervalHours;
      if (profile.autoOvertimeEnabled && reminderInterval > 0) {
        for (var i = 0; i < _overtimeReminderCount; i++) {
          final hoursAfterEnd = reminderInterval * (i + 1);
          final reminderTime = _timeToday(
            now,
            workplace.endTime,
          ).add(Duration(hours: hoursAfterEnd));
          await _plugin.zonedSchedule(
            id: _id(weekday, 2 + i),
            title: '残業中です',
            body: '定時から$hoursAfterEnd時間経過しました。忘れずに退勤打刻をしましょう。',
            scheduledDate: _nextInstanceOf(reminderTime, weekday),
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      }
    }

    if (workplace.payday != null && profile.notifyPayday) {
      // Fixed at 9:00 regardless of when the sync happens to run, so the
      // reminder time doesn't drift with whenever the app was last opened.
      final paydayTime = DateTime(now.year, now.month, now.day, 9, 0);
      await _plugin.zonedSchedule(
        id: _paydayId,
        title: '本日は給料日です',
        body: '給与明細を確認しましょう。',
        scheduledDate: _nextInstanceOfDayOfMonth(paydayTime, workplace.payday!),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    }
  }
}
