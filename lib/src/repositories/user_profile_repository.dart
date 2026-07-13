import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

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
}
