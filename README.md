# ratibi30

ratibi30 is an offline-first Flutter personal finance and salary management app.

## Features
- Salary setup with 30 or 31 day mode.
- Daily budget calculation.
- Smart dashboard with responsive layouts.
- Add, edit, delete, and filter expenses.
- Overspending warning.
- Automatic salary distribution (50/30/20).
- Smart saving system for unused daily budget.
- Savings challenge tracking.
- Reports with pie and bar charts.
- Calendar-style monthly spending view.
- Settings for salary, currency, dark mode, and automatic savings.
- Multi-platform Flutter structure for Android, iOS, Web, Windows, macOS, Linux, and tablets.

## Run
```bash
flutter pub get
flutter run
```

## Notes
- All data is stored locally using SharedPreferences.
- The project is modular and prepared for future repository expansion.
- A widget sync service abstraction is included so native Android/iOS home widgets can be added later without changing business logic.
