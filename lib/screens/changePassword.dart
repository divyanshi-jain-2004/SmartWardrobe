import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_wardrobe_new/main.dart';
import '../utils/constants/colors.dart';



class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Controllers
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // State for visibility and loading
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // 🎯 Theme Getters
  Color get _primaryTextColor => Theme.of(context).textTheme.bodyLarge!.color!;
  Color get _secondaryTextColor => Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.6);
  Color get _scaffoldColor => Theme.of(context).scaffoldBackgroundColor;
  Color get _dividerColor => Theme.of(context).dividerColor;


  @override
  void dispose() {
    _currentPasswordController.dispose();
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


  Future<void> _saveChanges() async {

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
        _showSnackbar('Password updated successfully! Please re-login with your new password.', AppColors.accentTeal);


        await supabase.auth.signOut();


        Get.offAllNamed('/login');
      }

    } on AuthException catch (e) {

      if (mounted) {
        _showSnackbar('Password Update Failed: ${e.message}', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('An unexpected error occurred: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05;
    final verticalSpacing = size.height * 0.02;

    return Scaffold(

      backgroundColor: _scaffoldColor,
      appBar: AppBar(

        elevation: 0,
        toolbarHeight: size.height * 0.08,
        title: Text(
          'Change Password',
          style: TextStyle(

            color: _primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: size.width * 0.05,
          ),
        ),
        centerTitle: true,

        iconTheme: IconThemeData(color: _primaryTextColor),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Form Fields
            _buildLabel('Current Password', size),
            _buildPasswordField(
              controller: _currentPasswordController,
              hintText: 'Enter your current password',
              obscureText: _obscureCurrent,
              onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
              size: size,
            ),
            SizedBox(height: verticalSpacing),

            _buildLabel('New Password', size),
            _buildPasswordField(
              controller: _newPasswordController,
              hintText: 'Enter your new password',
              obscureText: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              size: size,
            ),
            SizedBox(height: verticalSpacing),

            _buildLabel('Confirm New Password', size),
            _buildPasswordField(
              controller: _confirmPasswordController,
              hintText: 'Confirm your new password',
              obscureText: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
              size: size,
            ),
            SizedBox(height: verticalSpacing),


            _buildRequirementsText(size),
            SizedBox(height: verticalSpacing * 1.5),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,

                  disabledBackgroundColor: AppColors.accentTeal.withValues(alpha:0.5),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
                    : Text(
                  'Save Changes',
                  style: TextStyle(fontSize: size.width * 0.045, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.015),


            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(), // 🎯 GetX Navigation
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

                  side: BorderSide(color: _secondaryTextColor.withValues(alpha:0.8), width: 1),
                ),
                child: Text(
                  'Cancel',

                  style: TextStyle(fontSize: size.width * 0.045, color: _secondaryTextColor),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.04),
          ],
        ),
      ),
    );
  }



  Widget _buildLabel(String label, Size size) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.01),
      child: Text(
        label,
        style: TextStyle(
          fontSize: size.width * 0.04,
          fontWeight: FontWeight.w600,
          color: _primaryTextColor,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
    required Size size,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(fontSize: size.width * 0.042, color: _primaryTextColor),
      cursorColor: AppColors.accentTeal,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: _secondaryTextColor),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: _secondaryTextColor,
            size: size.width * 0.06,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: _scaffoldColor,
        contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.02),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accentTeal, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildRequirementsText(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
      child: Text(
        'Passwords must be at least 8 characters long and include a mix of uppercase letters, lowercase letters, numbers, and symbols.',
        style: TextStyle(
          fontSize: size.width * 0.035,
          color: _secondaryTextColor,
          height: 1.4,
        ),
      ),
    );
  }
}