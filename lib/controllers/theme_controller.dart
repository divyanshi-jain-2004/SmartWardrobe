import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {

  final _box = GetStorage();
  final _key = 'isDarkMode';

  bool _loadThemeFromBox() => _box.read(_key) ?? false;

  _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  void switchTheme() {

    bool newMode = !_loadThemeFromBox();

    Get.changeThemeMode(newMode ? ThemeMode.dark : ThemeMode.light);

    _saveThemeToBox(newMode);
  }

  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  bool get isDarkMode => _loadThemeFromBox();
}