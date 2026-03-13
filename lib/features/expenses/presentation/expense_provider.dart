import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratibi30/core/enums/expense_category.dart';
import 'package:ratibi30/core/extensions/date_extensions.dart';
import 'package:ratibi30/features/expenses/data/expense_repository.dart';
import 'package:ratibi30/features/expenses/domain/expense.dart';
import 'package:ratibi30/features/salary/presentation/salary_provider.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.read(localStorageProvider));
});

class ExpenseNotifier extends AsyncNotifier<List<Expense>> {
  @override
  Future<List<Expense>> build() async {
    return ref.read(expenseRepositoryProvider).load();
  }

  List<Expense> _currentExpenses() {
    return List<Expense>.from(state.value ?? const <Expense>[]);
  }

  Future<void> addExpense(Expense expense) async {
    final current = _currentExpenses()..add(expense);
    await ref.read(expenseRepositoryProvider).save(current);
    state = AsyncData(current);
  }

  Future<void> updateExpense(Expense expense) async {
    final current = _currentExpenses();
    final index = current.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      current[index] = expense;
      await ref.read(expenseRepositoryProvider).save(current);
      state = AsyncData(current);
    }
  }

  Future<void> deleteExpense(String id) async {
    final current = _currentExpenses()..removeWhere((e) => e.id == id);
    await ref.read(expenseRepositoryProvider).save(current);
    state = AsyncData(current);
  }

  double spentOnDate(DateTime date) {
    return (state.value ?? const <Expense>[])
        .where((e) => e.date.dateOnly.sameDate(date.dateOnly))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double spentThisMonth(DateTime month) {
    return (state.value ?? const <Expense>[])
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<ExpenseCategory, double> categoryTotals(DateTime month) {
    final result = {for (final c in ExpenseCategory.values) c: 0.0};
    for (final expense in state.value ?? const <Expense>[]) {
      if (expense.date.year == month.year && expense.date.month == month.month) {
        result[expense.category] = (result[expense.category] ?? 0) + expense.amount;
      }
    }
    return result;
  }

  Map<int, double> dailyTotals(DateTime month) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final result = {for (var i = 1; i <= lastDay; i++) i: 0.0};
    for (final expense in state.value ?? const <Expense>[]) {
      if (expense.date.year == month.year && expense.date.month == month.month) {
        result[expense.date.day] = (result[expense.date.day] ?? 0) + expense.amount;
      }
    }
    return result;
  }

  ExpenseCategory? topCategory(DateTime month) {
    final totals = categoryTotals(month)..removeWhere((key, value) => value <= 0);
    if (totals.isEmpty) return null;
    final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  double autoSavedCurrentMonth({
    required DateTime now,
    required double dailyBudget,
    required int daysInMonth,
    required bool autoSavings,
  }) {
    if (!autoSavings) return 0;
    final lastCountedDay = now.day > daysInMonth ? daysInMonth : now.day;
    double total = 0;
    for (var day = 1; day <= lastCountedDay; day++) {
      final spent = spentOnDate(DateTime(now.year, now.month, day));
      if (spent < dailyBudget) total += dailyBudget - spent;
    }
    return total;
  }
}

final expenseProvider =
    AsyncNotifierProvider<ExpenseNotifier, List<Expense>>(ExpenseNotifier.new);
