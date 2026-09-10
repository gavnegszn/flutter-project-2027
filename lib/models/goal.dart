class FinancialGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime deadline;
  final String category;
  final bool isCompleted;

  FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
    required this.category,
    this.isCompleted = false,
  });

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    final pct = (savedAmount / targetAmount) * 100;
    return pct > 100.0 ? 100.0 : pct;
  }

  double get remainingAmount {
    final rem = targetAmount - savedAmount;
    return rem < 0 ? 0 : rem;
  }

  FinancialGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? deadline,
    String? category,
    bool? isCompleted,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'deadline': deadline.toIso8601String(),
      'category': category,
      'isCompleted': isCompleted,
    };
  }

  factory FinancialGoal.fromMap(Map<String, dynamic> map) {
    return FinancialGoal(
      id: map['id'],
      name: map['name'],
      targetAmount: map['targetAmount'],
      savedAmount: map['savedAmount'],
      deadline: DateTime.parse(map['deadline']),
      category: map['category'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
