import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var obscurePassword = true.obs;

  final accentTeal = const Color(0xFF0F766E);

  // Snackbar
  void showCustomSnackbar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
    );
  }

  // Email/Password Login
  Future<void> signIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showCustomSnackbar('Error', 'Please enter all fields', Colors.orange);
      return;
    }

    isLoading.value = true;
    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user != null) {
        showCustomSnackbar('Success', 'Welcome back!', accentTeal);
        Get.offAllNamed('/home');
      }
    } on AuthException catch (e) {
      showCustomSnackbar('Login Failed', e.message, Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // Social Login (Google/Facebook)
  Future<void> handleSocialLogin(OAuthProvider provider) async {
    try {
      await supabase.auth.signInWithOAuth(
        provider,
        redirectTo: 'smartwardrobe://login-callback',
      );
    } catch (e) {
      showCustomSnackbar('Error', e.toString(), Colors.red);
    }
  }

  // Forgot Password
  Future<void> resetPassword(String email) async {
    if (!GetUtils.isEmail(email)) {
      showCustomSnackbar('Error', 'Enter a valid email', Colors.orange);
      return;
    }

    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'smartwardrobe://reset-callback',
      );
      showCustomSnackbar('Success', 'Reset link sent to $email', Colors.green);
    } catch (e) {
      showCustomSnackbar('Error', 'Failed to send link', Colors.red);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}