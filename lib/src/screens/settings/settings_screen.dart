import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/workplace_providers.dart';
import '../../widgets/workplace_form.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workplaceAsync = ref.watch(primaryWorkplaceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: workplaceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (workplace) => WorkplaceForm(
          workplace: workplace,
          onSaved: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存しました')));
          },
        ),
      ),
    );
  }
}
