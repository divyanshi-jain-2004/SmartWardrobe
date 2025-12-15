import 'package:smart_wardrobe_new/screens/login.dart';
import 'package:flutter/material.dart';
// ⚠️ Supabase और global client को एक्सेस करने के लिए main.dart से इम्पोर्ट करें
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_wardrobe_new/main.dart'; // assuming supabase client is initialized here

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 🔹 Controllers to capture input data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false; // Loading state for button

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 🛠️ Supabase Sign Up Logic (UPDATED)
  Future<void> signUpUser() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        // Optional: Add user name to metadata
        data: {'full_name': _nameController.text},
      );

      // Check for response error (Supabase throws an exception on error, but session/user being null handles policy checks)
      if (res.user != null) {
        // SUCCESS: User successfully created AND session started.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! ')),
          );

          // 3. SAFALTA KE BAAD hi Home par redirect karein
          // pushReplacementNamed ensures the user cannot go back to the SignUp screen.
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else if (res.session == null) {
        // This usually happens if Email Confirmation is required by Supabase RLS policy.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration successful. Check your email for verification before logging in.")),
          );
          // If email confirmation is needed, navigate to Login or a verification screen.
          // Since the session wasn't started, we typically send them back to the login screen.
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }

    } on AuthException catch (e) {
      // Supabase specific error handling (e.g., email already registered)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup Failed: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Media Query का उपयोग करें
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD8B4FE), Color(0xFFA5F3FC)], // pastel gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            // Vertical padding को Responsive बनाया गया
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: screenHeight * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Logo - Responsive Height
                Image.asset(
                  "assets/logo.png",
                  height: screenHeight * 0.12, // स्क्रीन हाइट का 12%
                ),
                SizedBox(height: screenHeight * 0.025), // Responsive Spacing

                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.035), // Responsive Spacing

                // 🔹 Name Field
                _buildTextField(
                  controller: _nameController,
                  hintText: "Enter your name",
                  icon: Icons.person_outline,
                ),
                SizedBox(height: screenHeight * 0.015), // Responsive Spacing

                // 🔹 Email Field
                _buildTextField(
                  controller: _emailController,
                  hintText: "Enter your email",
                  icon: Icons.email_outlined,
                ),
                SizedBox(height: screenHeight * 0.015), // Responsive Spacing

                // 🔹 Password Field
                _buildPasswordField(
                  controller: _passwordController,
                  hintText: "Create a password",
                  obscureText: _obscurePassword,
                  toggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                SizedBox(height: screenHeight * 0.015), // Responsive Spacing

                // 🔹 Confirm Password Field
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  hintText: "Confirm your password",
                  obscureText: _obscureConfirmPassword,
                  icon: Icons.lock_person_outlined,
                  toggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),

                SizedBox(height: screenHeight * 0.03), // Responsive Spacing

                // 🔹 Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E), // teal
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : signUpUser, // Call the Supabase function
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 3),
                    )
                        : const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.025), // Responsive Spacing

                const Text("or", style: TextStyle(color: Colors.black54, fontSize: 16)),

                SizedBox(height: screenHeight * 0.025), // Responsive Spacing

                // 🔹 Social Sign Up Buttons
                _socialButton("Google", "assets/google.png"),
                SizedBox(height: screenHeight * 0.015), // Responsive Spacing
                _socialButton("Facebook", "assets/facebook.png"),
                SizedBox(height: screenHeight * 0.015), // Responsive Spacing
                _socialButton("Apple", "assets/apple.png"),

                SizedBox(height: screenHeight * 0.03), // Responsive Spacing

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Changed to named route if available, or pop
                        Navigator.pop(context); // back to login
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xFF0F766E),
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

  // 🛠️ Helper Method: Standard TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 🛠️ Helper Method: Password Field
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    IconData icon = Icons.lock_outline, // Default icon
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: toggleVisibility,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 🔹 Social Button Widget
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
          // Implement social sign-up logic here (e.g., supabase.auth.signInWithOAuth)
        },
        label: Text("Continue with $text", style: const TextStyle(color: Colors.black87)),
      ),
    );
  }
}