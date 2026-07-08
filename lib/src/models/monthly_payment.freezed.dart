// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MonthlyPayment {

/// "yyyy-MM"
 String get id; String get workplaceId; int get receivedAmount; PaymentAmountType get amountType;@TimestampConverter() DateTime get createdAt;
/// Create a copy of MonthlyPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyPaymentCopyWith<MonthlyPayment> get copyWith => _$MonthlyPaymentCopyWithImpl<MonthlyPayment>(this as MonthlyPayment, _$identity);

  /// Serializes this MonthlyPayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.workplaceId, workplaceId) || other.workplaceId == workplaceId)&&(identical(other.receivedAmount, receivedAmount) || other.receivedAmount == receivedAmount)&&(identical(other.amountType, amountType) || other.amountType == amountType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workplaceId,receivedAmount,amountType,createdAt);

@override
String toString() {
  return 'MonthlyPayment(id: $id, workplaceId: $workplaceId, receivedAmount: $receivedAmount, amountType: $amountType, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MonthlyPaymentCopyWith<$Res>  {
  factory $MonthlyPaymentCopyWith(MonthlyPayment value, $Res Function(MonthlyPayment) _then) = _$MonthlyPaymentCopyWithImpl;
@useResult
$Res call({
 String id, String workplaceId, int receivedAmount, PaymentAmountType amountType,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$MonthlyPaymentCopyWithImpl<$Res>
    implements $MonthlyPaymentCopyWith<$Res> {
  _$MonthlyPaymentCopyWithImpl(this._self, this._then);

  final MonthlyPayment _self;
  final $Res Function(MonthlyPayment) _then;

/// Create a copy of MonthlyPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workplaceId = null,Object? receivedAmount = null,Object? amountType = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workplaceId: null == workplaceId ? _self.workplaceId : workplaceId // ignore: cast_nullable_to_non_nullable
as String,receivedAmount: null == receivedAmount ? _self.receivedAmount : receivedAmount // ignore: cast_nullable_to_non_nullable
as int,amountType: null == amountType ? _self.amountType : amountType // ignore: cast_nullable_to_non_nullable
as PaymentAmountType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyPayment].
extension MonthlyPaymentPatterns on MonthlyPayment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyPayment() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyPayment value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyPayment():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyPayment value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyPayment() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String workplaceId,  int receivedAmount,  PaymentAmountType amountType, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyPayment() when $default != null:
return $default(_that.id,_that.workplaceId,_that.receivedAmount,_that.amountType,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String workplaceId,  int receivedAmount,  PaymentAmountType amountType, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _MonthlyPayment():
return $default(_that.id,_that.workplaceId,_that.receivedAmount,_that.amountType,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String workplaceId,  int receivedAmount,  PaymentAmountType amountType, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyPayment() when $default != null:
return $default(_that.id,_that.workplaceId,_that.receivedAmount,_that.amountType,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthlyPayment implements MonthlyPayment {
  const _MonthlyPayment({required this.id, required this.workplaceId, required this.receivedAmount, required this.amountType, @TimestampConverter() required this.createdAt});
  factory _MonthlyPayment.fromJson(Map<String, dynamic> json) => _$MonthlyPaymentFromJson(json);

/// "yyyy-MM"
@override final  String id;
@override final  String workplaceId;
@override final  int receivedAmount;
@override final  PaymentAmountType amountType;
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of MonthlyPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyPaymentCopyWith<_MonthlyPayment> get copyWith => __$MonthlyPaymentCopyWithImpl<_MonthlyPayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlyPaymentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.workplaceId, workplaceId) || other.workplaceId == workplaceId)&&(identical(other.receivedAmount, receivedAmount) || other.receivedAmount == receivedAmount)&&(identical(other.amountType, amountType) || other.amountType == amountType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workplaceId,receivedAmount,amountType,createdAt);

@override
String toString() {
  return 'MonthlyPayment(id: $id, workplaceId: $workplaceId, receivedAmount: $receivedAmount, amountType: $amountType, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MonthlyPaymentCopyWith<$Res> implements $MonthlyPaymentCopyWith<$Res> {
  factory _$MonthlyPaymentCopyWith(_MonthlyPayment value, $Res Function(_MonthlyPayment) _then) = __$MonthlyPaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, String workplaceId, int receivedAmount, PaymentAmountType amountType,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$MonthlyPaymentCopyWithImpl<$Res>
    implements _$MonthlyPaymentCopyWith<$Res> {
  __$MonthlyPaymentCopyWithImpl(this._self, this._then);

  final _MonthlyPayment _self;
  final $Res Function(_MonthlyPayment) _then;

/// Create a copy of MonthlyPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workplaceId = null,Object? receivedAmount = null,Object? amountType = null,Object? createdAt = null,}) {
  return _then(_MonthlyPayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workplaceId: null == workplaceId ? _self.workplaceId : workplaceId // ignore: cast_nullable_to_non_nullable
as String,receivedAmount: null == receivedAmount ? _self.receivedAmount : receivedAmount // ignore: cast_nullable_to_non_nullable
as int,amountType: null == amountType ? _self.amountType : amountType // ignore: cast_nullable_to_non_nullable
as PaymentAmountType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
