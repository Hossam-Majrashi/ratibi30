import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double value, String currency) {
    return '${NumberFormat('#,##0.00').format(value)} $currency';
  }
}
