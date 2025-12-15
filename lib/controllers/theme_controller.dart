import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // GetStorage का उपयोग थीम को सेव करने के लिए

class ThemeController extends GetxController {
  // GetStorage का उपयोग: यह सुनिश्चित करता है कि ऐप बंद होने के बाद भी थीम याद रहे
  final _box = GetStorage();
  final _key = 'isDarkMode';

  // वर्तमान थीम को पढ़ें (Saved State or System Preference)
  bool _loadThemeFromBox() => _box.read(_key) ?? false;

  // थीम को Box में सेव करें
  _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  // थीम को टॉगल करें (RxBool का उपयोग नहीं कर रहे क्योंकि Get.changeTheme() स्वतः ही UI को अपडेट कर देता है)
  void switchTheme() {
    // वर्तमान थीम को लोड करें और उसे उलट दें
    bool newMode = !_loadThemeFromBox();

    // Flutter को थीम बदलने के लिए कहें
    Get.changeThemeMode(newMode ? ThemeMode.dark : ThemeMode.light);

    // नई थीम को डिवाइस में सेव करें
    _saveThemeToBox(newMode);
  }

  // Get.changeThemeMode को इनिशियल थीम देने के लिए
  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  // एक और उपयोगी Getter (ProfileScreen के Switch के लिए)
  bool get isDarkMode => _loadThemeFromBox();
}