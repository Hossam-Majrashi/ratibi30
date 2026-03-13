class SalarySettings {
  const SalarySettings({
    required this.monthlySalary,
    required this.daysInMonth,
    this.currency = 'SAR',
    this.autoDistribution = false,
    this.autoSavings = false,
    this.darkMode = false,
    this.languageCode = 'en',
    this.charityEnabled = false,
    this.charityMode = 'amount',
    this.charityAmount = 0,
    this.charityPercent = 0,
  });

  final double monthlySalary;
  final int daysInMonth;
  final String currency;
  final bool autoDistribution;
  final bool autoSavings;
  final bool darkMode;
  final String languageCode;
  final bool charityEnabled;
  final String charityMode;
  final double charityAmount;
  final double charityPercent;

  double get dailyBudget => daysInMonth == 0 ? 0 : monthlySalary / daysInMonth;

  double get monthlyCharity {
    if (!charityEnabled) return 0;
    if (charityMode == 'percent') {
      return monthlySalary * (charityPercent / 100);
    }
    return charityAmount;
  }

  SalarySettings copyWith({
    double? monthlySalary,
    int? daysInMonth,
    String? currency,
    bool? autoDistribution,
    bool? autoSavings,
    bool? darkMode,
    String? languageCode,
    bool? charityEnabled,
    String? charityMode,
    double? charityAmount,
    double? charityPercent,
  }) {
    return SalarySettings(
      monthlySalary: monthlySalary ?? this.monthlySalary,
      daysInMonth: daysInMonth ?? this.daysInMonth,
      currency: currency ?? this.currency,
      autoDistribution: autoDistribution ?? this.autoDistribution,
      autoSavings: autoSavings ?? this.autoSavings,
      darkMode: darkMode ?? this.darkMode,
      languageCode: languageCode ?? this.languageCode,
      charityEnabled: charityEnabled ?? this.charityEnabled,
      charityMode: charityMode ?? this.charityMode,
      charityAmount: charityAmount ?? this.charityAmount,
      charityPercent: charityPercent ?? this.charityPercent,
    );
  }

  Map<String, dynamic> toMap() => {
        'monthlySalary': monthlySalary,
        'daysInMonth': daysInMonth,
        'currency': currency,
        'autoDistribution': autoDistribution,
        'autoSavings': autoSavings,
        'darkMode': darkMode,
        'languageCode': languageCode,
        'charityEnabled': charityEnabled,
        'charityMode': charityMode,
        'charityAmount': charityAmount,
        'charityPercent': charityPercent,
      };

  factory SalarySettings.fromMap(Map<String, dynamic> map) {
    return SalarySettings(
      monthlySalary: (map['monthlySalary'] ?? 0).toDouble(),
      daysInMonth: map['daysInMonth'] ?? 30,
      currency: map['currency'] ?? 'SAR',
      autoDistribution: map['autoDistribution'] ?? false,
      autoSavings: map['autoSavings'] ?? false,
      darkMode: map['darkMode'] ?? false,
      languageCode: map['languageCode'] ?? 'en',
      charityEnabled: map['charityEnabled'] ?? false,
      charityMode: map['charityMode'] ?? 'amount',
      charityAmount: (map['charityAmount'] ?? 0).toDouble(),
      charityPercent: (map['charityPercent'] ?? 0).toDouble(),
    );
  }
}
