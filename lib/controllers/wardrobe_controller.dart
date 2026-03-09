import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WardrobeController extends GetxController {
  final supabase = Supabase.instance.client;

  // Observable map to store counts
  var categoryCounts = <String, int>{}.obs;
  var isLoading = true.obs;

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