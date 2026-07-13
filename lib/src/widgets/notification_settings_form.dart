import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../providers/auth_providers.dart';
import '../providers/firebase_providers.dart';
import '../providers/notification_providers.dart';
import 'settings_ui.dart';

/// Notification toggles, stored on the top-level `users/{uid}` doc. A single
/// master switch, plus separate switches for the clock-in/clock-out time
/// reminders so the user can silence one without the other.
class NotificationSettingsForm extends ConsumerWidget {
  const NotificationSettingsForm({super.key, required this.profile});

  final UserProfile profile;

  Future<void> _update(WidgetRef ref, UserProfile updated) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await ref.read(userProfileRepositoryProvider).update(uid, updated);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsSection(
      icon: Icons.notifications_outlined,
      title: '通知',
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('通知を受け取る'),
          value: profile.notificationsEnabled,
          onChanged: (v) async {
            if (v) await ref.read(notificationServiceProvider).requestPermissions();
            await _update(ref, profile.copyWith(notificationsEnabled: v));
          },
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('出勤予定時刻の通知'),
          value: profile.notifyClockInReminder,
          onChanged: !profile.notificationsEnabled
              ? null
              : (v) => _update(ref, profile.copyWith(notifyClockInReminder: v)),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('退勤予定時刻の通知'),
          value: profile.notifyClockOutReminder,
          onChanged: !profile.notificationsEnabled
              ? null
              : (v) =>
                    _update(ref, profile.copyWith(notifyClockOutReminder: v)),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('給料日の通知'),
          value: profile.notifyPayday,
          onChanged: !profile.notificationsEnabled
              ? null
              : (v) => _update(ref, profile.copyWith(notifyPayday: v)),
        ),
      ],
    );
  }
}

/// Controls whether overtime is counted automatically past the scheduled end
/// time, or the live count freezes there until the user opts in (see
/// [lib/src/util/earnings_calculator.dart] callers in home_screen.dart).
class OvertimeSettingsForm extends ConsumerWidget {
  const OvertimeSettingsForm({super.key, required this.profile});

  final UserProfile profile;

  Future<void> _update(WidgetRef ref, UserProfile updated) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await ref.read(userProfileRepositoryProvider).update(uid, updated);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsSection(
      icon: Icons.timer_outlined,
      title: '残業',
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('残業を自動計測する'),
          subtitle: const Text(
            'オフの場合、定時になると計測が止まり、通知で残業を記録するか確認します。',
          ),
          value: profile.autoOvertimeEnabled,
          onChanged: (v) => _update(ref, profile.copyWith(autoOvertimeEnabled: v)),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('残業中の通知'),
          trailing: DropdownButton<int>(
            value: profile.overtimeReminderIntervalHours,
            items: const [
              DropdownMenuItem(value: 0, child: Text('なし')),
              DropdownMenuItem(value: 1, child: Text('1時間ごと')),
              DropdownMenuItem(value: 2, child: Text('2時間ごと')),
              DropdownMenuItem(value: 3, child: Text('3時間ごと')),
            ],
            onChanged: !profile.autoOvertimeEnabled
                ? null
                : (v) => _update(
                    ref,
                    profile.copyWith(overtimeReminderIntervalHours: v!),
                  ),
          ),
        ),
      ],
    );
  }
}
