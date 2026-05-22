

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import 'Signup.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD8B4FE), Color(0xFFA5F3FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Positioned(
            top: -50,
            right: -50,
            child: _buildOrb(screenWidth * 0.6, Colors.white.withValues(alpha:0.3)),
          ),
          Positioned(
            bottom: -80,
            left: -30,
            child: _buildOrb(screenWidth * 0.5, Colors.deepPurple.withValues(alpha:0.1)),
          ),


          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withValues(alpha:0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.05),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo with Glow
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha:0.5),
                                blurRadius: 20,
                              )
                            ],
                          ),
                          child: Image.asset("assets/logo.png", height: screenHeight * 0.12),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4A148C),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Text(
                          "Login to your account",
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                        const SizedBox(height: 40),

                        // Email Field
                        _buildTextField(
                          controller.emailController,
                          "Email Address",
                          Icons.mail_rounded,
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        Obx(() => _buildTextField(
                          controller.passwordController,
                          "Password",
                          Icons.lock_rounded,
                          isPassword: true,
                          obscure: controller.obscurePassword.value,
                          toggle: () => controller.obscurePassword.toggle(),
                        )),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _showForgotDialog(context, controller),
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Color(0xFF6B21A8), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Modern Animated Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Obx(() => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: controller.accentTeal,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: controller.accentTeal.withValues(alpha:0.4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: controller.isLoading.value ? null : controller.signIn,
                            child: controller.isLoading.value
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Text(
                              "LOGIN",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                          )),
                        ),

                        const SizedBox(height: 30),

                        // Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("New here? ", style: TextStyle(color: Colors.black87)),
                            GestureDetector(
                              onTap: () => Get.to(() => const SignUpScreen()),
                              child: Text(
                                "Create Account",
                                style: TextStyle(
                                  color: controller.accentTeal,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController ctrl,
      String hint,
      IconData icon, {
        bool isPassword = false,
        bool obscure = false,
        VoidCallback? toggle,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,

        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF6B21A8)),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey),
            onPressed: toggle,
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  void _showForgotDialog(BuildContext context, LoginController controller) {
    final resetEmail = TextEditingController();
    Get.defaultDialog(
      title: "Reset Password",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      backgroundColor: Colors.white.withValues(alpha:0.9),
      radius: 20,
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        children: [
          const Text("Enter your email to receive a reset link", textAlign: TextAlign.center),
          const SizedBox(height: 15),
          TextField(
            controller: resetEmail,
            decoration: InputDecoration(
              hintText: "Email",
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.accentTeal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          controller.resetPassword(resetEmail.text.trim());
          Get.back();
        },
        child: const Text("Send Link", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}