// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExtraBreak _$ExtraBreakFromJson(Map<String, dynamic> json) => _ExtraBreak(
  start: const TimestampConverter().fromJson(json['start']),
  end: const NullableTimestampConverter().fromJson(json['end']),
);

Map<String, dynamic> _$ExtraBreakToJson(_ExtraBreak instance) =>
    <String, dynamic>{
      'start': const TimestampConverter().toJson(instance.start),
      'end': const NullableTimestampConverter().toJson(instance.end),
    };

_TimeEntry _$TimeEntryFromJson(Map<String, dynamic> json) => _TimeEntry(
  id: json['id'] as String,
  workplaceId: json['workplaceId'] as String,
  date: json['date'] as String,
  clockIn: const TimestampConverter().fromJson(json['clockIn']),
  clockOut: const NullableTimestampConverter().fromJson(json['clockOut']),
  breakMinutes: (json['breakMinutes'] as num?)?.toInt() ?? 0,
  breakStartOverride: const NullableTimestampConverter().fromJson(
    json['breakStartOverride'],
  ),
  scheduledEndOverride: const NullableTimestampConverter().fromJson(
    json['scheduledEndOverride'],
  ),
  extraBreaks:
      (json['extraBreaks'] as List<dynamic>?)
          ?.map((e) => ExtraBreak.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ExtraBreak>[],
  isModified: json['isModified'] as bool? ?? false,
  isAutoClockedIn: json['isAutoClockedIn'] as bool? ?? false,
  originalClockIn: const NullableTimestampConverter().fromJson(
    json['originalClockIn'],
  ),
  originalClockOut: const NullableTimestampConverter().fromJson(
    json['originalClockOut'],
  ),
  location: const GeoPointConverter().fromJson(json['location']),
  note: json['note'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$TimeEntryToJson(_TimeEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workplaceId': instance.workplaceId,
      'date': instance.date,
      'clockIn': const TimestampConverter().toJson(instance.clockIn),
      'clockOut': const NullableTimestampConverter().toJson(instance.clockOut),
      'breakMinutes': instance.breakMinutes,
      'breakStartOverride': const NullableTimestampConverter().toJson(
        instance.breakStartOverride,
      ),
      'scheduledEndOverride': const NullableTimestampConverter().toJson(
        instance.scheduledEndOverride,
      ),
      'extraBreaks': instance.extraBreaks,
      'isModified': instance.isModified,
      'isAutoClockedIn': instance.isAutoClockedIn,
      'originalClockIn': const NullableTimestampConverter().toJson(
        instance.originalClockIn,
      ),
      'originalClockOut': const NullableTimestampConverter().toJson(
        instance.originalClockOut,
      ),
      'location': const GeoPointConverter().toJson(instance.location),
      'note': instance.note,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
