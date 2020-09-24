import 'package:flutter/material.dart';

class Styles {
  static ThemeData getThemeData(bool isLightTheme) {
    return ThemeData(
        brightness: (isLightTheme ? Brightness.light : Brightness.dark),
        accentColor: Colors.blue);
  }
}
