import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/goal.dart';
import '../widgets/goal_card.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final theme = Theme.of(context);
    
    final activeGoals = state.goals.where((g) => !g.isCompleted).toList();
    final completedGoals = state.goals.where((g) => g.isCompleted).toList();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Financial Goals',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Turn your savings into milestones',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Active Goals Header
          if (activeGoals.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Text(
                  'Active Goals (${activeGoals.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),

          // Active Goals List / Empty State
          activeGoals.isEmpty && completedGoals.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.track_changes_rounded,
                          size: 64,
                          color: theme.colorScheme.outline.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No goals created yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + Create Goal to get started!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final goal = activeGoals[index];
                        return GoalCard(
                          goal: goal,
                          onAddFunds: (amt) {
                            state.addSavingsToGoal(goal.id, amt);
                          },
                          onDelete: () {
                            state.deleteGoal(goal.id);
                          },
                        );
                      },
                      childCount: activeGoals.length,
                    ),
                  ),
                ),

          // Completed Goals Header
          if (completedGoals.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0, bottom: 8.0),
                child: Text(
                  'Completed Goals (${completedGoals.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),

          // Completed Goals List
          if (completedGoals.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final goal = completedGoals[index];
                    return GoalCard(
                      goal: goal,
                      onAddFunds: (_) {},
                      onDelete: () {
                        state.deleteGoal(goal.id);
                      },
                    );
                  },
                  childCount: completedGoals.length,
                ),
              ),
            ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGoalSheet(context, state),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Goal'),
      ),
    );
  }

  void _showCreateGoalSheet(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return _CreateGoalForm(
          onSave: (goal) {
            state.addGoal(goal);
          },
        );
      },
    );
  }
}

class _CreateGoalForm extends StatefulWidget {
  final Function(FinancialGoal) onSave;

  const _CreateGoalForm({required this.onSave});

  @override
  State<_CreateGoalForm> createState() => _CreateGoalFormState();
}

class _CreateGoalFormState extends State<_CreateGoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _savedController = TextEditingController();

  DateTime _deadline = DateTime.now().add(const Duration(days: 90));
  String _selectedEmoji = '🎯';

  final List<String> _emojis = ['🎯', '🎮', '💻', '🚗', '🏠', '✈️', '🎓', '💰', '🎁', '💡'];

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _savedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 24,
        right: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Savings Goal',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Emoji Selector
            Text(
              'Select Goal Icon',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _emojis.length,
                itemBuilder: (ctx, index) {
                  final emoji = _emojis[index];
                  final isSelected = emoji == _selectedEmoji;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedEmoji = emoji;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surface,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Goal Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Goal Name',
                hintText: 'e.g., Gaming Laptop',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Please enter a goal name';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Target Amount
            TextFormField(
              controller: _targetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Target Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Please enter a target amount';
                final n = double.tryParse(val);
                if (n == null || n <= 0) return 'Please enter a valid target amount';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Initial Savings Amount
            TextFormField(
              controller: _savedController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Initial Saved Amount (Optional)',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return null;
                final n = double.tryParse(val);
                if (n == null || n < 0) return 'Please enter a valid positive savings amount';
                
                final targetStr = _targetController.text;
                if (targetStr.isNotEmpty) {
                  final target = double.tryParse(targetStr);
                  if (target != null && n > target) {
                    return 'Initial savings cannot exceed target amount';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Deadline Picker
            InkWell(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _deadline,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2035),
                );
                if (selectedDate != null) {
                  setState(() {
                    _deadline = selectedDate;
                  });
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Deadline',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${_deadline.day}/${_deadline.month}/${_deadline.year}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final name = _nameController.text.trim();
                  final target = double.parse(_targetController.text);
                  final savedVal = _savedController.text;
                  final saved = savedVal.isEmpty ? 0.0 : double.parse(savedVal);
                  
                  final goal = FinancialGoal(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    targetAmount: target,
                    savedAmount: saved,
                    deadline: _deadline,
                    category: _selectedEmoji,
                    isCompleted: saved >= target,
                  );

                  widget.onSave(goal);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Create Goal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
