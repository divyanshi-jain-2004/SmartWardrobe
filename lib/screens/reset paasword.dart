import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_wardrobe_new/main.dart';
import 'package:smart_wardrobe_new/screens/login.dart';

const Color accentTeal = Color(0xFF0F766E);
const Color originalGradientStart = Color(0xFFD8B4FE);
const Color originalGradientEnd = Color(0xFFA5F3FC);


class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, Color color) {
    Get.snackbar(
      color == Colors.red ? 'Error' : 'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
    );
  }


  Future<void> _updatePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackbar('New passwords do not match.', Colors.red);
      return;
    }
    if (_newPasswordController.text.length < 8) {
      _showSnackbar('Password must be at least 8 characters long.', Colors.red);
      return;
    }

    setState(() { _isLoading = true; });

    try {
      await supabase.auth.updateUser(
        UserAttributes(
          password: _newPasswordController.text,
        ),
      );

      if (mounted) {
        _showSnackbar('Password updated successfully! Please log in.', Colors.green);

        await supabase.auth.signOut();

        Get.offAll(() => const LoginScreen());
      }

    } on AuthException catch (e) {
      if (mounted) {
        _showSnackbar('Update Failed: ${e.message}. Session might have expired.', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('An unexpected error occurred.', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final backgroundDecoration = const BoxDecoration(
      gradient: LinearGradient(
        colors: [originalGradientStart, originalGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );

    return Scaffold(

      backgroundColor: Colors.transparent,


      body: Container(
        decoration: backgroundDecoration,
        child: Center(
          child: SingleChildScrollView(

            padding: EdgeInsets.symmetric(horizontal: 30, vertical: screenHeight * 0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Set New Password",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),

                // 🔹 New Password Field
                _buildPasswordField(
                  controller: _newPasswordController,
                  hintText: "New Password (min 8 chars)",
                  obscureText: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                ),
                SizedBox(height: screenHeight * 0.02),

                // 🔹 Confirm Password Field
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  hintText: "Confirm New Password",
                  obscureText: _obscureConfirm,
                  icon: Icons.lock_person_outlined,
                  onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),

                SizedBox(height: screenHeight * 0.04),

                // 🔹 Change Password Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.white.withOpacity(0.5),
                    ),
                    onPressed: _isLoading ? null : _updatePassword,
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: accentTeal, strokeWidth: 3),
                    )
                        : const Text(
                      "Change Password",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentTeal),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
    IconData icon = Icons.lock_outline,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.white.withOpacity(0.7),
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}