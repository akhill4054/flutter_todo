import 'package:flutter/material.dart';
import 'package:flutter_todo/ui/home.dart';
import 'package:flutter_todo/utils/PrefsStore.dart';
import 'package:flutter_todo/utils/ThemeProvider.dart';
import 'package:flutter_todo/utils/styles.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeModel themeProvider = ThemeModel();

  @override
  void initState() {
    super.initState();
    // Getting current theme
    getCurrentTheme();
  }

  void getCurrentTheme() async {
    themeProvider.lightTheme = await PrefsStore.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeProvider;
      },
      child: Consumer<ThemeModel>(
          builder: (BuildContext context, value, Widget child) {
        return MaterialApp(
          title: 'Todo App',
          debugShowCheckedModeBanner: false,
          theme: Styles.getThemeData(themeProvider.lightTheme),
          home: Home(),
        );
      }),
    );
  }
}
