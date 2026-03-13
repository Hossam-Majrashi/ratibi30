import 'package:flutter/material.dart';
import 'package:ratibi30/app/routes.dart';
import 'package:ratibi30/features/salary/data/salary_repository.dart';
import 'package:ratibi30/services/local_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  final SalaryRepository salaryRepository =
      SalaryRepository(LocalStorageService());

  @override
  void initState() {
    super.initState();
    _openNextScreen();
  }

  Future<void> _openNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    final savedSettings = await salaryRepository.load();
    if (!mounted) return;

    final nextRoute = savedSettings == null || savedSettings.monthlySalary <= 0
        ? AppRoutes.welcome
        : AppRoutes.dashboard;

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation =
        CurvedAnimation(parent: controller, curve: Curves.easeOutBack);
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: animation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 96,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text('ratibi30', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
      ),
    );
  }
}
