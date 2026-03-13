import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratibi30/app/routes.dart';
import 'package:ratibi30/core/enums/expense_category.dart';
import 'package:ratibi30/core/utils/currency_formatter.dart';
import 'package:ratibi30/core/widgets/adaptive_shell.dart';
import 'package:ratibi30/core/widgets/empty_state.dart';
import 'package:ratibi30/features/expenses/domain/expense.dart';
import 'package:ratibi30/features/expenses/presentation/expense_provider.dart';
import 'package:ratibi30/features/salary/presentation/salary_provider.dart';
import 'package:ratibi30/l10n/l10n.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  ExpenseCategory? filter;

  Future<void> _editExpense(BuildContext context, Expense expense, String currency) async {
    final l10n = context.l10n;
    final nameController = TextEditingController(text: expense.name);
    final amountController = TextEditingController(text: expense.amount.toStringAsFixed(2));
    var category = expense.category;
    DateTime date = expense.date;

    final updated = await showDialog<Expense>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.t('editExpense')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: l10n.t('expenseName')),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: '${l10n.t('amount')} ($currency)'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ExpenseCategory>(
                      value: category,
                      items: ExpenseCategory.values
                          .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                          .toList(),
                      onChanged: (value) => setState(() => category = value ?? category),
                      decoration: InputDecoration(labelText: l10n.t('category')),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'),
                      trailing: TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => date = picked);
                          }
                        },
                        child: Text(l10n.t('changeDate')),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.t('cancel')),
                ),
                FilledButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0;
                    if (nameController.text.trim().isEmpty || amount <= 0) return;
                    Navigator.pop(
                      context,
                      expense.copyWith(
                        name: nameController.text.trim(),
                        amount: amount,
                        category: category,
                        date: date,
                      ),
                    );
                  },
                  child: Text(l10n.t('save')),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    amountController.dispose();

    if (updated != null) {
      await ref.read(expenseProvider.notifier).updateExpense(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expenseProvider);
    final salary = ref.watch(salaryProvider).value;
    final currency = salary?.currency ?? 'SAR';
    final l10n = context.l10n;

    return AdaptiveShell(
      title: l10n.t('expenseList'),
      currentRoute: AppRoutes.expenses,
      child: expensesAsync.when(
        data: (expenses) {
          final filtered = filter == null ? [...expenses] : expenses.where((e) => e.category == filter).toList();
          filtered.sort((a, b) => b.date.compareTo(a.date));

          if (filtered.isEmpty) {
            return EmptyState(
              title: l10n.t('noExpensesYet'),
              icon: Icons.receipt_long_outlined,
            );
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<ExpenseCategory?>(
                      value: filter,
                      decoration: InputDecoration(labelText: l10n.t('filterByCategory')),
                      items: [
                        DropdownMenuItem<ExpenseCategory?>(
                          value: null,
                          child: Text(l10n.t('allCategories')),
                        ),
                        ...ExpenseCategory.values.map(
                          (e) => DropdownMenuItem(value: e, child: Text(e.label)),
                        ),
                      ],
                      onChanged: (value) => setState(() => filter = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.addExpense),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.t('add')),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final expense = filtered[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: expense.category.color.withOpacity(0.12),
                          child: Icon(expense.category.icon, color: expense.category.color),
                        ),
                        title: Text(expense.name),
                        subtitle: Text(
                          '${expense.category.label} • ${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(CurrencyFormatter.format(expense.amount, currency)),
                            IconButton(
                              onPressed: () => _editExpense(context, expense, currency),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              onPressed: () => ref.read(expenseProvider.notifier).deleteExpense(expense.id),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
      ),
    );
  }
}
