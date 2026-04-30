import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_wardrobe_new/controllers/outfit_controller.dart';
import 'package:smart_wardrobe_new/models/outfit_model.dart';
import '../utils/constants/colors.dart';

class OutfitSuggestionScreen extends StatefulWidget {
  final String? initialOutfitName;
  final String? initialOutfitImagePath;

  const OutfitSuggestionScreen({super.key, this.initialOutfitName, this.initialOutfitImagePath});

  @override
  State<OutfitSuggestionScreen> createState() => _OutfitSuggestionScreenState();
}

class _OutfitSuggestionScreenState extends State<OutfitSuggestionScreen> {
  final OutfitController outfitController = Get.find<OutfitController>();
  late bool _isViewingSavedOutfit;
  late String _displayedOutfitName;
  late String _displayedOutfitAssetPath;
  int _currentOutfitIndex = 0;
  bool _isLiked = false;

  // 🎯 FIX: Cache GetStorage outside build to avoid disk reads on every rebuild
  final _box = GetStorage();

  @override
  void initState() {
    super.initState();
    if (widget.initialOutfitName != null && widget.initialOutfitImagePath != null) {
      _displayedOutfitName = widget.initialOutfitName!;
      _displayedOutfitAssetPath = widget.initialOutfitImagePath!;
      _isViewingSavedOutfit = true;
    } else {
      _isViewingSavedOutfit = false;
      _displayedOutfitName = 'Generating...';
      _displayedOutfitAssetPath = '';

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await outfitController.generateAIOutfits();
        if (outfitController.generatedOutfits.isNotEmpty) {
          _updateDisplayFromGenerated();
        }
      });
    }
  }

  void _updateDisplayFromGenerated() {
    if (outfitController.generatedOutfits.isEmpty) return;
    var combo = outfitController.generatedOutfits[_currentOutfitIndex];
    setState(() {
      _displayedOutfitName = combo['name'] ?? 'Stylish Outfit';
      _displayedOutfitAssetPath = '${combo['top']['image_url']},${combo['bottom']['image_url']}';
    });
  }

  String _getCurrentCategory() {
    if (outfitController.generatedOutfits.isEmpty) return 'Fashion';
    var combo = outfitController.generatedOutfits[_currentOutfitIndex];
    return combo['bottom']?['category'] ?? 'Jeans';
  }

  void _loadNextOutfit() {
    if (_isViewingSavedOutfit) {
      _isViewingSavedOutfit = false;
      _currentOutfitIndex = 0;
    } else if (outfitController.generatedOutfits.isNotEmpty) {
      _currentOutfitIndex = (_currentOutfitIndex + 1) % outfitController.generatedOutfits.length;
    }
    _isLiked = false; // Reset liked state for new outfit
    if (outfitController.generatedOutfits.isNotEmpty && !_isViewingSavedOutfit) {
      _updateDisplayFromGenerated();
    }
  }

  void _skipOutfit() {
    setState(() => _loadNextOutfit());
    Get.snackbar(
      'Refreshing',
      'Scanning your wardrobe for a better match...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.7),
      colorText: Colors.white,
      icon: const Icon(Icons.auto_awesome, color: AppColors.accentTeal),
    );
  }

  void _saveOutfit() {
    if (_isLiked) return; // Already saved

    final newOutfit = OutfitModel(
      name: _displayedOutfitName,
      imageUrl: _displayedOutfitAssetPath,
      season: 'Current',
      gender: 'F',
    );
    outfitController.addOutfit(newOutfit);
    setState(() {
      _isLiked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('AI STYLIST', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black87)),
        // leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87), onPressed: () => Get.back()),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFDFCFB), Color(0xFFE2D1C3)], begin: Alignment.topLeft, end: Alignment.bottomRight)))),
          SafeArea(
            child: Obx(() {
              if (outfitController.isGenerating.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.accentTeal));
              }

              // Handle case where no outfits are available and not viewing a saved one
              if (outfitController.generatedOutfits.isEmpty && !_isViewingSavedOutfit) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        "No outfits found.\nAdd more items to your wardrobe!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal),
                        child: const Text("Go Back", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                );
              }

              // 🎯 FIX: Use cached _box instead of creating new GetStorage() in build
              final String profileGender = _box.read('user_gender') ?? 'Women';

              // Safely get currentCombo
              final currentCombo = outfitController.generatedOutfits.isNotEmpty
                  ? outfitController.generatedOutfits[_currentOutfitIndex % outfitController.generatedOutfits.length]
                  : null;

              String currentGender = currentCombo?['gender'] ??
                  currentCombo?['bottom']?['gender'] ??
                  'Women';

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: OutfitCard(outfitName: _displayedOutfitName, outfitImagePath: _displayedOutfitAssetPath),
                    ),
                    const SizedBox(height: 32),
                    _buildControlPanel(),
                    const SizedBox(height: 40),


                    if (currentCombo != null)

                      ShoppableGrid(
                        // 1. Get the category from the bottom (e.g., 'Jeans')
                        topCategory: currentCombo['top']?['category'] ?? 'Tops',
                        bottomCategory: currentCombo['bottom']?['category'] ?? 'Jeans',

                        // 2. Get the sub_type from the recommendation (e.g., 'Wide Leg')
                        subType: currentCombo['sub_type'] ?? '',

                        // 3. Get gender (Use your GetStorage or currentCombo metadata)
                        gender:profileGender,
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _skipOutfit,
            child: Container(
              height: 65,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.refresh_rounded, color: Colors.grey), SizedBox(width: 10), Text("Next Look")]),
            ),
          ),
        ),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: _saveOutfit,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 65, width: 75,
            decoration: BoxDecoration(
              gradient: _isLiked
                  ? const LinearGradient(colors: [Colors.redAccent, Colors.red], begin: Alignment.topLeft, end: Alignment.bottomRight)
                  : const LinearGradient(colors: [AppColors.accentTeal, Color(0xFF00A392)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (_isLiked ? Colors.red : AppColors.accentTeal).withValues(alpha:0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Icon(_isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }
}

class ShoppableGrid extends StatelessWidget {
  final String topCategory;    // 🎯 Added
  final String bottomCategory;
  final String subType;
  final String gender;

  const ShoppableGrid({
    super.key,

    required this.subType,
    required this.gender, required this.topCategory, required this.bottomCategory,
  });

  @override
  Widget build(BuildContext context) {
    // 🎯 FIX: Use FutureBuilder instead of StreamBuilder to avoid continuous streaming on main thread
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client
          .from('shopping_deals')
          .select()
          .eq('gender', gender)
          .limit(20)
          .then((data) => List<Map<String, dynamic>>.from(data)),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text("Error: ${snapshot.error}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<Map<String, dynamic>> allItems = snapshot.data ?? [];

        // 🎯 FIX: Removed all print() debug statements that were doing I/O on main thread

        // 🎯 1. FILTER LOGIC
        // This matches 'Jeans' with 'Jeans' and 'Women' with 'Women'
        final filteredItems = allItems.where((item) {
          String dbCat = (item['category'] ?? "").toString().toLowerCase().trim();
          String targetTop = topCategory.toLowerCase().trim();
          String targetBottom = bottomCategory.toLowerCase().trim();

          // Match if it's a top OR a bottom for this outfit
          return dbCat == targetTop || dbCat == targetBottom;
        }).toList();
        // 🎯 FIX: Removed filteredItems.shuffle() — shuffling inside build() causes
        // unnecessary main thread work on every rebuild. The list order from DB is fine.

        if (filteredItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Text(
                "No items found for $gender's $topCategory",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          );
        }

        // 🎯 3. UI RENDERING
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Shop the Look",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredItems.length, // ✅ Use filtered length
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                // ✅ Use the specific filtered item
                return _buildProductCard(filteredItems[index]);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(item['link']), mode: LaunchMode.externalApplication),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  item['image_url'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['platform'].toString().toUpperCase(),
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  Text(
                    item['item_name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₹${item['price']}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OutfitCard extends StatelessWidget {
  final String outfitName;
  final String outfitImagePath;
  const OutfitCard({required this.outfitName, required this.outfitImagePath, super.key});

  @override
  Widget build(BuildContext context) {
    List<String> images = outfitImagePath.split(',');
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: Container(
                color: const Color(0xFFF4F4F4),
                child: images.length > 1
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(child: _buildImage(images[0])),
                  Expanded(child: _buildImage(images[1])),
                ])
                    : _buildImage(images[0]),
              ),
            ),
            _buildInfoPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("PERFECT MATCH", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.accentTeal)),
        const SizedBox(height: 8),
        Text(outfitName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      ]),
    );
  }

  Widget _buildImage(String path) {
    if (path.isEmpty) return const SizedBox();

    // 🎯 Use Image.network for Supabase URLs
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        // 🛡️ FIX: This catches the 400 error and shows an icon instead of an exception
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFF4F4F4), // Match your card background
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey,
                size: 40,
              ),
            ),
          );
        },
        // 🌀 Optional: Show a tiny spinner while the image loads
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey,
            ),
          );
        },
      );
    }

    // Use Image.asset for your local mock images
    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
    );
  }
}