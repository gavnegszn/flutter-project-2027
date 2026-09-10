import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/xp_progress_bar.dart';
import '../widgets/financial_card.dart';
import '../widgets/goal_card.dart';
import '../widgets/transaction_item.dart';
import '../models/transaction.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final theme = Theme.of(context);
    
    final activeGoals = state.goals.where((g) => !g.isCompleted).toList();
    final recentTransactions = state.transactions.take(3).toList();

    // Group expenses by category
    final expenseTransactions = state.transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();
    
    final Map<String, double> categorySums = {};
    double totalExp = 0.0;
    for (final t in expenseTransactions) {
      categorySums[t.category] = (categorySums[t.category] ?? 0.0) + t.amount;
      totalExp += t.amount;
    }

    final sortedCategories = categorySums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Profile & Greeting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${state.profile.name} 👋',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome back to your dashboard',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    state.profile.name.isNotEmpty ? state.profile.name[0] : 'U',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // XP Progression Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: XpProgressBar(profile: state.profile),
            ),
            const SizedBox(height: 24),

            // Financial Cards (Balance, Income, Expenses, Savings)
            FinancialCard(
              balance: state.balance,
              income: state.totalIncome,
              expenses: state.totalExpenses,
              savings: state.totalSavings,
            ),
            const SizedBox(height: 28),

            // Expense Breakdown Chart
            if (sortedCategories.isNotEmpty) ...[
              _buildSectionHeader(theme, 'Expenses by Category'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: sortedCategories.take(4).map((entry) {
                    final catName = entry.key;
                    final amt = entry.value;
                    final pct = totalExp > 0 ? amt / totalExp : 0.0;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                catName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${amt.toStringAsFixed(0)} (${(pct * 100).toStringAsFixed(0)}%)',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getCategoryColor(catName),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 28),
            ],

            // Active Goals Section
            _buildSectionHeader(theme, 'Active Goals'),
            const SizedBox(height: 12),
            if (activeGoals.isEmpty)
              _buildEmptyState(
                context,
                icon: Icons.track_changes_rounded,
                message: 'No active goals. Tap "Goals" below to create one!',
              )
            else
              ...activeGoals.take(2).map((goal) {
                return GoalCard(
                  goal: goal,
                  onAddFunds: (amt) {
                    state.addSavingsToGoal(goal.id, amt);
                  },
                  onDelete: () {
                    state.deleteGoal(goal.id);
                  },
                );
              }),
            const SizedBox(height: 28),

            // Recent Transactions Section
            _buildSectionHeader(theme, 'Recent Transactions'),
            const SizedBox(height: 12),
            if (recentTransactions.isEmpty)
              _buildEmptyState(
                context,
                icon: Icons.swap_horiz_rounded,
                message: 'No transactions recorded yet.',
              )
            else
              ...recentTransactions.map((tx) {
                return TransactionItem(
                  transaction: tx,
                  onDelete: () {
                    state.deleteTransaction(tx.id);
                  },
                );
              }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required IconData icon, required String message}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transportation':
        return Colors.blue;
      case 'shopping':
        return Colors.purple;
      case 'bills':
        return Colors.red;
      case 'entertainment':
        return Colors.amber;
      case 'education':
        return Colors.indigo;
      case 'health':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
