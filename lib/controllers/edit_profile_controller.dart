import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class EditProfileController extends GetxController {
  final box = GetStorage();

  // Observables for Skin Tone
  var selectedSkinTone = Rxn<Color>();
  var selectedSkinName = "".obs;

  // Controllers for Body Measurements
  final shoulderController = TextEditingController();
  final waistController = TextEditingController();
  final hipController = TextEditingController();

  // Skin Tone Palette Data (Must match Onboarding exactly)
  final List<Map<String, dynamic>> skinToneData = [
    {"name": "Fair", "color": const Color(0xFFFFE7D1)},
    {"name": "Light", "color": const Color(0xFFF3D5B5)},
    {"name": "Medium", "color": const Color(0xFFC69061)},
    {"name": "Tan", "color": const Color(0xFFA15D2D)},
    {"name": "Deep", "color": const Color(0xFF632E18)},
  ];

  @override
  void onInit() {
    super.onInit();
    loadStoredData();
  }

  void loadStoredData() {
    // 1. Load Skin Tone Name and find the corresponding Color
    String? storedName = box.read('skin_tone_name');
    if (storedName != null) {
      selectedSkinName.value = storedName;
      // Find color from our palette matching the name
      var matchingTone = skinToneData.firstWhere(
            (element) => element['name'] == storedName,
        orElse: () => skinToneData[0],
      );
      selectedSkinTone.value = matchingTone['color'];
    }

    // 2. Load Body Measurements into TextFields
    shoulderController.text = box.read('shoulder') ?? "";
    waistController.text = box.read('waist') ?? "";
    hipController.text = box.read('hip') ?? "";
  }

  void selectSkinTone(Color color, String name) {
    selectedSkinTone.value = color;
    selectedSkinName.value = name;
  }

  void saveProfileUpdates() {
    // Write updated values back to GetStorage
    box.write('skin_tone_name', selectedSkinName.value);
    box.write('skin_tone_color', selectedSkinTone.value?.value);
    box.write('shoulder', shoulderController.text);
    box.write('waist', waistController.text);
    box.write('hip', hipController.text);

    Get.snackbar(
      'Success',
      'Physical traits updated successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF00ADB5),
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    shoulderController.dispose();
    waistController.dispose();
    hipController.dispose();
    super.onClose();
  }
}