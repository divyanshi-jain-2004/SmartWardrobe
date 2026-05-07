import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:smart_wardrobe_new/models/outfit_model.dart';
import 'package:smart_wardrobe_new/controllers/outfit_controller.dart';
import 'package:smart_wardrobe_new/screens/HomeScreen.dart';
import 'package:smart_wardrobe_new/screens/OutfitSuggestion.dart';
import 'package:smart_wardrobe_new/screens/profile.dart';

import '../utils/constants/colors.dart';



class SavedOutfitsScreen extends GetView<OutfitController> {

  const SavedOutfitsScreen({super.key});

  Color _primaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.color!;
  Color _secondaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
  Color _surfaceColor(BuildContext context) => Theme.of(context).colorScheme.surface;
  Color _scaffoldColor(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;


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
      items:  <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_)=>HomeScreen()));
          },
            child: Icon(Icons.home_outlined)), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), label: 'Outfits'),
        BottomNavigationBarItem(icon: InkWell(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=>ProfileScreen()));
          },
            child: Icon(Icons.person_outline)), label: 'Profile'),
      ],
    );
  }

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {

    return Obx(() {

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

      );
    });
  }
}


class _OutfitCard extends StatelessWidget {
  final OutfitModel outfit;

  const _OutfitCard({required this.outfit});

  Color _primaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.color!;
  Color _surfaceColor(BuildContext context) => Theme.of(context).colorScheme.surface;
  Color _dividerColor(BuildContext context) => Theme.of(context).dividerColor;


  @override
  Widget build(BuildContext context) {

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

          Builder(
            builder: (context) {
              final images = outfit.imageUrl.split(',');
              return Column(
                children: images.map((path) {
                  return Expanded(
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFF4F4F4),
                      child: path.startsWith('http')
                          ? Image.network(
                              path,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                            )
                          : Image.asset(
                              path,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                    ),
                  );
                }).toList(),
              );
            },
          ),


          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                _buildIconChip(
                  icon: Icons.favorite,
                  color: Colors.red,
                  onTap: () {

                    controller.removeOutfit(outfit);
                  },
                ),
                const SizedBox(width: 4),

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