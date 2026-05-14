import 'package:intl/intl.dart';

String formatMoney(double amount, {String code = 'PEN', String? symbol}) {
  final s = symbol ?? _symbolFor(code);
  final f = NumberFormat.currency(
    locale: 'es_PE',
    symbol: '',
    decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
  );
  final num = f.format(amount).trim();
  return '$num $s';
}

String _symbolFor(String code) {
  switch (code) {
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    case 'MXN':
      return 'MXN';
    case 'COP':
      return 'COP';
    case 'ARS':
      return '\$';
    case 'CLP':
      return 'CLP';
    case 'PEN':
    default:
      return 'S/.';
  }
}

String formatDate(DateTime d) =>
    DateFormat('d \'de\' MMMM \'de\' y', 'es').format(d);

String formatDateShort(DateTime d) => DateFormat('d/M', 'es').format(d);
String formatDayMonth(DateTime d) => DateFormat('d MMM', 'es').format(d);
String formatMonthYear(DateTime d) =>
    DateFormat('MMMM \'de\' y', 'es').format(d).replaceFirstMapped(
        RegExp(r'^.'), (m) => m.group(0)!.toUpperCase());
String formatWeekday(DateTime d) => DateFormat('EEEE', 'es').format(d);
String formatHourMinute(DateTime d) => DateFormat('HH:mm', 'es').format(d);
