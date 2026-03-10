import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'onboarding.dart'; // OnboardingScreen के लिए
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_wardrobe_new/main.dart';

// --- App Colors ---
const Color _kGradientStart = Color(0xFFD8B4FE);
const Color _kGradientEnd = Color(0xFFA5F3FC);
const Color _kBrandTeal = Color(0xFF00ADB5);//accenteal1
const Color _kBrandBlack = Color(0xFF333333);


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  // Animation variables
  late AnimationController _animationController;

  // Container Slide/Fade
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Logo Scale
  late Animation<double> _scaleAnimation;

  // Staggered Text Fade
  late Animation<double> _textFade1;
  late Animation<double> _textFade2;

  @override
  void initState() {
    super.initState();

    // 1. Animation Controller Set up
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // 2 seconds
    );

    // 2. Container Slide/Fade (Movement and Opacity)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // Start 0.2 units below center
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn, // Smooth movement
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    // 3. Logo Scale Animation (Zooming in with a bounce effect)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut, // Elastic bounce
      ),
    );

    // 4. Staggered Fade for Text
    _textFade1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn), // 'Clos'
      ),
    );

    _textFade2 = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn), // 'ora'
      ),
    );


    _animationController.forward();

    // 5. Navigation Logic (Called immediately)
    _checkUserStatusAndNavigate();
  }

  // SUPABASE AUTH STATUS CHECK LOGIC (UPDATED)
  // void _checkUserStatusAndNavigate() async {
  //   if (!mounted) return;
  //
  //   // --- 1. DEEP LINK / RECOVERY CHECK (FIRST PRIORITY) ---
  //   // 💡 FIX: Uri.base की जाँच तुरंत करें।
  //   final uri = Uri.parse(Uri.base.toString());
  //
  //   // Check for Deep Link pattern: smartwardrobe://reset-callback or ?access_token
  //   bool isDeepLinkRecovery = uri.pathSegments.contains('reset-callback') ||
  //       uri.queryParameters.containsKey('access_token') ||
  //       uri.queryParameters.containsKey('recovery_token');
  //
  //
  //   if (isDeepLinkRecovery) {
  //     // यदि यह रिकवरी फ़्लो है, तो तुरंत (बिना 3 सेकंड के डिले के) नेविगेट करें।
  //     // यह GlobalKey कॉन्फ़्लिक्ट को रोकने के लिए सबसे तेज़ रास्ता है।
  //     Get.offAllNamed('/password-reset');
  //     return;
  //   }
  //
  //
  //   // --- 2. REGULAR APP LAUNCH (WITH 3 SECOND DELAY) ---
  //   // अगर रिकवरी नहीं है, तो एनीमेशन के लिए प्रतीक्षा करें
  //   await Future.delayed(const Duration(seconds: 3));
  //
  //   final session = supabase.auth.currentSession;
  //   bool isAuthenticated = session != null;
  //
  //   bool isFirstTime = false; //  (GetStorage check here)
  //
  //
  //   if (!mounted) return;
  //
  //   // --- NAVIGATION LOGIC ---
  //   if (isAuthenticated) {
  //     Get.offNamed('/home');
  //   } else if (isFirstTime) {
  //     Get.offNamed('/onboarding');
  //   } else {
  //     Get.offNamed('/login');
  //   }
  // }

  //  SUPABASE AUTH STATUS CHECK LOGIC (UPDATED WITH GET_STORAGE)
  // void _checkUserStatusAndNavigate() async {
  //   if (!mounted) return;
  //
  //   // 1. Deep link check (keep your existing code)
  //   final uri = Uri.parse(Uri.base.toString());
  //   if (uri.pathSegments.contains('reset-callback')) {
  //     Get.offAllNamed('/password-reset');
  //     return;
  //   }
  //
  //   // 2. Wait for animation
  //   await Future.delayed(const Duration(seconds: 3));
  //
  //   // --- GET_STORAGE LOGIC ---
  //   final box = GetStorage();
  //   // Check if 'onboarding_complete' exists. If null, it means it's the first time.
  //   bool onboardingComplete = box.read('onboarding_complete') ?? false;
  //
  //   final session = supabase.auth.currentSession;
  //   bool isAuthenticated = session != null;
  //
  //   if (!mounted) return;
  //
  //   // --- NAVIGATION LOGIC ---
  //   if (isAuthenticated) {
  //     Get.offNamed('/home');
  //   } else if (!onboardingComplete) {
  //     // If onboarding is NOT complete, show onboarding
  //     Get.offNamed('/onboarding');
  //     //Get.off(() => const OnboardingScreen());
  //   } else {
  //     // If onboarding IS complete but not logged in, show login
  //     Get.offNamed('/login');
  //   }
  // }

  void _checkUserStatusAndNavigate() async {
    if (!mounted) return;

    // 1. Deep link check for Password Reset
    final uri = Uri.parse(Uri.base.toString());
    if (uri.pathSegments.contains('reset-callback')) {
      // Use offAllNamed to wipe the splash/login history
      Get.offAllNamed('/password-reset');
      return;
    }

    // 2. Wait for your 3-second animation
    await Future.delayed(const Duration(seconds: 3));

    final box = GetStorage();
    bool onboardingComplete = box.read('onboarding_complete') ?? false;

    // This checks if a session was left over from the last run
    final session = Supabase.instance.client.auth.currentSession;
    bool isAuthenticated = session != null;

    if (!mounted) return;

    // 3. Final Navigation
    if (isAuthenticated) {
      Get.offAllNamed('/home'); // Go home if token exists
    } else if (!onboardingComplete) {
      Get.offAllNamed('/onboarding');
    } else {
      Get.offAllNamed('/login'); // Go to login if token was deleted by signOut()
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ _kGradientStart, _kGradientEnd ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // 🔹 Decorative Icons (Unchanged)
            Positioned(top: 80, left: 30, child: Icon(Icons.checkroom, size: 40, color: Colors.grey.withOpacity(0.6))),
            Positioned(top: 120, right: 40, child: FaIcon(FontAwesomeIcons.shoePrints, size: 40, color: Colors.purple.withOpacity(0.5))),
            Positioned(bottom: 100, left: 30, child: FaIcon(FontAwesomeIcons.shirt, size: 40, color: Colors.blue.withOpacity(0.5))),
            Positioned(bottom: 80, right: 30, child: FaIcon(FontAwesomeIcons.bagShopping, size: 40, color: Colors.grey.withOpacity(0.5))),

            //  Center Content (Animated)
            Center(
              // 1. SlideTransition
              child: SlideTransition(
                position: _slideAnimation,
                // 2. FadeTransition
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 3. Logo: Scale Transition
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Image.asset("assets/logo.png", height: 200, width: 200),
                      ),

                      const SizedBox(height: 10),

                      // 4. Staggered RichText
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            // "Clos" - Part 1 Fade
                            WidgetSpan(
                              child: FadeTransition(
                                opacity: _textFade1,
                                child: Text(
                                  "Attire",
                                  style: TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                    color: _kBrandBlack,
                                  ),
                                ),
                              ),
                            ),
                            // "ora" - Part 2 Fade
                            WidgetSpan(
                              child: FadeTransition(
                                opacity: _textFade2,
                                child: Text(
                                  "Hub",
                                  style: TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                    color: _kBrandTeal,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 5),

                      // 5. Subtext
                      Text(
                        "Style Your Moments",
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}