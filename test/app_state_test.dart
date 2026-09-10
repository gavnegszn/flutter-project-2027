import 'package:finance_gamified/models/goal.dart';
import 'package:finance_gamified/models/transaction.dart';
import 'package:finance_gamified/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppState', () {
    late AppState state;

    setUp(() => state = AppState(userName: 'Test user'));

    test('a new account begins with no financial data', () {
      expect(state.profile.name, 'Test user');
      expect(state.profile.xp, 0);
      expect(state.transactions, isEmpty);
      expect(state.goals, isEmpty);
      expect(state.totalIncome, 0);
      expect(state.totalExpenses, 0);
      expect(state.balance, 0);
    });

    test('transactions affect the balance and can be removed', () {
      final transaction = Transaction(id: 'income', type: TransactionType.income, amount: 500, category: 'Freelance', description: 'Project', date: DateTime(2026));
      state.addTransaction(transaction);
      expect(state.balance, 500);
      state.deleteTransaction('income');
      expect(state.balance, 0);
    });

    test('adding savings updates a goal and grants XP', () {
      state.addGoal(FinancialGoal(id: 'goal', name: 'Laptop', targetAmount: 1000, savedAmount: 0, deadline: DateTime(2027), category: 'Electronics'));
      final afterGoalXp = state.profile.xp;
      state.addSavingsToGoal('goal', 100);
      expect(state.goals.single.savedAmount, 100);
      expect(state.profile.xp, greaterThan(afterGoalXp));
    });
  });
}
