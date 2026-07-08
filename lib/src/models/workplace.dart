import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../util/firestore_converters.dart';

part 'workplace.freezed.dart';
part 'workplace.g.dart';

/// A single employer/workplace's pay and schedule configuration.
///
/// V1 only shows one workplace in the UI, but the schema supports many
/// per user so multi-workplace support can be added later without a
/// data migration.
@freezed
abstract class Workplace with _$Workplace {
  const factory Workplace({
    required String id,
    required String name,
    /// Base hourly wage in yen.
    required int hourlyWage,
    /// Scheduled start time, "HH:mm" (24h, local time).
    required String startTime,
    /// Scheduled end time ("teiji"), "HH:mm" (24h, local time).
    required String endTime,
    required int breakMinutes,
    /// Overtime premium, e.g. 25 means 1.25x hourly wage.
    @Default(25) int overtimeRatePercent,
    /// ISO weekday numbers (1=Mon .. 7=Sun) treated as days off.
    @Default([]) List<int> holidayWeekdays,
    @TimestampConverter() required DateTime createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _Workplace;

  factory Workplace.fromJson(Map<String, dynamic> json) =>
      _$WorkplaceFromJson(json);
}

extension WorkplaceFirestore on Workplace {
  Map<String, dynamic> toFirestore() => toJson();

  static Workplace fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Workplace.fromJson({...doc.data()!, 'id': doc.id});
  }
}
