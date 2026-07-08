import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/notification_service.dart';
import 'user_profile_providers.dart';
import 'workplace_providers.dart';

part 'notification_providers.g.dart';

/// Overridden in `main.dart` with an instance that has already had
/// [NotificationService.init] called on it.
@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  throw UnimplementedError('notificationServiceProvider must be overridden');
}

/// Watching this anywhere keeps the scheduled reminders in sync with the
/// current workplace hours and notification preferences.
@riverpod
Future<void> notificationSync(Ref ref) async {
  final workplace = ref.watch(primaryWorkplaceProvider).value;
  final profile = ref.watch(userProfileProvider).value;
  if (profile == null) return;
  await ref.watch(notificationServiceProvider).syncSchedule(workplace, profile);
}
