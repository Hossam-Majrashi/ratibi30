import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratibi30/app/routes.dart';
import 'package:ratibi30/core/widgets/adaptive_shell.dart';
import 'package:ratibi30/features/salary/presentation/salary_provider.dart';
import 'package:ratibi30/l10n/l10n.dart';

class CharityFundScreen extends ConsumerStatefulWidget {
  const CharityFundScreen({super.key});

  @override
  ConsumerState<CharityFundScreen> createState() => _CharityFundScreenState();
}

class _CharityFundScreenState extends ConsumerState<CharityFundScreen> {
  final charityAmountController = TextEditingController();
  final charityPercentController = TextEditingController();
  bool charityEnabled = false;
  String charityMode = 'amount';
  bool initialized = false;

  @override
  void dispose() {
    charityAmountController.dispose();
    charityPercentController.dispose();
    super.dispose();
  }

  double _preview(double salaryValue) {
    if (!charityEnabled) return 0;
    if (charityMode == 'percent') {
      final percent = double.tryParse(charityPercentController.text.trim()) ?? 0;
      return salaryValue * percent / 100;
    }
    return double.tryParse(charityAmountController.text.trim()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final salaryAsync = ref.watch(salaryProvider);
    final l10n = context.l10n;

    return salaryAsync.when(
      data: (salary) {
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

        if (!initialized) {
          charityEnabled = salary.charityEnabled;
          charityMode = salary.charityMode;
          charityAmountController.text = salary.charityAmount == 0 ? '' : salary.charityAmount.toStringAsFixed(2);
          charityPercentController.text = salary.charityPercent == 0 ? '' : salary.charityPercent.toStringAsFixed(2);
          initialized = true;
        }

        final preview = _preview(salary.monthlySalary);

        return AdaptiveShell(
          title: l10n.t('charityBox'),
          currentRoute: AppRoutes.charity,
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.t('charitySettings'),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: charityEnabled,
                        onChanged: (value) => setState(() => charityEnabled = value),
                        title: Text(l10n.t('charityEnabled')),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: charityMode,
                        decoration: InputDecoration(labelText: l10n.t('charityMethod')),
                        items: [
                          DropdownMenuItem(value: 'amount', child: Text(l10n.t('fixedAmount'))),
                          DropdownMenuItem(value: 'percent', child: Text(l10n.t('percentageOfSalary'))),
                        ],
                        onChanged: charityEnabled ? (value) => setState(() => charityMode = value ?? 'amount') : null,
                      ),
                      const SizedBox(height: 12),
                      if (charityMode == 'amount')
                        TextField(
                          controller: charityAmountController,
                          enabled: charityEnabled,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(labelText: '${l10n.t('charityAmount')} (${salary.currency})'),
                          onChanged: (_) => setState(() {}),
                        )
                      else
                        TextField(
                          controller: charityPercentController,
                          enabled: charityEnabled,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(labelText: l10n.t('charityPercent')),
                          onChanged: (_) => setState(() {}),
                        ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.volunteer_activism_outlined),
                        title: Text(l10n.t('charityMonthlyValue')),
                        trailing: Text('${preview.toStringAsFixed(2)} ${salary.currency}'),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () async {
                          final nextAmount = double.tryParse(charityAmountController.text.trim()) ?? 0;
                          final nextPercent = double.tryParse(charityPercentController.text.trim()) ?? 0;
                          await ref.read(salaryProvider.notifier).saveSalary(
                                salary.copyWith(
                                  charityEnabled: charityEnabled,
                                  charityMode: charityMode,
                                  charityAmount: nextAmount,
                                  charityPercent: nextPercent,
                                ),
                              );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.t('settingsSaved'))),
                            );
                          }
                        },
                        child: Text(l10n.t('save')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text(error.toString()))),
    );
  }
}
