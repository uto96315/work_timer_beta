import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../util/firestore_converters.dart';

part 'time_entry.freezed.dart';
part 'time_entry.g.dart';

/// An ad-hoc break the user starts/stops live during a shift, on top of the
/// workplace's single scheduled break — mainly for breaks taken during
/// overtime, which the fixed schedule doesn't already account for.
/// [end] is null while the break is still ongoing.
@freezed
abstract class ExtraBreak with _$ExtraBreak {
  const factory ExtraBreak({
    @TimestampConverter() required DateTime start,
    @NullableTimestampConverter() DateTime? end,
  }) = _ExtraBreak;

  factory ExtraBreak.fromJson(Map<String, dynamic> json) =>
      _$ExtraBreakFromJson(json);
}

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
    /// Overrides the workplace's default break start time for this day only.
    @NullableTimestampConverter() DateTime? breakStartOverride,
    /// Overrides the workplace's default scheduled end time for this day
    /// only, e.g. when a late/early clock-in shifts the whole shift.
    @NullableTimestampConverter() DateTime? scheduledEndOverride,
    /// Ad-hoc breaks started/stopped during the shift, separate from the
    /// scheduled break above. Ordered by start time.
    @Default(<ExtraBreak>[]) List<ExtraBreak> extraBreaks,
    @Default(false) bool isModified,
    /// True when clockIn was created automatically at the scheduled start
    /// time rather than by the user tapping a button.
    @Default(false) bool isAutoClockedIn,
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
