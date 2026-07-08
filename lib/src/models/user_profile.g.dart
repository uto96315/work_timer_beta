// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
  ageBracket: $enumDecodeNullable(_$AgeBracketEnumMap, json['ageBracket']),
  prefecture: json['prefecture'] as String?,
  jobChangeIntention: $enumDecodeNullable(
    _$JobChangeIntentionEnumMap,
    json['jobChangeIntention'],
  ),
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
  notifyClockInReminder: json['notifyClockInReminder'] as bool? ?? true,
  notifyClockOutReminder: json['notifyClockOutReminder'] as bool? ?? true,
  updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$UserProfileToJson(
  _UserProfile instance,
) => <String, dynamic>{
  'gender': _$GenderEnumMap[instance.gender],
  'ageBracket': _$AgeBracketEnumMap[instance.ageBracket],
  'prefecture': instance.prefecture,
  'jobChangeIntention':
      _$JobChangeIntentionEnumMap[instance.jobChangeIntention],
  'notificationsEnabled': instance.notificationsEnabled,
  'notifyClockInReminder': instance.notifyClockInReminder,
  'notifyClockOutReminder': instance.notifyClockOutReminder,
  'updatedAt': const NullableTimestampConverter().toJson(instance.updatedAt),
};

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
  Gender.preferNotToSay: 'preferNotToSay',
};

const _$AgeBracketEnumMap = {
  AgeBracket.under18: 'under18',
  AgeBracket.age18to19: 'age18to19',
  AgeBracket.age20to24: 'age20to24',
  AgeBracket.age25to29: 'age25to29',
  AgeBracket.age30to34: 'age30to34',
  AgeBracket.age35to39: 'age35to39',
  AgeBracket.age40to44: 'age40to44',
  AgeBracket.age45to49: 'age45to49',
  AgeBracket.age50to54: 'age50to54',
  AgeBracket.age55to59: 'age55to59',
  AgeBracket.age60plus: 'age60plus',
};

const _$JobChangeIntentionEnumMap = {
  JobChangeIntention.rightAway: 'rightAway',
  JobChangeIntention.soon: 'soon',
  JobChangeIntention.ifGoodOffer: 'ifGoodOffer',
  JobChangeIntention.notMuch: 'notMuch',
  JobChangeIntention.notAtAll: 'notAtAll',
};
