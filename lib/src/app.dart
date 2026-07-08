import 'package:flutter/material.dart';

import 'screens/home/home_screen.dart';
import 'screens/monthly_summary/monthly_summary_screen.dart';
import 'screens/records/records_screen.dart';
import 'screens/settings/settings_screen.dart';

class WorkTimerApp extends StatelessWidget {
  const WorkTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '仕事タイマー',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const _RootScaffold(),
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
