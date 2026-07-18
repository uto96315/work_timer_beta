import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../models/time_entry.dart';
import '../models/workplace.dart';
import '../providers/auth_providers.dart';
import '../providers/firebase_providers.dart';
import '../providers/time_entry_providers.dart';
import '../providers/widget_sync_providers.dart';
import '../providers/workplace_providers.dart';
import '../util/earnings_calculator.dart';

/// 1 food per full hour actually worked (excluding breaks) — mirrors
/// `_foodForEntry` in `home_screen.dart`.
int _foodForEntry(TimeEntry entry, Workplace workplace) {
  final result = calculateEntryEarnings(workplace: workplace, entry: entry, now: DateTime.now());
  return (result.regularSeconds + result.overtimeSeconds) ~/ 3600;
}

/// The iOS home-screen widget's 退勤/休憩 buttons can't reach Firestore from
/// inside the widget extension (see `ios/WorkTimerWidget/WidgetIntents.swift`
/// for why), so they only update the widget's own cached display optimistically
/// and leave a note of what was tapped in the shared App Group storage.
///
/// This drains that note — applying the real clock-out/break-toggle through
/// the same repositories the in-app buttons use — whenever the app is opened
/// or resumed (see `_RootScaffoldState` in `app.dart`).
Future<void> applyPendingWidgetActions(WidgetRef ref) async {
  final pendingClockOut = await HomeWidget.getWidgetData<double>('pendingClockOutRequestedAtEpoch');
  final pendingBreakToggles = await HomeWidget.getWidgetData<int>('pendingBreakToggleCount') ?? 0;
  if (pendingClockOut == null && pendingBreakToggles == 0) return;

  final uid = ref.read(currentUidProvider);
  final workplace = ref.read(primaryWorkplaceProvider).value;
  if (uid == null || workplace == null) return;

  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);
  final entries = ref.read(entriesForDateProvider(todayStart)).value ?? const [];
  final firstEntry = entries.firstOrNull;
  if (firstEntry == null) return;
  var entry = firstEntry;

  final timeEntryRepo = ref.read(timeEntryRepositoryProvider);

  if (pendingClockOut != null && entry.clockOut == null) {
    await timeEntryRepo.clockOut(uid, workplace.id, entry.id);
    await ref.read(userProfileRepositoryProvider).addFood(uid, _foodForEntry(entry, workplace));
  }

  for (var i = 0; i < pendingBreakToggles; i++) {
    final isOnBreak = entry.extraBreaks.isNotEmpty && entry.extraBreaks.last.end == null;
    if (isOnBreak) {
      await timeEntryRepo.endExtraBreak(uid, workplace.id, entry);
      entry = entry.copyWith(
        extraBreaks: [
          ...entry.extraBreaks.sublist(0, entry.extraBreaks.length - 1),
          entry.extraBreaks.last.copyWith(end: DateTime.now()),
        ],
      );
    } else {
      await timeEntryRepo.startExtraBreak(uid, workplace.id, entry);
      entry = entry.copyWith(extraBreaks: [...entry.extraBreaks, ExtraBreak(start: DateTime.now())]);
    }
  }

  await HomeWidget.saveWidgetData<double?>('pendingClockOutRequestedAtEpoch', null);
  await HomeWidget.saveWidgetData<int>('pendingBreakToggleCount', 0);
  await triggerWidgetSyncNow(ref);
}
