import 'package:flutter_translate/flutter_translate.dart';

class AppLocalization {
  static String getWithKey(String key) => translate(key);
}
