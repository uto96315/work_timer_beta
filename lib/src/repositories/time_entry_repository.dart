import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/time_entry.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');

bool _sameMinute(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day &&
    a.hour == b.hour && a.minute == b.minute;

class TimeEntryRepository {
  TimeEntryRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(
    String uid,
    String workplaceId,
  ) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('workplaces')
          .doc(workplaceId)
          .collection('timeEntries');

  /// The entry that has been clocked in but not yet clocked out, if any.
  Stream<TimeEntry?> watchOpenEntry(String uid, String workplaceId) {
    return _collection(uid, workplaceId)
        .where('clockOut', isNull: true)
        .orderBy('clockIn', descending: true)
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty ? null : TimeEntryFirestore.fromDoc(s.docs.first));
  }

  /// One-shot equivalent of [watchOpenEntry], for callers without a live
  /// widget tree to subscribe from — e.g. a geofence background callback.
  Future<TimeEntry?> getOpenEntry(String uid, String workplaceId) async {
    final snapshot = await _collection(uid, workplaceId)
        .where('clockOut', isNull: true)
        .orderBy('clockIn', descending: true)
        .limit(1)
        .get();
    return snapshot.docs.isEmpty ? null : TimeEntryFirestore.fromDoc(snapshot.docs.first);
  }

  Stream<List<TimeEntry>> watchEntriesForDate(String uid, String workplaceId, DateTime date) {
    return _collection(uid, workplaceId)
        .where('date', isEqualTo: _dateFormat.format(date))
        .snapshots()
        .map((s) => s.docs.map(TimeEntryFirestore.fromDoc).toList());
  }

  /// [end] is exclusive.
  Stream<List<TimeEntry>> watchEntriesForRange(
    String uid,
    String workplaceId,
    DateTime start,
    DateTime end,
  ) {
    return _collection(uid, workplaceId)
        .where('date', isGreaterThanOrEqualTo: _dateFormat.format(start))
        .where('date', isLessThan: _dateFormat.format(end))
        .orderBy('date')
        .snapshots()
        .map((s) => s.docs.map(TimeEntryFirestore.fromDoc).toList());
  }

  Future<TimeEntry> clockIn(String uid, String workplaceId, int breakMinutes) async {
    final now = DateTime.now();
    return _createClockIn(
      uid,
      workplaceId,
      clockInTime: now,
      isAuto: false,
      breakMinutes: breakMinutes,
    );
  }

  /// Creates a clock-in entry backdated to the workplace's scheduled start
  /// time, used when the user opens the app after their shift should have
  /// already started. Flagged so the UI can prompt them to double-check it.
  Future<TimeEntry> autoClockIn(
    String uid,
    String workplaceId,
    DateTime scheduledStart,
    int breakMinutes,
  ) async {
    return _createClockIn(
      uid,
      workplaceId,
      clockInTime: scheduledStart,
      isAuto: true,
      breakMinutes: breakMinutes,
    );
  }

  Future<TimeEntry> _createClockIn(
    String uid,
    String workplaceId, {
    required DateTime clockInTime,
    required bool isAuto,
    required int breakMinutes,
  }) async {
    final doc = _collection(uid, workplaceId).doc();
    final entry = TimeEntry(
      id: doc.id,
      workplaceId: workplaceId,
      date: _dateFormat.format(clockInTime),
      clockIn: clockInTime,
      breakMinutes: breakMinutes,
      isAutoClockedIn: isAuto,
      createdAt: DateTime.now(),
    );
    await doc.set(entry.toFirestore());
    return entry;
  }

  Future<void> clockOut(
    String uid,
    String workplaceId,
    String entryId, {
    DateTime? clockOutTime,
  }) async {
    await _collection(uid, workplaceId).doc(entryId).update({
      'clockOut': Timestamp.fromDate(clockOutTime ?? DateTime.now()),
    });
  }

  /// Reopens an entry that was just clocked out, undoing the clock-out.
  Future<void> undoClockOut(String uid, String workplaceId, String entryId) async {
    await _collection(uid, workplaceId).doc(entryId).update({
      'clockOut': FieldValue.delete(),
    });
  }

  /// Corrects an entry's punch times and/or break length, preserving the
  /// original clock-in/out values the first time each is corrected.
  ///
  /// Only flags [TimeEntry.isModified] and writes anything at all if a
  /// passed-in value actually differs from what's already recorded —
  /// re-confirming an unchanged time (e.g. opening the edit sheet and
  /// tapping save without picking a different time) is a no-op, not a
  /// correction. Clock times are compared to the minute, since the edit UI
  /// only lets the user pick to that precision.
  Future<void> correct(
    String uid,
    String workplaceId,
    TimeEntry entry, {
    DateTime? newClockIn,
    DateTime? newClockOut,
    int? newBreakMinutes,
  }) async {
    final clockInChanged = newClockIn != null && !_sameMinute(newClockIn, entry.clockIn);
    final clockOutChanged = newClockOut != null &&
        (entry.clockOut == null || !_sameMinute(newClockOut, entry.clockOut!));
    final breakMinutesChanged = newBreakMinutes != null && newBreakMinutes != entry.breakMinutes;
    if (!clockInChanged && !clockOutChanged && !breakMinutesChanged) return;

    final update = <String, dynamic>{
      'isModified': true,
      if (clockInChanged) ...{
        'clockIn': Timestamp.fromDate(newClockIn),
        'originalClockIn': Timestamp.fromDate(entry.originalClockIn ?? entry.clockIn),
      },
      if (clockOutChanged) ...{
        'clockOut': Timestamp.fromDate(newClockOut),
        if (entry.clockOut != null)
          'originalClockOut': Timestamp.fromDate(entry.originalClockOut ?? entry.clockOut!),
      },
      if (breakMinutesChanged) 'breakMinutes': newBreakMinutes,
    };
    await _collection(uid, workplaceId).doc(entry.id).update(update);
  }

  /// Shifts today's break start time, without touching the workplace's
  /// default. Pass `null` to revert to the workplace default.
  Future<void> setBreakStart(
    String uid,
    String workplaceId,
    String entryId,
    DateTime? breakStart,
  ) async {
    await _collection(uid, workplaceId).doc(entryId).update({
      'breakStartOverride': breakStart == null
          ? FieldValue.delete()
          : Timestamp.fromDate(breakStart),
    });
  }

  /// Shifts today's scheduled end time, without touching the workplace's
  /// default. Pass `null` to revert to the workplace default.
  Future<void> setScheduledEnd(
    String uid,
    String workplaceId,
    String entryId,
    DateTime? scheduledEnd,
  ) async {
    await _collection(uid, workplaceId).doc(entryId).update({
      'scheduledEndOverride': scheduledEnd == null
          ? FieldValue.delete()
          : Timestamp.fromDate(scheduledEnd),
    });
  }

  /// Starts an ad-hoc break on top of the workplace's scheduled one — used
  /// for breaks taken during overtime, which the fixed schedule doesn't
  /// already account for. No-ops if the last break is still open.
  Future<void> startExtraBreak(
    String uid,
    String workplaceId,
    TimeEntry entry,
  ) async {
    if (entry.extraBreaks.isNotEmpty && entry.extraBreaks.last.end == null) {
      return;
    }
    final updated = [...entry.extraBreaks, ExtraBreak(start: DateTime.now())];
    await _writeExtraBreaks(uid, workplaceId, entry.id, updated);
  }

  /// Ends the currently-open ad-hoc break, if any.
  Future<void> endExtraBreak(
    String uid,
    String workplaceId,
    TimeEntry entry,
  ) async {
    if (entry.extraBreaks.isEmpty) return;
    final last = entry.extraBreaks.last;
    if (last.end != null) return;
    final updated = [
      ...entry.extraBreaks.sublist(0, entry.extraBreaks.length - 1),
      last.copyWith(end: DateTime.now()),
    ];
    await _writeExtraBreaks(uid, workplaceId, entry.id, updated);
  }

  Future<void> _writeExtraBreaks(
    String uid,
    String workplaceId,
    String entryId,
    List<ExtraBreak> breaks,
  ) async {
    await _collection(uid, workplaceId).doc(entryId).update({
      'extraBreaks': breaks.map((b) => b.toJson()).toList(),
    });
  }
}
