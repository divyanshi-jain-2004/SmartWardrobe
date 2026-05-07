import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/wardrobe_category_model.dart';

class WardrobeController extends GetxController {
  final supabase = Supabase.instance.client;

  var categoryCounts = <String, int>{}.obs;
  var isLoading = true.obs;

  final List<WardrobeCategory> categories = [
    WardrobeCategory(title: "Topwear", icon: Icons.checkroom, itemImage: 'assets/women_top.jpg', tags: ["Silk", "Floral", "Party"], genders: [Gender.women]),
    WardrobeCategory(title: "Bottomwear", icon: Icons.scatter_plot_outlined, itemImage: 'assets/women_jeans.jpg', tags: ["Pleated", "High-waist", "Work"], genders: [Gender.women]),
    WardrobeCategory(title: "Dresses", icon: Icons.woman_outlined, itemImage: 'assets/women_dress.jpg', tags: ["Maxi", "Cocktail", "Summer"], genders: [Gender.women]),
    WardrobeCategory(title: "Footwear", icon: Icons.directions_walk_outlined, itemImage: 'assets/women_footwear.jpg', tags: ["Heels", "Sandals", "Boots"], genders: [Gender.women]),
    WardrobeCategory(title: "Jewellery/Scarves", icon: Icons.watch_outlined, itemImage: 'assets/women_accesories.png', tags: ["Silver", "Necklace", "Scarf"], genders: [Gender.women]),
  ];

  int get totalItemsCount => categoryCounts.values.fold(0, (sum, count) => sum + count);

  @override
  void onInit() {
    super.onInit();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    try {
      isLoading(true);
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

      categoryCounts.value = counts;
    } catch (e) {
      print('Error fetching home stats: $e');
    } finally {
      isLoading(false);
    }
  }
}