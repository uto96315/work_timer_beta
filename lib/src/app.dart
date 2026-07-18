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
import 'services/widget_pending_action_service.dart';
import 'widgets/floating_nav_bar.dart';

class WorkTimerApp extends StatelessWidget {
  const WorkTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Pixel-art palette + a dot-matrix font, matching the pixel-sprite pet:
    // flat colors, square corners everywhere, no blur/gradients on chrome.
    const ink = Color(0xFF2E2A26);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5FBE99),
      brightness: Brightness.light,
    ).copyWith(outline: ink.withValues(alpha: 0.6));
    return MaterialApp(
      title: 'ikigai',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        fontFamily: 'DotGothic16',
        scaffoldBackgroundColor: const Color(0xFFFBF3DE),
        cardTheme: CardThemeData(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          color: const Color(0xFFFFFDF6),
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: const BorderSide(color: ink, width: 3),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFDF6),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: ink, width: 2),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: ink, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: colorScheme.primary, width: 3),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: colorScheme.error, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: ink, width: 3),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: ink, width: 3),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            side: const BorderSide(color: ink, width: 2),
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

class _RootScaffoldState extends ConsumerState<_RootScaffold> with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    applyPendingWidgetActions(ref);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Catches 退勤/休憩 taps made on the iOS home-screen widget while the app
    // was backgrounded — see widget_pending_action_service.dart for why the
    // widget can't write them to Firestore itself.
    if (state == AppLifecycleState.resumed) {
      applyPendingWidgetActions(ref);
    }
  }

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
