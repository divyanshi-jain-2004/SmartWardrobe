// lib/main.dart (Fixed - GlobalKey Error Resolved)

import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:smart_wardrobe_new/controllers/user_controller.dart';
import 'package:smart_wardrobe_new/controllers/weather_controller.dart';
import 'package:smart_wardrobe_new/controllers/wardrobe_controller.dart';
import 'package:smart_wardrobe_new/screens/HomeScreen.dart';
import 'package:smart_wardrobe_new/screens/OutfitSuggestion.dart';
import 'package:smart_wardrobe_new/screens/ResetPasswordScreen.dart';
import 'package:smart_wardrobe_new/screens/body_scan.dart';
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
  await GetStorage.init();

  await Supabase.initialize(
    url: 'https://srzyhowfebtkueubwyqr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyenlob3dmZWJ0a3VldWJ3eXFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3ODk5OTMsImV4cCI6MjA3ODM2NTk5M30.tbzSYGXo80I6nWogAOOMHq_paxTQhuBilk-irfeJWMk',
      realtimeClientOptions: const RealtimeClientOptions(
        eventsPerSecond: 10,
        timeout: Duration(seconds: 30),
      )
  );

  final session = Supabase.instance.client.auth.currentSession;

  Get.put(ThemeController());
  Get.put(UserController());
  Get.put(OutfitController());
  Get.put(WeatherController());
  Get.put(WardrobeController());

  runApp(const MyApp());

  supabase.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;
    if (event == AuthChangeEvent.passwordRecovery) {
      // When the app opens via the email link, Supabase triggers this event.
      // We then send the user to the ResetPasswordScreen.
      Get.to(() => const ResetPasswordScreen());
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return GetMaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'AI Smart Wardrobe',

      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeController.theme,

      // ✅ Splash Screen
      initialRoute: "/splash",
      
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/signup', page: () => const SignUpScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/body-scan', page: () => const BodyScanScreen()),
        GetPage(name: '/password-reset', page: () => const PasswordResetScreen()),

      ],
    );
  }
}