import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/time_entry.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');

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

  Future<TimeEntry> clockIn(String uid, String workplaceId) async {
    final now = DateTime.now();
    return _createClockIn(uid, workplaceId, clockInTime: now, isAuto: false);
  }

  /// Creates a clock-in entry backdated to the workplace's scheduled start
  /// time, used when the user opens the app after their shift should have
  /// already started. Flagged so the UI can prompt them to double-check it.
  Future<TimeEntry> autoClockIn(String uid, String workplaceId, DateTime scheduledStart) async {
    return _createClockIn(uid, workplaceId, clockInTime: scheduledStart, isAuto: true);
  }

  Future<TimeEntry> _createClockIn(
    String uid,
    String workplaceId, {
    required DateTime clockInTime,
    required bool isAuto,
  }) async {
    final doc = _collection(uid, workplaceId).doc();
    final entry = TimeEntry(
      id: doc.id,
      workplaceId: workplaceId,
      date: _dateFormat.format(clockInTime),
      clockIn: clockInTime,
      isAutoClockedIn: isAuto,
      createdAt: DateTime.now(),
    );
    await doc.set(entry.toFirestore());
    return entry;
  }

  Future<void> clockOut(String uid, String workplaceId, String entryId) async {
    await _collection(uid, workplaceId).doc(entryId).update({
      'clockOut': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Corrects an entry's punch times for the current day only, preserving
  /// the original values the first time a correction is made.
  Future<void> correct(
    String uid,
    String workplaceId,
    TimeEntry entry, {
    DateTime? newClockIn,
    DateTime? newClockOut,
  }) async {
    final update = <String, dynamic>{
      'isModified': true,
      'originalClockIn':
          entry.originalClockIn == null ? Timestamp.fromDate(entry.clockIn) : Timestamp.fromDate(entry.originalClockIn!),
      if (entry.clockOut != null)
        'originalClockOut': entry.originalClockOut == null
            ? Timestamp.fromDate(entry.clockOut!)
            : Timestamp.fromDate(entry.originalClockOut!),
      if (newClockIn != null) 'clockIn': Timestamp.fromDate(newClockIn),
      if (newClockOut != null) 'clockOut': Timestamp.fromDate(newClockOut),
    };
    await _collection(uid, workplaceId).doc(entry.id).update(update);
  }
}
