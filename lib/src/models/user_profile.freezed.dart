// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 Gender? get gender; AgeBracket? get ageBracket; String? get prefecture; JobChangeIntention? get jobChangeIntention; bool get notificationsEnabled; bool get notifyClockInReminder; bool get notifyClockOutReminder; bool get notifyPayday;/// When false (the default), live earnings/worked-time stop counting once
/// the scheduled end time passes, and the user is prompted via
/// notification/in-app banner to decide whether to record overtime.
 bool get autoOvertimeEnabled;/// Only relevant when [autoOvertimeEnabled] is true: sends a reminder
/// notification every N hours while overtime is ongoing. 0 means no
/// reminder; otherwise one of 1/2/3.
 int get overtimeReminderIntervalHours;/// Cumulative food earned from worked hours, used to grow the pet (see
/// [lib/src/util/pet_stage.dart]).
 int get totalFood;/// Raw affection points, gained once per calendar day worked. Unlike
/// [totalFood] (a permanent milestone counter), the *displayed*
/// affection level decays when [lastWorkedDate] falls behind — see
/// [lib/src/util/affection.dart]. Not clamped at write time; clamped
/// when displayed instead.
 int get affectionPoints;/// "yyyy-MM-dd" of the last day a shift was recorded, used to compute
/// affection decay since. Null means never worked yet.
 String? get lastWorkedDate;/// When the pet was "born" — set once, the first time the home screen
/// loads with no value yet, so the displayed age (see
/// [lib/src/util/pet_age.dart]) counts up from install rather than
/// resetting every session.
@NullableTimestampConverter() DateTime? get petBornAt;@NullableTimestampConverter() DateTime? get updatedAt;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.ageBracket, ageBracket) || other.ageBracket == ageBracket)&&(identical(other.prefecture, prefecture) || other.prefecture == prefecture)&&(identical(other.jobChangeIntention, jobChangeIntention) || other.jobChangeIntention == jobChangeIntention)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.notifyClockInReminder, notifyClockInReminder) || other.notifyClockInReminder == notifyClockInReminder)&&(identical(other.notifyClockOutReminder, notifyClockOutReminder) || other.notifyClockOutReminder == notifyClockOutReminder)&&(identical(other.notifyPayday, notifyPayday) || other.notifyPayday == notifyPayday)&&(identical(other.autoOvertimeEnabled, autoOvertimeEnabled) || other.autoOvertimeEnabled == autoOvertimeEnabled)&&(identical(other.overtimeReminderIntervalHours, overtimeReminderIntervalHours) || other.overtimeReminderIntervalHours == overtimeReminderIntervalHours)&&(identical(other.totalFood, totalFood) || other.totalFood == totalFood)&&(identical(other.affectionPoints, affectionPoints) || other.affectionPoints == affectionPoints)&&(identical(other.lastWorkedDate, lastWorkedDate) || other.lastWorkedDate == lastWorkedDate)&&(identical(other.petBornAt, petBornAt) || other.petBornAt == petBornAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gender,ageBracket,prefecture,jobChangeIntention,notificationsEnabled,notifyClockInReminder,notifyClockOutReminder,notifyPayday,autoOvertimeEnabled,overtimeReminderIntervalHours,totalFood,affectionPoints,lastWorkedDate,petBornAt,updatedAt);

@override
String toString() {
  return 'UserProfile(gender: $gender, ageBracket: $ageBracket, prefecture: $prefecture, jobChangeIntention: $jobChangeIntention, notificationsEnabled: $notificationsEnabled, notifyClockInReminder: $notifyClockInReminder, notifyClockOutReminder: $notifyClockOutReminder, notifyPayday: $notifyPayday, autoOvertimeEnabled: $autoOvertimeEnabled, overtimeReminderIntervalHours: $overtimeReminderIntervalHours, totalFood: $totalFood, affectionPoints: $affectionPoints, lastWorkedDate: $lastWorkedDate, petBornAt: $petBornAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 Gender? gender, AgeBracket? ageBracket, String? prefecture, JobChangeIntention? jobChangeIntention, bool notificationsEnabled, bool notifyClockInReminder, bool notifyClockOutReminder, bool notifyPayday, bool autoOvertimeEnabled, int overtimeReminderIntervalHours, int totalFood, int affectionPoints, String? lastWorkedDate,@NullableTimestampConverter() DateTime? petBornAt,@NullableTimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gender = freezed,Object? ageBracket = freezed,Object? prefecture = freezed,Object? jobChangeIntention = freezed,Object? notificationsEnabled = null,Object? notifyClockInReminder = null,Object? notifyClockOutReminder = null,Object? notifyPayday = null,Object? autoOvertimeEnabled = null,Object? overtimeReminderIntervalHours = null,Object? totalFood = null,Object? affectionPoints = null,Object? lastWorkedDate = freezed,Object? petBornAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,ageBracket: freezed == ageBracket ? _self.ageBracket : ageBracket // ignore: cast_nullable_to_non_nullable
as AgeBracket?,prefecture: freezed == prefecture ? _self.prefecture : prefecture // ignore: cast_nullable_to_non_nullable
as String?,jobChangeIntention: freezed == jobChangeIntention ? _self.jobChangeIntention : jobChangeIntention // ignore: cast_nullable_to_non_nullable
as JobChangeIntention?,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,notifyClockInReminder: null == notifyClockInReminder ? _self.notifyClockInReminder : notifyClockInReminder // ignore: cast_nullable_to_non_nullable
as bool,notifyClockOutReminder: null == notifyClockOutReminder ? _self.notifyClockOutReminder : notifyClockOutReminder // ignore: cast_nullable_to_non_nullable
as bool,notifyPayday: null == notifyPayday ? _self.notifyPayday : notifyPayday // ignore: cast_nullable_to_non_nullable
as bool,autoOvertimeEnabled: null == autoOvertimeEnabled ? _self.autoOvertimeEnabled : autoOvertimeEnabled // ignore: cast_nullable_to_non_nullable
as bool,overtimeReminderIntervalHours: null == overtimeReminderIntervalHours ? _self.overtimeReminderIntervalHours : overtimeReminderIntervalHours // ignore: cast_nullable_to_non_nullable
as int,totalFood: null == totalFood ? _self.totalFood : totalFood // ignore: cast_nullable_to_non_nullable
as int,affectionPoints: null == affectionPoints ? _self.affectionPoints : affectionPoints // ignore: cast_nullable_to_non_nullable
as int,lastWorkedDate: freezed == lastWorkedDate ? _self.lastWorkedDate : lastWorkedDate // ignore: cast_nullable_to_non_nullable
as String?,petBornAt: freezed == petBornAt ? _self.petBornAt : petBornAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Gender? gender,  AgeBracket? ageBracket,  String? prefecture,  JobChangeIntention? jobChangeIntention,  bool notificationsEnabled,  bool notifyClockInReminder,  bool notifyClockOutReminder,  bool notifyPayday,  bool autoOvertimeEnabled,  int overtimeReminderIntervalHours,  int totalFood,  int affectionPoints,  String? lastWorkedDate, @NullableTimestampConverter()  DateTime? petBornAt, @NullableTimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.gender,_that.ageBracket,_that.prefecture,_that.jobChangeIntention,_that.notificationsEnabled,_that.notifyClockInReminder,_that.notifyClockOutReminder,_that.notifyPayday,_that.autoOvertimeEnabled,_that.overtimeReminderIntervalHours,_that.totalFood,_that.affectionPoints,_that.lastWorkedDate,_that.petBornAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Gender? gender,  AgeBracket? ageBracket,  String? prefecture,  JobChangeIntention? jobChangeIntention,  bool notificationsEnabled,  bool notifyClockInReminder,  bool notifyClockOutReminder,  bool notifyPayday,  bool autoOvertimeEnabled,  int overtimeReminderIntervalHours,  int totalFood,  int affectionPoints,  String? lastWorkedDate, @NullableTimestampConverter()  DateTime? petBornAt, @NullableTimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.gender,_that.ageBracket,_that.prefecture,_that.jobChangeIntention,_that.notificationsEnabled,_that.notifyClockInReminder,_that.notifyClockOutReminder,_that.notifyPayday,_that.autoOvertimeEnabled,_that.overtimeReminderIntervalHours,_that.totalFood,_that.affectionPoints,_that.lastWorkedDate,_that.petBornAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Gender? gender,  AgeBracket? ageBracket,  String? prefecture,  JobChangeIntention? jobChangeIntention,  bool notificationsEnabled,  bool notifyClockInReminder,  bool notifyClockOutReminder,  bool notifyPayday,  bool autoOvertimeEnabled,  int overtimeReminderIntervalHours,  int totalFood,  int affectionPoints,  String? lastWorkedDate, @NullableTimestampConverter()  DateTime? petBornAt, @NullableTimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.gender,_that.ageBracket,_that.prefecture,_that.jobChangeIntention,_that.notificationsEnabled,_that.notifyClockInReminder,_that.notifyClockOutReminder,_that.notifyPayday,_that.autoOvertimeEnabled,_that.overtimeReminderIntervalHours,_that.totalFood,_that.affectionPoints,_that.lastWorkedDate,_that.petBornAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({this.gender, this.ageBracket, this.prefecture, this.jobChangeIntention, this.notificationsEnabled = true, this.notifyClockInReminder = true, this.notifyClockOutReminder = true, this.notifyPayday = true, this.autoOvertimeEnabled = false, this.overtimeReminderIntervalHours = 0, this.totalFood = 0, this.affectionPoints = 0, this.lastWorkedDate, @NullableTimestampConverter() this.petBornAt, @NullableTimestampConverter() this.updatedAt});
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  Gender? gender;
@override final  AgeBracket? ageBracket;
@override final  String? prefecture;
@override final  JobChangeIntention? jobChangeIntention;
@override@JsonKey() final  bool notificationsEnabled;
@override@JsonKey() final  bool notifyClockInReminder;
@override@JsonKey() final  bool notifyClockOutReminder;
@override@JsonKey() final  bool notifyPayday;
/// When false (the default), live earnings/worked-time stop counting once
/// the scheduled end time passes, and the user is prompted via
/// notification/in-app banner to decide whether to record overtime.
@override@JsonKey() final  bool autoOvertimeEnabled;
/// Only relevant when [autoOvertimeEnabled] is true: sends a reminder
/// notification every N hours while overtime is ongoing. 0 means no
/// reminder; otherwise one of 1/2/3.
@override@JsonKey() final  int overtimeReminderIntervalHours;
/// Cumulative food earned from worked hours, used to grow the pet (see
/// [lib/src/util/pet_stage.dart]).
@override@JsonKey() final  int totalFood;
/// Raw affection points, gained once per calendar day worked. Unlike
/// [totalFood] (a permanent milestone counter), the *displayed*
/// affection level decays when [lastWorkedDate] falls behind — see
/// [lib/src/util/affection.dart]. Not clamped at write time; clamped
/// when displayed instead.
@override@JsonKey() final  int affectionPoints;
/// "yyyy-MM-dd" of the last day a shift was recorded, used to compute
/// affection decay since. Null means never worked yet.
@override final  String? lastWorkedDate;
/// When the pet was "born" — set once, the first time the home screen
/// loads with no value yet, so the displayed age (see
/// [lib/src/util/pet_age.dart]) counts up from install rather than
/// resetting every session.
@override@NullableTimestampConverter() final  DateTime? petBornAt;
@override@NullableTimestampConverter() final  DateTime? updatedAt;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.ageBracket, ageBracket) || other.ageBracket == ageBracket)&&(identical(other.prefecture, prefecture) || other.prefecture == prefecture)&&(identical(other.jobChangeIntention, jobChangeIntention) || other.jobChangeIntention == jobChangeIntention)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.notifyClockInReminder, notifyClockInReminder) || other.notifyClockInReminder == notifyClockInReminder)&&(identical(other.notifyClockOutReminder, notifyClockOutReminder) || other.notifyClockOutReminder == notifyClockOutReminder)&&(identical(other.notifyPayday, notifyPayday) || other.notifyPayday == notifyPayday)&&(identical(other.autoOvertimeEnabled, autoOvertimeEnabled) || other.autoOvertimeEnabled == autoOvertimeEnabled)&&(identical(other.overtimeReminderIntervalHours, overtimeReminderIntervalHours) || other.overtimeReminderIntervalHours == overtimeReminderIntervalHours)&&(identical(other.totalFood, totalFood) || other.totalFood == totalFood)&&(identical(other.affectionPoints, affectionPoints) || other.affectionPoints == affectionPoints)&&(identical(other.lastWorkedDate, lastWorkedDate) || other.lastWorkedDate == lastWorkedDate)&&(identical(other.petBornAt, petBornAt) || other.petBornAt == petBornAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gender,ageBracket,prefecture,jobChangeIntention,notificationsEnabled,notifyClockInReminder,notifyClockOutReminder,notifyPayday,autoOvertimeEnabled,overtimeReminderIntervalHours,totalFood,affectionPoints,lastWorkedDate,petBornAt,updatedAt);

@override
String toString() {
  return 'UserProfile(gender: $gender, ageBracket: $ageBracket, prefecture: $prefecture, jobChangeIntention: $jobChangeIntention, notificationsEnabled: $notificationsEnabled, notifyClockInReminder: $notifyClockInReminder, notifyClockOutReminder: $notifyClockOutReminder, notifyPayday: $notifyPayday, autoOvertimeEnabled: $autoOvertimeEnabled, overtimeReminderIntervalHours: $overtimeReminderIntervalHours, totalFood: $totalFood, affectionPoints: $affectionPoints, lastWorkedDate: $lastWorkedDate, petBornAt: $petBornAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 Gender? gender, AgeBracket? ageBracket, String? prefecture, JobChangeIntention? jobChangeIntention, bool notificationsEnabled, bool notifyClockInReminder, bool notifyClockOutReminder, bool notifyPayday, bool autoOvertimeEnabled, int overtimeReminderIntervalHours, int totalFood, int affectionPoints, String? lastWorkedDate,@NullableTimestampConverter() DateTime? petBornAt,@NullableTimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gender = freezed,Object? ageBracket = freezed,Object? prefecture = freezed,Object? jobChangeIntention = freezed,Object? notificationsEnabled = null,Object? notifyClockInReminder = null,Object? notifyClockOutReminder = null,Object? notifyPayday = null,Object? autoOvertimeEnabled = null,Object? overtimeReminderIntervalHours = null,Object? totalFood = null,Object? affectionPoints = null,Object? lastWorkedDate = freezed,Object? petBornAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_UserProfile(
gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,ageBracket: freezed == ageBracket ? _self.ageBracket : ageBracket // ignore: cast_nullable_to_non_nullable
as AgeBracket?,prefecture: freezed == prefecture ? _self.prefecture : prefecture // ignore: cast_nullable_to_non_nullable
as String?,jobChangeIntention: freezed == jobChangeIntention ? _self.jobChangeIntention : jobChangeIntention // ignore: cast_nullable_to_non_nullable
as JobChangeIntention?,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,notifyClockInReminder: null == notifyClockInReminder ? _self.notifyClockInReminder : notifyClockInReminder // ignore: cast_nullable_to_non_nullable
as bool,notifyClockOutReminder: null == notifyClockOutReminder ? _self.notifyClockOutReminder : notifyClockOutReminder // ignore: cast_nullable_to_non_nullable
as bool,notifyPayday: null == notifyPayday ? _self.notifyPayday : notifyPayday // ignore: cast_nullable_to_non_nullable
as bool,autoOvertimeEnabled: null == autoOvertimeEnabled ? _self.autoOvertimeEnabled : autoOvertimeEnabled // ignore: cast_nullable_to_non_nullable
as bool,overtimeReminderIntervalHours: null == overtimeReminderIntervalHours ? _self.overtimeReminderIntervalHours : overtimeReminderIntervalHours // ignore: cast_nullable_to_non_nullable
as int,totalFood: null == totalFood ? _self.totalFood : totalFood // ignore: cast_nullable_to_non_nullable
as int,affectionPoints: null == affectionPoints ? _self.affectionPoints : affectionPoints // ignore: cast_nullable_to_non_nullable
as int,lastWorkedDate: freezed == lastWorkedDate ? _self.lastWorkedDate : lastWorkedDate // ignore: cast_nullable_to_non_nullable
as String?,petBornAt: freezed == petBornAt ? _self.petBornAt : petBornAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
