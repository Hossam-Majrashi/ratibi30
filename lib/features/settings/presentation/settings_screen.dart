import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratibi30/app/routes.dart';
import 'package:ratibi30/core/widgets/adaptive_shell.dart';
import 'package:ratibi30/features/salary/presentation/salary_provider.dart';
import 'package:ratibi30/l10n/l10n.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final salaryController = TextEditingController();
  final customDaysController = TextEditingController();
  final currencies = const ['SAR', 'USD', 'EUR'];
  String currency = 'SAR';
  bool darkMode = false;
  bool autoSavings = false;
  bool autoDistribution = false;
  String languageCode = 'en';
  String dayOption = '30';
  bool initialized = false;

  static const developerName = 'Hossam Majrashi';
  static const developerGithub = 'github.com/HossamMajrashi';
  static const developerEmail = 'Hossam.Majrashi@gmail.com';

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

  void _showPrivacyDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.t('privacyTitle')),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _PrivacyPoint(
                  title: l10n.t('privacyPoint1Title'),
                  description: l10n.t('privacyPoint1Desc'),
                ),
                const SizedBox(height: 12),
                _PrivacyPoint(
                  title: l10n.t('privacyPoint2Title'),
                  description: l10n.t('privacyPoint2Desc'),
                ),
                const SizedBox(height: 12),
                _PrivacyPoint(
                  title: l10n.t('privacyPoint3Title'),
                  description: l10n.t('privacyPoint3Desc'),
                ),
                const SizedBox(height: 12),
                _PrivacyPoint(
                  title: l10n.t('privacyPoint4Title'),
                  description: l10n.t('privacyPoint4Desc'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.t('ok')),
            ),
          ],
        );
      },
    );
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
          salaryController.text = salary.monthlySalary.toStringAsFixed(2);
          currency = salary.currency;
          darkMode = salary.darkMode;
          autoSavings = salary.autoSavings;
          autoDistribution = salary.autoDistribution;
          languageCode = salary.languageCode;
          if ({5, 10, 30, 31}.contains(salary.daysInMonth)) {
            dayOption = salary.daysInMonth.toString();
          } else {
            dayOption = 'custom';
            customDaysController.text = salary.daysInMonth.toString();
          }
          initialized = true;
        }

        return AdaptiveShell(
          title: l10n.t('settings'),
          currentRoute: AppRoutes.settings,
          child: ListView(
            children: [
              TextField(
                controller: salaryController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.t('monthlySalary')),
              ),
              const SizedBox(height: 12),
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
                  decoration: InputDecoration(labelText: l10n.t('enterCustomDays')),
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: currency,
                decoration: InputDecoration(labelText: l10n.t('currency')),
                items: currencies.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) => setState(() => currency = value ?? 'SAR'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: languageCode,
                decoration: InputDecoration(labelText: l10n.t('language')),
                items: [
                  DropdownMenuItem(value: 'en', child: Text(l10n.t('english'))),
                  DropdownMenuItem(value: 'ar', child: Text(l10n.t('arabic'))),
                ],
                onChanged: (value) {
                  final next = value ?? 'en';
                  setState(() => languageCode = next);
                  ref.read(selectedLanguageProvider.notifier).setLanguage(next);
                },
              ),
              const SizedBox(height: 16),
              Text(
                l10n.t('darkMode'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment<bool>(
                    value: false,
                    icon: const Icon(Icons.light_mode_outlined),
                    label: Text(l10n.t('dayMode')),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    icon: const Icon(Icons.dark_mode_outlined),
                    label: Text(l10n.t('nightMode')),
                  ),
                ],
                selected: {darkMode},
                onSelectionChanged: (value) {
                  final nextDarkMode = value.first;
                  setState(() => darkMode = nextDarkMode);
                  ref.read(selectedThemeModeProvider.notifier).setThemeMode(
                    nextDarkMode ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: autoSavings,
                onChanged: (value) => setState(() => autoSavings = value),
                title: Text(l10n.t('autoSavings')),
              ),
              SwitchListTile(
                value: autoDistribution,
                onChanged: (value) => setState(() => autoDistribution = value),
                title: Text(l10n.t('autoDistribution')),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final salaryValue = double.tryParse(salaryController.text.trim()) ?? 0;
                  final daysValue = resolvedDays;
                  if (salaryValue <= 0 || daysValue <= 0) return;
                  await ref.read(salaryProvider.notifier).saveSalary(
                        salary.copyWith(
                          monthlySalary: salaryValue,
                          daysInMonth: daysValue,
                          currency: currency,
                          darkMode: darkMode,
                          autoSavings: autoSavings,
                          autoDistribution: autoDistribution,
                          languageCode: languageCode,
                        ),
                      );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.t('settingsSaved'))),
                    );
                    setState(() {});
                  }
                },
                child: Text(l10n.t('saveSettings')),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  l10n.t('privacyTitle'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 22,
                  ),
                ),
                title: Text(l10n.t('privacyTitle')),
                subtitle: Text(
                  '${l10n.t('privacyPoint1Title')} · ${l10n.t('privacyPoint2Title')}...',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showPrivacyDialog(context),
              ),
              const Divider(),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.t('developerInfo'),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.person_outline),
                        title: Text(l10n.t('developerName')),
                        subtitle: const SelectableText(developerName),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.code_outlined),
                        title: Text(l10n.t('github')),
                        subtitle: const SelectableText(developerGithub),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.email_outlined),
                        title: Text(l10n.t('email')),
                        subtitle: const SelectableText(developerEmail),
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

class _PrivacyPoint extends StatelessWidget {
  const _PrivacyPoint({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(description),
      ],
    );
  }
}
