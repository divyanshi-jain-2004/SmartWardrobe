import 'package:smart_wardrobe_new/screens/OutfitSuggestion.dart';
import 'package:smart_wardrobe_new/screens/eventPlanner.dart';
import 'package:smart_wardrobe_new/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/wardrobe_category_model.dart';
import '../models/wardrobe_item_model.dart';
import '../utils/constants/colors.dart';
import 'HomeScreen.dart';
import 'addNewItem.dart';

final supabase = Supabase.instance.client;

// --- WARDROBE SCREEN (Main Categories View) ---

class MyWardrobeScreen extends StatefulWidget {
  const MyWardrobeScreen({super.key});

  @override
  State<MyWardrobeScreen> createState() => _MyWardrobeScreenState();
}

class _MyWardrobeScreenState extends State<MyWardrobeScreen> {
  Gender _selectedGender = Gender.men;
  int _selectedIndex = 1;

  // 🆕 Track item counts per category
  Map<String, int> _categoryItemCounts = {};
  bool _isLoadingCounts = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryCounts();
  }

  // 🆕 Load item counts for each category
  Future<void> _loadCategoryCounts() async {
    setState(() => _isLoadingCounts = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User not logged in');
        return;
      }

      // Fetch all items for this user
      final response = await supabase
          .from('wardrobe_items')
          .select('category')
          .eq('user_id', userId);

      print('📊 Fetched items: $response');

      // Count items per category
      Map<String, int> counts = {};
      for (var item in response) {
        String category = item['category'] ?? 'Unknown';
        counts[category] = (counts[category] ?? 0) + 1;
      }

      setState(() {
        _categoryItemCounts = counts;
        _isLoadingCounts = false;
      });

      print('✅ Category counts: $_categoryItemCounts');
    } catch (e) {
      print('❌ Error loading category counts: $e');
      setState(() => _isLoadingCounts = false);
    }
  }

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

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Get.offAll(() => const HomeScreen());
    } else if (index == 1) {
      return;
    } else if (index == 2) {
      Get.to(() => const OutfitSuggestionScreen());
    } else if (index == 3) {
      Get.to(() => const EventPlannerScreen());
    } else if (index == 4) {
      Get.to(() => const ProfileScreen());
    }
  }

  Color get _primaryTextColor => Theme.of(context).textTheme.bodyLarge!.color!;
  Color get _secondaryTextColor => Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
  Color get _scaffoldColor => Theme.of(context).scaffoldBackgroundColor;
  Color get _surfaceColor => Theme.of(context).colorScheme.surface;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.04;

    return Scaffold(
      appBar: _buildAppBar(size),
      backgroundColor: _scaffoldColor,
      body: _isLoadingCounts
          ? Center(child: CircularProgressIndicator(color: AppColors.accentTeal))
          : SingleChildScrollView(
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

  AppBar _buildAppBar(Size size) {
    return AppBar(
      elevation: 0,
      backgroundColor: _scaffoldColor,
      toolbarHeight: size.height * 0.1,
      title: Text(
        'My Wardrobe',
        style: TextStyle(
          color: _primaryTextColor,
          fontWeight: FontWeight.bold,
          fontSize: size.width * 0.055,
        ),
      ),
      centerTitle: true,
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
          itemCount: _categoryItemCounts[filteredData[index].title] ?? 0,
          onTap: () async {
            // 🆕 Navigate and refresh on return
            await Get.to(() => WardrobeItemScreen(
              categoryTitle: filteredData[index].title,
            ));
            _loadCategoryCounts(); // Refresh counts when returning
          },
        );
      },
    );
  }

  Widget _buildAddItemButton(Size size) {
    return FloatingActionButton(
      heroTag: 'addItemFab',
      onPressed: () async {
        // 🆕 Wait for result and refresh
        final result = await Get.to(() => const AddItemScreen());
        if (result == true) {
          _loadCategoryCounts(); // Refresh when item is added
        }
      },
      backgroundColor: AppColors.accentTeal.withOpacity(0.8),
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      elevation: 8,
      child: Icon(Icons.add, size: size.width * 0.06),
    );
  }

  Widget _buildGenerateOutfitButton(Size size) {
    final accentTeal = AppColors.accentTeal;

    return FloatingActionButton.extended(
      heroTag: 'generateOutfitFab',
      onPressed: () {
        Get.to(() => const OutfitSuggestionScreen());
      },
      backgroundColor: _surfaceColor,
      foregroundColor: accentTeal,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.08),
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
        color: _surfaceColor,
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
        unselectedItemColor: unselectedColor,
        selectedLabelStyle: TextStyle(fontSize: size.width * 0.03),
        unselectedLabelStyle: TextStyle(fontSize: size.width * 0.03),
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: 'Wardrobe'),
          BottomNavigationBarItem(icon: Icon(Icons.star_half_rounded), label: 'AI Stylist'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Planner'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

// --- GENDER TOGGLE WIDGET ---

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
    final Color primaryTextColor = Theme.of(context).textTheme.bodyLarge!.color!;
    final Color secondaryTextColor = Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
    final Color surfaceColor = Theme.of(context).colorScheme.surface;
    final Color selectedColor = AppColors.accentTeal.withOpacity(0.5);

    final double paddingH = size.width * 0.04;
    final double paddingV = size.height * 0.012;
    final double fontSize = size.width * 0.035;

    return GestureDetector(
      onTap: () => onGenderSelected(gender),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : surfaceColor,
          borderRadius: BorderRadius.circular(size.width * 0.08),
          border: Border.all(
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
              color: isSelected ? primaryTextColor : secondaryTextColor,
            ),
            SizedBox(width: size.width * 0.01),
            Text(
              label,
              style: TextStyle(
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

// --- CATEGORY CARD WIDGET ---

class _CategoryCard extends StatelessWidget {
  final WardrobeCategory category;
  final Size size;
  final int itemCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.size,
    required this.itemCount,
    required this.onTap,
  });

  Color _primaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.color!;

  @override
  Widget build(BuildContext context) {
    final double titleFontSize = size.width * 0.045;
    final double iconSize = size.width * 0.07;
    final double tagFontSize = size.width * 0.025;
    final double padding = size.width * 0.03;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size.width * 0.05),
      child: Card(
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
              // 🆕 Item count badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(category.icon, size: iconSize, color: _primaryTextColor(context)),
                  if (itemCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.02,
                        vertical: size.height * 0.003,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentTeal,
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                      ),
                      child: Text(
                        '$itemCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: size.height * 0.005),
              Center(
                child: Text(
                  category.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                    color: _primaryTextColor(context),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.01),
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
                            color: Theme.of(context).dividerColor.withOpacity(0.5),
                            child: const Center(
                                child: Icon(Icons.image_not_supported_outlined,
                                    color: Colors.white)),
                          );
                        },
                      ),
                      Positioned(
                        bottom: size.height * 0.01,
                        left: size.width * 0.01,
                        right: size.width * 0.01,
                        child: Wrap(
                          spacing: size.width * 0.015,
                          runSpacing: size.width * 0.01,
                          children: category.tags
                              .map((tag) => _buildTag(tag, tagFontSize, context))
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
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(size.width * 0.015),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// --- ITEM VIEW SCREEN (Fetches from Supabase) ---

class WardrobeItemScreen extends StatefulWidget {
  final String categoryTitle;

  const WardrobeItemScreen({super.key, required this.categoryTitle});

  @override
  State<WardrobeItemScreen> createState() => _WardrobeItemScreenState();
}

class _WardrobeItemScreenState extends State<WardrobeItemScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // 🆕 Fetch items from Supabase
  Future<void> _loadItems() async {
    setState(() => _isLoading = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User not logged in');
        return;
      }

      print('📥 Fetching items for category: ${widget.categoryTitle}');

      final response = await supabase
          .from('wardrobe_items')
          .select('*')
          .eq('user_id', userId)
          .eq('category', widget.categoryTitle)
          .order('created_at', ascending: false);

      print('✅ Fetched ${response.length} items');

      setState(() {
        _items = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading items: $e');
      setState(() => _isLoading = false);
    }
  }

  Color _primaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.color!;
  Color _scaffoldColor(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
  Color _secondaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryTitle,
          style: TextStyle(color: _primaryTextColor(context)),
        ),
        backgroundColor: _scaffoldColor(context),
        elevation: 0,
        foregroundColor: _primaryTextColor(context),
      ),
      backgroundColor: _scaffoldColor(context),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accentTeal))
          : _items.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom_outlined,
              size: size.width * 0.2,
              color: _secondaryTextColor(context),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'No items in this category yet',
              style: TextStyle(
                fontSize: size.width * 0.045,
                color: _secondaryTextColor(context),
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              'Tap + to add your first item',
              style: TextStyle(
                fontSize: size.width * 0.035,
                color: _secondaryTextColor(context),
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        color: AppColors.accentTeal,
        onRefresh: _loadItems,
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: size.width * 0.03,
              mainAxisSpacing: size.width * 0.03,
              childAspectRatio: 0.7,
            ),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return _WardrobeItemCard(
                item: _items[index],
                size: size,
                onDelete: () async {
                  await _deleteItem(_items[index]['id']);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // 🆕 Delete item from Supabase
  Future<void> _deleteItem(int itemId) async {
    try {
      await supabase.from('wardrobe_items').delete().eq('id', itemId);

      Get.snackbar(
        'Deleted',
        'Item removed from wardrobe',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      _loadItems(); // Refresh the list
    } catch (e) {
      print('❌ Error deleting item: $e');
      Get.snackbar(
        'Error',
        'Failed to delete item',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
}

// --- INDIVIDUAL WARDROBE ITEM CARD WIDGET ---

class _WardrobeItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Size size;
  final VoidCallback onDelete;

  const _WardrobeItemCard({
    required this.item,
    required this.size,
    required this.onDelete,
  });

  Color _primaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.color!;
  Color _surfaceColor(BuildContext context) => Theme.of(context).colorScheme.surface;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Item?'),
            content: Text('Remove "${item['item_name']}" from wardrobe?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDelete();
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Card(
        color: _surfaceColor(context),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.03),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(size.width * 0.03),
                ),
                child: Image.network(
                  item['image_url'] ?? '',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppColors.accentTeal,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.015),
              child: Text(
                item['item_name'] ?? 'Unnamed',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: size.width * 0.035,
                  color: _primaryTextColor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}