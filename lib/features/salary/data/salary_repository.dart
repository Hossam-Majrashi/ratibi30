import 'package:ratibi30/features/salary/domain/salary_settings.dart';
import 'package:ratibi30/services/local_storage_service.dart';

class SalaryRepository {
  const SalaryRepository(this.storage);

  final LocalStorageService storage;

  Future<SalarySettings?> load() async {
    final data = await storage.readMap(LocalStorageService.salaryKey);
    if (data == null) return null;
    return SalarySettings.fromMap(data);
  }

  Future<void> save(SalarySettings settings) {
    return storage.writeMap(LocalStorageService.salaryKey, settings.toMap());
  }
}
