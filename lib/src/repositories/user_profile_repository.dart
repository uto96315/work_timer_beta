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
}
