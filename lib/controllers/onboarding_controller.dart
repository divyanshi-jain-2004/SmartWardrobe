import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../screens/body_scan.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final box = GetStorage();

  // Observables
  var currentPage = 0.obs;
  var selectedSkinTone = Rxn<Color>();
  var selectedSkinName = "".obs;

  // Text Controllers for Body Type
  final shoulderController = TextEditingController();
  final waistController = TextEditingController();
  final hipController = TextEditingController();

  // Skin Tone Data with Names
  final List<Map<String, dynamic>> skinToneData = [
    {"name": "Fair", "color": const Color(0xFFFFE7D1)},
    {"name": "Light", "color": const Color(0xFFF3D5B5)},
    {"name": "Medium", "color": const Color(0xFFC69061)},
    {"name": "Tan", "color": const Color(0xFFA15D2D)},
    {"name": "Deep", "color": const Color(0xFF632E18)},
  ];

  bool get isLastPage => currentPage.value == 4;

  void onPageChanged(int index) => currentPage.value = index;

  void selectSkinTone(Color color, String name) {
    selectedSkinTone.value = color;
    selectedSkinName.value = name;
  }

  void handleNext() {
    if (isLastPage) {
      finishOnboardingAndNavigate();
      //Get.off(() => const BodyScanScreen());

    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void finishOnboardingAndNavigate() {
    // Save to GetStorage
    box.write('onboarding_complete', true);
    box.write('skin_tone_name', selectedSkinName.value);
    box.write('skin_tone_color', selectedSkinTone.value?.value);
    box.write('shoulder', shoulderController.text);
    box.write('waist', waistController.text);
    box.write('hip', hipController.text);

    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    pageController.dispose();
    shoulderController.dispose();
    waistController.dispose();
    hipController.dispose();
    super.onClose();
  }
}