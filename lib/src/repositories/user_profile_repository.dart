import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/user_profile.dart';
import '../util/affection.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');

class UserProfileRepository {
  UserProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('users').doc(uid);

  Stream<UserProfile> watch(String uid) {
    return _doc(uid).snapshots().map(UserProfileFirestore.fromDoc);
  }

  Future<void> update(String uid, UserProfile profile) async {
    await _doc(uid).set(
      profile.copyWith(updatedAt: DateTime.now()).toFirestore(),
      SetOptions(merge: true),
    );
  }

  /// Adds (or, with a negative [delta], removes) food earned from worked
  /// hours — a plain increment rather than a full [update] so concurrent
  /// writes to other profile fields aren't clobbered.
  Future<void> addFood(String uid, int delta) async {
    if (delta == 0) return;
    await _doc(uid).set({
      'totalFood': FieldValue.increment(delta),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  /// Records that [day] was worked, for affection tracking (see
  /// `util/affection.dart`) — gains a fixed amount of affection and marks
  /// [day] as the most recent worked day.
  ///
  /// Callers are expected to only call this once per calendar day (the
  /// only current call site, home_screen's auto clock-in, only fires once
  /// a day itself), so this doesn't re-check [UserProfile.lastWorkedDate]
  /// before writing.
  Future<void> recordWorkedDay(String uid, DateTime day) async {
    await _doc(uid).set({
      'affectionPoints': FieldValue.increment(affectionGainPerDay),
      'lastWorkedDate': _dateFormat.format(day),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  /// Sets the pet's "birth" date the first time this is called for [uid] —
  /// callers are expected to only call this when `UserProfile.petBornAt` is
  /// still null, so a concurrent call can't overwrite an already-set date.
  Future<void> setPetBornAtNow(String uid) async {
    await _doc(uid).set({
      'petBornAt': Timestamp.fromDate(DateTime.now()),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }
}
