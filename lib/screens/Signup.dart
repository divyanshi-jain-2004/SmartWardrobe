// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../controllers/signup_controller.dart';
//
// class SignUpScreen extends StatelessWidget {
//   const SignUpScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Controller inject karna
//     final controller = Get.put(SignUpController());
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFD8B4FE), Color(0xFFA5F3FC)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: 30, vertical: screenHeight * 0.05),
//             child: Column(
//               children: [
//                 Image.asset("assets/logo.png", height: screenHeight * 0.12),
//                 SizedBox(height: screenHeight * 0.025),
//                 const Text("Create Account",
//                     style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
//                 SizedBox(height: screenHeight * 0.035),
//
//                 // Name Field
//                 _inputField(controller.nameController, "Full Name", Icons.person_outline),
//                 const SizedBox(height: 15),
//
//                 // Email Field
//                 _inputField(controller.emailController, "Email Address", Icons.email_outlined),
//                 const SizedBox(height: 15),
//
//                 // Password Field
//                 Obx(() => _passwordField(
//                   controller.passwordController,
//                   "Password",
//                   controller.obscurePassword.value,
//                       () => controller.obscurePassword.toggle(),
//                 )),
//                 const SizedBox(height: 15),
//
//                 // Confirm Password Field
//                 Obx(() => _passwordField(
//                   controller.confirmPasswordController,
//                   "Confirm Password",
//                   controller.obscureConfirmPassword.value,
//                       () => controller.obscureConfirmPassword.toggle(),
//                 )),
//
//                 const SizedBox(height: 30),
//
//                 // Signup Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: Obx(() => ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: controller.accentTeal,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       elevation: 2,
//                     ),
//                     onPressed: controller.isLoading.value ? null : () => controller.signUp(),
//                     child: controller.isLoading.value
//                         ? const SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//                     )
//                         : const Text("Sign Up",
//                         style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//                   )),
//                 ),
//
//                 const SizedBox(height: 25),
//
//                 // Back to Login
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Already have an account? ", style: TextStyle(color: Colors.black54)),
//                     GestureDetector(
//                       onTap: () => Get.back(),
//                       child: Text("Login",
//                           style: TextStyle(
//                               color: controller.accentTeal, fontWeight: FontWeight.bold, fontSize: 15)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Helper Widgets
//   Widget _inputField(TextEditingController ctrl, String hint, IconData icon) {
//     return TextField(
//       controller: ctrl,
//       decoration: InputDecoration(
//         hintText: hint,
//         prefixIcon: Icon(icon),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//       ),
//     );
//   }
//
//   Widget _passwordField(TextEditingController ctrl, String hint, bool obscure, VoidCallback toggle, {IconData icon = Icons.lock_outline}) {
//     return TextField(
//       controller: ctrl,
//       obscureText: obscure,
//       decoration: InputDecoration(
//         hintText: hint,
//         prefixIcon: Icon(icon),
//         suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility), onPressed: toggle),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//       ),
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/signup_controller.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E7FF), // Base soft background
      body: Stack(
        children: [
          // 1. Advanced Gradient Layer
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD8B4FE), Color(0xFFA5F3FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 2. Enhanced Glow Orbs (Matching Login Screen)
          Positioned(
            top: -100,
            right: -50,
            child: _buildGlowOrb(screenWidth * 0.8, Colors.white.withOpacity(0.4)),
          ),
          Positioned(
            bottom: -50,
            left: -80,
            child: _buildGlowOrb(screenWidth * 0.7, Colors.deepPurple.withOpacity(0.15)),
          ),

          // 3. Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo with soft glow
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 30,
                        )
                      ],
                    ),
                    child: Image.asset("assets/logo.png", height: screenHeight * 0.10),
                  ),
                  const SizedBox(height: 20),

                  // Glassmorphic Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4A148C),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Join us and start your journey",
                              style: TextStyle(
                                color: Colors.indigo.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Name Field
                            _buildEnhancedField(
                              controller.nameController,
                              "Full Name",
                              Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 16),

                            // Email Field
                            _buildEnhancedField(
                              controller.emailController,
                              "Email Address",
                              Icons.alternate_email_rounded,
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            Obx(() => _buildEnhancedField(
                              controller.passwordController,
                              "Password",
                              Icons.lock_outline_rounded,
                              isPassword: true,
                              obscure: controller.obscurePassword.value,
                              toggle: () => controller.obscurePassword.toggle(),
                            )),
                            const SizedBox(height: 16),

                            // Confirm Password Field
                            Obx(() => _buildEnhancedField(
                              controller.confirmPasswordController,
                              "Confirm Password",
                              Icons.verified_user_outlined,
                              isPassword: true,
                              obscure: controller.obscureConfirmPassword.value,
                              toggle: () => controller.obscureConfirmPassword.toggle(),
                            )),

                            const SizedBox(height: 30),

                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: Obx(() => ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: controller.accentTeal,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18)),
                                ),
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () => controller.signUp(),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                                    : const Text(
                                  "SIGN UP",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Footer: Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? ",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: controller.accentTeal,
                            fontWeight: FontWeight.w900,
                            decoration: TextDecoration.underline,
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
        ],
      ),
    );
  }

  // Enhanced Glassy TextField
  Widget _buildEnhancedField(
      TextEditingController ctrl,
      String hint,
      IconData icon, {
        bool isPassword = false,
        bool obscure = false,
        VoidCallback? toggle,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.indigo.withOpacity(0.4), fontSize: 15),
          prefixIcon: Icon(icon, color: const Color(0xFF6B21A8).withOpacity(0.7)),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
                obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: Colors.indigo.withOpacity(0.4)),
            onPressed: toggle,
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
      ),
    );
  }

  // Glow Orb helper
  Widget _buildGlowOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}