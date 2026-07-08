// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workplace.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Workplace {

 String get id;/// What kind of job this is, used for benchmarking pay against similar
/// jobs elsewhere.
 Industry? get industry; EmploymentType? get employmentType;/// Base hourly wage in yen.
 int get hourlyWage;/// Scheduled start time, "HH:mm" (24h, local time).
 String get startTime;/// Scheduled end time ("teiji"), "HH:mm" (24h, local time).
 String get endTime; int get breakMinutes;/// Break start time, "HH:mm" (24h, local time). Used to render the
/// day's schedule as blocks; defaults to a typical noon lunch break.
 String get breakStartTime;/// Overtime premium, e.g. 25 means 1.25x hourly wage.
 int get overtimeRatePercent;/// ISO weekday numbers (1=Mon .. 7=Sun) treated as days off.
 List<int> get holidayWeekdays;@TimestampConverter() DateTime get createdAt;@NullableTimestampConverter() DateTime? get updatedAt;
/// Create a copy of Workplace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkplaceCopyWith<Workplace> get copyWith => _$WorkplaceCopyWithImpl<Workplace>(this as Workplace, _$identity);

  /// Serializes this Workplace to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Workplace&&(identical(other.id, id) || other.id == id)&&(identical(other.industry, industry) || other.industry == industry)&&(identical(other.employmentType, employmentType) || other.employmentType == employmentType)&&(identical(other.hourlyWage, hourlyWage) || other.hourlyWage == hourlyWage)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.breakMinutes, breakMinutes) || other.breakMinutes == breakMinutes)&&(identical(other.breakStartTime, breakStartTime) || other.breakStartTime == breakStartTime)&&(identical(other.overtimeRatePercent, overtimeRatePercent) || other.overtimeRatePercent == overtimeRatePercent)&&const DeepCollectionEquality().equals(other.holidayWeekdays, holidayWeekdays)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,industry,employmentType,hourlyWage,startTime,endTime,breakMinutes,breakStartTime,overtimeRatePercent,const DeepCollectionEquality().hash(holidayWeekdays),createdAt,updatedAt);

@override
String toString() {
  return 'Workplace(id: $id, industry: $industry, employmentType: $employmentType, hourlyWage: $hourlyWage, startTime: $startTime, endTime: $endTime, breakMinutes: $breakMinutes, breakStartTime: $breakStartTime, overtimeRatePercent: $overtimeRatePercent, holidayWeekdays: $holidayWeekdays, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $WorkplaceCopyWith<$Res>  {
  factory $WorkplaceCopyWith(Workplace value, $Res Function(Workplace) _then) = _$WorkplaceCopyWithImpl;
@useResult
$Res call({
 String id, Industry? industry, EmploymentType? employmentType, int hourlyWage, String startTime, String endTime, int breakMinutes, String breakStartTime, int overtimeRatePercent, List<int> holidayWeekdays,@TimestampConverter() DateTime createdAt,@NullableTimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$WorkplaceCopyWithImpl<$Res>
    implements $WorkplaceCopyWith<$Res> {
  _$WorkplaceCopyWithImpl(this._self, this._then);

  final Workplace _self;
  final $Res Function(Workplace) _then;

/// Create a copy of Workplace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? industry = freezed,Object? employmentType = freezed,Object? hourlyWage = null,Object? startTime = null,Object? endTime = null,Object? breakMinutes = null,Object? breakStartTime = null,Object? overtimeRatePercent = null,Object? holidayWeekdays = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,industry: freezed == industry ? _self.industry : industry // ignore: cast_nullable_to_non_nullable
as Industry?,employmentType: freezed == employmentType ? _self.employmentType : employmentType // ignore: cast_nullable_to_non_nullable
as EmploymentType?,hourlyWage: null == hourlyWage ? _self.hourlyWage : hourlyWage // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,breakMinutes: null == breakMinutes ? _self.breakMinutes : breakMinutes // ignore: cast_nullable_to_non_nullable
as int,breakStartTime: null == breakStartTime ? _self.breakStartTime : breakStartTime // ignore: cast_nullable_to_non_nullable
as String,overtimeRatePercent: null == overtimeRatePercent ? _self.overtimeRatePercent : overtimeRatePercent // ignore: cast_nullable_to_non_nullable
as int,holidayWeekdays: null == holidayWeekdays ? _self.holidayWeekdays : holidayWeekdays // ignore: cast_nullable_to_non_nullable
as List<int>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Workplace].
extension WorkplacePatterns on Workplace {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Workplace value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Workplace() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Workplace value)  $default,){
final _that = this;
switch (_that) {
case _Workplace():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Workplace value)?  $default,){
final _that = this;
switch (_that) {
case _Workplace() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Industry? industry,  EmploymentType? employmentType,  int hourlyWage,  String startTime,  String endTime,  int breakMinutes,  String breakStartTime,  int overtimeRatePercent,  List<int> holidayWeekdays, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Workplace() when $default != null:
return $default(_that.id,_that.industry,_that.employmentType,_that.hourlyWage,_that.startTime,_that.endTime,_that.breakMinutes,_that.breakStartTime,_that.overtimeRatePercent,_that.holidayWeekdays,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Industry? industry,  EmploymentType? employmentType,  int hourlyWage,  String startTime,  String endTime,  int breakMinutes,  String breakStartTime,  int overtimeRatePercent,  List<int> holidayWeekdays, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Workplace():
return $default(_that.id,_that.industry,_that.employmentType,_that.hourlyWage,_that.startTime,_that.endTime,_that.breakMinutes,_that.breakStartTime,_that.overtimeRatePercent,_that.holidayWeekdays,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Industry? industry,  EmploymentType? employmentType,  int hourlyWage,  String startTime,  String endTime,  int breakMinutes,  String breakStartTime,  int overtimeRatePercent,  List<int> holidayWeekdays, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Workplace() when $default != null:
return $default(_that.id,_that.industry,_that.employmentType,_that.hourlyWage,_that.startTime,_that.endTime,_that.breakMinutes,_that.breakStartTime,_that.overtimeRatePercent,_that.holidayWeekdays,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Workplace implements Workplace {
  const _Workplace({required this.id, this.industry, this.employmentType, required this.hourlyWage, required this.startTime, required this.endTime, required this.breakMinutes, this.breakStartTime = '12:00', this.overtimeRatePercent = 25, final  List<int> holidayWeekdays = const [], @TimestampConverter() required this.createdAt, @NullableTimestampConverter() this.updatedAt}): _holidayWeekdays = holidayWeekdays;
  factory _Workplace.fromJson(Map<String, dynamic> json) => _$WorkplaceFromJson(json);

@override final  String id;
/// What kind of job this is, used for benchmarking pay against similar
/// jobs elsewhere.
@override final  Industry? industry;
@override final  EmploymentType? employmentType;
/// Base hourly wage in yen.
@override final  int hourlyWage;
/// Scheduled start time, "HH:mm" (24h, local time).
@override final  String startTime;
/// Scheduled end time ("teiji"), "HH:mm" (24h, local time).
@override final  String endTime;
@override final  int breakMinutes;
/// Break start time, "HH:mm" (24h, local time). Used to render the
/// day's schedule as blocks; defaults to a typical noon lunch break.
@override@JsonKey() final  String breakStartTime;
/// Overtime premium, e.g. 25 means 1.25x hourly wage.
@override@JsonKey() final  int overtimeRatePercent;
/// ISO weekday numbers (1=Mon .. 7=Sun) treated as days off.
 final  List<int> _holidayWeekdays;
/// ISO weekday numbers (1=Mon .. 7=Sun) treated as days off.
@override@JsonKey() List<int> get holidayWeekdays {
  if (_holidayWeekdays is EqualUnmodifiableListView) return _holidayWeekdays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_holidayWeekdays);
}

@override@TimestampConverter() final  DateTime createdAt;
@override@NullableTimestampConverter() final  DateTime? updatedAt;

/// Create a copy of Workplace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkplaceCopyWith<_Workplace> get copyWith => __$WorkplaceCopyWithImpl<_Workplace>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkplaceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Workplace&&(identical(other.id, id) || other.id == id)&&(identical(other.industry, industry) || other.industry == industry)&&(identical(other.employmentType, employmentType) || other.employmentType == employmentType)&&(identical(other.hourlyWage, hourlyWage) || other.hourlyWage == hourlyWage)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.breakMinutes, breakMinutes) || other.breakMinutes == breakMinutes)&&(identical(other.breakStartTime, breakStartTime) || other.breakStartTime == breakStartTime)&&(identical(other.overtimeRatePercent, overtimeRatePercent) || other.overtimeRatePercent == overtimeRatePercent)&&const DeepCollectionEquality().equals(other._holidayWeekdays, _holidayWeekdays)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,industry,employmentType,hourlyWage,startTime,endTime,breakMinutes,breakStartTime,overtimeRatePercent,const DeepCollectionEquality().hash(_holidayWeekdays),createdAt,updatedAt);

@override
String toString() {
  return 'Workplace(id: $id, industry: $industry, employmentType: $employmentType, hourlyWage: $hourlyWage, startTime: $startTime, endTime: $endTime, breakMinutes: $breakMinutes, breakStartTime: $breakStartTime, overtimeRatePercent: $overtimeRatePercent, holidayWeekdays: $holidayWeekdays, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$WorkplaceCopyWith<$Res> implements $WorkplaceCopyWith<$Res> {
  factory _$WorkplaceCopyWith(_Workplace value, $Res Function(_Workplace) _then) = __$WorkplaceCopyWithImpl;
@override @useResult
$Res call({
 String id, Industry? industry, EmploymentType? employmentType, int hourlyWage, String startTime, String endTime, int breakMinutes, String breakStartTime, int overtimeRatePercent, List<int> holidayWeekdays,@TimestampConverter() DateTime createdAt,@NullableTimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$WorkplaceCopyWithImpl<$Res>
    implements _$WorkplaceCopyWith<$Res> {
  __$WorkplaceCopyWithImpl(this._self, this._then);

  final _Workplace _self;
  final $Res Function(_Workplace) _then;

/// Create a copy of Workplace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? industry = freezed,Object? employmentType = freezed,Object? hourlyWage = null,Object? startTime = null,Object? endTime = null,Object? breakMinutes = null,Object? breakStartTime = null,Object? overtimeRatePercent = null,Object? holidayWeekdays = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_Workplace(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,industry: freezed == industry ? _self.industry : industry // ignore: cast_nullable_to_non_nullable
as Industry?,employmentType: freezed == employmentType ? _self.employmentType : employmentType // ignore: cast_nullable_to_non_nullable
as EmploymentType?,hourlyWage: null == hourlyWage ? _self.hourlyWage : hourlyWage // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,breakMinutes: null == breakMinutes ? _self.breakMinutes : breakMinutes // ignore: cast_nullable_to_non_nullable
as int,breakStartTime: null == breakStartTime ? _self.breakStartTime : breakStartTime // ignore: cast_nullable_to_non_nullable
as String,overtimeRatePercent: null == overtimeRatePercent ? _self.overtimeRatePercent : overtimeRatePercent // ignore: cast_nullable_to_non_nullable
as int,holidayWeekdays: null == holidayWeekdays ? _self._holidayWeekdays : holidayWeekdays // ignore: cast_nullable_to_non_nullable
as List<int>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
