import 'package:intl/intl.dart';

String formatDateFromString(String date, {String format = 'dd/MM/yyyy, kk:mm'}) {
  return DateFormat(format).format(DateTime.parse(date));
}