import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratibi30/app/routes.dart';
import 'package:ratibi30/app/theme.dart';
import 'package:ratibi30/features/calendar/presentation/calendar_screen.dart';
import 'package:ratibi30/features/charity/presentation/charity_fund_screen.dart';
import 'package:ratibi30/features/dashboard/presentation/dashboard_screen.dart';
import 'package:ratibi30/features/expenses/presentation/add_expense_screen.dart';
import 'package:ratibi30/features/expenses/presentation/expense_list_screen.dart';
import 'package:ratibi30/features/reports/presentation/reports_screen.dart';
import 'package:ratibi30/features/salary/presentation/salary_provider.dart';
import 'package:ratibi30/features/salary/presentation/salary_setup_screen.dart';
import 'package:ratibi30/features/savings/presentation/savings_challenge_screen.dart';
import 'package:ratibi30/features/settings/presentation/settings_screen.dart';
import 'package:ratibi30/features/splash/presentation/splash_screen.dart';
import 'package:ratibi30/features/splash/presentation/welcome_screen.dart';
import 'package:ratibi30/l10n/app_localizations.dart';

class Ratibi30App extends ConsumerWidget {
  const Ratibi30App({super.key});

  String _resolveLocaleCode(String? selectedLanguage, String? savedLanguage) {
    final systemCode = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final candidate = selectedLanguage ?? savedLanguage ?? systemCode;
    return AppLocalizations.supportedLocales.any((e) => e.languageCode == candidate)
        ? candidate
        : 'en';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salaryAsync = ref.watch(salaryProvider);
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final selectedThemeMode = ref.watch(selectedThemeModeProvider);
    final settings = salaryAsync.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );
    final localeCode = _resolveLocaleCode(selectedLanguage, settings?.languageCode);
    final themeMode = selectedThemeMode ?? ((settings?.darkMode ?? false) ? ThemeMode.dark : ThemeMode.light);

    return MaterialApp(
      title: 'ratibi30',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: Locale(localeCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.welcome: (_) => const WelcomeScreen(),
        AppRoutes.salarySetup: (_) => const SalarySetupScreen(),
        AppRoutes.dashboard: (_) => const DashboardScreen(),
        AppRoutes.addExpense: (_) => const AddExpenseScreen(),
        AppRoutes.expenses: (_) => const ExpenseListScreen(),
        AppRoutes.charity: (_) => const CharityFundScreen(),
        AppRoutes.reports: (_) => const ReportsScreen(),
        AppRoutes.calendar: (_) => const CalendarScreen(),
        AppRoutes.savings: (_) => const SavingsChallengeScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
    );
  }
}
