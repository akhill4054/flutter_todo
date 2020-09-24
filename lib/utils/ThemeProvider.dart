import 'package:flutter/cupertino.dart';
import 'package:flutter_todo/utils/PrefsStore.dart';

class ThemeModel with ChangeNotifier {
  bool _isLightTheme = false;

  bool get lightTheme => _isLightTheme;

  set lightTheme(bool value) {
    _isLightTheme = value;
    PrefsStore.setLightTheme(value);
    notifyListeners();
  }
}
