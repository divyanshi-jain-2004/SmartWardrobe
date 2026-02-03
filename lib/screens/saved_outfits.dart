import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ⚠️ Ensure these paths are correct
import 'package:smart_wardrobe_new/models/outfit_model.dart';
import 'package:smart_wardrobe_new/controllers/outfit_controller.dart';
import 'package:smart_wardrobe_new/screens/OutfitSuggestion.dart';

import '../utils/constants/colors.dart'; // 🎯 OutfitSuggestionScreen इम्पोर्ट करें

// --- App Colors (Unchanged) ---
// class AppColors {
//   static const Color accentTeal = Color(0xFF00C7B1);
//   static const Color mintGreen = Color(0xFFA8E6CF);
// }

// 🎯 Changed to GetView to access the controller directly
class SavedOutfitsScreen extends GetView<OutfitController> {
  // ❌ initialSavedOutfits फ़ील्ड हटा दिया गया है
  // final List<OutfitModel> initialSavedOutfits;

  // 🎯 FIX: कंस्ट्रक्टर को ठीक किया गया (कोई आवश्यक पैरामीटर नहीं)
  const SavedOutfitsScreen({super.key});
  // Note: यदि आप ProfileScreen में बिना बदलाव के पुरानी नेविगेशन (जो डेटा पास कर रही थी)
  // का उपयोग करना चाहती हैं, तो कंस्ट्रक्टर को केवल एक dummy variable स्वीकार करना होगा:
  // const SavedOutfitsScreen({super.key, required List<OutfitModel> initialSavedOutfits});
  // लेकिन GetX के सर्वोत्तम अभ्यास के लिए, इसे हटा देना चाहिए।

  // 🎯 Theme Getters for StatelessWidget (Unchanged)
  Color _primaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.color!;
  Color _secondaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
  Color _surfaceColor(BuildContext context) => Theme.of(context).colorScheme.surface;
  Color _scaffoldColor(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;

  // --- WIDGET BUILDERS ---
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: _scaffoldColor(context),
      title: Text(
          'Saved Outfits',
          style: TextStyle(
              color: _primaryTextColor(context),
              fontWeight: FontWeight.bold,
              fontSize: 22
          )
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.share_outlined, color: _secondaryTextColor(context)),
          onPressed: () {
            Get.snackbar('Share', 'Sharing functionality is not yet implemented.', snackPosition: SnackPosition.TOP);
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final accentColor = AppColors.accentTeal;
    final unselectedColor = _secondaryTextColor(context);
    final surfaceColor = _surfaceColor(context);

    return BottomNavigationBar(
      elevation: 10,
      currentIndex: 1,
      selectedItemColor: accentColor,
      unselectedItemColor: unselectedColor,
      showUnselectedLabels: true,
      backgroundColor: surfaceColor,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 0) {
          Get.offAllNamed('/home');
        } else if (index == 2) {
          Get.toNamed('/profile');
        }
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), label: 'Outfits'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    // 🎯 Obx used to listen to controller's live list
    return Obx(() {
      // 💡 Controller से लाइव डेटा प्राप्त करें (इसमें Mock Data या यूजर डेटा होगा)
      final liveOutfits = controller.savedOutfits;
      final bool isEmpty = liveOutfits.isEmpty;

      return Scaffold(
        appBar: _buildAppBar(context),
        backgroundColor: _scaffoldColor(context),
        body: isEmpty
            ? Center(
          // Empty State
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.style_outlined, size: 60, color: _secondaryTextColor(context)),
                const SizedBox(height: 16),
                Text(
                  'No Outfits Saved Yet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryTextColor(context)),
                ),
                const SizedBox(height: 8),
                Text(
                  // 🎯 मैसेज बदला गया है ताकि 'Planner' पर जाने का संकेत मिले
                  'Start saving your favorite styles from the AI Suggestions screen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: _secondaryTextColor(context)),
                ),
              ],
            ),
          ),
        )
            : Column(
          children: [
            // Search Bar Placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: _surfaceColor(context),
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).dividerColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                    ]
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: _secondaryTextColor(context)),
                    const SizedBox(width: 8),
                    // 💡 Display the size of the live list
                    Text('Showing all ${liveOutfits.length} saved outfits', style: TextStyle(color: _secondaryTextColor(context))),
                  ],
                ),
              ),
            ),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.65,
                ),
                itemCount: liveOutfits.length, // 💡 Using the live list
                itemBuilder: (context, index) {
                  final outfit = liveOutfits[index];

                  return GestureDetector(
                    onTap: () {
                      // 🎯 GetX Navigation: आउटफिट डेटा पास करें
                      Get.to(() => OutfitSuggestionScreen(
                        initialOutfitName: outfit.name,
                        initialOutfitImagePath: outfit.imageUrl,
                      ));
                    },
                    child: _OutfitCard(outfit: outfit),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      );
    });
  }
}

// --- OUTFIT CARD WIDGET (Unchanged Logic) ---

class _OutfitCard extends StatelessWidget {
  final OutfitModel outfit;

  const _OutfitCard({required this.outfit});

  Color _primaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.color!;
  Color _surfaceColor(BuildContext context) => Theme.of(context).colorScheme.surface;
  Color _dividerColor(BuildContext context) => Theme.of(context).dividerColor;


  @override
  Widget build(BuildContext context) {
    // 💡 Controller को एक्सेस करें
    final OutfitController controller = Get.find<OutfitController>();

    return Card(
      elevation: 3,
      color: _surfaceColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Outfit Image (Using Image.asset for locally saved suggestions)
          Image.asset(
            outfit.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback for missing asset
              return Container(
                color: Theme.of(context).dividerColor.withOpacity(0.5),
                child: Center(
                  child: Icon(Icons.style_outlined, color: _primaryTextColor(context).withOpacity(0.5)),
                ),
              );
            },
          ),

          // ... (Icons and Text positioning remain unchanged) ...
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                _buildIconChip(
                  icon: Icons.favorite,
                  color: Colors.red,
                  onTap: () {
                    // 🎯 FIX: Controller से removeOutfit को कॉल करें
                    controller.removeOutfit(outfit);
                  },
                ),
                const SizedBox(width: 4),
                _buildIconChip(
                  icon: Icons.edit_outlined,
                  color: _primaryTextColor(context),
                  onTap: () {
                    Get.snackbar('Edit', 'Editing ${outfit.name}.', snackPosition: SnackPosition.TOP);
                  },
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      outfit.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // ❌ Menu Book Icon HATA DIYA GAYA HAI
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconChip({
    required IconData icon,
    required Color color,
    Color? backgroundColor,
    required VoidCallback onTap,
  }) {
    final chipBackgroundColor = backgroundColor ?? _surfaceColor(Get.context!).withOpacity(0.9);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: chipBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}