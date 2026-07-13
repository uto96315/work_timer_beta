import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../util/firestore_converters.dart';
import 'age_bracket.dart';
import 'gender.dart';
import 'job_change_intention.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Personal/demographic info stored at `users/{uid}`, separate from the
/// per-workplace docs in the `workplaces` subcollection. Used to power
/// future benchmarking (e.g. average pay for similar people) and optional
/// local notifications.
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    Gender? gender,
    AgeBracket? ageBracket,
    String? prefecture,
    JobChangeIntention? jobChangeIntention,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool notifyClockInReminder,
    @Default(true) bool notifyClockOutReminder,
    @Default(true) bool notifyPayday,
    /// When false (the default), live earnings/worked-time stop counting once
    /// the scheduled end time passes, and the user is prompted via
    /// notification/in-app banner to decide whether to record overtime.
    @Default(false) bool autoOvertimeEnabled,
    /// Only relevant when [autoOvertimeEnabled] is true: sends a reminder
    /// notification every N hours while overtime is ongoing. 0 means no
    /// reminder; otherwise one of 1/2/3.
    @Default(0) int overtimeReminderIntervalHours,
    /// Cumulative food earned from worked hours, used to grow the pet (see
    /// [lib/src/util/pet_stage.dart]).
    @Default(0) int totalFood,
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

extension UserProfileFirestore on UserProfile {
  Map<String, dynamic> toFirestore() => toJson();

  static UserProfile fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return data == null ? const UserProfile() : UserProfile.fromJson(data);
  }
}
