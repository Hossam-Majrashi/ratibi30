import 'package:ratibi30/features/savings/domain/savings_goal.dart';
import 'package:ratibi30/services/local_storage_service.dart';

class SavingsRepository {
  const SavingsRepository(this.storage);

  final LocalStorageService storage;

  Future<SavingsGoal?> load() async {
    final data = await storage.readMap(LocalStorageService.goalKey);
    if (data == null) return null;
    return SavingsGoal.fromMap(data);
  }

  Future<void> save(SavingsGoal goal) {
    return storage.writeMap(LocalStorageService.goalKey, goal.toMap());
  }
}
