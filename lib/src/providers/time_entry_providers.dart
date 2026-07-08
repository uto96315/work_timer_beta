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

@riverpod
EarningsResult? liveEarnings(Ref ref) {
  final workplace = ref.watch(primaryWorkplaceProvider).value;
  final entry = ref.watch(activeTimeEntryProvider).value;
  final now = ref.watch(secondTickerProvider).value ?? DateTime.now();
  if (workplace == null || entry == null) return null;
  return calculateLiveEarnings(
    workplace: workplace,
    clockIn: entry.clockIn,
    breakMinutes: entry.breakMinutes,
    now: now,
  );
}
