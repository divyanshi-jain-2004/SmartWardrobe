import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ New Import
import 'login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  // 🛠️ Step 1: Flag सेट करने और नेविगेट करने का फंक्शन
  void _finishOnboardingAndNavigate() async {
    // SharedPreferences को इनिशियलाइज़ करें
    final prefs = await SharedPreferences.getInstance();

    // 'onboarding_complete' flag को TRUE पर सेट करें
    await prefs.setBool('onboarding_complete', true);

    // User को Login Screen पर भेजें और Onboarding Stack को हटा दें
    if (mounted) {
      // Note: चूंकि आपने /login route define किया है, इसलिए pushReplacementNamed का उपयोग करें
      Navigator.of(context).pushReplacementNamed('/login');
      // अगर named routes काम न करे तो आप यह भी उपयोग कर सकते हैं:
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Media Query का उपयोग करें
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF6EDDE),
              Color(0xFFD6EEF3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() {
                      // 4 pages हैं (0, 1, 2, 3), इसलिए index 3 अंतिम पेज है।
                      isLastPage = index == 3;
                    });
                  },
                  children: [
                    _buildPage(
                      screenHeight: screenHeight,
                      image: "assets/outfit.png",
                      title: "Your Style, AI-Powered",
                      description:
                      "Discover personalized outfit suggestions tailored just for you. "
                          "Our AI learns your preferences to curate perfect looks.",
                    ),
                    _buildPage(
                      screenHeight: screenHeight,
                      image: "assets/wardrobe.png",
                      title: "Smart Wardrobe Management",
                      description:
                      "Organize your clothing digitally, track what you own, "
                          "and discover new ways to style your items.",
                    ),
                    _buildPage(
                      screenHeight: screenHeight,
                      image: "assets/shopping.png",
                      title: "Seamless Hybrid Shopping",
                      description:
                      "Mix and match your existing wardrobe with new, curated suggestions "
                          "to effortlessly complete your perfect look.",
                    ),
                    _buildCategoryPage(
                      screenWidth: screenWidth,
                    ),
                  ],
                ),
              ),

              // 🔹 Page Indicator + Next Button
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  children: [
                    SmoothPageIndicator(
                      controller: _controller,
                      count: 4,
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        if (isLastPage) {
                          // ✅ Step 2: "Get Started" पर flag सेट करें और navigate करें
                          _finishOnboardingAndNavigate();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        isLastPage ? "Get Started" : "Next →",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🛠️ Page building helper methods (unchanged)
  Widget _buildPage({
    required double screenHeight,
    required String image,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset(
            image,
            height: screenHeight * 0.35,
          ),
          Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPage({required double screenWidth}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            "Choose Your Style Categories",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Select categories to personalize your wardrobe experience.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
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
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: const Color(0xFF009688)),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}