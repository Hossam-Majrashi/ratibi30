import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratibi30/features/salary/presentation/salary_provider.dart';
import 'package:ratibi30/features/savings/data/savings_repository.dart';
import 'package:ratibi30/features/savings/domain/savings_goal.dart';

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  return SavingsRepository(ref.read(localStorageProvider));
});

class SavingsGoalNotifier extends AsyncNotifier<SavingsGoal?> {
  @override
  Future<SavingsGoal?> build() async {
    return ref.read(savingsRepositoryProvider).load();
  }

  Future<void> saveGoal(SavingsGoal goal) async {
    await ref.read(savingsRepositoryProvider).save(goal);
    state = AsyncData(goal);
  }
}

final savingsGoalProvider = AsyncNotifierProvider<SavingsGoalNotifier, SavingsGoal?>(
  SavingsGoalNotifier.new,
);
