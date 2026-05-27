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
  final Map<String, dynamic>? initialOutfitData;

  const OutfitSuggestionScreen({
    super.key,
    this.initialOutfitName,
    this.initialOutfitImagePath,
    this.initialOutfitData,
  });

  @override
  State<OutfitSuggestionScreen> createState() => _OutfitSuggestionScreenState();
}

class _OutfitSuggestionScreenState extends State<OutfitSuggestionScreen> {
  final OutfitController outfitController = Get.find<OutfitController>();
  late bool _isViewingSavedOutfit;
  late String _displayedOutfitName;
  late String _displayedOutfitAssetPath;
  late String _displayedWeatherLabel;
  int _currentOutfitIndex = 0;
  bool _isLiked = false;
  Map<String, dynamic>? _activeCombo;

  // 🎯 FIX: Cache GetStorage outside build to avoid disk reads on every rebuild
  final _box = GetStorage();

  @override
  void initState() {
    super.initState();
    if (widget.initialOutfitData != null) {
      final combo = widget.initialOutfitData!;
      _activeCombo = combo;
      final top = (combo['top'] as Map<String, dynamic>? ?? {});
      final bottom = (combo['bottom'] as Map<String, dynamic>? ?? {});
      final footwear = (combo['footwear'] as Map<String, dynamic>? ?? {});
      final topName = (top['item_name'] ?? '').toString().trim();
      final bottomName = (bottom['item_name'] ?? '').toString().trim();
      final footwearName = (footwear['item_name'] ?? '').toString().trim();
      final topImage = (top['image_url'] ?? '').toString().trim();
      final bottomImage = (bottom['image_url'] ?? '').toString().trim();
      final footwearImage = (footwear['image_url'] ?? '').toString().trim();

      _displayedOutfitName = [
        topName,
        bottomName,
        footwearName,
      ].where((name) => name.isNotEmpty).join(' & ');
      _displayedOutfitAssetPath = [
        topImage,
        bottomImage,
        footwearImage,
      ].where((img) => img.isNotEmpty && img != 'null').join(',');
      _displayedWeatherLabel = (combo['season'] ?? 'Current').toString();
      _isViewingSavedOutfit = true;
    } else if (widget.initialOutfitName != null &&
        widget.initialOutfitImagePath != null) {
      _displayedOutfitName = widget.initialOutfitName!;
      _displayedOutfitAssetPath = widget.initialOutfitImagePath!;
      _displayedWeatherLabel = 'Current';
      _isViewingSavedOutfit = true;
      _activeCombo = null;
    } else {
      _isViewingSavedOutfit = false;
      _displayedOutfitName = 'Generating...';
      _displayedOutfitAssetPath = '';
      _displayedWeatherLabel = 'Current';
      _activeCombo = null;

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
    final combo = outfitController.generatedOutfits[_currentOutfitIndex];
    final top = (combo['top'] as Map<String, dynamic>? ?? {});
    final bottom = (combo['bottom'] as Map<String, dynamic>? ?? {});
    final footwear = (combo['footwear'] as Map<String, dynamic>? ?? {});
    final topName = (top['item_name'] ?? '').toString().trim();
    final bottomName = (bottom['item_name'] ?? '').toString().trim();
    final footwearName = (footwear['item_name'] ?? '').toString().trim();
    final topColor = (top['color'] ?? '').toString().trim();
    final bottomColor = (bottom['color'] ?? '').toString().trim();
    final footwearColor = (footwear['color'] ?? '').toString().trim();
    final topImage = (top['image_url'] ?? '').toString().trim();
    final bottomImage = (bottom['image_url'] ?? '').toString().trim();
    final footwearImage = (footwear['image_url'] ?? '').toString().trim();
    final weather = (combo['season'] ?? 'Current').toString().trim();

    final displayTop =
        topName.isNotEmpty
            ? topName
            : (topColor.isNotEmpty ? '$topColor Top' : 'Top');
    final displayBottom =
        bottomName.isNotEmpty
            ? bottomName
            : (bottomColor.isNotEmpty ? '$bottomColor Bottom' : 'Bottom');
    final displayFootwear =
        footwearName.isNotEmpty
            ? footwearName
            : (footwearColor.isNotEmpty ? '$footwearColor Footwear' : '');
    final mergedImagePath = [
      topImage,
      bottomImage,
      footwearImage,
    ].where((img) => img.isNotEmpty && img != 'null').join(',');

    setState(() {
      _activeCombo = combo;
      _displayedOutfitName = [
        displayTop,
        displayBottom,
        displayFootwear,
      ].where((name) => name.isNotEmpty).join(' & ');
      _displayedOutfitAssetPath = mergedImagePath;
      _displayedWeatherLabel = weather.isNotEmpty ? weather : 'Current';
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
      _currentOutfitIndex =
          (_currentOutfitIndex + 1) % outfitController.generatedOutfits.length;
    }
    _isLiked = false; // Reset liked state for new outfit
    if (outfitController.generatedOutfits.isNotEmpty &&
        !_isViewingSavedOutfit) {
      _updateDisplayFromGenerated();
    }
  }

  void _skipOutfit() {
    setState(() => _loadNextOutfit());
    Get.snackbar(
      'Refreshing',
      'Scanning your wardrobe for a better match...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      colorText: Colors.white,
      icon: const Icon(Icons.auto_awesome, color: AppColors.accentTeal),
    );
  }

  void _saveOutfit() {
    if (_isLiked) return; // Already saved

    final newOutfit = OutfitModel(
      name: _displayedOutfitName,
      imageUrl: _displayedOutfitAssetPath,
      season: _displayedWeatherLabel,
      gender: 'F',
    );
    outfitController.addOutfit(newOutfit);
    setState(() {
      _isLiked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'AI STYLIST',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                      : [const Color(0xFFFDFCFB), const Color(0xFFE2D1C3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Obx(() {
              if (outfitController.isGenerating.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accentTeal),
                );
              }

              // Handle case where no outfits are available and not viewing a saved one
              if (outfitController.generatedOutfits.isEmpty &&
                  !_isViewingSavedOutfit) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.sentiment_dissatisfied,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No outfits found.\nAdd more items to your wardrobe!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentTeal,
                        ),
                        child: const Text(
                          "Go Back",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // 🎯 FIX: Use cached _box instead of creating new GetStorage() in build
              final String rawGender = _box.read('gender') ?? 'Female';
              final String profileGender =
                  (rawGender.toLowerCase() == 'male' ||
                          rawGender.toLowerCase() == 'men')
                      ? 'Men'
                      : 'Women';

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: OutfitCard(
                        outfitName: _displayedOutfitName,
                        outfitImagePath: _displayedOutfitAssetPath,
                        weatherLabel: _displayedWeatherLabel,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildControlPanel(),
                    const SizedBox(height: 40),

                    ShoppableGrid(
                      activeCombo: _activeCombo,
                      gender: profileGender,
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _skipOutfit,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isDark ? Border.all(color: Colors.white10) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, color: isDark ? Colors.white70 : Colors.grey),
                  const SizedBox(width: 10),
                  Text(
                    "Next Look",
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: _saveOutfit,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 65,
            width: 75,
            decoration: BoxDecoration(
              gradient:
                  _isLiked
                      ? const LinearGradient(
                        colors: [Colors.redAccent, Colors.red],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                      : const LinearGradient(
                        colors: [AppColors.accentTeal, Color(0xFF00A392)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (_isLiked ? Colors.red : AppColors.accentTeal)
                      .withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}

class ShoppableGrid extends StatefulWidget {
  final Map<String, dynamic>? activeCombo;
  final String gender;

  const ShoppableGrid({super.key, this.activeCombo, required this.gender});

  @override
  State<ShoppableGrid> createState() => _ShoppableGridState();
}

class _ShoppableGridState extends State<ShoppableGrid> {
  late Future<List<List<Map<String, dynamic>>>> _dealsFuture;
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDeals();
  }

  @override
  void didUpdateWidget(covariant ShoppableGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeCombo != widget.activeCombo ||
        oldWidget.gender != widget.gender) {
      _loadDeals();
      _activeTabIndex = 0;
    }
  }

  void _loadDeals() {
    final gender = widget.gender;
    _dealsFuture = Future.wait([
      // Tops
      Supabase.instance.client
          .from('shopping_deals')
          .select()
          .eq('gender', gender)
          .inFilter('category', [
            'Tops',
            'tops',
            'T-Shirt',
            't-shirt',
            'Outerwear',
            'outerwear',
            'Topwear',
            'topwear',
          ])
          .limit(50)
          .then((d) => List<Map<String, dynamic>>.from(d)),
      // Bottoms
      Supabase.instance.client
          .from('shopping_deals')
          .select()
          .eq('gender', gender)
          .inFilter('category', [
            'Jeans',
            'jeans',
            'Bottomwear',
            'bottomwear',
            'Bottoms',
            'bottoms',
          ])
          .limit(50)
          .then((d) => List<Map<String, dynamic>>.from(d)),
    ]);
  }

  bool _isWrongGender(String itemName, String targetGender) {
    final name = itemName.toLowerCase();
    if (targetGender == 'Women') {
      // We want Women's items. If name contains "men" but NOT "women" (or "woman"), it's probably a men's item!
      // Also check for "boy" or "boys".
      final hasMen = name.contains('men') && !name.contains('women');
      final hasMan = name.contains('man') && !name.contains('woman');
      final hasBoy = name.contains('boy') && !name.contains('tomboy');
      return hasMen || hasMan || hasBoy;
    } else if (targetGender == 'Men') {
      // We want Men's items. If name contains "women" or "woman" or "girl" or "lady" or "ladies", it's probably a women's item!
      final hasWomen = name.contains('women') || name.contains('woman');
      final hasGirl = name.contains('girl');
      final hasLady = name.contains('lady') || name.contains('ladies');
      return hasWomen || hasGirl || hasLady;
    }
    return false;
  }

  List<Map<String, dynamic>> _scoreAndSortItems(
    List<Map<String, dynamic>> items,
    Map<String, dynamic>? outfitPart,
  ) {
    if (outfitPart == null) return items;

    final partColor =
        (outfitPart['color'] ?? '').toString().toLowerCase().trim();
    final partSubType =
        (outfitPart['sub_type'] ?? '').toString().toLowerCase().trim();
    final partName =
        (outfitPart['item_name'] ?? '').toString().toLowerCase().trim();

    final scoredItems =
        items.map((item) {
          int score = 0;
          final itemName = (item['item_name'] ?? '').toString().toLowerCase();
          final dbSubType = (item['sub_type'] ?? '').toString().toLowerCase();

          // 1. Subtype match
          if (partSubType.isNotEmpty) {
            if (dbSubType.contains(partSubType) ||
                partSubType.contains(dbSubType)) {
              score += 15;
            }
            if (itemName.contains(partSubType)) {
              score += 10;
            }
          }

          // 2. Color match
          if (partColor.isNotEmpty) {
            if (itemName.contains(partColor)) {
              score += 8;
            }
          }

          // 3. Name word matches
          if (partName.isNotEmpty) {
            final nameWords = partName.split(' ').where((w) => w.length > 2);
            for (var word in nameWords) {
              if (itemName.contains(word)) {
                score += 2;
              }
            }
          }

          return {...item, '_matchScore': score};
        }).toList();

    // Sort by score descending
    scoredItems.sort(
      (a, b) => (b['_matchScore'] as int).compareTo(a['_matchScore'] as int),
    );
    return scoredItems;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<List<List<Map<String, dynamic>>>>(
      future: _dealsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text("Error: ${snapshot.error}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(color: AppColors.accentTeal),
            ),
          );
        }

        final List<List<Map<String, dynamic>>> data = snapshot.data ?? [[], []];
        final rawTops = data[0];
        final rawBottoms = data[1];

        // Retrieve parts from combo
        final topPart = widget.activeCombo?['top'];
        final bottomPart = widget.activeCombo?['bottom'];

        // Filter out items of the wrong gender (impurity fix)
        final rawTopsFiltered =
            rawTops
                .where(
                  (item) =>
                      !_isWrongGender(item['item_name'] ?? '', widget.gender),
                )
                .toList();
        final rawBottomsFiltered =
            rawBottoms
                .where(
                  (item) =>
                      !_isWrongGender(item['item_name'] ?? '', widget.gender),
                )
                .toList();

        // Score and sort items
        final tops = _scoreAndSortItems(rawTopsFiltered, topPart);
        final bottoms = _scoreAndSortItems(rawBottomsFiltered, bottomPart);

        // Filter tabs if it's a dress
        final bool isDress = widget.activeCombo?['is_dress'] ?? false;
        final List<String> tabLabels =
            isDress
                ? ['✨ Complete Look', '👗 Dresses']
                : ['✨ Complete Look', '👕 Tops', '👖 Bottoms'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.accentTeal, size: 22),
                const SizedBox(width: 8),
                Text(
                  "Shop the Look",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Premium category pill selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(tabLabels.length, (index) {
                  final isSelected = _activeTabIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTabIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              isSelected
                                  ? const LinearGradient(
                                    colors: [
                                      AppColors.accentTeal,
                                      Color(0xFF00ADB5),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                  : null,
                          color: isSelected ? null : (isDark ? AppColors.darkCard : Colors.white),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.transparent
                                    : (isDark ? Colors.white10 : Colors.grey.shade200),
                            width: 1.5,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: AppColors.accentTeal.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Text(
                          tabLabels[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),

            // Render Tab Content
            _buildTabContent(tops, bottoms, isDress),
          ],
        );
      },
    );
  }

  Widget _buildTabContent(
    List<Map<String, dynamic>> tops,
    List<Map<String, dynamic>> bottoms,
    bool isDress,
  ) {
    // 0: All, 1: Tops/Dresses, 2: Bottoms
    int index = _activeTabIndex;

    if (index == 0) {
      // "Complete Look" - Horizontal scrolling lists
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tops.isNotEmpty) ...[
            _buildCategorySection(
              isDress ? "Recommended Dresses" : "Recommended Tops",
              tops,
            ),
            const SizedBox(height: 24),
          ],
          if (!isDress && bottoms.isNotEmpty) ...[
            _buildCategorySection("Recommended Bottoms", bottoms),
            const SizedBox(height: 16),
          ],
          if (tops.isEmpty && bottoms.isEmpty) _buildEmptyPlaceholder(),
        ],
      );
    } else if (index == 1) {
      // Tops / Dresses Grid
      return tops.isEmpty ? _buildEmptyPlaceholder() : _buildProductGrid(tops);
    } else {
      // Bottoms Grid
      return bottoms.isEmpty
          ? _buildEmptyPlaceholder()
          : _buildProductGrid(bottoms);
    }
  }

  Widget _buildCategorySection(String title, List<Map<String, dynamic>> items) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount:
                items.length > 8
                    ? 8
                    : items.length, // Curate top 8 matches for the Look
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 14, bottom: 8),
                child: _buildProductCard(items[index], isHorizontal: true),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.64,
      ),
      itemBuilder: (context, index) {
        return _buildProductCard(items[index]);
      },
    );
  }

  Widget _buildEmptyPlaceholder() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 40),
            SizedBox(height: 8),
            Text(
              "No deals matching this outfit are available.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    Map<String, dynamic> item, {
    bool isHorizontal = false,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final int score = item['_matchScore'] as int? ?? 0;
    final bool isBestMatch = score >= 15;
    final bool isGoodMatch = score >= 8 && score < 15;

    // Platform configurations
    final String platform = item['platform']?.toString() ?? 'Fashion';
    Color platformBg = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100;
    Color platformTxt = isDark ? Colors.white70 : Colors.grey.shade700;
    if (platform.toLowerCase() == 'myntra') {
      platformBg = isDark ? Colors.pink.withValues(alpha: 0.15) : Colors.pink.shade50;
      platformTxt = isDark ? Colors.pink.shade300 : Colors.pink.shade600;
    } else if (platform.toLowerCase() == 'flipkart') {
      platformBg = isDark ? Colors.amber.withValues(alpha: 0.15) : Colors.amber.shade50;
      platformTxt = isDark ? Colors.amber.shade300 : Colors.amber.shade900;
    }

    Widget cardContent = Container(
      width: isHorizontal ? 150 : double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with badge overlay
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      item['image_url'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: isDark ? Colors.white30 : Colors.grey,
                              ),
                            ),
                          ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accentTeal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Match indicator overlay badge
                if (isBestMatch)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.orangeAccent, Colors.redAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 10,
                          ),
                          SizedBox(width: 2),
                          Text(
                            "Best Match",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isGoodMatch)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentTeal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "✨ Match",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Card Details
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Platform Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: platformBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    platform.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: platformTxt,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Item Name
                Text(
                  item['item_name'] ?? 'Fashion Item',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹${item['price']}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_outward_rounded,
                      size: 14,
                      color: AppColors.accentTeal,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap:
          () => launchUrl(
            Uri.parse(item['link']),
            mode: LaunchMode.externalApplication,
          ),
      child: cardContent,
    );
  }
}

class OutfitCard extends StatelessWidget {
  final String outfitName;
  final String outfitImagePath;
  final String weatherLabel;
  const OutfitCard({
    required this.outfitName,
    required this.outfitImagePath,
    required this.weatherLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<String> images =
        outfitImagePath
            .split(',')
            .map((img) => img.trim())
            .where((img) => img.isNotEmpty && img != 'null')
            .toList();
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: isDark ? Border.all(color: Colors.white10, width: 1) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: Container(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFECECEC),
                child:
                    images.isEmpty
                        ? _buildImage('', isDark)
                        : images.length > 1
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              images
                                  .map(
                                    (img) => Expanded(child: _buildImage(img, isDark)),
                                  )
                                  .toList(),
                        )
                        : _buildImage(images[0], isDark),
              ),
            ),
            _buildInfoPanel(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PERFECT MATCH",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.accentTeal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            outfitName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentTeal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Weather: $weatherLabel',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.accentTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String path, bool isDark) {
    if (path.isEmpty) {
      return Container(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F4F4),
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: isDark ? Colors.white24 : Colors.grey,
            size: 40,
          ),
        ),
      );
    }

    // 🎯 Use Image.network for Supabase URLs
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        // 🛡️ FIX: This catches the 400 error and shows an icon instead of an exception
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F4F4), // Match your card background
            child: Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: isDark ? Colors.white24 : Colors.grey,
                size: 40,
              ),
            ),
          );
        },
        // 🌀 Optional: Show a tiny spinner while the image loads
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isDark ? Colors.white24 : Colors.grey,
            ),
          );
        },
      );
    }

    // Use Image.asset for your local mock images
    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder:
          (context, error, stackTrace) => const Icon(Icons.broken_image),
    );
  }
}
