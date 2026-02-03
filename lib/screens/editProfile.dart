import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants/colors.dart';
import '../controllers/edit_profile_controller.dart';


class EditPersonalInfoScreen extends StatefulWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  // Personal Details Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _selectedGender;
  final List<String> _genders = ['Female', 'Male', 'Non-Binary', 'Prefer not to say'];

  // Initialize Edit Controller
  final editController = Get.put(EditProfileController());

  Color get _primaryTextColor => Theme.of(context).textTheme.bodyLarge!.color!;
  Color get _secondaryTextColor => Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
  Color get _surfaceColor => Theme.of(context).colorScheme.surface;
  Color get _scaffoldColor => Theme.of(context).scaffoldBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05;

    return Scaffold(
      backgroundColor: _scaffoldColor,
      appBar: AppBar(
        elevation: 0,
        title: Text('Edit Personal Info',
            style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: IconThemeData(color: _primaryTextColor),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
            child: Column(
              children: [
                // 1. Personal Details Card (Existing)
                _buildInfoCard(
                  size: size,
                  title: 'Personal Details',
                  children: [
                    _buildLabel('First Name', size),
                    _buildTextField(controller: _firstNameController, size: size),
                    const SizedBox(height: 15),
                    _buildLabel('Last Name', size),
                    _buildTextField(controller: _lastNameController, size: size),
                    const SizedBox(height: 15),
                    _buildLabel('Gender', size),
                    _buildGenderDropdown(size),
                  ],
                ),

                const SizedBox(height: 20),

                // 2. Physical Profile Card (New Replacement)
                _buildInfoCard(
                  size: size,
                  title: 'Physical Profile',
                  children: [
                    _buildLabel('Skin Tone', size),
                    const SizedBox(height: 10),
                    _buildSkinTonePalette(editController),
                    const SizedBox(height: 30),
                    _buildLabel('Body Measurements (inches)', size),
                    const SizedBox(height: 10),
                    _buildBodyFields(editController, size),
                    const SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ],
            ),
          ),

          // Save Button Container
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              color: _surfaceColor,
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  // Save both local state and GetX state
                  editController.saveProfileUpdates();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Changes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- New Helper Widgets for Physical Profile ---

  Widget _buildSkinTonePalette(EditProfileController controller) {
    return Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 15,
        alignment: WrapAlignment.center,
        children: controller.skinToneData.map((data) {
          final Color color = data['color'];
          final String name = data['name'];
          return GestureDetector(
            onTap: () => controller.selectSkinTone(color, name),
            child: Column(
              children: [
                Obx(() => Container(
                  width: 45, height: 45,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: controller.selectedSkinName.value == name
                          ? AppColors.accentTeal : Colors.grey.withOpacity(0.3),
                      width: 2.5,
                    ),
                  ),
                )),
                const SizedBox(height: 4),
                Text(name, style: TextStyle(fontSize: 11, color: _secondaryTextColor)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBodyFields(EditProfileController controller, Size size) {
    return Column(
      children: [
        _buildMeasurementRow("Shoulder", controller.shoulderController, size),
        _buildMeasurementRow("Waist", controller.waistController, size),
        _buildMeasurementRow("Hip", controller.hipController, size),
      ],
    );
  }

  Widget _buildMeasurementRow(String label, TextEditingController ctrl, Size size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(color: _primaryTextColor))),
          Expanded(
            flex: 3,
            child: _buildTextField(controller: ctrl, size: size, hint: "in"),
          ),
        ],
      ),
    );
  }

  // --- Existing Helper Widgets (Modified for consistency) ---

  Widget _buildInfoCard({required Size size, required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryTextColor)),
          const Divider(height: 30),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String label, Size size) {
    return Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _primaryTextColor));
  }

  Widget _buildTextField({required TextEditingController controller, required Size size, String? hint}) {
    return TextField(
      controller: controller,
      style: TextStyle(color: _primaryTextColor),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: _scaffoldColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildGenderDropdown(Size size) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: _scaffoldColor, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          isExpanded: true,
          hint: Text("Select Gender", style: TextStyle(color: _secondaryTextColor)),
          dropdownColor: _surfaceColor,
          items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g, style: TextStyle(color: _primaryTextColor)))).toList(),
          onChanged: (val) => setState(() => _selectedGender = val),
        ),
      ),
    );
  }
}