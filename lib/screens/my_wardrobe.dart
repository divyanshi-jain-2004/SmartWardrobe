
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_wardrobe_new/controllers/wardrobe_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/wardrobe_category_model.dart';
import '../models/wardrobe_item_model.dart';
import '../utils/constants/colors.dart';
import 'addNewItem.dart';

final supabase = Supabase.instance.client;

class MyWardrobeScreen extends StatefulWidget {
  const MyWardrobeScreen({super.key});

  @override
  State<MyWardrobeScreen> createState() => _MyWardrobeScreenState();
}

class _MyWardrobeScreenState extends State<MyWardrobeScreen> {


  final WardrobeController wardrobeController = Get.find<WardrobeController>();
  Map<String, int> _categoryItemCounts = {};
  bool _isLoadingCounts = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryCounts();
  }

  Future<void> _loadCategoryCounts() async {
    setState(() => _isLoadingCounts = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('wardrobe_items')
          .select('category')
          .eq('user_id', userId);

      Map<String, int> counts = {};
      for (var item in response) {
        String category = item['category'] ?? 'Unknown';
        counts[category] = (counts[category] ?? 0) + 1;
      }

      print('MyWardrobe counts response: $response');
      setState(() {
        _categoryItemCounts = counts;
        _isLoadingCounts = false;
      });
    } catch (e) {
      print('MyWardrobe counts error: $e');
      setState(() => _isLoadingCounts = false);
    }
  }

  List<WardrobeCategory> _getFilteredWardrobeData() {
    return wardrobeController.categories;
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 DYNAMIC THEME COLORS
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      // extendBody set to true to handle the floating nav bar from the parent shell
      extendBody: true,
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: CircleAvatar(
                radius: 150,
                backgroundColor: AppColors.accentTeal.withValues(alpha:isDark ? 0.1 : 0.05)
            ),
          ),

          SafeArea(
            bottom: false,
            child: _isLoadingCounts
                ? Center(child: CircularProgressIndicator(color: AppColors.accentTeal))
                : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Collections", style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
                            Text("My Wardrobe", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1, color: textColor)),
                          ],
                        ),
                        // _buildHeaderAction(Icons.search_rounded, cardColor, textColor),
                      ],
                    ),
                  ),
                ),

                // Removed GenderToggle Sliver


                SliverPadding(
                  // Added bottom padding (150) to ensure content isn't hidden behind the floating bar
                  padding: const EdgeInsets.fromLTRB(25, 10, 25, 150),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 25,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final filteredData = _getFilteredWardrobeData();
                        return _CategoryCard(
                          category: filteredData[index],
                          itemCount: _categoryItemCounts[filteredData[index].title] ?? 0,
                          isDark: isDark,
                          onTap: () async {
                            await Get.to(() => WardrobeItemScreen(categoryTitle: filteredData[index].title));
                            _loadCategoryCounts();
                          },
                        );
                      },
                      childCount: _getFilteredWardrobeData().length,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Local Add Button (Optional: Keep it here or move it to the Shell)
          Positioned(
            bottom: 120,
            right: 25,
            child: FloatingActionButton(
              heroTag: 'add_item',
              onPressed: () async {
                final result = await Get.to(() => const AddItemScreen());
                if (result == true) _loadCategoryCounts();
              },
              backgroundColor: AppColors.accentTeal,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
      // REMOVED: bottomNavigationBar. It is now provided by the HomeScreen shell.
    );
  }

  Widget _buildHeaderAction(IconData icon, Color bg, Color iconCol) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.1), blurRadius: 10)],
      ),
      child: Icon(icon, color: iconCol, size: 24),
    );
  }
}

// ... _GenderToggle, _CategoryCard, and WardrobeItemScreen remain below ...

// --- GENDER TOGGLE REMOVED ---

// --- PREMIUM CATEGORY CARD ---
class _CategoryCard extends StatelessWidget {
  final WardrobeCategory category;
  final int itemCount;
  final VoidCallback onTap;
  final bool isDark;

  const _CategoryCard({required this.category, required this.itemCount, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:isDark ? 0.3 : 0.1), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(category.itemImage, fit: BoxFit.cover),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha:0.8)],
                ),
              ),
            ),
            Positioned(
              top: 15, left: 15,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: isDark ? Colors.black45 : Colors.white.withValues(alpha:0.9),
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Icon(category.icon, size: 18, color: AppColors.accentTeal),
              ),
            ),
            Positioned(
              bottom: 45, left: 15,
              child: Text(
                "$itemCount Items",
                style: TextStyle(color: AppColors.accentTeal.withValues(alpha:0.9), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              bottom: 15, left: 15, right: 15,
              child: Text(
                category.title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WARDROBE ITEM SCREEN ---
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

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      final response = await supabase
          .from('wardrobe_items')
          .select('*')
          .eq('user_id', userId!)
          .eq('category', widget.categoryTitle);

      print('WardrobeItemScreen response for ${widget.categoryTitle}: $response');
      setState(() {
        _items = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e, stacktrace) {
      print('WardrobeItemScreen load error: $e');
      print(stacktrace);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    final itemId = item['id'];
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmDelete) return;

    try {
      // 1. Detele from DB and verify it was deleted by returning the row
      final response = await supabase.from('wardrobe_items').delete().eq('id', itemId).select();

      // If it returned empty, it means no row was matched/deleted (maybe due to RLS)
      if (response.isEmpty) {
        throw Exception('Item could not be deleted from database.');
      }

      // 2. Try to delete the image from storage to free up space
      try {
        final imageUrl = item['image_url'] as String?;
        if (imageUrl != null && imageUrl.contains('wardrobe_image/')) {
          // Extract the path after 'wardrobe_image/'
          final pathParts = imageUrl.split('wardrobe_image/');
          if (pathParts.length > 1) {
            final storagePath = pathParts[1];
            await supabase.storage.from('wardrobe_image').remove([storagePath]);
            print('Deleted from storage: $storagePath');
          }
        }
      } catch (e) {
        print('Warning: Failed to delete image from storage: $e');
        // We don't throw here, as the row was successfully deleted
      }

      setState(() {
        _items.removeWhere((element) => element['id'] == itemId);
      });

      // 3. ✨ CRITICAL: Update the global WardrobeController so the Home Screen Stats refresh
      if (Get.isRegistered<WardrobeController>()) {
        Get.find<WardrobeController>().fetchCounts();
      }

      Get.snackbar(
        'Success',
        'Item deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha:0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      print('Delete error: $e');
      Get.snackbar(
        'Error',
        'Failed to delete item',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha:0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(widget.categoryTitle, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        centerTitle: true,
        backgroundColor: scaffoldBg,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.8,
          ),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark ? Colors.white.withValues(alpha:0.05) : Colors.grey[100],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(item['image_url'], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _deleteItem(item),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha:0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(item['item_name'], style: TextStyle(fontWeight: FontWeight.bold, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}