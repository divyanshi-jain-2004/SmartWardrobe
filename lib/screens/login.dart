import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/login_controller.dart';
import 'Signup.dart';
// import 'signup_screen.dart'; // Apna signup screen import karein

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
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
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Image.asset("assets/logo.png", height: screenHeight * 0.12),
                const SizedBox(height: 20),
                const Text("Login", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                _buildTextField(controller.emailController, "Email", Icons.email_outlined),
                const SizedBox(height: 15),

                Obx(() => TextField(
                  controller: controller.passwordController,
                  obscureText: controller.obscurePassword.value,
                  decoration: InputDecoration(
                    hintText: "Password",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(controller.obscurePassword.value ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => controller.obscurePassword.toggle(),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                )),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotDialog(context, controller),
                    child: const Text("Forgot Password?"),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.accentTeal,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: controller.isLoading.value ? null : controller.signIn,
                    child: controller.isLoading.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Login", style: TextStyle(color: Colors.white, fontSize: 18)),
                  )),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("or"),
                ),

                _socialBtn("Google", "assets/google.png", OAuthProvider.google, controller),
                const SizedBox(height: 10),
                _socialBtn("Facebook", "assets/facebook.png", OAuthProvider.facebook, controller),

                // ######################################################################
                //                   🎯 SIGN UP LINK ADDED BACK (UPDATED)
                // ######################################################################
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don’t have an account? ",
                      style: TextStyle(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        // GetX navigation use karein ya Navigator
                        Get.to(() => const SignUpScreen());
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: controller.accentTeal,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets (Same as before) ---

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon) {
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

  Widget _socialBtn(String label, String icon, OAuthProvider provider, LoginController controller) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Image.asset(icon, height: 20),
      label: Text("Continue with $label", style: const TextStyle(color: Colors.black)),
      onPressed: () => controller.handleSocialLogin(provider),
    );
  }

  void _showForgotDialog(BuildContext context, LoginController controller) {
    final resetEmail = TextEditingController();
    Get.defaultDialog(
      title: "Forgot Password",
      content: TextField(controller: resetEmail, decoration: const InputDecoration(hintText: "Email")),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: controller.accentTeal),
        onPressed: () {
          controller.resetPassword(resetEmail.text.trim());
          Get.back();
        },
        child: const Text("Send", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}