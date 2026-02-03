import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Jahan aapka supabase client define hai

class SignUpController extends GetxController {
  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State Variables
  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;

  final Color accentTeal = const Color(0xFF0F766E);

  // Snackbar Helper
  void showSnackbar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
    );
  }

  // 🛠️ Supabase Sign Up Logic
  Future<void> signUp() async {
    // Basic Validation
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      showSnackbar('Error', 'Please fill in all fields.', Colors.orange);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showSnackbar('Error', 'Passwords do not match.', Colors.red);
      return;
    }

    isLoading.value = true;

    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {'full_name': nameController.text.trim()},
      );

      if (res.user != null) {
        showSnackbar('Success', 'Registration successful!', accentTeal);
        // Direct home par le jayein
        Get.offAllNamed('/home');
      } else if (res.session == null) {
        showSnackbar('Check Email', 'Please verify your email to continue.', Colors.blue);
        Get.offAllNamed('/login');
      }
    } on AuthException catch (e) {
      showSnackbar('Signup Failed', e.message, Colors.red);
    } catch (e) {
      showSnackbar('Error', 'An unexpected error occurred.', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // Social Login Handle
  Future<void> handleSocialLogin(OAuthProvider provider) async {
    try {
      await supabase.auth.signInWithOAuth(
        provider,
        redirectTo: 'smartwardrobe://login-callback',
      );
    } catch (e) {
      showSnackbar('Error', e.toString(), Colors.red);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}