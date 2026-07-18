import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/workplace.dart';

class WorkplaceRepository {
  WorkplaceRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('workplaces');

  /// V1 only ever shows a single workplace; this returns the first one
  /// (creating it doesn't happen here — see [create]).
  Stream<Workplace?> watchPrimary(String uid) {
    return _collection(uid)
        .orderBy('createdAt')
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty ? null : WorkplaceFirestore.fromDoc(s.docs.first));
  }

  /// One-shot equivalent of [watchPrimary], for callers without a live
  /// widget tree to subscribe from — e.g. a geofence background callback.
  Future<Workplace?> getPrimary(String uid) async {
    final snapshot = await _collection(uid).orderBy('createdAt').limit(1).get();
    return snapshot.docs.isEmpty ? null : WorkplaceFirestore.fromDoc(snapshot.docs.first);
  }

  Future<Workplace> create(String uid, Workplace workplace) async {
    final doc = _collection(uid).doc();
    final withId = workplace.copyWith(id: doc.id);
    await doc.set(withId.toFirestore());
    return withId;
  }

  Future<void> update(String uid, Workplace workplace) async {
    await _collection(uid)
        .doc(workplace.id)
        .update(workplace.copyWith(updatedAt: DateTime.now()).toFirestore());
  }
}
