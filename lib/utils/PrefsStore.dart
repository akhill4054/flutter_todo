import 'package:shared_preferences/shared_preferences.dart';

class PrefsStore {
  static const THEME_STAT = "themeStat";

  static setLightTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STAT, value);
  }

  static Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STAT) ?? false;
  }
}