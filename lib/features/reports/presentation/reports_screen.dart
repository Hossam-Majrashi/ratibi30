import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratibi30/app/routes.dart';
import 'package:ratibi30/core/enums/expense_category.dart';
import 'package:ratibi30/core/utils/currency_formatter.dart';
import 'package:ratibi30/core/utils/responsive_helper.dart';
import 'package:ratibi30/core/widgets/adaptive_shell.dart';
import 'package:ratibi30/core/widgets/app_card.dart';
import 'package:ratibi30/features/expenses/presentation/expense_provider.dart';
import 'package:ratibi30/features/salary/presentation/salary_provider.dart';
import 'package:ratibi30/l10n/l10n.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salary = ref.watch(salaryProvider).value;
    final expensesAsync = ref.watch(expenseProvider);
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

    return AdaptiveShell(
      title: l10n.t('reports'),
      currentRoute: AppRoutes.reports,
      child: expensesAsync.when(
        data: (_) {
          final totals = ref.read(expenseProvider.notifier).categoryTotals(DateTime.now());
          final topCategory = ref.read(expenseProvider.notifier).topCategory(DateTime.now());
          final dailyTotals = ref.read(expenseProvider.notifier).dailyTotals(DateTime.now());
          final chartSections = totals.entries
              .where((entry) => entry.value > 0)
              .map(
                (entry) => PieChartSectionData(
                  value: entry.value,
                  title: entry.key.label,
                  radius: 78,
                  color: entry.key.color,
                ),
              )
              .toList();

          final chartCards = [
            AppCard(
              child: SizedBox(
                height: 320,
                child: chartSections.isEmpty
                    ? Center(child: Text(l10n.t('noExpenseData')))
                    : PieChart(PieChartData(sections: chartSections, sectionsSpace: 3)),
              ),
            ),
            AppCard(
              child: SizedBox(
                height: 320,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
                        ),
                      ),
                    ),
                    barGroups: dailyTotals.entries
                        .where((entry) => entry.key <= 7 || entry.key == DateTime.now().day)
                        .map(
                          (entry) => BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value,
                                width: 18,
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ];

          return ListView(
            children: [
              GridView.count(
                crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: ResponsiveHelper.isDesktop(context) ? 1.5 : 1.0,
                children: chartCards,
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.t('topSpendingCategory'), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(topCategory?.label ?? l10n.t('noCategoryYet')),
                    const SizedBox(height: 12),
                    ...totals.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text(entry.key.label)),
                            Text(CurrencyFormatter.format(entry.value, salary.currency)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (salary.autoDistribution) ...[
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.t('autoSalaryDistribution'), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 280,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(value: salary.monthlySalary * 0.5, title: l10n.t('needs50'), color: Colors.green),
                              PieChartSectionData(value: salary.monthlySalary * 0.3, title: l10n.t('entertainment30'), color: Colors.blue),
                              PieChartSectionData(value: salary.monthlySalary * 0.2, title: l10n.t('savings20'), color: Colors.orange),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
      ),
    );
  }
}
