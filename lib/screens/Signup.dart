import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/signup_controller.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller inject karna
    final controller = Get.put(SignUpController());
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD8B4FE), Color(0xFFA5F3FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: screenHeight * 0.05),
            child: Column(
              children: [
                Image.asset("assets/logo.png", height: screenHeight * 0.12),
                SizedBox(height: screenHeight * 0.025),
                const Text("Create Account",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: screenHeight * 0.035),

                // Name Field
                _inputField(controller.nameController, "Full Name", Icons.person_outline),
                const SizedBox(height: 15),

                // Email Field
                _inputField(controller.emailController, "Email Address", Icons.email_outlined),
                const SizedBox(height: 15),

                // Password Field
                Obx(() => _passwordField(
                  controller.passwordController,
                  "Password",
                  controller.obscurePassword.value,
                      () => controller.obscurePassword.toggle(),
                )),
                const SizedBox(height: 15),

                // Confirm Password Field
                Obx(() => _passwordField(
                  controller.confirmPasswordController,
                  "Confirm Password",
                  controller.obscureConfirmPassword.value,
                      () => controller.obscureConfirmPassword.toggle(),
                )),

                const SizedBox(height: 30),

                // Signup Button
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.accentTeal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: controller.isLoading.value ? null : () => controller.signUp(),
                    child: controller.isLoading.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text("Sign Up",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  )),
                ),

                const SizedBox(height: 25),

                // Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ", style: TextStyle(color: Colors.black54)),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text("Login",
                          style: TextStyle(
                              color: controller.accentTeal, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _inputField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _passwordField(TextEditingController ctrl, String hint, bool obscure, VoidCallback toggle, {IconData icon = Icons.lock_outline}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility), onPressed: toggle),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}