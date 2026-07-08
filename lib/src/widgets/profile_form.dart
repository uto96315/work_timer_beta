import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/age_bracket.dart';
import '../models/gender.dart';
import '../models/job_change_intention.dart';
import '../models/prefectures.dart';
import '../models/user_profile.dart';
import '../providers/auth_providers.dart';
import '../providers/firebase_providers.dart';
import 'settings_ui.dart';

const _unset = '未設定';

/// Editable personal/demographic fields, stored on the top-level
/// `users/{uid}` doc (see [UserProfile]). All optional — used for future
/// benchmarking against similar workers, never required to use the app.
/// Every field saves immediately on selection; there's nothing to submit.
class ProfileForm extends ConsumerWidget {
  const ProfileForm({super.key, required this.profile});

  final UserProfile profile;

  Future<void> _save(WidgetRef ref, UserProfile updated) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await ref.read(userProfileRepositoryProvider).update(uid, updated);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsSection(
      icon: Icons.badge_outlined,
      title: 'プロフィール',
      children: [
        SettingsPickerRow<Gender?>(
          label: '性別',
          value: profile.gender,
          options: [null, ...Gender.values],
          labelOf: (v) => v?.label ?? _unset,
          onChanged: (v) => _save(ref, profile.copyWith(gender: v)),
        ),
        const SizedBox(height: 10),
        SettingsPickerRow<AgeBracket?>(
          label: '年齢',
          value: profile.ageBracket,
          options: [null, ...AgeBracket.values],
          labelOf: (v) => v?.label ?? _unset,
          onChanged: (v) => _save(ref, profile.copyWith(ageBracket: v)),
        ),
        const SizedBox(height: 10),
        SettingsPickerRow<String?>(
          label: '都道府県',
          value: profile.prefecture,
          options: [null, ...kPrefectures],
          labelOf: (v) => v ?? _unset,
          onChanged: (v) => _save(ref, profile.copyWith(prefecture: v)),
        ),
        const SizedBox(height: 10),
        SettingsPickerRow<JobChangeIntention?>(
          label: '転職意思',
          value: profile.jobChangeIntention,
          options: [null, ...JobChangeIntention.values],
          labelOf: (v) => v?.label ?? _unset,
          onChanged: (v) => _save(ref, profile.copyWith(jobChangeIntention: v)),
        ),
      ],
    );
  }
}
