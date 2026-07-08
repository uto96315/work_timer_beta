import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/age_bracket.dart';
import '../models/gender.dart';
import '../models/job_change_intention.dart';
import '../models/prefectures.dart';
import '../models/user_profile.dart';
import '../providers/auth_providers.dart';
import '../providers/firebase_providers.dart';

/// Editable personal/demographic fields, stored on the top-level
/// `users/{uid}` doc (see [UserProfile]). All optional — used for future
/// benchmarking against similar workers, never required to use the app.
class ProfileForm extends ConsumerStatefulWidget {
  const ProfileForm({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<ProfileForm> {
  late Gender? _gender = widget.profile.gender;
  late AgeBracket? _ageBracket = widget.profile.ageBracket;
  late String? _prefecture = widget.profile.prefecture;
  late JobChangeIntention? _jobChangeIntention = widget.profile.jobChangeIntention;

  Future<void> _save() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await ref.read(userProfileRepositoryProvider).update(
      uid,
      widget.profile.copyWith(
        gender: _gender,
        ageBracket: _ageBracket,
        prefecture: _prefecture,
        jobChangeIntention: _jobChangeIntention,
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('保存しました')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<Gender?>(
          initialValue: _gender,
          decoration: const InputDecoration(labelText: '性別（任意）'),
          items: [
            const DropdownMenuItem(value: null, child: Text('未設定')),
            for (final gender in Gender.values)
              DropdownMenuItem(value: gender, child: Text(gender.label)),
          ],
          onChanged: (v) => setState(() => _gender = v),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<AgeBracket?>(
          initialValue: _ageBracket,
          decoration: const InputDecoration(labelText: '年齢（任意）'),
          items: [
            const DropdownMenuItem(value: null, child: Text('未設定')),
            for (final bracket in AgeBracket.values)
              DropdownMenuItem(value: bracket, child: Text(bracket.label)),
          ],
          onChanged: (v) => setState(() => _ageBracket = v),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String?>(
          initialValue: _prefecture,
          decoration: const InputDecoration(labelText: '都道府県（任意）'),
          items: [
            const DropdownMenuItem(value: null, child: Text('未設定')),
            for (final prefecture in kPrefectures)
              DropdownMenuItem(value: prefecture, child: Text(prefecture)),
          ],
          onChanged: (v) => setState(() => _prefecture = v),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<JobChangeIntention?>(
          initialValue: _jobChangeIntention,
          decoration: const InputDecoration(labelText: '転職意思（任意）'),
          items: [
            const DropdownMenuItem(value: null, child: Text('未設定')),
            for (final intention in JobChangeIntention.values)
              DropdownMenuItem(value: intention, child: Text(intention.label)),
          ],
          onChanged: (v) => setState(() => _jobChangeIntention = v),
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: _save, child: const Text('保存')),
      ],
    );
  }
}
