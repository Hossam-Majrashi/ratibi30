import 'package:ratibi30/features/expenses/domain/expense.dart';
import 'package:ratibi30/services/local_storage_service.dart';

class ExpenseRepository {
  const ExpenseRepository(this.storage);

  final LocalStorageService storage;

  Future<List<Expense>> load() async {
    final raw = await storage.readList(LocalStorageService.expensesKey);
    return raw.map(Expense.fromMap).toList();
  }

  Future<void> save(List<Expense> expenses) {
    return storage.writeList(
      LocalStorageService.expensesKey,
      expenses.map((e) => e.toMap()).toList(),
    );
  }
}
