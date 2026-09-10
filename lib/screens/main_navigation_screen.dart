import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/goal.dart';
import '../state/app_state.dart';
import '../widgets/goal_completed_dialog.dart';
import '../widgets/level_up_dialog.dart';
import 'dashboard_screen.dart';
import 'goals_screen.dart';
import 'profile_screen.dart';
import 'transactions_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final ValueChanged<bool> onThemeChanged;

  const MainNavigationScreen({
    super.key,
    required this.onLogout,
    required this.onThemeChanged,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const TransactionsScreen(),
      const GoalsScreen(),
      ProfileScreen(onLogout: widget.onLogout, onThemeChanged: widget.onThemeChanged),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _AppEventListener(child: _screens[_currentIndex])),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.swap_horiz_outlined), selectedIcon: Icon(Icons.swap_horiz_rounded), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.track_changes_outlined), selectedIcon: Icon(Icons.track_changes_rounded), label: 'Goals'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _AppEventListener extends StatefulWidget {
  final Widget child;
  const _AppEventListener({required this.child});

  @override
  State<_AppEventListener> createState() => _AppEventListenerState();
}

class _AppEventListenerState extends State<_AppEventListener> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateProvider.of(context);

    if (state.lastLevelUpLevel != null) {
      final level = state.lastLevelUpLevel!;
      state.clearLevelUp();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showDialog(context: context, barrierDismissible: false, builder: (_) => LevelUpDialog(newLevel: level));
      });
    }

    if (state.newlyUnlockedAchievements.isNotEmpty) {
      final unlocked = List<Achievement>.from(state.newlyUnlockedAchievements);
      state.clearNewlyUnlockedAchievements();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        for (final achievement in unlocked) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Achievement unlocked: ${achievement.title}'),
          ));
        }
      });
    }

    if (state.newlyCompletedGoals.isNotEmpty) {
      final completed = List<FinancialGoal>.from(state.newlyCompletedGoals);
      state.clearNewlyCompletedGoals();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        for (final goal in completed) {
          showDialog(context: context, barrierDismissible: false, builder: (_) => GoalCompletedDialog(goal: goal));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
