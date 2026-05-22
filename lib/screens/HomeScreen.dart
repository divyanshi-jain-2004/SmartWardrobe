
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_wardrobe_new/controllers/outfit_controller.dart';

// Controllers
import 'package:smart_wardrobe_new/controllers/user_controller.dart';
import 'package:smart_wardrobe_new/controllers/weather_controller.dart';
import 'package:smart_wardrobe_new/controllers/wardrobe_controller.dart';
// Screens
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
  // 1. Current Index Tracker
  int _selectedIndex = 0;

  // 2. Lazy screen cache — only build a screen the first time it is tapped
  final Map<int, Widget> _builtScreens = {};

  static const _screenBuilders = [
    HomeContent.new,
    MyWardrobeScreen.new,
    OutfitSuggestionScreen.new,
    EventPlannerScreen.new,
    ProfileScreen.new,
  ];

  Widget _getScreen(int index) {
    return _builtScreens.putIfAbsent(
      index,
      () => _screenBuilders[index](),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      // Only the screens that have been visited are kept in the stack
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(
          _screenBuilders.length,
          (i) => _builtScreens.containsKey(i) || i == _selectedIndex
              ? _getScreen(i)
              : const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: _buildUnifiedBottomNavBar(isDark),
    );
  }

  Widget _buildUnifiedBottomNavBar(bool isDark) {
    final barColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // The Background Container (Dock)
          Container(
            height: 65,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
          ),
          // The Icons Row
          SizedBox(
            height: 85, // Extra height to allow floating without overflow
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _navIcon(Icons.home_filled, 0, isDark),
                _navIcon(Icons.checkroom_rounded, 1, isDark),
                _navIcon(Icons.auto_awesome_rounded, 2, isDark),
                _navIcon(Icons.calendar_today_rounded, 3, isDark),
                _navIcon(Icons.person_rounded, 4, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index, bool isDark) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        // Subtle float (Move up by 15 pixels)
        transform: Matrix4.translationValues(0, isSelected ? -15 : 0, 0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentTeal : Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: isSelected
                ? [
              BoxShadow(
                  color: AppColors.accentTeal.withValues(alpha:0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6))
            ]
                : [],
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : (isDark ? Colors.white38 : Colors.black38),
            size: 26,
          ),
        ),
      ),
    );
  }
}

// --- Separated Home Content to allow IndexedStack switching ---
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF263238);
    final WeatherController weatherController = Get.find<WeatherController>();
    final WardrobeController wardrobeController = Get.find<WardrobeController>();

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                  : [const Color(0xFFF8F9FF), const Color(0xFFE0F7FA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await weatherController.fetchWeather();
              await wardrobeController.fetchCounts();
            },
            color: AppColors.accentTeal,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 120, top: 20),
              children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: const HomeHeader(),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: const LookCard(),
              ),
              const SizedBox(height: 30),
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
              const SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: const WardrobeStatsGrid(),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: const CuratedForYou(),
              ),
            ],
          ),
        ),
        )
      ],

    );
  }
}

// --- Keep your existing HomeHeader, LookCard, WardrobeStatsGrid, and CuratedForYou classes below ---
// (Make sure they are present in your file or imported)

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
                  GestureDetector(
                    onTap: () => weatherController.handleLocationTap(),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                  ),
                ],
              ),
            ],
          ),
          // Row(
          //   children: [
          //     _buildGlassIconButton(context, Icons.refresh_rounded, () {
          //       weatherController.fetchWeather();
          //       Get.find<WardrobeController>().fetchCounts();
          //     }),
          //     const SizedBox(width: 8),
              _buildGlassIconButton(context, "assets/body.png", () => Get.toNamed('/body-scan')),
          //   ],
          // ),
        ],
      );
    });
  }

  Widget _buildGlassIconButton(BuildContext context, dynamic iconOrImage, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // BackdropFilter/blur removed — it forces a full offscreen compositing pass
    // every frame and is a significant cause of jank on mid-range devices.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha:0.15) : Colors.white.withValues(alpha:0.75),
          shape: BoxShape.circle,
          border: Border.all(color: isDark ? Colors.white24 : Colors.white.withValues(alpha:0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: iconOrImage is IconData
            ? Icon(iconOrImage, size: 24, color: isDark ? Colors.white : Colors.black87)
            : Image.asset(iconOrImage, height: 24, width: 24),
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
    final OutfitController outfitController = Get.find<OutfitController>();

    return Obx(() {
      if (outfitController.isGenerating.value) {
        return Container(
          height: size.height * 0.42,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(35),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.accentTeal),
          ),
        );
      }

      if (outfitController.dailyOutfit.isEmpty) {
        return Container(
          height: size.height * 0.42,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(35),
          ),
          child: const Center(
            child: Text(
              "Add more items to get\nDaily AI Outfits!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }

      var dailyCombo = outfitController.dailyOutfit;
      var top = dailyCombo['top'];
      var bot = dailyCombo['bottom'];
      String outfitName = dailyCombo['name'] ?? 'Daily Styling';
      String topUrl = top != null ? top['image_url'] ?? '' : '';
      String botUrl = bot != null ? bot['image_url'] ?? '' : '';

      return Container(
        height: size.height * 0.52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(color: AppColors.accentTeal.withValues(alpha:0.2), blurRadius: 30, offset: const Offset(0, 15)),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                   Expanded(
                     child: Padding(
                       padding: EdgeInsets.only(top: 15, bottom: botUrl.isNotEmpty ? 5 : 65, left: 15, right: 15),
                       child: _buildImage(topUrl),
                     )
                   ),
                   if (botUrl.isNotEmpty)
                     Expanded(
                       child: Padding(
                         padding: const EdgeInsets.only(top: 5, bottom: 65, left: 15, right: 15),
                         child: _buildImage(botUrl),
                       ),
                     ),
                ],
              ),
            ),
            ),

            Positioned(
              bottom: 15, left: 15, right: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha:0.5),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('AI Daily Pick', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12)),
                          Text(outfitName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.to(() => OutfitSuggestionScreen(initialOutfitData: outfitController.dailyOutfit )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text('Try it On', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildImage(String path) {
    if (path.isEmpty) return Container(color: Colors.grey[300]);
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
      );
    } else {
      return Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
      );
    }
  }
}

// --- Stats Grid ---
class WardrobeStatsGrid extends StatelessWidget {
  const WardrobeStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final WardrobeController wardrobeController = Get.find<WardrobeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (wardrobeController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final counts = wardrobeController.categoryCounts;

      // 🎯 Calculate total count using the new getter
      final totalAll = wardrobeController.totalItemsCount;

      final stats = [];

      // 🎯 1. Dynamic Category Cards from Controller
      for (var cat in wardrobeController.categories) {
        stats.add({
          'count': '${counts[cat.title] ?? 0}',
          'label': cat.title,
          'icon': cat.icon,
          'color': _getCategoryColor(cat.title, isDark),
        });
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.4,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) => _buildStatTile(context, stats[index]),
      );
    });
  }

  Color? _getCategoryColor(String title, bool isDark) {
    if (title.contains('Top')) return isDark ? Colors.blue[900]?.withValues(alpha:0.3) : Colors.blue[50];
    if (title.contains('Bottom')) return isDark ? Colors.orange[900]?.withValues(alpha:0.3) : Colors.orange[50];
    if (title.contains('Footwear')) return isDark ? Colors.pink[900]?.withValues(alpha:0.3) : Colors.pink[50];
    if (title.contains('Jewellery') || title.contains('Accessory')) return isDark ? Colors.green[900]?.withValues(alpha:0.3) : Colors.green[50];
    return isDark ? Colors.cyan[900]?.withValues(alpha:0.3) : Colors.cyan[50];
  }

  Widget _buildStatTile(BuildContext context, Map<String, dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha:0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.white),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha:isDark ? 0.2 : 0.03),
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