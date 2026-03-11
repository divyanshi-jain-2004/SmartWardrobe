// import 'package:smart_wardrobe_new/screens/OutfitSuggestion.dart';
// import 'package:smart_wardrobe_new/screens/body_scan.dart';
// import 'package:smart_wardrobe_new/screens/eventPlanner.dart';
// import 'package:smart_wardrobe_new/screens/my_wardrobe.dart';
// import 'package:smart_wardrobe_new/screens/profile.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart'; // 🎯 GetX Import
//
// // 🎯 Controller Imports
// import 'package:smart_wardrobe_new/controllers/user_controller.dart';
// // 🎯 Weather Controller Import (नया)
// import 'package:smart_wardrobe_new/controllers/weather_controller.dart';
//
// import '../controllers/wardrobe_controller.dart';
// import '../utils/constants/colors.dart';
//
// // --- Custom Colors ---
// // class AppColors {
// //   static const Color accentTeal = Color(0xFF00C7B1);
// //   static const Color cardGradientStart = Color(0xFFB0F4E8);
// //   static const Color cardGradientEnd = Color(0xFF8ED2C7);
// // }
//
// // --- Main Screen Class (Stateful) ---
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final horizontalPadding = size.width * 0.05;
//
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: SafeArea(
//         child: ListView(
//           padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
//           children: [
//             // 1. Header Section
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//               child: const HomeHeader(),
//             ),
//             SizedBox(height: size.height * 0.03),
//
//             // 2. Main Look Card Section
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//               child: const LookCard(),
//             ),
//             SizedBox(height: size.height * 0.04),
//
//             // 3. Wardrobe Stats Section (Title)
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//               child: Text(
//                 'Your Wardrobe Stats',
//                 style: TextStyle(
//                   fontSize: size.width * 0.048,
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).textTheme.bodyLarge!.color,
//                 ),
//               ),
//             ),
//             SizedBox(height: size.height * 0.02),
//
//             // 4. Wardrobe Stats Grid
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//               child: const WardrobeStatsGrid(),
//             ),
//             SizedBox(height: size.height * 0.04),
//
//             // 5. Curated For You Section
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//               child: const CuratedForYou(),
//             ),
//             SizedBox(height: size.height * 0.01),
//           ],
//         ),
//       ),
//       // 6. Bottom Navigation Bar
//       bottomNavigationBar: const BottomNavBar(),
//     );
//   }
// }
//
// // --- Component Widgets ---
//
// class HomeHeader extends StatelessWidget {
//   const HomeHeader({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // 💡 Controllers को Find करें
//     final UserController userController = Get.find<UserController>();
//     final WeatherController weatherController = Get.find<WeatherController>();
//
//     final size = MediaQuery.of(context).size;
//     final iconSize = size.width * 0.065;
//
//     // 🎯 Theme-Aware Color References
//     final primaryTextColor = Theme.of(context).textTheme.bodyLarge!.color;
//     final secondaryTextColor = Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
//     final cardColor = Theme.of(context).colorScheme.surface;
//
//     return Obx(() { // 🎯 Obx से रैप करें ताकि यूजर/वेदर डेटा बदलने पर यह रीबिल्ड हो
//       // 💡 Controller से लाइव डेटा प्राप्त करें
//       final userName = userController.userName.value;
//       final avatarUrl = userController.avatarUrl.value;
//
//       // 🎯 WEATHER DATA
//       final location = weatherController.locationName.value;
//       final temp = weatherController.temperature.value;
//       final icon = weatherController.weatherIcon.value;
//
//       // 💡 इमेज प्रोवाइडर लॉजिक
//       ImageProvider imageProvider;
//       if (avatarUrl.isNotEmpty) {
//         imageProvider = NetworkImage(avatarUrl);
//       } else {
//         imageProvider = const NetworkImage('https://i.pravatar.cc/150?img=1');
//       }
//
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               // Profile Image (Avatar)
//               CircleAvatar(
//                 radius: size.width * 0.05,
//                 backgroundColor: cardColor,
//                 backgroundImage: imageProvider, // 🎯 डायनामिक इमेज प्रोवाइडर
//                 child: avatarUrl.isEmpty ? Icon(Icons.person, color: secondaryTextColor, size: iconSize) : null,
//               ),
//               SizedBox(width: size.width * 0.03),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     // 🎯 डायनामिक नाम
//                     'Welcome Back, $userName!',
//                     style: TextStyle(
//                       fontSize: size.width * 0.04,
//                       fontWeight: FontWeight.w600,
//                       color: primaryTextColor,
//                     ),
//                   ),
//                   // 🎯 DYNAMIC WEATHER DISPLAY
//                   Text(
//                     '$location, $temp $icon',
//                     style: TextStyle(
//                       fontSize: size.width * 0.03,
//                       color: secondaryTextColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           // Notification Icon
//           Container(
//             padding: EdgeInsets.all(size.width * 0.02),
//             decoration: BoxDecoration(
//               color: cardColor,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: InkWell(
//               onTap: () => Get.toNamed('/body-scan'),
//               child: Icon(
//                 Icons.notifications_none,
//                 color: primaryTextColor,
//                 size: iconSize,
//               ),
//             ),
//           ),
//         ],
//       );
//     });
//   }
// }
//
// // --- LookCard with Full Image Fit Changes (Unchanged) ---
// class LookCard extends StatelessWidget {
//   const LookCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final cardHeight = size.height * 0.45;
//
//     return Container(
//       height: cardHeight,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(size.width * 0.05),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.accentTeal.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(size.width * 0.05),
//             child: ColorFiltered(
//               colorFilter: ColorFilter.mode(
//                 Colors.black.withOpacity(0.2),
//                 BlendMode.darken,
//               ),
//               child: Image.asset(
//                 "assets/outfit_spring_casual.jpg",
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 height: double.infinity,
//               ),
//             ),
//           ),
//
//           Positioned(
//             left: size.width * 0.05,
//             bottom: size.height * 0.025,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Your Perfect Spring Look!',
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: size.width * 0.048,
//                       fontWeight: FontWeight.bold,
//                       shadows: [
//                         Shadow(
//                           color: Colors.black.withOpacity(0.8),
//                           blurRadius: 4,
//                           offset: const Offset(1, 1),
//                         )
//                       ]
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.012),
//                 ElevatedButton(
//                   onPressed: () {
//                     Get.to(() => const OutfitSuggestionScreen());
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.accentTeal,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(size.width * 0.03),
//                     ),
//                     padding: EdgeInsets.symmetric(
//                         horizontal: size.width * 0.06, vertical: size.height * 0.015),
//                     elevation: 5,
//                   ),
//                   child: Text(
//                     'View Look',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.width * 0.038),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // --- Remaining Component Widgets (Unchanged) ---
//
// // class WardrobeStatsGrid extends StatelessWidget {
// //   const WardrobeStatsGrid({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final List<Map<String, String>> stats = [
// //       {'count': '120', 'label': 'Tops'},
// //       {'count': '75', 'label': 'Bottoms'},
// //       {'count': '40', 'label': 'Footwear'},
// //       {'count': '65', 'label': 'Accessories'},
// //     ];
// //
// //     final size = MediaQuery.of(context).size;
// //     final crossAxisSpacing = size.width * 0.04;
// //     final mainAxisSpacing = size.width * 0.04;
// //     final childAspectRatio = size.width / (size.height / 2.5);
// //
// //     return GridView.builder(
// //       physics: const NeverScrollableScrollPhysics(),
// //       shrinkWrap: true,
// //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //         crossAxisCount: 2,
// //         crossAxisSpacing: crossAxisSpacing,
// //         mainAxisSpacing: mainAxisSpacing,
// //         childAspectRatio: childAspectRatio,
// //       ),
// //       itemCount: stats.length,
// //       itemBuilder: (context, index) {
// //         return StatBox(
// //           count: stats[index]['count']!,
// //           label: stats[index]['label']!,
// //         );
// //       },
// //     );
// //   }
// // }
//
// class WardrobeStatsGrid extends StatelessWidget {
//   const WardrobeStatsGrid({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // 🎯 Find the WardrobeController
//     final WardrobeController wardrobeController = Get.put(WardrobeController());
//
//     final size = MediaQuery.of(context).size;
//     final crossAxisSpacing = size.width * 0.04;
//     final mainAxisSpacing = size.width * 0.04;
//     final childAspectRatio = size.width / (size.height / 2.5);
//
//     return Obx(() {
//       // Mapping the DB categories to your UI Labels
//       final counts = wardrobeController.categoryCounts;
//
//       final List<Map<String, String>> stats = [
//         {'count': '${counts['Topwear'] ?? counts['Tops/Blouses'] ?? 0}', 'label': 'Tops'},
//         {'count': '${counts['Bottomwear'] ?? counts['Bottomwear (Women)'] ?? 0}', 'label': 'Bottoms'},
//         {'count': '${counts['Footwear'] ?? 0}', 'label': 'Footwear'},
//         {'count': '${counts['Accessories'] ?? counts['Jewellery/Scarves'] ?? 0}', 'label': 'Accessories'},
//       ];
//
//       if (wardrobeController.isLoading.value) {
//         return const Center(child: CircularProgressIndicator());
//       }
//
//       return GridView.builder(
//         physics: const NeverScrollableScrollPhysics(),
//         shrinkWrap: true,
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: crossAxisSpacing,
//           mainAxisSpacing: mainAxisSpacing,
//           childAspectRatio: childAspectRatio,
//         ),
//         itemCount: stats.length,
//         itemBuilder: (context, index) {
//           return StatBox(
//             count: stats[index]['count']!,
//             label: stats[index]['label']!,
//           );
//         },
//       );
//     });
//   }
// }
//
// class StatBox extends StatelessWidget {
//   final String count;
//   final String label;
//
//   const StatBox({
//     required this.count,
//     required this.label,
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     final cardColor = Theme.of(context).colorScheme.surface;
//     final primaryTextColor = Theme.of(context).textTheme.bodyLarge!.color;
//     final secondaryTextColor = Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
//
//     return Container(
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(size.width * 0.04),
//         border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
//       ),
//       padding: EdgeInsets.all(size.width * 0.04),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             count,
//             style: TextStyle(
//               fontSize: size.width * 0.065,
//               fontWeight: FontWeight.w800,
//               color: primaryTextColor,
//             ),
//           ),
//           SizedBox(height: size.height * 0.005),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: size.width * 0.035,
//               fontWeight: FontWeight.w500,
//               color: secondaryTextColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class CuratedForYou extends StatelessWidget {
//   const CuratedForYou({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final cardColor = Theme.of(context).colorScheme.surface;
//     final primaryTextColor = Theme.of(context).textTheme.bodyLarge!.color;
//     final secondaryTextColor = Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
//
//     return Container(
//       padding: EdgeInsets.all(size.width * 0.05),
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(size.width * 0.04),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Curated for You',
//             style: TextStyle(
//               fontSize: size.width * 0.048,
//               fontWeight: FontWeight.bold,
//               color: primaryTextColor,
//             ),
//           ),
//           SizedBox(height: size.height * 0.012),
//           Text(
//             'Discover personalized fashion tips and unique outfit ideas tailored to your style preferences and current wardrobe. Our AI stylists are always working to inspire your next look!',
//             style: TextStyle(
//               fontSize: size.width * 0.035,
//               height: 1.4,
//               color: secondaryTextColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class BottomNavBar extends StatelessWidget {
//   const BottomNavBar({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final cardColor = Theme.of(context).colorScheme.surface;
//     final unselectedColor = Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5);
//
//     return Container(
//       decoration: BoxDecoration(
//         color: cardColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: BottomNavigationBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: AppColors.accentTeal,
//         unselectedItemColor: unselectedColor,
//         selectedLabelStyle: const TextStyle(fontSize: 12),
//         unselectedLabelStyle: const TextStyle(fontSize: 12),
//         currentIndex: 0,
//         onTap: (index) {
//           if (index == 0) {
//             // Stay on Home
//           } else if (index == 1) {
//             Get.to(() => const MyWardrobeScreen())?.then((_) {
//               Get.find<WardrobeController>().fetchCounts(); // Refresh when coming back
//             });
//           } else if (index == 2) {
//             Get.to(() => const OutfitSuggestionScreen());
//           } else if (index == 3) {
//             Get.to(() => const EventPlannerScreen());
//           } else if (index == 4) {
//             Get.to(() => const ProfileScreen());
//           }
//         },
//         items:[
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.home_filled),
//             label: 'Home',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.checkroom),
//             label: 'Wardrobe',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.star_half_rounded),
//             label: 'AI Stylist',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_today_outlined),
//             label: 'Planner',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controllers
import 'package:smart_wardrobe_new/controllers/user_controller.dart';
import 'package:smart_wardrobe_new/controllers/weather_controller.dart';
import 'package:smart_wardrobe_new/controllers/wardrobe_controller.dart';

// Screens & Utils
import 'package:smart_wardrobe_new/screens/OutfitSuggestion.dart';
import 'package:smart_wardrobe_new/screens/eventPlanner.dart';
import 'package:smart_wardrobe_new/screens/my_wardrobe.dart';
import 'package:smart_wardrobe_new/screens/profile.dart';
import '../utils/constants/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onNavTapped(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) return;
    else if (index == 1) Get.to(() => const MyWardrobeScreen());
    else if (index == 2) Get.to(() => const OutfitSuggestionScreen());
    else if (index == 3) Get.to(() => const EventPlannerScreen());
    else if (index == 4) Get.to(() => const ProfileScreen());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05;

    // 🎯 THEME PROPERTIES
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF263238);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // 1. Sophisticated Dynamic Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)] // Deep dark blues
                    : [const Color(0xFFF8F9FF), const Color(0xFFE0F7FA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: ListView(
              padding: EdgeInsets.only(bottom: 120, top: size.height * 0.02),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: const HomeHeader(),
                ),
                SizedBox(height: size.height * 0.03),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: const LookCard(),
                ),
                SizedBox(height: size.height * 0.04),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Wardrobe Insights',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Icon(Icons.insights_rounded, color: AppColors.accentTeal),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: const WardrobeStatsGrid(),
                ),
                SizedBox(height: size.height * 0.03),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: const CuratedForYou(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildUnifiedBottomNavBar(isDark),
    );
  }

  Widget _buildUnifiedBottomNavBar(bool isDark) {
    // 🎯 INVERSION LOGIC: Light Mode -> Dark Bar | Dark Mode -> Light Bar
    final barColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final inactiveColor = isDark ? Colors.black38 : Colors.white54;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      height: 70,
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10)
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(Icons.home_filled, 0, inactiveColor),
          _navIcon(Icons.checkroom_rounded, 1, inactiveColor),
          _navIcon(Icons.auto_awesome_rounded, 2, inactiveColor),
          _navIcon(Icons.calendar_today_rounded, 3, inactiveColor),
          _navIcon(Icons.person_rounded, 4, inactiveColor),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index, Color inactiveColor) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavTapped(index),
      child: Icon(
          icon,
          color: isSelected ? AppColors.accentTeal : inactiveColor,
          size: 26
      ),
    );
  }
}

// --- Header Section ---
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    final WeatherController weatherController = Get.find<WeatherController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final userName = userController.userName.value;
      final avatarUrl = userController.avatarUrl.value;
      final location = weatherController.locationName.value;
      final temp = weatherController.temperature.value;
      final icon = weatherController.weatherIcon.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppColors.accentTeal, Colors.purpleAccent]),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : const NetworkImage('https://i.pravatar.cc/150?img=1'),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hey, $userName ✨',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: AppColors.accentTeal),
                      Text(
                        ' $location • $temp $icon',
                        style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          _buildGlassIconButton(context, Icons.notifications_none_rounded, () => Get.toNamed('/body-scan')),
        ],
      );
    });
  }

  Widget _buildGlassIconButton(BuildContext context, IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? Colors.white10 : Colors.white.withOpacity(0.3)),
            ),
            child: Icon(icon, color: isDark ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }
}

// --- LookCard (Images usually look fine in both, but we'll ensure the text overlay stays readable) ---
class LookCard extends StatelessWidget {
  const LookCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: AppColors.accentTeal.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15)),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: Image.asset(
              "assets/outfit_spring_casual.jpg",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 25, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Daily Pick', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12)),
                      Text('Spring Casual Look', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Get.to(() => const OutfitSuggestionScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Try it On', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Stats Grid ---
class WardrobeStatsGrid extends StatelessWidget {
  const WardrobeStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final WardrobeController wardrobeController = Get.put(WardrobeController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (wardrobeController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final counts = wardrobeController.categoryCounts;
      final stats = [
        {'count': '${counts['Topwear'] ?? 0}', 'label': 'Tops', 'icon': Icons.dry_cleaning_rounded, 'color': isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50]},
        {'count': '${counts['Bottomwear'] ?? 0}', 'label': 'Bottoms', 'icon': Icons.layers_rounded, 'color': isDark ? Colors.orange[900]?.withOpacity(0.3) : Colors.orange[50]},
        {'count': '${counts['Footwear'] ?? 0}', 'label': 'Footwear', 'icon': Icons.ice_skating_rounded, 'color': isDark ? Colors.pink[900]?.withOpacity(0.3) : Colors.pink[50]},
        {'count': '${counts['Accessories'] ?? 0}', 'label': 'Jewelry', 'icon': Icons.watch_rounded, 'color': isDark ? Colors.green[900]?.withOpacity(0.3) : Colors.green[50]},
      ];

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.4,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => _buildStatTile(context, stats[index]),
      );
    });
  }

  Widget _buildStatTile(BuildContext context, Map<String, dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.white),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 5)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: data['color'], shape: BoxShape.circle),
            child: Icon(data['icon'], size: 18, color: isDark ? Colors.white : Colors.blueGrey[800]),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['count'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
              Text(data['label'], style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Curated AI Tips (Stays colorful, just adjust internal text if needed) ---
class CuratedForYou extends StatelessWidget {
  const CuratedForYou({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.accentTeal, const Color(0xFF009688)]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Smart Tip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Your current wardrobe suggests you have a love for Earth tones. Try matching your beige bottoms with the new teal top!',
            style: TextStyle(color: Colors.white, height: 1.5, fontSize: 14),
          ),
        ],
      ),
    );
  }
}