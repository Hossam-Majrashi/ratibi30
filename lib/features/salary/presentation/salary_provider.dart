import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratibi30/features/salary/data/salary_repository.dart';
import 'package:ratibi30/features/salary/domain/salary_settings.dart';
import 'package:ratibi30/services/local_storage_service.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final salaryRepositoryProvider = Provider<SalaryRepository>((ref) {
  return SalaryRepository(ref.read(localStorageProvider));
});

class SelectedLanguageNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setLanguage(String? value) {
    state = value;
  }
}

final selectedLanguageProvider =
    NotifierProvider<SelectedLanguageNotifier, String?>(
  SelectedLanguageNotifier.new,
);

class SelectedThemeModeNotifier extends Notifier<ThemeMode?> {
  @override
  ThemeMode? build() => null;

  void setThemeMode(ThemeMode? value) {
    state = value;
  }
}

final selectedThemeModeProvider =
    NotifierProvider<SelectedThemeModeNotifier, ThemeMode?>(
  SelectedThemeModeNotifier.new,
);

class SalaryNotifier extends AsyncNotifier<SalarySettings?> {
  @override
  Future<SalarySettings?> build() async {
    final settings = await ref.read(salaryRepositoryProvider).load();
    ref.read(selectedLanguageProvider.notifier).setLanguage(
      settings?.languageCode ?? 'en',
    );
    ref.read(selectedThemeModeProvider.notifier).setThemeMode(
      (settings?.darkMode ?? false) ? ThemeMode.dark : ThemeMode.light,
    );
    return settings;
  }

  Future<void> saveSalary(SalarySettings settings) async {
    await ref.read(salaryRepositoryProvider).save(settings);
    ref.read(selectedLanguageProvider.notifier).setLanguage(
      settings.languageCode,
    );
    ref.read(selectedThemeModeProvider.notifier).setThemeMode(
      settings.darkMode ? ThemeMode.dark : ThemeMode.light,
    );
    state = AsyncData(settings);
  }
}

final salaryProvider =
    AsyncNotifierProvider<SalaryNotifier, SalarySettings?>(SalaryNotifier.new);
