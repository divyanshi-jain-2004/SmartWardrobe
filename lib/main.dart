// lib/main.dart (Fixed - GlobalKey Error Resolved)

import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:smart_wardrobe_new/controllers/user_controller.dart';
import 'package:smart_wardrobe_new/controllers/weather_controller.dart';
import 'package:smart_wardrobe_new/screens/HomeScreen.dart';
import 'package:smart_wardrobe_new/screens/OutfitSuggestion.dart';
import 'package:smart_wardrobe_new/screens/my_wardrobe.dart';
import 'package:smart_wardrobe_new/screens/profile.dart' hide LoginScreen;
import 'package:flutter/material.dart';
import 'package:smart_wardrobe_new/screens/splash.dart';
import 'package:smart_wardrobe_new/screens/onboarding.dart';
import 'package:smart_wardrobe_new/screens/login.dart';
import 'package:smart_wardrobe_new/screens/signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controllers/outfit_controller.dart';
import 'controllers/theme_controller.dart';
import 'utils/themes.dart';
import 'screens/reset paasword.dart';

// Supabase client instance global access
final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://srzyhowfebtkueubwyqr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyenlob3dmZWJ0a3VldWJ3eXFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3ODk5OTMsImV4cCI6MjA3ODM2NTk5M30.tbzSYGXo80I6nWogAOOMHq_paxTQhuBilk-irfeJWMk',
  );

  await GetStorage.init();

  Get.put(ThemeController());
  Get.put(UserController());
  Get.put(OutfitController());
  Get.put(WeatherController());

  runApp(const MyApp());

  // Supabase Recovery Listener (सिर्फ़ डेटा अपडेट)
  supabase.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      // यहां कोई navigation नहीं
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      // ✅ FIX: navigatorKey हटा दिया - GetX को अपना key manage करने दें
      // navigatorKey: globalNavigatorKey,  // ❌ REMOVED

      debugShowCheckedModeBanner: false,
      title: 'AI Smart Wardrobe',

      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeController.theme,

      // ✅ Splash Screen से शुरुआत
      initialRoute: "/splash",

      // ✅ FIX: सभी routes को getPages में convert करें
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/signup', page: () => const SignUpScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/password-reset', page: () => const PasswordResetScreen()),
      ],
    );
  }
}