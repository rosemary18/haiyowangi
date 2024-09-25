import 'package:intl/intl.dart';

String parseRupiahCurrency (String value, {int digits = 0}) {

  var formattted = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: digits,
  ).format(double.parse(value));

  formattted = formattted.replaceAll('.', ',');
  formattted = formattted.replaceAll(',', '.');

  return formattted;
}

String parsePriceFromInput(String value) {

  return value.replaceAll(RegExp(r'[^\d]'), '');
}