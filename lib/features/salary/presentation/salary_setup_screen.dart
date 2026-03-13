import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratibi30/app/routes.dart';
import 'package:ratibi30/features/salary/domain/salary_settings.dart';
import 'package:ratibi30/features/salary/presentation/salary_provider.dart';
import 'package:ratibi30/l10n/l10n.dart';

class SalarySetupScreen extends ConsumerStatefulWidget {
  const SalarySetupScreen({super.key});

  @override
  ConsumerState<SalarySetupScreen> createState() => _SalarySetupScreenState();
}

class _SalarySetupScreenState extends ConsumerState<SalarySetupScreen> {
  final salaryController = TextEditingController();
  final customDaysController = TextEditingController();
  bool autoDistribution = false;
  bool autoSavings = false;
  String dayOption = '30';

  int get resolvedDays {
    if (dayOption == 'custom') {
      return int.tryParse(customDaysController.text.trim()) ?? 0;
    }
    return int.tryParse(dayOption) ?? 30;
  }

  @override
  void dispose() {
    salaryController.dispose();
    customDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final salary = double.tryParse(salaryController.text.trim()) ?? 0;
    final daysInMonth = resolvedDays;
    final dailyBudget = daysInMonth == 0 ? 0 : salary / daysInMonth;
    final currentLanguage = ref.watch(selectedLanguageProvider) ?? 'en';
    final currentThemeMode = ref.watch(selectedThemeModeProvider) ?? ThemeMode.light;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('salarySetup'))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l10n.t('enterSalaryIntro'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: currentLanguage,
                decoration: InputDecoration(labelText: l10n.t('language')),
                items: [
                  DropdownMenuItem(value: 'en', child: Text(l10n.t('english'))),
                  DropdownMenuItem(value: 'ar', child: Text(l10n.t('arabic'))),
                ],
                onChanged: (value) {
                  final next = value ?? 'en';
                  ref.read(selectedLanguageProvider.notifier).setLanguage(next);
                },
              ),
              const SizedBox(height: 16),
              Text(
                l10n.t('darkMode'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode_outlined),
                    label: Text(l10n.t('dayMode')),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode_outlined),
                    label: Text(l10n.t('nightMode')),
                  ),
                ],
                selected: {currentThemeMode},
                onSelectionChanged: (value) {
                  ref.read(selectedThemeModeProvider.notifier).setThemeMode(value.first);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: salaryController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.t('monthlySalary'),
                  prefixIcon: const Icon(Icons.payments_outlined),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.t('daysInMonth'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.t('days5')),
                    selected: dayOption == '5',
                    onSelected: (_) => setState(() => dayOption = '5'),
                  ),
                  ChoiceChip(
                    label: Text(l10n.t('days10')),
                    selected: dayOption == '10',
                    onSelected: (_) => setState(() => dayOption = '10'),
                  ),
                  ChoiceChip(
                    label: Text(l10n.t('days30')),
                    selected: dayOption == '30',
                    onSelected: (_) => setState(() => dayOption = '30'),
                  ),
                  ChoiceChip(
                    label: Text(l10n.t('days31')),
                    selected: dayOption == '31',
                    onSelected: (_) => setState(() => dayOption = '31'),
                  ),
                  ChoiceChip(
                    label: Text(l10n.t('customDays')),
                    selected: dayOption == 'custom',
                    onSelected: (_) => setState(() => dayOption = 'custom'),
                  ),
                ],
              ),
              if (dayOption == 'custom') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: customDaysController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.t('enterCustomDays'),
                    prefixIcon: const Icon(Icons.edit_calendar_outlined),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
              const SizedBox(height: 16),
              SwitchListTile(
                value: autoDistribution,
                onChanged: (value) => setState(() => autoDistribution = value),
                title: Text(l10n.t('autoDistribution')),
              ),
              SwitchListTile(
                value: autoSavings,
                onChanged: (value) => setState(() => autoSavings = value),
                title: Text(l10n.t('autoSavings')),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: Text(l10n.t('dailyBudget')),
                  subtitle: Text(dailyBudget.toStringAsFixed(2)),
                  trailing: Text(daysInMonth > 0 ? '${daysInMonth.toString()} ${l10n.t('daysLabel')}' : '-'),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: salary <= 0 || daysInMonth <= 0
                    ? null
                    : () async {
                        final settings = SalarySettings(
                          monthlySalary: salary,
                          daysInMonth: daysInMonth,
                          autoDistribution: autoDistribution,
                          autoSavings: autoSavings,
                          darkMode: currentThemeMode == ThemeMode.dark,
                          languageCode: currentLanguage,
                        );
                        await ref.read(salaryProvider.notifier).saveSalary(settings);
                        if (mounted) {
                          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                        }
                      },
                child: Text(l10n.t('calculateDailyBudget')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
