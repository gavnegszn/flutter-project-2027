import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/achievement.dart';
import '../models/user_profile.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  final String? persistenceKey;
  bool _hasLoadedSavedState = false;
  late UserProfile _profile;
  late List<Transaction> _transactions;
  late List<FinancialGoal> _goals;
  late List<Achievement> _achievements;

  int? _lastLevelUpLevel;
  int? get lastLevelUpLevel => _lastLevelUpLevel;

  final List<Achievement> _newlyUnlockedAchievements = [];
  List<Achievement> get newlyUnlockedAchievements => _newlyUnlockedAchievements;

  final List<FinancialGoal> _newlyCompletedGoals = [];
  List<FinancialGoal> get newlyCompletedGoals => _newlyCompletedGoals;

  AppState({String? userName, this.persistenceKey}) {
    _initSampleData();
    _profile = UserProfile(name: userName?.trim().isNotEmpty == true ? userName!.trim() : 'User', xp: 0);
    _transactions = [];
    _goals = [];
    _achievements = _achievements.map((item) => item.copyWith(isUnlocked: false, unlockedAt: null)).toList();
  }

  Future<void> loadSaved(String key) async {
    if (_hasLoadedSavedState) return;
    _hasLoadedSavedState = true;
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('state_$key');
    if (raw == null) return;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    _profile = UserProfile(name: data['name'] as String, xp: data['xp'] as int);
    _transactions = (data['transactions'] as List).map((e) => Transaction.fromMap(Map<String, dynamic>.from(e))).toList();
    _goals = (data['goals'] as List).map((e) => FinancialGoal.fromMap(Map<String, dynamic>.from(e))).toList();
    if (data['achievements'] is List) {
      _achievements = (data['achievements'] as List).map((e) => Achievement.fromMap(Map<String, dynamic>.from(e))).toList();
    }
    notifyListeners();
  }
  Future<void> persist() async { if (persistenceKey != null) await _save(persistenceKey!); }
  Future<void> _save(String key) async { final p = await SharedPreferences.getInstance(); await p.setString('state_$key', jsonEncode({'name': _profile.name, 'xp': _profile.xp, 'transactions': _transactions.map((e) => e.toMap()).toList(), 'goals': _goals.map((e) => e.toMap()).toList(), 'achievements': _achievements.map((e) => e.toMap()).toList()})); }

  UserProfile get profile => _profile;

  void updateProfileName(String name) {
    if (name.trim().isEmpty) return;
    _profile = _profile.copyWith(name: name.trim());
    notifyListeners();
    if (persistenceKey != null) _save(persistenceKey!);
  }
  List<Transaction> get transactions => _transactions;
  List<FinancialGoal> get goals => _goals;
  List<Achievement> get achievements => _achievements;

  void _initSampleData() {
    _profile = UserProfile(name: 'Ibrahim', xp: 750);

    _transactions = [
      Transaction(
        id: 't1',
        type: TransactionType.income,
        amount: 2000.0,
        category: 'Salary',
        description: 'Monthly payroll',
        date: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Transaction(
        id: 't2',
        type: TransactionType.expense,
        amount: 50.0,
        category: 'Food',
        description: 'Grocery shopping',
        date: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Transaction(
        id: 't3',
        type: TransactionType.expense,
        amount: 30.0,
        category: 'Transportation',
        description: 'Fuel & subway fare',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: 't4',
        type: TransactionType.expense,
        amount: 100.0,
        category: 'Shopping',
        description: 'New shoes',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Transaction(
        id: 't5',
        type: TransactionType.expense,
        amount: 200.0,
        category: 'Bills',
        description: 'Electricity & Water',
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Transaction(
        id: 't6',
        type: TransactionType.expense,
        amount: 50.0,
        category: 'Entertainment',
        description: 'Movie ticket & snacks',
        date: DateTime.now().subtract(const Duration(days: 4)),
      ),
      // Adding a $320 expense to make the total expenses exactly $750 (matches prompt's summary card)
      Transaction(
        id: 't7',
        type: TransactionType.expense,
        amount: 320.0,
        category: 'Bills',
        description: 'Internet & rent portion',
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    _goals = [
      FinancialGoal(
        id: 'g1',
        name: 'Gaming Laptop',
        targetAmount: 1000.0,
        savedAmount: 500.0,
        category: 'Electronics',
        deadline: DateTime(2026, 12, 1),
      ),
      FinancialGoal(
        id: 'g2',
        name: 'Emergency Fund',
        targetAmount: 2000.0,
        savedAmount: 700.0,
        category: 'Savings',
        deadline: DateTime(2027, 1, 1),
      ),
      // Three completed goals to match the Profile screen stats ("Completed Goals: 3", "Total Savings: $1,450")
      // Active savings: $500 (Laptop) + $700 (Fund) = $1,200.
      // Completed goals savings: $50 + $100 + $100 = $250.
      // Total savings = $1,450.
      FinancialGoal(
        id: 'g3',
        name: 'Textbooks',
        targetAmount: 50.0,
        savedAmount: 50.0,
        category: 'Education',
        deadline: DateTime.now().subtract(const Duration(days: 30)),
        isCompleted: true,
      ),
      FinancialGoal(
        id: 'g4',
        name: 'Gift for Mom',
        targetAmount: 100.0,
        savedAmount: 100.0,
        category: 'Other',
        deadline: DateTime.now().subtract(const Duration(days: 20)),
        isCompleted: true,
      ),
      FinancialGoal(
        id: 'g5',
        name: 'Smart Watch',
        targetAmount: 100.0,
        savedAmount: 100.0,
        category: 'Electronics',
        deadline: DateTime.now().subtract(const Duration(days: 10)),
        isCompleted: true,
      ),
    ];

    _achievements = [
      Achievement(
        id: 'ach_first_step',
        title: 'First Step',
        description: 'Create your first financial goal.',
        isUnlocked: true,
        icon: '🏆',
      ),
      Achievement(
        id: 'ach_first_saver',
        title: 'First Saver',
        description: 'Save your first \$100.',
        isUnlocked: true,
        icon: '💰',
      ),
      Achievement(
        id: 'ach_goal_crusher',
        title: 'Goal Crusher',
        description: 'Complete your first financial goal.',
        isUnlocked: true,
        icon: '🎯',
      ),
      Achievement(
        id: 'ach_super_saver',
        title: 'Super Saver',
        description: 'Save \$500.',
        isUnlocked: false,
        icon: '💎',
      ),
    ];
  }

  // Getters for totals
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpenses;

  // Let's calculate total savings as cumulative savings in goals
  double get totalSavings => _goals.fold(0.0, (sum, g) => sum + g.savedAmount);

  int get completedGoalsCount => _goals.where((g) => g.isCompleted).length;

  // State Modifying Actions

  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction);
    notifyListeners();
    if (persistenceKey != null) _save(persistenceKey!);
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    if (persistenceKey != null) _save(persistenceKey!);
  }

  void addGoal(FinancialGoal goal) {
    _goals.insert(0, goal);
    
    // XP reward: Create first financial goal (+50 XP)
    // Check if this is the first goal (apart from completed ones, or check if we unlock 'First Step')
    // We already start with active goals, but let's check achievement state
    final firstStepAch = _achievements.firstWhere((a) => a.id == 'ach_first_step');
    if (!firstStepAch.isUnlocked) {
      _unlockAchievement('ach_first_step');
      _gainXP(50);
    }
    
    notifyListeners();
    if (persistenceKey != null) _save(persistenceKey!);
  }

  void deleteGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
    if (persistenceKey != null) _save(persistenceKey!);
  }

  void addSavingsToGoal(String goalId, double amount) {
    if (amount <= 0) return;

    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index == -1) return;

    final goal = _goals[index];
    if (goal.isCompleted) return;

    final newSavedAmount = goal.savedAmount + amount;
    final isNowCompleted = newSavedAmount >= goal.targetAmount;

    final updatedGoal = goal.copyWith(
      savedAmount: isNowCompleted ? goal.targetAmount : newSavedAmount,
      isCompleted: isNowCompleted,
    );

    _goals[index] = updatedGoal;

    // Award XP for saving: +10 XP per $10 saved
    final xpEarned = (amount ~/ 10) * 10;
    if (xpEarned > 0) {
      _gainXP(xpEarned);
    }

    // Check achievement: First Saver (Save first $100)
    // In our sample, it is already unlocked. But let's verify if not unlocked.
    final firstSaverAch = _achievements.firstWhere((a) => a.id == 'ach_first_saver');
    if (!firstSaverAch.isUnlocked && totalSavings >= 100.0) {
      _unlockAchievement('ach_first_saver');
      _gainXP(100);
    }

    // Check achievement: Super Saver (Save $500 total in goals)
    final superSaverAch = _achievements.firstWhere((a) => a.id == 'ach_super_saver');
    if (!superSaverAch.isUnlocked && totalSavings >= 500.0) {
      _unlockAchievement('ach_super_saver');
      _gainXP(150); // Award 150 XP for super saver
    }

    // Check goal completion reward
    if (isNowCompleted) {
      _gainXP(500); // Complete a financial goal: +500 XP
      _newlyCompletedGoals.add(updatedGoal);

      // Check achievement: Goal Crusher (Complete your first goal)
      final goalCrusherAch = _achievements.firstWhere((a) => a.id == 'ach_goal_crusher');
      if (!goalCrusherAch.isUnlocked) {
        _unlockAchievement('ach_goal_crusher');
      }
    }

    notifyListeners();
    if (persistenceKey != null) _save(persistenceKey!);
  }

  void _gainXP(int amount) {
    final oldLevel = _profile.level;
    final newXp = _profile.xp + amount;
    _profile = _profile.copyWith(xp: newXp);

    if (_profile.level > oldLevel) {
      _lastLevelUpLevel = _profile.level;
    }
  }

  void _unlockAchievement(String achId) {
    final index = _achievements.indexWhere((a) => a.id == achId);
    if (index != -1 && !_achievements[index].isUnlocked) {
      final unlocked = _achievements[index].copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      _achievements[index] = unlocked;
      _newlyUnlockedAchievements.add(unlocked);
    }
  }

  void clearLevelUp() {
    _lastLevelUpLevel = null;
  }

  void clearNewlyUnlockedAchievements() {
    _newlyUnlockedAchievements.clear();
  }

  void clearNewlyCompletedGoals() {
    _newlyCompletedGoals.clear();
  }
}

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'No AppStateProvider found in context');
    return provider!.notifier!;
  }
}
