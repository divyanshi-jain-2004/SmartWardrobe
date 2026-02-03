import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6EDDE), Color(0xFFD6EEF3)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  children: [
                    _buildPage(
                      screenHeight: screenHeight,
                      image: "assets/outfit.png",
                      title: "Your Style, AI-Powered",
                      description: "Discover personalized outfit suggestions tailored just for you. Our AI learns your preferences to curate perfect looks.",
                    ),
                    _buildPage(
                      screenHeight: screenHeight,
                      image: "assets/wardrobe.png",
                      title: "Smart Wardrobe Management",
                      description: "Organize your clothing digitally, track what you own, and discover new ways to style your items.",
                    ),
                    _buildPage(
                      screenHeight: screenHeight,
                      image: "assets/shopping.png",
                      title: "Seamless Hybrid Shopping",
                      description: "Mix and match your existing wardrobe with new, curated suggestions to effortlessly complete your perfect look.",
                    ),
                    // ✨ Updated Personalization Slide
                    _buildPersonalizationPage(controller, screenWidth),
                    _buildCategoryPage(screenWidth: screenWidth),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  children: [
                    SmoothPageIndicator(
                      controller: controller.pageController,
                      count: 5,
                      effect: const ExpandingDotsEffect(
                        activeDotColor: Color(0xFF009688),
                        dotColor: Colors.black26,
                        dotHeight: 10,
                        dotWidth: 10,
                        expansionFactor: 3,
                        spacing: 5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: controller.handleNext,
                      child: Text(
                        controller.isLastPage ? "Get Started" : "Next →",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({required double screenHeight, required String image, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset(image, height: screenHeight * 0.35),
          Column(
            children: [
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 12),
              Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5)),
            ],
          ),
        ],
      ),
    );
  }

  // ✨ UPDATED: Skin Tone Slide with Labels
  Widget _buildPersonalizationPage(OnboardingController controller, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Body & Skin Tone", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Help us tailor suggestions to your physique.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 30),

            const Text("Select Skin Tone", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),

            Wrap(
              spacing: 15,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: controller.skinToneData.map((data) {
                final Color toneColor = data['color'];
                final String toneName = data['name'];

                return GestureDetector(
                  onTap: () => controller.selectSkinTone(toneColor, toneName),
                  child: Column(
                    children: [
                      Obx(() => Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: toneColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: controller.selectedSkinTone.value == toneColor ? const Color(0xFF009688) : Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            if (controller.selectedSkinTone.value == toneColor)
                              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)
                          ],
                        ),
                      )),
                      const SizedBox(height: 8),
                      Text(toneName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),
            const Text("Body Measurements (inches)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 15),
            _buildInputField("Shoulder Width", controller.shoulderController),
            _buildInputField("Waist Size", controller.waistController),
            _buildInputField("Hip Size", controller.hipController),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController textController) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: textController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryPage({required double screenWidth}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text("Choose Your Style Categories", textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 10),
          const Text("Select categories to personalize your wardrobe experience.", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.black54, height: 1.5)),
          const SizedBox(height: 30),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCategoryCard(screenWidth, Icons.male, "Men"),
                  _buildCategoryCard(screenWidth, Icons.female, "Women"),
                ],
              ),
              const SizedBox(height: 20),
              _buildCategoryCard(screenWidth, Icons.child_care, "Kids"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(double screenWidth, IconData icon, String label) {
    final cardSize = screenWidth * 0.35;
    return Container(
      width: cardSize,
      height: cardSize * 0.92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: const Color(0xFF009688)),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}
