import 'package:smart_wardrobe_new/screens/OutfitSuggestion.dart';
import 'package:smart_wardrobe_new/screens/body_scan.dart';
import 'package:smart_wardrobe_new/screens/eventPlanner.dart';
import 'package:smart_wardrobe_new/screens/my_wardrobe.dart';
import 'package:smart_wardrobe_new/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 🎯 GetX Import

// 🎯 Controller Imports
import 'package:smart_wardrobe_new/controllers/user_controller.dart';
// 🎯 Weather Controller Import (नया)
import 'package:smart_wardrobe_new/controllers/weather_controller.dart';

import '../utils/constants/colors.dart';

// --- Custom Colors ---
// class AppColors {
//   static const Color accentTeal = Color(0xFF00C7B1);
//   static const Color cardGradientStart = Color(0xFFB0F4E8);
//   static const Color cardGradientEnd = Color(0xFF8ED2C7);
// }

// --- Main Screen Class (Stateful) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
          children: [
            // 1. Header Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: const HomeHeader(),
            ),
            SizedBox(height: size.height * 0.03),

            // 2. Main Look Card Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: const LookCard(),
            ),
            SizedBox(height: size.height * 0.04),

            // 3. Wardrobe Stats Section (Title)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                'Your Wardrobe Stats',
                style: TextStyle(
                  fontSize: size.width * 0.048,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),

            // 4. Wardrobe Stats Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: const WardrobeStatsGrid(),
            ),
            SizedBox(height: size.height * 0.04),

            // 5. Curated For You Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: const CuratedForYou(),
            ),
            SizedBox(height: size.height * 0.01),
          ],
        ),
      ),
      // 6. Bottom Navigation Bar
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

// --- Component Widgets ---

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Controllers को Find करें
    final UserController userController = Get.find<UserController>();
    final WeatherController weatherController = Get.find<WeatherController>();

    final size = MediaQuery.of(context).size;
    final iconSize = size.width * 0.065;

    // 🎯 Theme-Aware Color References
    final primaryTextColor = Theme.of(context).textTheme.bodyLarge!.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
    final cardColor = Theme.of(context).colorScheme.surface;

    return Obx(() { // 🎯 Obx से रैप करें ताकि यूजर/वेदर डेटा बदलने पर यह रीबिल्ड हो
      // 💡 Controller से लाइव डेटा प्राप्त करें
      final userName = userController.userName.value;
      final avatarUrl = userController.avatarUrl.value;

      // 🎯 WEATHER DATA
      final location = weatherController.locationName.value;
      final temp = weatherController.temperature.value;
      final icon = weatherController.weatherIcon.value;

      // 💡 इमेज प्रोवाइडर लॉजिक
      ImageProvider imageProvider;
      if (avatarUrl.isNotEmpty) {
        imageProvider = NetworkImage(avatarUrl);
      } else {
        imageProvider = const NetworkImage('https://i.pravatar.cc/150?img=1');
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Profile Image (Avatar)
              CircleAvatar(
                radius: size.width * 0.05,
                backgroundColor: cardColor,
                backgroundImage: imageProvider, // 🎯 डायनामिक इमेज प्रोवाइडर
                child: avatarUrl.isEmpty ? Icon(Icons.person, color: secondaryTextColor, size: iconSize) : null,
              ),
              SizedBox(width: size.width * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // 🎯 डायनामिक नाम
                    'Welcome Back, $userName!',
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                  ),
                  // 🎯 DYNAMIC WEATHER DISPLAY
                  Text(
                    '$location, $temp $icon',
                    style: TextStyle(
                      fontSize: size.width * 0.03,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Notification Icon
          Container(
            padding: EdgeInsets.all(size.width * 0.02),
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => Get.toNamed('/body-scan'),
              child: Icon(
                Icons.notifications_none,
                color: primaryTextColor,
                size: iconSize,
              ),
            ),
          ),
        ],
      );
    });
  }
}

// --- LookCard with Full Image Fit Changes (Unchanged) ---
class LookCard extends StatelessWidget {
  const LookCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardHeight = size.height * 0.45;

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.width * 0.05),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentTeal.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(size.width * 0.05),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2),
                BlendMode.darken,
              ),
              child: Image.asset(
                "assets/outfit_spring_casual.jpg",
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          Positioned(
            left: size.width * 0.05,
            bottom: size.height * 0.025,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Perfect Spring Look!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.048,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        )
                      ]
                  ),
                ),
                SizedBox(height: size.height * 0.012),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => const OutfitSuggestionScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size.width * 0.03),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.06, vertical: size.height * 0.015),
                    elevation: 5,
                  ),
                  child: Text(
                    'View Look',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.width * 0.038),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Remaining Component Widgets (Unchanged) ---

class WardrobeStatsGrid extends StatelessWidget {
  const WardrobeStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> stats = [
      {'count': '120', 'label': 'Tops'},
      {'count': '75', 'label': 'Bottoms'},
      {'count': '40', 'label': 'Footwear'},
      {'count': '65', 'label': 'Accessories'},
    ];

    final size = MediaQuery.of(context).size;
    final crossAxisSpacing = size.width * 0.04;
    final mainAxisSpacing = size.width * 0.04;
    final childAspectRatio = size.width / (size.height / 2.5);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return StatBox(
          count: stats[index]['count']!,
          label: stats[index]['label']!,
        );
      },
    );
  }
}

class StatBox extends StatelessWidget {
  final String count;
  final String label;

  const StatBox({
    required this.count,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final cardColor = Theme.of(context).colorScheme.surface;
    final primaryTextColor = Theme.of(context).textTheme.bodyLarge!.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(size.width * 0.04),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
      ),
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: size.width * 0.065,
              fontWeight: FontWeight.w800,
              color: primaryTextColor,
            ),
          ),
          SizedBox(height: size.height * 0.005),
          Text(
            label,
            style: TextStyle(
              fontSize: size.width * 0.035,
              fontWeight: FontWeight.w500,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class CuratedForYou extends StatelessWidget {
  const CuratedForYou({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardColor = Theme.of(context).colorScheme.surface;
    final primaryTextColor = Theme.of(context).textTheme.bodyLarge!.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);

    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(size.width * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Curated for You',
            style: TextStyle(
              fontSize: size.width * 0.048,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          SizedBox(height: size.height * 0.012),
          Text(
            'Discover personalized fashion tips and unique outfit ideas tailored to your style preferences and current wardrobe. Our AI stylists are always working to inspire your next look!',
            style: TextStyle(
              fontSize: size.width * 0.035,
              height: 1.4,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardColor = Theme.of(context).colorScheme.surface;
    final unselectedColor = Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.accentTeal,
        unselectedItemColor: unselectedColor,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            // Stay on Home
          } else if (index == 1) {
            Get.to(() => const MyWardrobeScreen());
          } else if (index == 2) {
            Get.to(() => const OutfitSuggestionScreen());
          } else if (index == 3) {
            Get.to(() => const EventPlannerScreen());
          } else if (index == 4) {
            Get.to(() => const ProfileScreen());
          }
        },
        items:[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: 'Wardrobe',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.star_half_rounded),
            label: 'AI Stylist',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Planner',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}