import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = transaction.type == TransactionType.income;
    final isToday = _isSameDay(transaction.date, DateTime.now());
    final isYesterday = _isSameDay(transaction.date, DateTime.now().subtract(const Duration(days: 1)));
    
    String dateStr;
    if (isToday) {
      dateStr = 'Today';
    } else if (isYesterday) {
      dateStr = 'Yesterday';
    } else {
      dateStr = '${_getMonthName(transaction.date.month)} ${transaction.date.day}';
    }

    final categoryData = _getCategoryData(transaction.category, isIncome);

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: categoryData.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                categoryData.icon,
                color: categoryData.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description.isNotEmpty
                        ? transaction.description
                        : transaction.category,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        transaction.category,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: TextStyle(
                          color: theme.colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  _CategoryData _getCategoryData(String category, bool isIncome) {
    if (isIncome) {
      switch (category.toLowerCase()) {
        case 'salary':
          return _CategoryData(Icons.work_rounded, Colors.blue);
        case 'freelance':
          return _CategoryData(Icons.computer_rounded, Colors.teal);
        case 'gift':
          return _CategoryData(Icons.card_giftcard_rounded, Colors.pink);
        default:
          return _CategoryData(Icons.attach_money_rounded, Colors.grey);
      }
    } else {
      switch (category.toLowerCase()) {
        case 'food':
          return _CategoryData(Icons.restaurant_rounded, Colors.orange);
        case 'transportation':
          return _CategoryData(Icons.directions_bus_rounded, Colors.blue);
        case 'shopping':
          return _CategoryData(Icons.shopping_bag_rounded, Colors.purple);
        case 'bills':
          return _CategoryData(Icons.receipt_long_rounded, Colors.red);
        case 'entertainment':
          return _CategoryData(Icons.movie_filter_rounded, Colors.amber);
        case 'education':
          return _CategoryData(Icons.school_rounded, Colors.indigo);
        case 'health':
          return _CategoryData(Icons.healing_rounded, Colors.green);
        default:
          return _CategoryData(Icons.category_rounded, Colors.grey);
      }
    }
  }
}

class _CategoryData {
  final IconData icon;
  final Color color;

  _CategoryData(this.icon, this.color);
}
