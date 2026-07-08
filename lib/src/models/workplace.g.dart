// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workplace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Workplace _$WorkplaceFromJson(Map<String, dynamic> json) => _Workplace(
  id: json['id'] as String,
  name: json['name'] as String?,
  hourlyWage: (json['hourlyWage'] as num).toInt(),
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  breakMinutes: (json['breakMinutes'] as num).toInt(),
  breakStartTime: json['breakStartTime'] as String? ?? '12:00',
  overtimeRatePercent: (json['overtimeRatePercent'] as num?)?.toInt() ?? 25,
  holidayWeekdays:
      (json['holidayWeekdays'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$WorkplaceToJson(
  _Workplace instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'hourlyWage': instance.hourlyWage,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'breakMinutes': instance.breakMinutes,
  'breakStartTime': instance.breakStartTime,
  'overtimeRatePercent': instance.overtimeRatePercent,
  'holidayWeekdays': instance.holidayWeekdays,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const NullableTimestampConverter().toJson(instance.updatedAt),
};
