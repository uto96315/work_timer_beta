import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../util/firestore_converters.dart';

part 'time_entry.freezed.dart';
part 'time_entry.g.dart';

/// A single day's clock-in/clock-out record for a workplace.
@freezed
abstract class TimeEntry with _$TimeEntry {
  const factory TimeEntry({
    required String id,
    required String workplaceId,
    /// Local calendar date this entry belongs to, "yyyy-MM-dd".
    required String date,
    @TimestampConverter() required DateTime clockIn,
    @NullableTimestampConverter() DateTime? clockOut,
    @Default(0) int breakMinutes,
    @Default(false) bool isModified,
    @NullableTimestampConverter() DateTime? originalClockIn,
    @NullableTimestampConverter() DateTime? originalClockOut,
    /// Reserved for the paid GPS proof-of-attendance feature; unused in MVP.
    @GeoPointConverter() GeoPoint? location,
    String? note,
    @TimestampConverter() required DateTime createdAt,
  }) = _TimeEntry;

  factory TimeEntry.fromJson(Map<String, dynamic> json) =>
      _$TimeEntryFromJson(json);
}

extension TimeEntryFirestore on TimeEntry {
  Map<String, dynamic> toFirestore() => toJson();

  static TimeEntry fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return TimeEntry.fromJson({...doc.data()!, 'id': doc.id});
  }

  bool get isOpen => clockOut == null;
}
