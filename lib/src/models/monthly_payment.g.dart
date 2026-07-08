// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MonthlyPayment _$MonthlyPaymentFromJson(Map<String, dynamic> json) =>
    _MonthlyPayment(
      id: json['id'] as String,
      workplaceId: json['workplaceId'] as String,
      receivedAmount: (json['receivedAmount'] as num).toInt(),
      amountType: $enumDecode(_$PaymentAmountTypeEnumMap, json['amountType']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$MonthlyPaymentToJson(_MonthlyPayment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workplaceId': instance.workplaceId,
      'receivedAmount': instance.receivedAmount,
      'amountType': _$PaymentAmountTypeEnumMap[instance.amountType]!,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

const _$PaymentAmountTypeEnumMap = {
  PaymentAmountType.gross: 'gross',
  PaymentAmountType.net: 'net',
};
