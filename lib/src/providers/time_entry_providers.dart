import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/time_entry.dart';
import '../util/earnings_calculator.dart';
import 'auth_providers.dart';
import 'firebase_providers.dart';
import 'workplace_providers.dart';

part 'time_entry_providers.g.dart';

@riverpod
Stream<TimeEntry?> activeTimeEntry(Ref ref) {
  final uid = ref.watch(currentUidProvider);
  final workplace = ref.watch(primaryWorkplaceProvider).value;
  if (uid == null || workplace == null) return const Stream.empty();
  return ref.watch(timeEntryRepositoryProvider).watchOpenEntry(uid, workplace.id);
}

@riverpod
Stream<List<TimeEntry>> entriesForDate(Ref ref, DateTime date) {
  final uid = ref.watch(currentUidProvider);
  final workplace = ref.watch(primaryWorkplaceProvider).value;
  if (uid == null || workplace == null) return const Stream.empty();
  return ref.watch(timeEntryRepositoryProvider).watchEntriesForDate(uid, workplace.id, date);
}

/// [end] is exclusive.
@riverpod
Stream<List<TimeEntry>> entriesInRange(Ref ref, DateTime start, DateTime end) {
  final uid = ref.watch(currentUidProvider);
  final workplace = ref.watch(primaryWorkplaceProvider).value;
  if (uid == null || workplace == null) return const Stream.empty();
  return ref.watch(timeEntryRepositoryProvider).watchEntriesForRange(uid, workplace.id, start, end);
}

/// Ticks once a second so the live earnings counter can redraw. Kept
/// separate from [activeTimeEntryProvider] so the Firestore stream doesn't
/// need to re-fire every second.
@riverpod
Stream<DateTime> secondTicker(Ref ref) {
  return Stream<DateTime>.periodic(const Duration(seconds: 1), (_) => DateTime.now());
}

/// Entry ids for which the user has tapped "残業を記録する" on the frozen-count
/// prompt, opting this shift back into live overtime counting for the rest
/// of the app session. Intentionally in-memory only (not persisted) — it's a
/// one-shift decision, not a setting.
@riverpod
class OvertimeApproval extends _$OvertimeApproval {
  @override
  Set<String> build() => {};

  void approve(String entryId) => state = {...state, entryId};
}

@riverpod
EarningsResult? liveEarnings(Ref ref) {
  final workplace = ref.watch(primaryWorkplaceProvider).value;
  final entry = ref.watch(activeTimeEntryProvider).value;
  final now = ref.watch(secondTickerProvider).value ?? DateTime.now();
  if (workplace == null || entry == null) return null;
  final extraBreakSeconds = entry.extraBreaks.fold<int>(0, (sum, b) {
    final end = b.end ?? now;
    return sum + end.difference(b.start).inSeconds.clamp(0, 1 << 31);
  });
  return calculateLiveEarnings(
    workplace: workplace,
    clockIn: entry.clockIn,
    breakMinutes: entry.breakMinutes,
    now: now,
    scheduledEndOverride: entry.scheduledEndOverride,
    extraBreakSeconds: extraBreakSeconds,
  );
}
