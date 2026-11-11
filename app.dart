import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'features/shared/habit_store.dart';
import 'features/home/home_page.dart';
import 'features/progress/progress_page.dart';
import 'features/money/money_page.dart';
import 'features/awards/awards_page.dart';
import 'features/profile/profile_page.dart';

class NoSmokeNoBoozeApp extends StatelessWidget {
  const NoSmokeNoBoozeApp({super.key, required this.store});
  final HabitStore store;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'НЕ КУРЮ И НЕ БУХАЮ',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    home: MainShell(store: store),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.store});
  final HabitStore store;
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(store: widget.store),
      ProgressPage(store: widget.store),
      MoneyPage(store: widget.store),
      AwardsPage(store: widget.store),
      ProfilePage(store: widget.store),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Прогресс'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Деньги'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Награды'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Профиль'),
        ],
      ),
    );
  }
}
