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
  salaryType:
      $enumDecodeNullable(_$SalaryTypeEnumMap, json['salaryType']) ??
      SalaryType.hourly,
  hourlyWage: (json['hourlyWage'] as num).toInt(),
  baseMonthlySalary: (json['baseMonthlySalary'] as num?)?.toInt(),
  fixedOvertimeAllowance: (json['fixedOvertimeAllowance'] as num?)?.toInt(),
  fixedOvertimeHours: (json['fixedOvertimeHours'] as num?)?.toDouble(),
  standardMonthlyHours: (json['standardMonthlyHours'] as num?)?.toDouble(),
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
  payday: (json['payday'] as num?)?.toInt(),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$WorkplaceToJson(
  _Workplace instance,
) => <String, dynamic>{
  'id': instance.id,
  'industry': _$IndustryEnumMap[instance.industry],
  'employmentType': _$EmploymentTypeEnumMap[instance.employmentType],
  'salaryType': _$SalaryTypeEnumMap[instance.salaryType]!,
  'hourlyWage': instance.hourlyWage,
  'baseMonthlySalary': instance.baseMonthlySalary,
  'fixedOvertimeAllowance': instance.fixedOvertimeAllowance,
  'fixedOvertimeHours': instance.fixedOvertimeHours,
  'standardMonthlyHours': instance.standardMonthlyHours,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'breakMinutes': instance.breakMinutes,
  'breakStartTime': instance.breakStartTime,
  'overtimeRatePercent': instance.overtimeRatePercent,
  'holidayWeekdays': instance.holidayWeekdays,
  'payday': instance.payday,
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

const _$SalaryTypeEnumMap = {
  SalaryType.hourly: 'hourly',
  SalaryType.monthly: 'monthly',
};
