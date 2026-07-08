import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../util/firestore_converters.dart';

part 'monthly_payment.freezed.dart';
part 'monthly_payment.g.dart';

enum PaymentAmountType { gross, net }

/// The salary the user actually received for a given month, used to compute
/// the gap against what they should have earned.
@freezed
abstract class MonthlyPayment with _$MonthlyPayment {
  const factory MonthlyPayment({
    /// "yyyy-MM"
    required String id,
    required String workplaceId,
    required int receivedAmount,
    required PaymentAmountType amountType,
    @TimestampConverter() required DateTime createdAt,
  }) = _MonthlyPayment;

  factory MonthlyPayment.fromJson(Map<String, dynamic> json) =>
      _$MonthlyPaymentFromJson(json);
}

extension MonthlyPaymentFirestore on MonthlyPayment {
  Map<String, dynamic> toFirestore() => toJson();

  static MonthlyPayment fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return MonthlyPayment.fromJson({...doc.data()!, 'id': doc.id});
  }
}
