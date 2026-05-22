import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'onboarding.dart';
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


  late AnimationController _animationController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late Animation<double> _scaleAnimation;

  late Animation<double> _textFade1;
  late Animation<double> _textFade2;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // 2 seconds
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
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

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut, // Elastic bounce
      ),
    );

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

    _checkUserStatusAndNavigate();
  }



  void _checkUserStatusAndNavigate() async {
    if (!mounted) return;

    final uri = Uri.parse(Uri.base.toString());
    if (uri.pathSegments.contains('reset-callback')) {

      Get.offAllNamed('/password-reset');
      return;
    }

    await Future.delayed(const Duration(seconds: 3));

    final box = GetStorage();
    bool onboardingComplete = box.read('onboarding_complete') ?? false;

    final session = Supabase.instance.client.auth.currentSession;
    bool isAuthenticated = session != null;

    if (!mounted) return;

    // 3. Final Navigation
    if (isAuthenticated) {
      Get.offAllNamed('/home');
    } else if (!onboardingComplete) {
      Get.offAllNamed('/onboarding');
    } else {
      Get.offAllNamed('/login');
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
            Positioned(top: 80, left: 30, child: Icon(Icons.checkroom, size: 40, color: Colors.grey.withValues(alpha:0.6))),
            Positioned(top: 120, right: 40, child: FaIcon(FontAwesomeIcons.shoePrints, size: 40, color: Colors.purple.withValues(alpha:0.5))),
            Positioned(bottom: 100, left: 30, child: FaIcon(FontAwesomeIcons.shirt, size: 40, color: Colors.blue.withValues(alpha:0.5))),
            Positioned(bottom: 80, right: 30, child: FaIcon(FontAwesomeIcons.bagShopping, size: 40, color: Colors.grey.withValues(alpha:0.5))),

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