import 'package:smart_wardrobe_new/screens/Signup.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_wardrobe_new/main.dart';
import 'package:get/get.dart'; // GetX Snackbar के लिए जोड़ा गया

// --- App Colors (Forgot Password Dialog के लिए जरूरी) ---
const Color accentTeal = Color(0xFF0F766E);
const Color primaryText = Colors.black87;
const Color secondaryText = Colors.grey;
const Color backgroundWhite = Colors.white;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // 🎯 GetX Snackbar Helper (नया)
  void _showSnackbar(String message, Color color) {
    Get.snackbar(
      color == Colors.red ? 'Error' : 'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
    );
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🛠️ Supabase Sign In Logic (ScaffoldMessenger की जगह GetX Snackbar)
  Future<void> signInUser() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackbar('Please enter email and password.', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (res.user != null) {
        if (mounted) {
          _showSnackbar("Login Successful! ", accentTeal);
          // Navigator का उपयोग जारी रखा गया है
          Navigator.of(context).pushReplacementNamed('/home');
        }

      } else {
        if (mounted) {
          _showSnackbar("Authentication response was null. Check network or server status.", Colors.red);
        }
      }

    } on AuthException catch (e) {
      if (mounted) {
        _showSnackbar("Login Failed: ${e.message}. (Did you verify your email?)", Colors.red);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('An unexpected error occurred: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ######################################################################
  //                   🎯 FORGOT PASSWORD LOGIC ADDED (UPDATED)
  // ######################################################################

  // 1. रीसेट ईमेल भेजने का Supabase फ़ंक्शन
  Future<void> _resetPassword(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      _showSnackbar('Please enter a valid email address.', Colors.orange);
      return;
    }

    // ❌ OLD ScaffoldMessenger कॉल हटा दिया गया
    // 💡 FIX: केवल Get.snackbar का उपयोग करें
    Get.snackbar(
        'Sending',
        'Sending password reset link...',
        duration: const Duration(seconds: 5),
        backgroundColor: accentTeal,
        colorText: Colors.white
    );


    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        // 🎯 Deep Link URI
        redirectTo: 'smartwardrobe://reset-callback',
      );

      _showSnackbar('Password reset link sent to $email. Check your inbox!', Colors.green);

    } on AuthException catch (e) {
      _showSnackbar('Error: ${e.message}', Colors.red);
    } catch (e) {
      _showSnackbar('An unexpected error occurred.', Colors.red);
    }
  }

  // 2. Forgot Password Dialog (Unchanged)
  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailResetController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: backgroundWhite,
          title: const Text('Forgot Password', style: TextStyle(color: primaryText, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your registered email address to receive a password reset link.',
                style: TextStyle(color: secondaryText),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailResetController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: primaryText),
                cursorColor: accentTeal,
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: const TextStyle(color: secondaryText),
                  prefixIcon: const Icon(Icons.email_outlined, color: secondaryText),
                  filled: true,
                  fillColor: Colors.grey.shade100, // Light gray fill
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: secondaryText)),
            ),
            ElevatedButton(
              onPressed: () {
                final email = emailResetController.text.trim();
                Navigator.pop(dialogContext); // Close the dialog first
                _resetPassword(email); // Send reset request
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentTeal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send Reset Link'),
            ),
          ],
        );
      },
    );
  }
  // ######################################################################


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // 🎯 GRADIENT BACKGROUND (ओरिजिनल कोड)
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD8B4FE), Color(0xFFA5F3FC)], // lavender → teal pastel gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: screenHeight * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Logo - Responsive Height
                Image.asset(
                  "assets/logo.png", // apna splash logo yahan rakho
                  height: screenHeight * 0.12,
                ),
                SizedBox(height: screenHeight * 0.025),

                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.035),

                // 🔹 Email
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),

                // 🔹 Password with Eye Toggle
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.01),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _showForgotPasswordDialog(context);
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.01),

                // 🔹 Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentTeal,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : signInUser,
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 3),
                    )
                        : const Text(
                      "Login",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.025),

                const Text("or", style: TextStyle(color: Colors.black54, fontSize: 16)),

                SizedBox(height: screenHeight * 0.025),

                // 🔹 Social Login Buttons
                _socialButton("Continue with Google", "assets/google.png"),
                SizedBox(height: screenHeight * 0.015),
                _socialButton("Continue with Apple", "assets/apple.png"),
                SizedBox(height: screenHeight * 0.015),
                _socialButton("Continue with Facebook", "assets/facebook.png"),

                SizedBox(height: screenHeight * 0.025),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don’t have an account? ",
                      style: TextStyle(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: accentTeal,
                          fontSize: 20,
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
    );
  }

  // 🔹 Social Button Widget (Unchanged)
  Widget _socialButton(String text, String iconPath) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Colors.black12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
        ),
        icon: Image.asset(iconPath, height: 20),
        onPressed: () {
          // Implement social login logic here (e.g., supabase.auth.signInWithOAuth)
        },
        label: Text(text, style: const TextStyle(color: Colors.black87)),
      ),
    );
  }
}