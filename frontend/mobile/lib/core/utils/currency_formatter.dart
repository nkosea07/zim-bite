import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _usdFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  static String formatUsd(double amount) => _usdFormat.format(amount);
}
