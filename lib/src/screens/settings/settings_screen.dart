import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/user_profile_providers.dart';
import '../../providers/workplace_providers.dart';
import '../../widgets/account_link_form.dart';
import '../../widgets/notification_settings_form.dart';
import '../../widgets/profile_form.dart';
import '../../widgets/settings_ui.dart';
import '../../widgets/workplace_form.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workplaceAsync = ref.watch(primaryWorkplaceProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return KeyboardDoneScaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 140),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Text('設定', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            ),
            workplaceAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('エラー: $e'),
              data: (workplace) => WorkplaceForm(workplace: workplace),
            ),
            const SizedBox(height: 16),
            profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('エラー: $e'),
              data: (profile) => ProfileForm(profile: profile),
            ),
            const SizedBox(height: 16),
            const AccountLinkForm(),
            const SizedBox(height: 16),
            profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('エラー: $e'),
              data: (profile) => NotificationSettingsForm(profile: profile),
            ),
          ],
        ),
      ),
    );
  }
}
