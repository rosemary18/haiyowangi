import 'dart:math';

export 'network.dart';
export 'loader.dart';
export 'date.dart';
export 'currency.dart';

String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
String nums = '1234567890';
final _rnd = Random();

String generateRandomString(int length, {bool numsOnly = false}) {
  return String.fromCharCodes(Iterable.generate(length, (_) {
    if (numsOnly) {
      return nums.codeUnitAt(_rnd.nextInt(nums.length));
    }
    return _chars.codeUnitAt(_rnd.nextInt(_chars.length));
  }));
}