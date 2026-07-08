// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workplace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Workplace _$WorkplaceFromJson(Map<String, dynamic> json) => _Workplace(
  id: json['id'] as String,
  industry: $enumDecodeNullable(_$IndustryEnumMap, json['industry']),
  employmentType: $enumDecodeNullable(
    _$EmploymentTypeEnumMap,
    json['employmentType'],
  ),
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
  'industry': _$IndustryEnumMap[instance.industry],
  'employmentType': _$EmploymentTypeEnumMap[instance.employmentType],
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

const _$IndustryEnumMap = {
  Industry.foodService: 'foodService',
  Industry.retail: 'retail',
  Industry.officeWork: 'officeWork',
  Industry.itEngineer: 'itEngineer',
  Industry.education: 'education',
  Industry.medicalWelfare: 'medicalWelfare',
  Industry.logistics: 'logistics',
  Industry.manufacturing: 'manufacturing',
  Industry.construction: 'construction',
  Industry.serviceIndustry: 'serviceIndustry',
  Industry.agriculture: 'agriculture',
  Industry.finance: 'finance',
  Industry.publicServant: 'publicServant',
  Industry.student: 'student',
  Industry.other: 'other',
};

const _$EmploymentTypeEnumMap = {
  EmploymentType.partTimeArbeit: 'partTimeArbeit',
  EmploymentType.partTime: 'partTime',
  EmploymentType.fullTime: 'fullTime',
  EmploymentType.contract: 'contract',
  EmploymentType.temporary: 'temporary',
  EmploymentType.other: 'other',
};
