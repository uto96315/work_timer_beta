import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/user_profile_providers.dart';
import '../../providers/workplace_providers.dart';
import '../../widgets/account_link_form.dart';
import '../../widgets/notification_settings_form.dart';
import '../../widgets/profile_form.dart';
import '../../widgets/workplace_form.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workplaceAsync = ref.watch(primaryWorkplaceProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      // appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 40,),
          const _SectionTitle('勤務先'),
          workplaceAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('エラー: $e'),
            data: (workplace) => WorkplaceForm(
              workplace: workplace,
              onSaved: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('保存しました')));
              },
            ),
          ),
          const SizedBox(height: 32),
          const _SectionTitle('プロフィール'),
          profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('エラー: $e'),
            data: (profile) => ProfileForm(profile: profile),
          ),
          const SizedBox(height: 32),
          const _SectionTitle('アカウント'),
          const AccountLinkForm(),
          const SizedBox(height: 32),
          const _SectionTitle('通知'),
          profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('エラー: $e'),
            data: (profile) => NotificationSettingsForm(profile: profile),
          ),
          const SizedBox(height: 140,),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
