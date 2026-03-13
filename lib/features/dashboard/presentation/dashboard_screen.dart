import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratibi30/app/routes.dart';
import 'package:ratibi30/core/utils/responsive_helper.dart';
import 'package:ratibi30/core/widgets/adaptive_shell.dart';
import 'package:ratibi30/core/widgets/app_card.dart';
import 'package:ratibi30/core/widgets/stat_card.dart';
import 'package:ratibi30/features/expenses/presentation/expense_provider.dart';
import 'package:ratibi30/features/salary/presentation/salary_provider.dart';
import 'package:ratibi30/l10n/l10n.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salaryAsync = ref.watch(salaryProvider);
    final expensesAsync = ref.watch(expenseProvider);
    final l10n = context.l10n;

    return salaryAsync.when(
      data: (salary) {
        if (salary == null) {
          return Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.salarySetup),
                child: Text(l10n.t('setUpSalary')),
              ),
            ),
          );
        }

        return AdaptiveShell(
          title: l10n.t('dashboard'),
          currentRoute: AppRoutes.dashboard,
          child: expensesAsync.when(
            data: (_) {
              final todaySpent = ref.read(expenseProvider.notifier).spentOnDate(DateTime.now());
              final monthSpent = ref.read(expenseProvider.notifier).spentThisMonth(DateTime.now());
              final charity = salary.monthlyCharity;
              final remainingToday = salary.dailyBudget - todaySpent;
              final remainingMonth = salary.monthlySalary - monthSpent - charity;
              final saved = ref.read(expenseProvider.notifier).autoSavedCurrentMonth(
                    now: DateTime.now(),
                    dailyBudget: salary.dailyBudget,
                    daysInMonth: salary.daysInMonth,
                    autoSavings: salary.autoSavings,
                  );
              final progress = salary.monthlySalary == 0 ? 0.0 : (monthSpent / salary.monthlySalary).clamp(0.0, 1.0);

              return ListView(
                children: [
                  GridView.count(
                    crossAxisCount: ResponsiveHelper.dashboardColumns(context),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: ResponsiveHelper.isDesktop(context) ? 2.3 : 2.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StatCard(title: l10n.t('monthlySalary'), value: salary.monthlySalary, currency: salary.currency, icon: Icons.account_balance_wallet_outlined),
                      StatCard(title: l10n.t('dailyBudget'), value: salary.dailyBudget, currency: salary.currency, icon: Icons.today_outlined),
                      StatCard(title: l10n.t('remainingToday'), value: remainingToday, currency: salary.currency, icon: Icons.trending_up_outlined, color: remainingToday < 0 ? Colors.red : Colors.green),
                      StatCard(title: l10n.t('remainingMonth'), value: remainingMonth, currency: salary.currency, icon: Icons.calendar_month_outlined),
                      StatCard(title: l10n.t('charityBox'), value: charity, currency: salary.currency, icon: Icons.volunteer_activism_outlined),
                      StatCard(title: l10n.t('savingsBalance'), value: saved, currency: salary.currency, icon: Icons.account_balance_wallet_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.t('monthlySpendingProgress'), style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 700),
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 12,
                              borderRadius: BorderRadius.circular(99),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text('${(progress * 100).toStringAsFixed(1)}% ${l10n.t('spentPercent')}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.addExpense),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.t('addExpense')),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.reports),
                        icon: const Icon(Icons.pie_chart_outline),
                        label: Text(l10n.t('openReports')),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.calendar),
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: Text(l10n.t('openCalendar')),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.savings),
                        icon: const Icon(Icons.account_balance_wallet_outlined),
                        label: Text(l10n.t('savingsChallenge')),
                      ),
                    ],
                  ),
                  if (remainingToday < 0) ...[
                    const SizedBox(height: 16),
                    MaterialBanner(
                      content: Text(l10n.t('youExceededDailyBudget')),
                      leading: const Icon(Icons.warning_amber_rounded),
                      actions: [
                        TextButton(onPressed: () {}, child: Text(l10n.t('ok'))),
                      ],
                    ),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text(error.toString())),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text(error.toString()))),
    );
  }
}
