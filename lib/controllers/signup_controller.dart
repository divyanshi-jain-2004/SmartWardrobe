import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

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
        data: {'full_name': nameController.text.trim() },
      );

      if (res.user != null) {
        showSnackbar('Success', 'Registration successful!', accentTeal);

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

  @override

  void dispose(){
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}