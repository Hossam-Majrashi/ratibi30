import 'package:ratibi30/core/enums/expense_category.dart';

class Expense {
  const Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
  });

  final String id;
  final String name;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;

  Expense copyWith({
    String? id,
    String? name,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'amount': amount,
        'category': category.name,
        'date': date.toIso8601String(),
      };

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      name: map['name'],
      amount: (map['amount'] ?? 0).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ExpenseCategory.other,
      ),
      date: DateTime.parse(map['date']),
    );
  }
}
