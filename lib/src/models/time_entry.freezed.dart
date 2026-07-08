// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExtraBreak {

@TimestampConverter() DateTime get start;@NullableTimestampConverter() DateTime? get end;
/// Create a copy of ExtraBreak
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExtraBreakCopyWith<ExtraBreak> get copyWith => _$ExtraBreakCopyWithImpl<ExtraBreak>(this as ExtraBreak, _$identity);

  /// Serializes this ExtraBreak to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExtraBreak&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end);

@override
String toString() {
  return 'ExtraBreak(start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class $ExtraBreakCopyWith<$Res>  {
  factory $ExtraBreakCopyWith(ExtraBreak value, $Res Function(ExtraBreak) _then) = _$ExtraBreakCopyWithImpl;
@useResult
$Res call({
@TimestampConverter() DateTime start,@NullableTimestampConverter() DateTime? end
});




}
/// @nodoc
class _$ExtraBreakCopyWithImpl<$Res>
    implements $ExtraBreakCopyWith<$Res> {
  _$ExtraBreakCopyWithImpl(this._self, this._then);

  final ExtraBreak _self;
  final $Res Function(ExtraBreak) _then;

/// Create a copy of ExtraBreak
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? end = freezed,}) {
  return _then(_self.copyWith(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExtraBreak].
extension ExtraBreakPatterns on ExtraBreak {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExtraBreak value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExtraBreak() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExtraBreak value)  $default,){
final _that = this;
switch (_that) {
case _ExtraBreak():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExtraBreak value)?  $default,){
final _that = this;
switch (_that) {
case _ExtraBreak() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@TimestampConverter()  DateTime start, @NullableTimestampConverter()  DateTime? end)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExtraBreak() when $default != null:
return $default(_that.start,_that.end);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@TimestampConverter()  DateTime start, @NullableTimestampConverter()  DateTime? end)  $default,) {final _that = this;
switch (_that) {
case _ExtraBreak():
return $default(_that.start,_that.end);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@TimestampConverter()  DateTime start, @NullableTimestampConverter()  DateTime? end)?  $default,) {final _that = this;
switch (_that) {
case _ExtraBreak() when $default != null:
return $default(_that.start,_that.end);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExtraBreak implements ExtraBreak {
  const _ExtraBreak({@TimestampConverter() required this.start, @NullableTimestampConverter() this.end});
  factory _ExtraBreak.fromJson(Map<String, dynamic> json) => _$ExtraBreakFromJson(json);

@override@TimestampConverter() final  DateTime start;
@override@NullableTimestampConverter() final  DateTime? end;

/// Create a copy of ExtraBreak
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExtraBreakCopyWith<_ExtraBreak> get copyWith => __$ExtraBreakCopyWithImpl<_ExtraBreak>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExtraBreakToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExtraBreak&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end);

@override
String toString() {
  return 'ExtraBreak(start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class _$ExtraBreakCopyWith<$Res> implements $ExtraBreakCopyWith<$Res> {
  factory _$ExtraBreakCopyWith(_ExtraBreak value, $Res Function(_ExtraBreak) _then) = __$ExtraBreakCopyWithImpl;
@override @useResult
$Res call({
@TimestampConverter() DateTime start,@NullableTimestampConverter() DateTime? end
});




}
/// @nodoc
class __$ExtraBreakCopyWithImpl<$Res>
    implements _$ExtraBreakCopyWith<$Res> {
  __$ExtraBreakCopyWithImpl(this._self, this._then);

  final _ExtraBreak _self;
  final $Res Function(_ExtraBreak) _then;

/// Create a copy of ExtraBreak
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = freezed,}) {
  return _then(_ExtraBreak(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$TimeEntry {

 String get id; String get workplaceId;/// Local calendar date this entry belongs to, "yyyy-MM-dd".
 String get date;@TimestampConverter() DateTime get clockIn;@NullableTimestampConverter() DateTime? get clockOut; int get breakMinutes;/// Overrides the workplace's default break start time for this day only.
@NullableTimestampConverter() DateTime? get breakStartOverride;/// Overrides the workplace's default scheduled end time for this day
/// only, e.g. when a late/early clock-in shifts the whole shift.
@NullableTimestampConverter() DateTime? get scheduledEndOverride;/// Ad-hoc breaks started/stopped during the shift, separate from the
/// scheduled break above. Ordered by start time.
 List<ExtraBreak> get extraBreaks; bool get isModified;/// True when clockIn was created automatically at the scheduled start
/// time rather than by the user tapping a button.
 bool get isAutoClockedIn;@NullableTimestampConverter() DateTime? get originalClockIn;@NullableTimestampConverter() DateTime? get originalClockOut;/// Reserved for the paid GPS proof-of-attendance feature; unused in MVP.
@GeoPointConverter() GeoPoint? get location; String? get note;@TimestampConverter() DateTime get createdAt;
/// Create a copy of TimeEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeEntryCopyWith<TimeEntry> get copyWith => _$TimeEntryCopyWithImpl<TimeEntry>(this as TimeEntry, _$identity);

  /// Serializes this TimeEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.workplaceId, workplaceId) || other.workplaceId == workplaceId)&&(identical(other.date, date) || other.date == date)&&(identical(other.clockIn, clockIn) || other.clockIn == clockIn)&&(identical(other.clockOut, clockOut) || other.clockOut == clockOut)&&(identical(other.breakMinutes, breakMinutes) || other.breakMinutes == breakMinutes)&&(identical(other.breakStartOverride, breakStartOverride) || other.breakStartOverride == breakStartOverride)&&(identical(other.scheduledEndOverride, scheduledEndOverride) || other.scheduledEndOverride == scheduledEndOverride)&&const DeepCollectionEquality().equals(other.extraBreaks, extraBreaks)&&(identical(other.isModified, isModified) || other.isModified == isModified)&&(identical(other.isAutoClockedIn, isAutoClockedIn) || other.isAutoClockedIn == isAutoClockedIn)&&(identical(other.originalClockIn, originalClockIn) || other.originalClockIn == originalClockIn)&&(identical(other.originalClockOut, originalClockOut) || other.originalClockOut == originalClockOut)&&(identical(other.location, location) || other.location == location)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workplaceId,date,clockIn,clockOut,breakMinutes,breakStartOverride,scheduledEndOverride,const DeepCollectionEquality().hash(extraBreaks),isModified,isAutoClockedIn,originalClockIn,originalClockOut,location,note,createdAt);

@override
String toString() {
  return 'TimeEntry(id: $id, workplaceId: $workplaceId, date: $date, clockIn: $clockIn, clockOut: $clockOut, breakMinutes: $breakMinutes, breakStartOverride: $breakStartOverride, scheduledEndOverride: $scheduledEndOverride, extraBreaks: $extraBreaks, isModified: $isModified, isAutoClockedIn: $isAutoClockedIn, originalClockIn: $originalClockIn, originalClockOut: $originalClockOut, location: $location, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TimeEntryCopyWith<$Res>  {
  factory $TimeEntryCopyWith(TimeEntry value, $Res Function(TimeEntry) _then) = _$TimeEntryCopyWithImpl;
@useResult
$Res call({
 String id, String workplaceId, String date,@TimestampConverter() DateTime clockIn,@NullableTimestampConverter() DateTime? clockOut, int breakMinutes,@NullableTimestampConverter() DateTime? breakStartOverride,@NullableTimestampConverter() DateTime? scheduledEndOverride, List<ExtraBreak> extraBreaks, bool isModified, bool isAutoClockedIn,@NullableTimestampConverter() DateTime? originalClockIn,@NullableTimestampConverter() DateTime? originalClockOut,@GeoPointConverter() GeoPoint? location, String? note,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$TimeEntryCopyWithImpl<$Res>
    implements $TimeEntryCopyWith<$Res> {
  _$TimeEntryCopyWithImpl(this._self, this._then);

  final TimeEntry _self;
  final $Res Function(TimeEntry) _then;

/// Create a copy of TimeEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workplaceId = null,Object? date = null,Object? clockIn = null,Object? clockOut = freezed,Object? breakMinutes = null,Object? breakStartOverride = freezed,Object? scheduledEndOverride = freezed,Object? extraBreaks = null,Object? isModified = null,Object? isAutoClockedIn = null,Object? originalClockIn = freezed,Object? originalClockOut = freezed,Object? location = freezed,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workplaceId: null == workplaceId ? _self.workplaceId : workplaceId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,clockIn: null == clockIn ? _self.clockIn : clockIn // ignore: cast_nullable_to_non_nullable
as DateTime,clockOut: freezed == clockOut ? _self.clockOut : clockOut // ignore: cast_nullable_to_non_nullable
as DateTime?,breakMinutes: null == breakMinutes ? _self.breakMinutes : breakMinutes // ignore: cast_nullable_to_non_nullable
as int,breakStartOverride: freezed == breakStartOverride ? _self.breakStartOverride : breakStartOverride // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledEndOverride: freezed == scheduledEndOverride ? _self.scheduledEndOverride : scheduledEndOverride // ignore: cast_nullable_to_non_nullable
as DateTime?,extraBreaks: null == extraBreaks ? _self.extraBreaks : extraBreaks // ignore: cast_nullable_to_non_nullable
as List<ExtraBreak>,isModified: null == isModified ? _self.isModified : isModified // ignore: cast_nullable_to_non_nullable
as bool,isAutoClockedIn: null == isAutoClockedIn ? _self.isAutoClockedIn : isAutoClockedIn // ignore: cast_nullable_to_non_nullable
as bool,originalClockIn: freezed == originalClockIn ? _self.originalClockIn : originalClockIn // ignore: cast_nullable_to_non_nullable
as DateTime?,originalClockOut: freezed == originalClockOut ? _self.originalClockOut : originalClockOut // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoPoint?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TimeEntry].
extension TimeEntryPatterns on TimeEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimeEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimeEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimeEntry value)  $default,){
final _that = this;
switch (_that) {
case _TimeEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimeEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TimeEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String workplaceId,  String date, @TimestampConverter()  DateTime clockIn, @NullableTimestampConverter()  DateTime? clockOut,  int breakMinutes, @NullableTimestampConverter()  DateTime? breakStartOverride, @NullableTimestampConverter()  DateTime? scheduledEndOverride,  List<ExtraBreak> extraBreaks,  bool isModified,  bool isAutoClockedIn, @NullableTimestampConverter()  DateTime? originalClockIn, @NullableTimestampConverter()  DateTime? originalClockOut, @GeoPointConverter()  GeoPoint? location,  String? note, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimeEntry() when $default != null:
return $default(_that.id,_that.workplaceId,_that.date,_that.clockIn,_that.clockOut,_that.breakMinutes,_that.breakStartOverride,_that.scheduledEndOverride,_that.extraBreaks,_that.isModified,_that.isAutoClockedIn,_that.originalClockIn,_that.originalClockOut,_that.location,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String workplaceId,  String date, @TimestampConverter()  DateTime clockIn, @NullableTimestampConverter()  DateTime? clockOut,  int breakMinutes, @NullableTimestampConverter()  DateTime? breakStartOverride, @NullableTimestampConverter()  DateTime? scheduledEndOverride,  List<ExtraBreak> extraBreaks,  bool isModified,  bool isAutoClockedIn, @NullableTimestampConverter()  DateTime? originalClockIn, @NullableTimestampConverter()  DateTime? originalClockOut, @GeoPointConverter()  GeoPoint? location,  String? note, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TimeEntry():
return $default(_that.id,_that.workplaceId,_that.date,_that.clockIn,_that.clockOut,_that.breakMinutes,_that.breakStartOverride,_that.scheduledEndOverride,_that.extraBreaks,_that.isModified,_that.isAutoClockedIn,_that.originalClockIn,_that.originalClockOut,_that.location,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String workplaceId,  String date, @TimestampConverter()  DateTime clockIn, @NullableTimestampConverter()  DateTime? clockOut,  int breakMinutes, @NullableTimestampConverter()  DateTime? breakStartOverride, @NullableTimestampConverter()  DateTime? scheduledEndOverride,  List<ExtraBreak> extraBreaks,  bool isModified,  bool isAutoClockedIn, @NullableTimestampConverter()  DateTime? originalClockIn, @NullableTimestampConverter()  DateTime? originalClockOut, @GeoPointConverter()  GeoPoint? location,  String? note, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TimeEntry() when $default != null:
return $default(_that.id,_that.workplaceId,_that.date,_that.clockIn,_that.clockOut,_that.breakMinutes,_that.breakStartOverride,_that.scheduledEndOverride,_that.extraBreaks,_that.isModified,_that.isAutoClockedIn,_that.originalClockIn,_that.originalClockOut,_that.location,_that.note,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimeEntry implements TimeEntry {
  const _TimeEntry({required this.id, required this.workplaceId, required this.date, @TimestampConverter() required this.clockIn, @NullableTimestampConverter() this.clockOut, this.breakMinutes = 0, @NullableTimestampConverter() this.breakStartOverride, @NullableTimestampConverter() this.scheduledEndOverride, final  List<ExtraBreak> extraBreaks = const <ExtraBreak>[], this.isModified = false, this.isAutoClockedIn = false, @NullableTimestampConverter() this.originalClockIn, @NullableTimestampConverter() this.originalClockOut, @GeoPointConverter() this.location, this.note, @TimestampConverter() required this.createdAt}): _extraBreaks = extraBreaks;
  factory _TimeEntry.fromJson(Map<String, dynamic> json) => _$TimeEntryFromJson(json);

@override final  String id;
@override final  String workplaceId;
/// Local calendar date this entry belongs to, "yyyy-MM-dd".
@override final  String date;
@override@TimestampConverter() final  DateTime clockIn;
@override@NullableTimestampConverter() final  DateTime? clockOut;
@override@JsonKey() final  int breakMinutes;
/// Overrides the workplace's default break start time for this day only.
@override@NullableTimestampConverter() final  DateTime? breakStartOverride;
/// Overrides the workplace's default scheduled end time for this day
/// only, e.g. when a late/early clock-in shifts the whole shift.
@override@NullableTimestampConverter() final  DateTime? scheduledEndOverride;
/// Ad-hoc breaks started/stopped during the shift, separate from the
/// scheduled break above. Ordered by start time.
 final  List<ExtraBreak> _extraBreaks;
/// Ad-hoc breaks started/stopped during the shift, separate from the
/// scheduled break above. Ordered by start time.
@override@JsonKey() List<ExtraBreak> get extraBreaks {
  if (_extraBreaks is EqualUnmodifiableListView) return _extraBreaks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extraBreaks);
}

@override@JsonKey() final  bool isModified;
/// True when clockIn was created automatically at the scheduled start
/// time rather than by the user tapping a button.
@override@JsonKey() final  bool isAutoClockedIn;
@override@NullableTimestampConverter() final  DateTime? originalClockIn;
@override@NullableTimestampConverter() final  DateTime? originalClockOut;
/// Reserved for the paid GPS proof-of-attendance feature; unused in MVP.
@override@GeoPointConverter() final  GeoPoint? location;
@override final  String? note;
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of TimeEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeEntryCopyWith<_TimeEntry> get copyWith => __$TimeEntryCopyWithImpl<_TimeEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimeEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.workplaceId, workplaceId) || other.workplaceId == workplaceId)&&(identical(other.date, date) || other.date == date)&&(identical(other.clockIn, clockIn) || other.clockIn == clockIn)&&(identical(other.clockOut, clockOut) || other.clockOut == clockOut)&&(identical(other.breakMinutes, breakMinutes) || other.breakMinutes == breakMinutes)&&(identical(other.breakStartOverride, breakStartOverride) || other.breakStartOverride == breakStartOverride)&&(identical(other.scheduledEndOverride, scheduledEndOverride) || other.scheduledEndOverride == scheduledEndOverride)&&const DeepCollectionEquality().equals(other._extraBreaks, _extraBreaks)&&(identical(other.isModified, isModified) || other.isModified == isModified)&&(identical(other.isAutoClockedIn, isAutoClockedIn) || other.isAutoClockedIn == isAutoClockedIn)&&(identical(other.originalClockIn, originalClockIn) || other.originalClockIn == originalClockIn)&&(identical(other.originalClockOut, originalClockOut) || other.originalClockOut == originalClockOut)&&(identical(other.location, location) || other.location == location)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workplaceId,date,clockIn,clockOut,breakMinutes,breakStartOverride,scheduledEndOverride,const DeepCollectionEquality().hash(_extraBreaks),isModified,isAutoClockedIn,originalClockIn,originalClockOut,location,note,createdAt);

@override
String toString() {
  return 'TimeEntry(id: $id, workplaceId: $workplaceId, date: $date, clockIn: $clockIn, clockOut: $clockOut, breakMinutes: $breakMinutes, breakStartOverride: $breakStartOverride, scheduledEndOverride: $scheduledEndOverride, extraBreaks: $extraBreaks, isModified: $isModified, isAutoClockedIn: $isAutoClockedIn, originalClockIn: $originalClockIn, originalClockOut: $originalClockOut, location: $location, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TimeEntryCopyWith<$Res> implements $TimeEntryCopyWith<$Res> {
  factory _$TimeEntryCopyWith(_TimeEntry value, $Res Function(_TimeEntry) _then) = __$TimeEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String workplaceId, String date,@TimestampConverter() DateTime clockIn,@NullableTimestampConverter() DateTime? clockOut, int breakMinutes,@NullableTimestampConverter() DateTime? breakStartOverride,@NullableTimestampConverter() DateTime? scheduledEndOverride, List<ExtraBreak> extraBreaks, bool isModified, bool isAutoClockedIn,@NullableTimestampConverter() DateTime? originalClockIn,@NullableTimestampConverter() DateTime? originalClockOut,@GeoPointConverter() GeoPoint? location, String? note,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$TimeEntryCopyWithImpl<$Res>
    implements _$TimeEntryCopyWith<$Res> {
  __$TimeEntryCopyWithImpl(this._self, this._then);

  final _TimeEntry _self;
  final $Res Function(_TimeEntry) _then;

/// Create a copy of TimeEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workplaceId = null,Object? date = null,Object? clockIn = null,Object? clockOut = freezed,Object? breakMinutes = null,Object? breakStartOverride = freezed,Object? scheduledEndOverride = freezed,Object? extraBreaks = null,Object? isModified = null,Object? isAutoClockedIn = null,Object? originalClockIn = freezed,Object? originalClockOut = freezed,Object? location = freezed,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_TimeEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workplaceId: null == workplaceId ? _self.workplaceId : workplaceId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,clockIn: null == clockIn ? _self.clockIn : clockIn // ignore: cast_nullable_to_non_nullable
as DateTime,clockOut: freezed == clockOut ? _self.clockOut : clockOut // ignore: cast_nullable_to_non_nullable
as DateTime?,breakMinutes: null == breakMinutes ? _self.breakMinutes : breakMinutes // ignore: cast_nullable_to_non_nullable
as int,breakStartOverride: freezed == breakStartOverride ? _self.breakStartOverride : breakStartOverride // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledEndOverride: freezed == scheduledEndOverride ? _self.scheduledEndOverride : scheduledEndOverride // ignore: cast_nullable_to_non_nullable
as DateTime?,extraBreaks: null == extraBreaks ? _self._extraBreaks : extraBreaks // ignore: cast_nullable_to_non_nullable
as List<ExtraBreak>,isModified: null == isModified ? _self.isModified : isModified // ignore: cast_nullable_to_non_nullable
as bool,isAutoClockedIn: null == isAutoClockedIn ? _self.isAutoClockedIn : isAutoClockedIn // ignore: cast_nullable_to_non_nullable
as bool,originalClockIn: freezed == originalClockIn ? _self.originalClockIn : originalClockIn // ignore: cast_nullable_to_non_nullable
as DateTime?,originalClockOut: freezed == originalClockOut ? _self.originalClockOut : originalClockOut // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoPoint?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
