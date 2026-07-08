import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_providers.dart';
import 'providers/workplace_providers.dart';
import 'screens/home/home_screen.dart';
import 'screens/monthly_summary/monthly_summary_screen.dart';
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/records/records_screen.dart';
import 'screens/settings/settings_screen.dart';

class WorkTimerApp extends StatelessWidget {
  const WorkTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '仕事タイマー',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const _RootRouter(),
    );
  }
}

/// Decides between the splash screen, the onboarding flow, and the main app
/// shell based on auth/workplace state. Once a workplace exists in
/// Firestore, this rebuilds and swaps straight to [_RootScaffold] regardless
/// of how deep the onboarding flow's own navigation stack is.
class _RootRouter extends ConsumerWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUidProvider);
    if (uid == null) {
      return const SplashScreen();
    }

    final workplaceAsync = ref.watch(primaryWorkplaceProvider);
    return workplaceAsync.when(
      loading: () => const SplashScreen(),
      error: (e, _) => Scaffold(body: Center(child: Text('エラー: $e'))),
      data: (workplace) => workplace == null ? const WelcomeScreen() : const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatefulWidget {
  const _RootScaffold();

  @override
  State<_RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<_RootScaffold> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    RecordsScreen(),
    MonthlySummaryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer_outlined), label: 'ホーム'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: '記録'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: '月次'),
          NavigationDestination(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
