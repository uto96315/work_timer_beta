import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_providers.dart';
import 'providers/notification_providers.dart';
import 'providers/widget_sync_providers.dart';
import 'providers/workplace_providers.dart';
import 'screens/account/account_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/records/records_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'widgets/floating_nav_bar.dart';

class WorkTimerApp extends StatelessWidget {
  const WorkTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF0EA894));
    return MaterialApp(
      title: 'ヌリツブ',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF4F6F7),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE8EBEC)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF4F6F7),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.error, width: 1.2),
          ),
        ),
      ),
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

class _RootScaffold extends ConsumerStatefulWidget {
  const _RootScaffold();

  @override
  ConsumerState<_RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends ConsumerState<_RootScaffold> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    RecordsScreen(),
    AccountScreen(),
    SettingsScreen(),
  ];

  static const _destinations = [
    FloatingNavDestination(icon: Icons.timer_outlined, selectedIcon: Icons.timer),
    FloatingNavDestination(icon: Icons.list_alt_outlined, selectedIcon: Icons.list_alt),
    FloatingNavDestination(icon: Icons.person_outline, selectedIcon: Icons.person),
    FloatingNavDestination(icon: Icons.settings_outlined, selectedIcon: Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    // Keeps scheduled local notifications in sync with the workplace hours
    // and notification prefs whenever either changes.
    ref.watch(notificationSyncProvider);
    // Keeps the iOS home-screen widget's shared data in sync.
    ref.watch(widgetSyncProvider);
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: FloatingNavBar(
        destinations: _destinations,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
