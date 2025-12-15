import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 🎯 GetX Import

// --- Custom Colors ---
class AppColors {
  static const Color accentTeal = Color(0xFF00ADB5);
// ⚠️ बाकी Hardcoded Colors हटा दिए गए हैं, वे Theme से आएंगे।
}

class EditPersonalInfoScreen extends StatefulWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _apparelSizeController = TextEditingController();

  // Dropdown State
  String? _selectedGender;
  final List<String> _genders = ['Female', 'Male', 'Non-Binary', 'Prefer not to say'];

  // Sizing Dropdown
  String? _selectedSizeUnit;
  final List<String> _sizeUnits = ['EU', 'US', 'UK'];

  // 🎯 Theme Getters
  Color get _primaryTextColor => Theme.of(context).textTheme.bodyLarge!.color!;
  Color get _secondaryTextColor => Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
  Color get _surfaceColor => Theme.of(context).colorScheme.surface;
  Color get _scaffoldColor => Theme.of(context).scaffoldBackgroundColor;


  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _apparelSizeController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // Implement save logic here (e.g., Supabase update)
    // 🎯 GetX Snackbar
    Get.snackbar(
      'Success',
      'Changes saved successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.accentTeal,
      colorText: Colors.white,
    );
    // Optionally navigate back
    // Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05;
    final cardMargin = size.height * 0.02;

    return Scaffold(
      // 🎯 Theme-Aware Background Color
      backgroundColor: _scaffoldColor,
      appBar: AppBar(
        // AppBar Background color Theme से आएगा
        elevation: 0,
        toolbarHeight: size.height * 0.08,
        title: Text(
          'Edit Personal Info',
          style: TextStyle(
            // 🎯 Theme-Aware Text Color
            color: _primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: size.width * 0.05,
          ),
        ),
        centerTitle: true,
        // 🎯 Theme-Aware Icon Color
        iconTheme: IconThemeData(color: _primaryTextColor),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: cardMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Personal Details Card
                _buildInfoCard(
                  size: size,
                  title: 'Personal Details',
                  children: [
                    _buildLabel('First Name', size),
                    _buildTextField(
                      controller: _firstNameController,
                      size: size,
                    ),
                    SizedBox(height: size.height * 0.02),
                    _buildLabel('Last Name', size),
                    _buildTextField(
                      controller: _lastNameController,
                      size: size,
                    ),
                    SizedBox(height: size.height * 0.02),
                    _buildLabel('Gender', size),
                    _buildGenderDropdown(size),
                  ],
                ),

                SizedBox(height: cardMargin),

                // 2. Sizing Information Card
                _buildInfoCard(
                  size: size,
                  title: 'Sizing Information',
                  children: [
                    _buildLabel('Apparel Size', size),
                    _buildSizingField(size),
                    // Add extra padding to prevent the scrollable content from being hidden by the button
                    SizedBox(height: size.height * 0.15),
                  ],
                ),
              ],
            ),
          ),

          // 3. Floating Save Button (Always visible at the bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: _surfaceColor, // 🎯 Theme-Aware Bottom Container Color
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: size.height * 0.02),
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildInfoCard({required Size size, required String title, required List<Widget> children}) {
    return Card(
      elevation: 4,
      // 🎯 Card color Theme से आएगा
      color: _surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: _primaryTextColor, // 🎯 Theme-Aware Text Color
              ),
            ),
            SizedBox(height: size.height * 0.025),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label, Size size) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.005),
      child: Text(
        label,
        style: TextStyle(
          fontSize: size.width * 0.038,
          fontWeight: FontWeight.w600,
          color: _primaryTextColor, // 🎯 Theme-Aware Text Color
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required Size size}) {
    return TextField(
      controller: controller,
      // 🎯 Theme-Aware Input Text Color
      style: TextStyle(fontSize: size.width * 0.04, color: _primaryTextColor),
      cursorColor: AppColors.accentTeal,
      decoration: InputDecoration(
        filled: true,
        fillColor: _scaffoldColor, // 🎯 Theme-Aware Fill Color
        contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.02),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accentTeal, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      decoration: BoxDecoration(
        color: _scaffoldColor, // 🎯 Theme-Aware Fill Color
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintText: 'Select Gender',
          hintStyle: TextStyle(color: _secondaryTextColor), // 🎯 Theme-Aware Hint Text
        ),
        // 🎯 Theme-Aware Text Color
        style: TextStyle(fontSize: size.width * 0.04, color: _primaryTextColor),
        dropdownColor: _surfaceColor, // 🎯 Dropdown List Background
        icon: Icon(Icons.arrow_drop_down, color: _secondaryTextColor), // 🎯 Theme-Aware Icon
        items: _genders.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            // 🎯 Theme-Aware Dropdown Item Text Color
            child: Text(value, style: TextStyle(color: _primaryTextColor)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
      ),
    );
  }

  Widget _buildSizingField(Size size) {
    return Row(
      children: [
        // Input Field (Size)
        Expanded(
          flex: 2,
          child: TextField(
            controller: _apparelSizeController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: size.width * 0.04, color: _primaryTextColor), // 🎯 Theme-Aware Text Color
            cursorColor: AppColors.accentTeal,
            decoration: InputDecoration(
              filled: true,
              fillColor: _scaffoldColor, // 🎯 Theme-Aware Fill Color
              contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.02),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.accentTeal, width: 1.5),
              ),
              hintText: 'e.g. 38',
              hintStyle: TextStyle(color: _secondaryTextColor.withOpacity(0.7)), // 🎯 Theme-Aware Hint Text
            ),
          ),
        ),

        SizedBox(width: size.width * 0.02),

        // Dropdown Unit (EU/US/UK)
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            decoration: BoxDecoration(
              color: _scaffoldColor, // 🎯 Theme-Aware Fill Color
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedSizeUnit,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Unit',
                hintStyle: TextStyle(color: _secondaryTextColor), // 🎯 Theme-Aware Hint Text
              ),
              // 🎯 Theme-Aware Text Color
              style: TextStyle(fontSize: size.width * 0.04, color: _primaryTextColor),
              dropdownColor: _surfaceColor, // 🎯 Dropdown List Background
              iconSize: size.width * 0.045,
              items: _sizeUnits.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  // 🎯 Theme-Aware Dropdown Item Text Color
                  child: Text(value, textAlign: TextAlign.center, style: TextStyle(color: _primaryTextColor)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSizeUnit = newValue;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}