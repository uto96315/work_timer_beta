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
