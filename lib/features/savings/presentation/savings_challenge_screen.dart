import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratibi30/app/routes.dart';
import 'package:ratibi30/core/utils/currency_formatter.dart';
import 'package:ratibi30/core/widgets/adaptive_shell.dart';
import 'package:ratibi30/core/widgets/app_card.dart';
import 'package:ratibi30/features/expenses/presentation/expense_provider.dart';
import 'package:ratibi30/features/salary/presentation/salary_provider.dart';
import 'package:ratibi30/features/savings/domain/savings_goal.dart';
import 'package:ratibi30/features/savings/presentation/savings_provider.dart';
import 'package:ratibi30/l10n/l10n.dart';

class SavingsChallengeScreen extends ConsumerStatefulWidget {
  const SavingsChallengeScreen({super.key});

  @override
  ConsumerState<SavingsChallengeScreen> createState() => _SavingsChallengeScreenState();
}

class _SavingsChallengeScreenState extends ConsumerState<SavingsChallengeScreen> {
  final titleController = TextEditingController();
  final targetController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final salary = ref.watch(salaryProvider).value;
    final goalAsync = ref.watch(savingsGoalProvider);
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

    final saved = ref.read(expenseProvider.notifier).autoSavedCurrentMonth(
          now: DateTime.now(),
          dailyBudget: salary.dailyBudget,
          daysInMonth: salary.daysInMonth,
          autoSavings: salary.autoSavings,
        );

    return AdaptiveShell(
      title: l10n.t('savingsChallenge'),
      currentRoute: AppRoutes.savings,
      child: goalAsync.when(
        data: (goal) {
          titleController.text = titleController.text.isEmpty ? (goal?.title ?? 'Save 1000 SAR this month') : titleController.text;
          targetController.text = targetController.text.isEmpty ? ((goal?.targetAmount ?? 1000).toStringAsFixed(0)) : targetController.text;

          final target = double.tryParse(targetController.text.trim()) ?? 0;
          final progress = target == 0 ? 0.0 : (saved / target).clamp(0.0, 1.0);
          final remaining = (target - saved).clamp(0, double.infinity);
          final complete = saved >= target && target > 0;

          return ListView(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: l10n.t('goalTitle')),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: targetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: '${l10n.t('targetAmount')} (${salary.currency})'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        final targetValue = double.tryParse(targetController.text.trim()) ?? 0;
                        if (titleController.text.trim().isEmpty || targetValue <= 0) return;
                        await ref.read(savingsGoalProvider.notifier).saveGoal(
                              SavingsGoal(
                                title: titleController.text.trim(),
                                targetAmount: targetValue,
                              ),
                            );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.t('goalSaved'))),
                          );
                          setState(() {});
                        }
                      },
                      child: Text(l10n.t('saveGoal')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal?.title ?? l10n.t('monthlySavingsGoal'), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 14,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    const SizedBox(height: 12),
                    Text('${l10n.t('saved')}: ${CurrencyFormatter.format(saved, salary.currency)}'),
                    Text('${l10n.t('remaining')}: ${CurrencyFormatter.format(remaining.toDouble(), salary.currency)}'),
                    const SizedBox(height: 12),
                    if (complete)
                      Chip(
                        avatar: const Icon(Icons.verified_rounded),
                        label: Text(l10n.t('challengeCompleted')),
                        backgroundColor: Colors.green.withOpacity(0.14),
                      ),
                  ],
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
