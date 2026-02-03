import 'package:smart_wardrobe_new/screens/OutfitSuggestion.dart';
import 'package:smart_wardrobe_new/screens/eventPlanner.dart';
import 'package:smart_wardrobe_new/screens/my_wardrobe.dart';
import 'package:smart_wardrobe_new/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/wardrobe_category_model.dart';
import '../models/wardrobe_item_model.dart';
import '../utils/constants/colors.dart';
import 'HomeScreen.dart';
import 'addNewItem.dart'; // 🎯 GetX Import

// --- DATA MODEL (Unchanged) ---
// enum Gender { men, women }
//
// class WardrobeCategory {
//   final String title;
//   final IconData icon;
//   final String itemImage;
//   final List<String> tags;
//   final List<Gender> genders;
//
//   WardrobeCategory({
//     required this.title,
//     required this.icon,
//     required this.itemImage,
//     required this.tags,
//     required this.genders,
//   });
// }

// --- ITEM DATA MODEL (Unchanged) ---
// class WardrobeItem {
//   final String name;
//   final String imagePath;
//   final String category;
//
//   WardrobeItem({
//     required this.name,
//     required this.imagePath,
//     required this.category,
//   });
// }

// --- MOCK DUMMY ITEM DATA (Unchanged) ---
final List<WardrobeItem> _allWardrobeItems = [
  // ... (Your dummy data remains the same)
  WardrobeItem(name: "Blue T-shirt", imagePath: 'assets/men_item_1.jpg', category: "Topwear"),
  WardrobeItem(name: "Formal Shirt", imagePath: 'assets/men_item_2.jpg', category: "Topwear"),
  WardrobeItem(name: "Polo White", imagePath: 'assets/men_item_3.jpg', category: "Topwear"),
  WardrobeItem(name: "Black Jeans", imagePath: 'assets/men_item_4.jpg', category: "Bottomwear"),
  WardrobeItem(name: "Khaki Chinos", imagePath: 'assets/men_item_5.jpg', category: "Bottomwear"),
  WardrobeItem(name: "Red Cocktail", imagePath: 'assets/women_item_1.jpg', category: "Dresses"),
  WardrobeItem(name: "Summer Maxi", imagePath: 'assets/women_item_2.jpg', category: "Dresses"),
  WardrobeItem(name: "Silk Blouse", imagePath: 'assets/women_item_4.jpg', category: "Tops/Blouses"),
  WardrobeItem(name: "Stripe Top", imagePath: 'assets/women_item_7.jpg', category: "Tops/Blouses"),
  WardrobeItem(name: "Black Heels", imagePath: 'assets/women_item_5.jpg', category: "Footwear"),
  WardrobeItem(name: "Leather Belt", imagePath: 'assets/watch.png', category: "Accessories"),
  WardrobeItem(name: "Gold Necklace", imagePath: 'assets/women_accesories.png', category: "Jewellery/Scarves"),
];

// --- APP COLORS (Only Accent needed) ---
// class AppColors {
//   static const Color accentTeal = Color(0xFF00C7B1); // Use this for accent
// }

// --- WARDROBE SCREEN (Main Categories View) ---

class MyWardrobeScreen extends StatefulWidget {
  const MyWardrobeScreen({super.key});

  @override
  State<MyWardrobeScreen> createState() => _MyWardrobeScreenState();
}

class _MyWardrobeScreenState extends State<MyWardrobeScreen> {
  Gender _selectedGender = Gender.men;
  int _selectedIndex = 1;

  // Mock data for the wardrobe (Unchanged)
  final List<WardrobeCategory> _allWardrobeData = [
    // --- Men Specific Categories ---
    WardrobeCategory(
      title: "Topwear",
      icon: Icons.checkroom_outlined,
      itemImage: 'assets/shirt.jpg',
      tags: ["Blue", "Summer", "Casual"],
      genders: [Gender.men],
    ),
    WardrobeCategory(
      title: "Bottomwear",
      icon: Icons.unfold_more,
      itemImage: 'assets/pant.png',
      tags: ["Denim", "Dark", "Slim Fit"],
      genders: [Gender.men],
    ),
    WardrobeCategory(
      title: "Footwear",
      icon: Icons.directions_walk_outlined,
      itemImage: 'assets/shoes.png',
      tags: ["White", "Sneakers", "Sport"],
      genders: [Gender.men],
    ),
    WardrobeCategory(
      title: "Accessories",
      icon: Icons.watch_outlined,
      itemImage: 'assets/watch.png',
      tags: ["Brown", "Watch", "Belt"],
      genders: [Gender.men],
    ),

    // --- Women Specific Categories ---
    WardrobeCategory(
      title: "Tops/Blouses",
      icon: Icons.checkroom,
      itemImage: 'assets/women_top.jpg',
      tags: ["Silk", "Floral", "Party"],
      genders: [Gender.women],
    ),
    WardrobeCategory(
      title: "Bottomwear (Women)",
      icon: Icons.scatter_plot_outlined,
      itemImage: 'assets/women_jeans.jpg',
      tags: ["Pleated", "High-waist", "Work"],
      genders: [Gender.women],
    ),
    WardrobeCategory(
      title: "Dresses",
      icon: Icons.woman_outlined,
      itemImage: 'assets/women_dress.jpg',
      tags: ["Maxi", "Cocktail", "Summer"],
      genders: [Gender.women],
    ),
    WardrobeCategory(
      title: "Footwear",
      icon: Icons.directions_walk_outlined,
      itemImage: 'assets/women_footwear.jpg',
      tags: ["Heels", "Sandals", "Boots"],
      genders: [Gender.women],
    ),
    WardrobeCategory(
      title: "Jewellery/Scarves",
      icon: Icons.watch_outlined,
      itemImage: 'assets/women_accesories.png',
      tags: ["Silver", "Necklace", "Scarf"],
      genders: [Gender.women],
    ),
  ];

  List<WardrobeCategory> _getFilteredWardrobeData() {
    return _allWardrobeData
        .where((category) => category.genders.contains(_selectedGender))
        .toList();
  }

  void _onGenderSelected(Gender gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  // 🎯 GetX Navigation for Bottom NavBar
  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Get.offAll(() => const HomeScreen()); // 🎯 Use Get.offAll for replacement to root
    } else if (index == 1) {
      return; // Stay on Wardrobe screen
    } else if (index == 2) {
      Get.to(() => const OutfitSuggestionScreen());
    } else if (index == 3) {
      Get.to(() => const EventPlannerScreen());
    } else if (index == 4) {
      Get.to(() => const ProfileScreen());
    }
  }

  // 🎯 Theme Getters
  Color get _primaryTextColor => Theme.of(context).textTheme.bodyLarge!.color!;
  Color get _secondaryTextColor => Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
  Color get _scaffoldColor => Theme.of(context).scaffoldBackgroundColor;
  Color get _surfaceColor => Theme.of(context).colorScheme.surface;


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.04;

    return Scaffold(
      // 🎯 Theme-Aware Background Color
      appBar: _buildAppBar(size),
      backgroundColor: _scaffoldColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: size.height * 0.01),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GenderToggle(
              selectedGender: _selectedGender,
              onGenderSelected: _onGenderSelected,
              size: size,
            ),
            SizedBox(height: size.height * 0.025),
            _buildCategoryGrid(size),
            SizedBox(height: size.height * 0.1),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFloatingActionButtons(size),
      bottomNavigationBar: _buildCustomBottomNavBar(size),
    );
  }

  // --- WIDGET BUILDERS ---

  AppBar _buildAppBar(Size size) {
    return AppBar(
      elevation: 0,
      // 🎯 AppBar Background Color Theme से आएगा
      backgroundColor: _scaffoldColor,
      toolbarHeight: size.height * 0.1,
      title: Text(
        'My Wardrobe',
        style: TextStyle(
          // 🎯 Theme-Aware Text Color
          color: _primaryTextColor,
          fontWeight: FontWeight.bold,
          fontSize: size.width * 0.055,
        ),
      ),
      centerTitle: true,
      // ❌ Calendar Icon और Profile Avatar हटा दिए गए हैं
      actions: const [],
    );
  }

  Widget _buildCategoryGrid(Size size) {
    final filteredData = _getFilteredWardrobeData();
    final double cardAspectRatio = size.width / (size.height / 0.85);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: filteredData.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: size.width * 0.04,
        mainAxisSpacing: size.height * 0.02,
        childAspectRatio: cardAspectRatio,
      ),
      itemBuilder: (context, index) {
        return _CategoryCard(
          category: filteredData[index],
          size: size,
        );
      },
    );
  }

  Widget _buildAddItemButton(Size size) {
    // 🎯 Use Accent Teal for Add Item FAB
    return FloatingActionButton(
      heroTag: 'addItemFab',
      onPressed: () {
        // 🎯 GetX Navigation
        Get.to(() => const AddItemScreen());
      },
      backgroundColor: AppColors.accentTeal.withOpacity(0.8),
      foregroundColor: Colors.white, // Text/Icon color is always white
      shape: const CircleBorder(),
      elevation: 8,
      child: Icon(Icons.add, size: size.width * 0.06),
    );
  }

  Widget _buildGenerateOutfitButton(Size size) {
    // 🎯 Theme-Aware Colors
    final accentTeal = AppColors.accentTeal;

    return FloatingActionButton.extended(
      heroTag: 'generateOutfitFab',
      onPressed: () {
        // 🎯 GetX Navigation
        Get.to(() => const OutfitSuggestionScreen());
      },
      // 🎯 Theme-Aware Background Color (Surface/Card)
      backgroundColor: _surfaceColor,
      foregroundColor: accentTeal,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.08),
        // 🎯 Theme-Aware Border
        side: BorderSide(color: _secondaryTextColor.withOpacity(0.3), width: 1.5),
      ),
      label: Text(
        'Generate Outfit',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: size.width * 0.035,
        ),
      ),
      icon: Icon(Icons.auto_fix_high, size: size.width * 0.05),
    );
  }

  Widget _buildFloatingActionButtons(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildGenerateOutfitButton(size),
        SizedBox(width: size.width * 0.03),
        _buildAddItemButton(size),
      ],
    );
  }

  Widget _buildCustomBottomNavBar(Size size) {
    const Color accentTeal = AppColors.accentTeal;
    final unselectedColor = _secondaryTextColor.withOpacity(0.7);

    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor, // 🎯 Theme-Aware Background Color
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
        selectedItemColor: accentTeal,
        unselectedItemColor: unselectedColor, // 🎯 Theme-Aware Unselected Color
        selectedLabelStyle: TextStyle(fontSize: size.width * 0.03),
        unselectedLabelStyle: TextStyle(fontSize: size.width * 0.03),
        currentIndex: _selectedIndex,
        onTap: _onNavTapped, // 🎯 Use the GetX enabled handler
        items: [
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
          // ⚠️ InkWell Removed - Navigation handled by _onNavTapped
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

// --- GENDER TOGGLE WIDGET (Theme-Aware) ---

class _GenderToggle extends StatelessWidget {
  final Gender selectedGender;
  final Function(Gender) onGenderSelected;
  final Size size;

  const _GenderToggle({
    required this.selectedGender,
    required this.onGenderSelected,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildGenderChip(context, Gender.men, "Men", Icons.male_outlined),
        SizedBox(width: size.width * 0.02),
        _buildGenderChip(context, Gender.women, "Women", Icons.female_outlined),
      ],
    );
  }

  Widget _buildGenderChip(BuildContext context, Gender gender, String label, IconData icon) {
    final bool isSelected = selectedGender == gender;
    // 🎯 Theme-Aware Colors
    final Color primaryTextColor = Theme.of(context).textTheme.bodyLarge!.color!;
    final Color secondaryTextColor = Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
    final Color surfaceColor = Theme.of(context).colorScheme.surface;

    // Using a softer accent color for chip selection (A8E6CF approx)
    final Color selectedColor = AppColors.accentTeal.withOpacity(0.5);

    final double paddingH = size.width * 0.04;
    final double paddingV = size.height * 0.012;
    final double fontSize = size.width * 0.035;

    return GestureDetector(
      onTap: () => onGenderSelected(gender),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : surfaceColor, // 🎯 Theme-Aware Color
          borderRadius: BorderRadius.circular(size.width * 0.08),
          border: Border.all(
            // 🎯 Theme-Aware Border
            color: isSelected ? selectedColor : secondaryTextColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: selectedColor.withOpacity(0.4),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: size.width * 0.05,
              // 🎯 Theme-Aware Icon Color
              color: isSelected ? primaryTextColor : secondaryTextColor,
            ),
            SizedBox(width: size.width * 0.01),
            Text(
              label,
              style: TextStyle(
                // 🎯 Theme-Aware Text Color
                color: isSelected ? primaryTextColor : secondaryTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CATEGORY CARD WIDGET (Theme-Aware) ---

class _CategoryCard extends StatelessWidget {
  final WardrobeCategory category;
  final Size size;

  const _CategoryCard({required this.category, required this.size});

  // Navigation function: Navigates from Category Grid to Item Grid
  void _navigateToItems(BuildContext context) {
    // 🎯 GetX Navigation
    Get.to(() => WardrobeItemScreen(categoryTitle: category.title));
  }

  // 🎯 Theme Getters for StatelessWidget
  Color _primaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.color!;


  @override
  Widget build(BuildContext context) {
    final double titleFontSize = size.width * 0.045;
    final double iconSize = size.width * 0.07;
    final double tagFontSize = size.width * 0.025;
    final double padding = size.width * 0.03;

    return InkWell(
      onTap: () => _navigateToItems(context),
      borderRadius: BorderRadius.circular(size.width * 0.05),
      child: Card(
        // 🎯 Card color Theme से आएगा
        color: Theme.of(context).colorScheme.surface,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.05),
        ),
        child: Container(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category Header (Icon and Title)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🎯 Theme-Aware Icon Color
                  Icon(category.icon, size: iconSize, color: _primaryTextColor(context)),
                ],
              ),
              SizedBox(height: size.height * 0.005),
              Center(
                child: Text(
                  category.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                    color: _primaryTextColor(context), // 🎯 Theme-Aware Text Color
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.01),

              // Item Image Preview (Stacked with Tags)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(size.width * 0.03),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        category.itemImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context).dividerColor.withOpacity(0.5), // 🎯 Theme-Aware Fallback BG
                            child: const Center(
                                child: Icon(Icons.image_not_supported_outlined,
                                    color: Colors.white)),
                          );
                        },
                      ),
                      // Tags Overlay (Bottom Left)
                      Positioned(
                        bottom: size.height * 0.01,
                        left: size.width * 0.01,
                        right: size.width * 0.01,
                        child: Wrap(
                          spacing: size.width * 0.015,
                          runSpacing: size.width * 0.01,
                          children: category.tags
                              .map((tag) => _buildTag(tag, tagFontSize, context)) // Pass context
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String tag, double fontSize, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.015, vertical: size.height * 0.005),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5), // Tags remain opaque black for image contrast
        borderRadius: BorderRadius.circular(size.width * 0.015),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: Colors.white, // Text remains white for contrast
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}


// --- ITEM VIEW SCREEN (The actual grid of saved items - Theme-Aware) ---

class WardrobeItemScreen extends StatelessWidget {
  final String categoryTitle;

  const WardrobeItemScreen({super.key, required this.categoryTitle});

  List<WardrobeItem> _getCategoryItems() {
    // ... filtering logic remains ...
    final targetCategoryTitle = categoryTitle.contains('Bottomwear') && categoryTitle.contains('Women') ? 'Bottomwear (Women)' : categoryTitle;
    return _allWardrobeItems
        .where((item) => item.category == categoryTitle)
        .toList();
  }

  // 🎯 Theme Getters for StatelessWidget
  Color _primaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.color!;
  Color _scaffoldColor(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
  Color _secondaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);

  @override
  Widget build(BuildContext context) {
    final List<WardrobeItem> items = _getCategoryItems();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryTitle,
          style: TextStyle(color: _primaryTextColor(context)), // 🎯 Theme-Aware Title
        ),
        // 🎯 AppBar Background Color Theme से आएगा
        backgroundColor: _scaffoldColor(context),
        elevation: 0,
        foregroundColor: _primaryTextColor(context), // 🎯 Theme-Aware Back Button Color
      ),
      backgroundColor: _scaffoldColor(context), // 🎯 Theme-Aware Background
      body: items.isEmpty
          ? Center(
        child: Text(
          'There is no item in this category',
          style: TextStyle(fontSize: 18, color: _secondaryTextColor(context)), // 🎯 Theme-Aware Text Color
        ),
      )
          : Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: size.width * 0.03,
            mainAxisSpacing: size.width * 0.03,
            childAspectRatio: 0.7,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _WardrobeItemCard(item: items[index], size: size);
          },
        ),
      ),
    );
  }
}

// --- INDIVIDUAL WARDROBE ITEM CARD WIDGET (Theme-Aware) ---

class _WardrobeItemCard extends StatelessWidget {
  final WardrobeItem item;
  final Size size;

  const _WardrobeItemCard({required this.item, required this.size});

  // 🎯 Theme Getters for StatelessWidget
  Color _primaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.color!;
  Color _surfaceColor(BuildContext context) => Theme.of(context).colorScheme.surface;

  @override
  Widget build(BuildContext context) {
    return Card(
      // 🎯 Card color Theme से आएगा
      color: _surfaceColor(context),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Item Image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(size.width * 0.03),
              ),
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).dividerColor.withOpacity(0.5), // 🎯 Theme-Aware Fallback BG
                    child: const Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: Colors.white)),
                  );
                },
              ),
            ),
          ),
          // Item Name
          Padding(
            padding: EdgeInsets.all(size.width * 0.015),
            child: Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: size.width * 0.035,
                color: _primaryTextColor(context), // 🎯 Theme-Aware Text Color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
