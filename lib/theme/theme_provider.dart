import 'package:flutter/material.dart';
import 'package:habits/theme/dark_mode.dart';
import 'package:habits/theme/light_mode.dart';

class ThemeProvider extends ChangeNotifier{
  // initially light mode
  ThemeData _themeData= lightMode;

  //get the current theme
  ThemeData get themeData => _themeData;

  // is current mode dark mode
  bool get isDarkMode => _themeData == darkMode;

  //set the theme
  set themeData(ThemeData themeData){
    _themeData = themeData;
    notifyListeners();
  }

  //toggle the theme
  void toggleTheme(){
    if(_themeData==lightMode){
      themeData = darkMode;
    }else{
      themeData = lightMode;
    }
  }
}
