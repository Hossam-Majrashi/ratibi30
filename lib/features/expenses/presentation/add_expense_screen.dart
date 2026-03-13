import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratibi30/app/routes.dart';
import 'package:ratibi30/core/enums/expense_category.dart';
import 'package:ratibi30/core/widgets/adaptive_shell.dart';
import 'package:ratibi30/features/expenses/domain/expense.dart';
import 'package:ratibi30/features/expenses/presentation/expense_provider.dart';
import 'package:ratibi30/features/salary/presentation/salary_provider.dart';
import 'package:ratibi30/l10n/l10n.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  ExpenseCategory category = ExpenseCategory.food;
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AdaptiveShell(
      title: l10n.t('addExpense'),
      currentRoute: AppRoutes.addExpense,
      child: ListView(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: l10n.t('expenseName'),
              prefixIcon: const Icon(Icons.edit_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.t('amount'),
              prefixIcon: const Icon(Icons.attach_money_outlined),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ExpenseCategory>(
            value: category,
            items: ExpenseCategory.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                .toList(),
            onChanged: (value) => setState(() => category = value ?? ExpenseCategory.other),
            decoration: InputDecoration(
              labelText: l10n.t('category'),
              prefixIcon: const Icon(Icons.category_outlined),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.date_range_outlined),
            title: Text('${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}'),
            trailing: OutlinedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
              child: Text(l10n.t('pickDate')),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final amount = double.tryParse(amountController.text.trim()) ?? 0;
              if (name.isEmpty || amount <= 0) return;

              final expense = Expense(
                id: _id(),
                name: name,
                amount: amount,
                category: category,
                date: selectedDate,
              );

              await ref.read(expenseProvider.notifier).addExpense(expense);

              final salary = ref.read(salaryProvider).value;
              if (salary != null) {
                final spent = ref.read(expenseProvider.notifier).spentOnDate(selectedDate);
                if (spent > salary.dailyBudget && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.t('youExceededDailyBudget'))),
                  );
                }
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.t('expenseSaved'))),
                );
                Navigator.pushReplacementNamed(context, AppRoutes.expenses);
              }
            },
            child: Text(l10n.t('save')),
          ),
        ],
      ),
    );
  }
}
