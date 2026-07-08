import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/widget_sync_service.dart';
import 'time_entry_providers.dart';
import 'workplace_providers.dart';

part 'widget_sync_providers.g.dart';

/// Overridden in `main.dart` with an instance that has already had
/// [WidgetSyncService.init] called on it.
@Riverpod(keepAlive: true)
WidgetSyncService widgetSyncService(Ref ref) {
  throw UnimplementedError('widgetSyncServiceProvider must be overridden');
}

/// Watching this anywhere keeps the iOS home-screen widget's shared data in
/// sync with today's workplace hours and clock-in/out state.
@riverpod
Future<void> widgetSync(Ref ref) async {
  final workplace = ref.watch(primaryWorkplaceProvider).value;
  if (workplace == null) {
    await ref.watch(widgetSyncServiceProvider).sync(workplace: null, entry: null);
    return;
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final todayEntries = ref.watch(entriesForDateProvider(today)).value ?? const [];
  final entry = todayEntries.firstOrNull;

  await ref.watch(widgetSyncServiceProvider).sync(workplace: workplace, entry: entry);
}
