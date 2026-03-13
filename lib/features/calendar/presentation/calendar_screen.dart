import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratibi30/app/routes.dart';
import 'package:ratibi30/core/widgets/adaptive_shell.dart';
import 'package:ratibi30/features/expenses/presentation/expense_provider.dart';
import 'package:ratibi30/features/salary/presentation/salary_provider.dart';
import 'package:ratibi30/l10n/l10n.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salary = ref.watch(salaryProvider).value;
    final l10n = context.l10n;

    if (salary == null) {
      return Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.salarySetup),
            child: Text(l10n.t('setUpSalaryFirst')),
          ),
        ),
      );
    }

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return AdaptiveShell(
      title: l10n.t('calendar'),
      currentRoute: AppRoutes.calendar,
      child: GridView.builder(
        itemCount: daysInMonth,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width >= 1024 ? 7 : MediaQuery.of(context).size.width >= 600 ? 5 : 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.05,
        ),
        itemBuilder: (context, index) {
          final date = DateTime(now.year, now.month, index + 1);
          final spent = ref.read(expenseProvider.notifier).spentOnDate(date);
          final withinBudget = spent <= salary.dailyBudget;
          final bg = spent == 0
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : withinBudget
                  ? Colors.green.withOpacity(0.15)
                  : Colors.red.withOpacity(0.15);

          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(
                  spent.toStringAsFixed(2),
                  style: TextStyle(
                    color: withinBudget ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
