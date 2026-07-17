import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/user_profile_providers.dart';
import '../../providers/widget_sync_providers.dart';
import '../../providers/workplace_providers.dart';
import '../../widgets/account_link_form.dart';
import '../../widgets/notification_settings_form.dart';
import '../../widgets/profile_form.dart';
import '../../widgets/settings_ui.dart';
import '../../widgets/workplace_form.dart';
import '../dev/dog_design_preview_screen.dart';
import 'readme_screen.dart';

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
            const SizedBox(height: 16),
            profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('エラー: $e'),
              data: (profile) => OvertimeSettingsForm(profile: profile),
            ),
            const SizedBox(height: 16),
            const _WidgetSyncSection(),
            const SizedBox(height: 16),
            const _LicenseCreditsSection(),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('README'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReadmeScreen()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.pets_outlined),
                title: const Text('犬デザイン候補を見る（開発用）'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DogDesignPreviewScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Attribution for third-party assets used in the UI — currently just the
/// dog emoji, which is CC-BY 4.0 (attribution required, unlike the Twemoji
/// *library* code itself, which is MIT) rather than public domain.
class _LicenseCreditsSection extends StatelessWidget {
  const _LicenseCreditsSection();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SettingsSection(
      icon: Icons.info_outline,
      title: 'ライセンス表記',
      children: [
        Text(
          '🐶 Dog emoji by Twemoji — licensed under CC-BY 4.0\n'
          'https://creativecommons.org/licenses/by/4.0/',
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Manually re-pushes today's data to the iOS home-screen widget and
/// reports success/failure via a SnackBar. Release builds print nothing to
/// any console the user can see, so this is the only way to tell whether a
/// sync attempt actually failed on their device.
class _WidgetSyncSection extends ConsumerStatefulWidget {
  const _WidgetSyncSection();

  @override
  ConsumerState<_WidgetSyncSection> createState() => _WidgetSyncSectionState();
}

class _WidgetSyncSectionState extends ConsumerState<_WidgetSyncSection> {
  bool _isSyncing = false;

  Future<void> _sync() async {
    setState(() => _isSyncing = true);
    final error = await triggerWidgetSyncNow(ref);
    if (!mounted) return;
    setState(() => _isSyncing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error == null ? 'ウィジェットを更新しました' : '更新に失敗しました: $error'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      icon: Icons.widgets_outlined,
      title: 'ウィジェット',
      children: [
        FilledButton.tonal(
          onPressed: _isSyncing ? null : _sync,
          child: _isSyncing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('ウィジェットを今すぐ更新'),
        ),
      ],
    );
  }
}
