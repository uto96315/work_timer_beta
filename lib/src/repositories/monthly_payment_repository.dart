import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/monthly_payment.dart';

class MonthlyPaymentRepository {
  MonthlyPaymentRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(
    String uid,
    String workplaceId,
  ) => _firestore
      .collection('users')
      .doc(uid)
      .collection('workplaces')
      .doc(workplaceId)
      .collection('monthlyPayments');

  Stream<List<MonthlyPayment>> watchForWorkplace(String uid, String workplaceId) {
    return _collection(uid, workplaceId)
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots()
        .map((s) => s.docs.map(MonthlyPaymentFirestore.fromDoc).toList());
  }

  /// Creates or overwrites the payment record for [payment.id] (a "yyyy-MM"
  /// month key) — there's only ever one recorded amount per month.
  Future<void> upsert(String uid, String workplaceId, MonthlyPayment payment) async {
    await _collection(uid, workplaceId).doc(payment.id).set(payment.toFirestore());
  }
}
