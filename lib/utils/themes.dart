import 'package:flutter/material.dart';

enum CurrentTheme { dark, light }

final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    buttonTheme: const ButtonThemeData(buttonColor: Colors.black),
    unselectedWidgetColor: Colors.white,
    primaryTextTheme: const TextTheme(caption: TextStyle(color: Colors.white)),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.white,
      background: Colors.white,
    )
);


final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.blue,
    buttonTheme: const ButtonThemeData(buttonColor: Colors.black),
    unselectedWidgetColor: Colors.white,
    primaryTextTheme: const TextTheme(caption: TextStyle(color: Colors.white)),
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.white,
        background: Colors.white,

    )
);
