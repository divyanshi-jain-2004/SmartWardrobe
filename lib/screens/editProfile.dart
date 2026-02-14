import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants/colors.dart';
import '../controllers/edit_profile_controller.dart';
import '../controllers/body_scan_controller.dart';
import 'body_scan.dart';


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

  // Initialize Controllers
  final editController = Get.put(EditProfileController());
  final scanController = Get.put(BodyScanController());

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
                // 1. Personal Details Card
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

                // 2. Body Type Card (NEW - Shows detected body type)
                _buildBodyTypeCard(size),

                const SizedBox(height: 20),

                // 3. Physical Profile Card
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
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: _surfaceColor,
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
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

  // NEW: Body Type Display Card
  Widget _buildBodyTypeCard(Size size) {
    final bodyType = scanController.getStoredBodyType();
    final hasScanned = scanController.hasCompletedScan();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Body Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryTextColor)),
              if (hasScanned)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, color: AppColors.accentTeal, size: 16),
                      SizedBox(width: 5),
                      Text('AI Detected',
                          style: TextStyle(color: AppColors.accentTeal, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const Divider(height: 30),

          if (!hasScanned)
          // Show scan button if not scanned yet
            Center(
              child: Column(
                children: [
                  const Icon(Icons.person_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 15),
                  Text('Scan your body to detect your type',
                      style: TextStyle(color: _secondaryTextColor, fontSize: 14),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => const BodyScanScreen());
                    },
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text('Scan Now', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentTeal,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            )
          else
          // Show detected body type
            Column(
              children: [
                Row(
                  children: [
                    // Body type icon
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.accentTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: _getBodyTypeIcon(bodyType),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Body type info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bodyType,
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _primaryTextColor)),
                          const SizedBox(height: 5),
                          Text(_getBodyTypeDescription(bodyType),
                              style: TextStyle(fontSize: 13, color: _secondaryTextColor)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Rescan button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Get.to(() => const BodyScanScreen());
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Rescan'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accentTeal,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _getBodyTypeIcon(String bodyType) {
    IconData iconData;
    switch (bodyType) {
      case 'Pear':
        iconData = Icons.vertical_align_bottom;
        break;
      case 'Apple':
        iconData = Icons.circle;
        break;
      case 'Rectangle':
        iconData = Icons.rectangle_outlined;
        break;
      case 'Inverted Triangle':
        iconData = Icons.vertical_align_top;
        break;
      case 'Hourglass':
        iconData = Icons.hourglass_empty;
        break;
      default:
        iconData = Icons.person;
    }
    return Icon(iconData, size: 35, color: AppColors.accentTeal);
  }

  String _getBodyTypeDescription(String bodyType) {
    switch (bodyType) {
      case 'Pear':
        return 'Wider hips, narrower shoulders';
      case 'Apple':
        return 'Fuller midsection, narrower hips';
      case 'Rectangle':
        return 'Balanced proportions throughout';
      case 'Inverted Triangle':
        return 'Broader shoulders, narrower hips';
      case 'Hourglass':
        return 'Defined waist, balanced proportions';
      default:
        return 'Your unique body shape';
    }
  }

  // Existing Helper Widgets
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
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: controller.selectedSkinName.value == name
                          ? AppColors.accentTeal
                          : Colors.grey.withOpacity(0.3),
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
          items: _genders
              .map((g) => DropdownMenuItem(value: g, child: Text(g, style: TextStyle(color: _primaryTextColor))))
              .toList(),
          onChanged: (val) => setState(() => _selectedGender = val),
        ),
      ),
    );
  }
}