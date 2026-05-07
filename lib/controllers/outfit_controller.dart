import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_wardrobe_new/models/outfit_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smart_wardrobe_new/main.dart';
import 'package:smart_wardrobe_new/utils/recommendation_engine.dart';


class OutfitController extends GetxController {

  final RxList<OutfitModel> savedOutfits = <OutfitModel>[].obs;
  
  // New observable for generated outfits
  final RxList<Map<String, dynamic>> generatedOutfits = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> dailyOutfit = <String, dynamic>{}.obs;
  final RxBool isGenerating = false.obs;

  @override
  void onInit() {
    super.onInit();


    supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        fetchOutfits();
        generateAIOutfits();
      } else if (data.event == AuthChangeEvent.signedOut) {
        savedOutfits.clear();
        generatedOutfits.clear();
        dailyOutfit.clear();
      }
    });
    fetchOutfits();
    generateAIOutfits();
  }

//fetching data from supabase
  Future<void> fetchOutfits() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      savedOutfits.clear();
      return;
    }

    try {
      final List<dynamic> response = await supabase
          .from('saved_outfits')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // Map the DB response to the OutfitModel
      final List<OutfitModel> loadedOutfits = response.map((data) => OutfitModel(
        id: data['id'],
        name: data['outfit_name'] ?? 'Untitled Outfit',
        imageUrl: data['image_url'] ?? 'assets/placeholder_error.png',
        season: 'N/A',
        gender: 'N/A',
      )).toList();

      savedOutfits.assignAll(loadedOutfits); // RxList को अपडेट करें

    } catch (e) {
      print("Error fetching outfits: $e");
      Get.snackbar('Error', 'Failed to load saved outfits from server.', backgroundColor: Colors.red);
    }
  }

  // Generate dynamic AI outfits using the RecommendationEngine
  Future<void> generateAIOutfits() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      isGenerating.value = true;
      // Fetch all wardrobe items
      final response = await supabase
          .from('wardrobe_items')
          .select('*')
          .eq('user_id', userId);

      List<Map<String, dynamic>> wardrobeItems = List<Map<String, dynamic>>.from(response);

      // Generate fits using the AI engine
      RecommendationEngine engine = RecommendationEngine();
      List<Map<String, dynamic>> combos = engine.generateOutfits(wardrobeItems, 15);

      generatedOutfits.assignAll(combos);
      
      // Determine Daily Outfit
      if (combos.isNotEmpty) {
        final box = engine.box;
        String todayString = DateTime.now().toIso8601String().substring(0, 10);
        String? savedDate = box.read('daily_outfit_date');
        
        if (savedDate == todayString && box.hasData('daily_outfit_data')) {
           // Provide the cached one
           dailyOutfit.value = box.read('daily_outfit_data');
        } else {
           // We keep the best match for the daily outfit
           var bestDaily = combos.first;
           dailyOutfit.value = bestDaily;
           box.write('daily_outfit_date', todayString);
           box.write('daily_outfit_data', bestDaily);
        }
      }

    } catch (e) {
      print("Error generating outfits: $e");
      Get.snackbar('Generation Error', 'Failed to generate outfits.', backgroundColor: Colors.orange);
    } finally {
      isGenerating.value = false;
    }
  }

  // 🎯 ADD LOGIC: Supabase में इंसर्ट करें
  void addOutfit(OutfitModel outfit) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      Get.snackbar('Error', 'Please log in to save outfits.', backgroundColor: Colors.red);
      return;
    }

    try {
      await supabase.from('saved_outfits').insert({
        'user_id': userId,
        'outfit_name': outfit.name,
        'image_url': outfit.imageUrl,
        // (यदि आवश्यक हो तो अन्य कॉलम जोड़ें)
      });

      // सफलता के बाद लिस्ट को फिर से फ़ेच करें ताकि UI अपडेट हो
      await fetchOutfits();

      Get.snackbar('Success!', 'Outfit saved permanently.', backgroundColor: Colors.green);

    } catch (e) {
      Get.snackbar('Error', 'Failed to save outfit to database.', backgroundColor: Colors.red);
    }
  }

  // 🎯 REMOVE LOGIC: Supabase से डिलीट करें
  void removeOutfit(OutfitModel outfit) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      Get.snackbar('Error', 'Please log in to remove outfits.', backgroundColor: Colors.red);
      return;
    }
    if (userId == null || outfit.id == null) return;

    try {
      // डेटाबेस से हटाने के लिए user_id और outfit_name का उपयोग करें
      // (outfit_name को यूनिक होना चाहिए या आप ID का उपयोग करें)
      await supabase.from('saved_outfits')
          .delete()
          .eq('id', outfit.id!)
          .eq('user_id', userId)
          .eq('outfit_name', outfit.name);

      // डेटाबेस से हटाने के बाद UI को अपडेट करने के लिए लिस्ट को फ़ेच करें
      // await fetchOutfits();
      savedOutfits.removeWhere((item) => item.id == outfit.id);

      Get.snackbar('Success', 'Outfit removed', backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar('Error', 'Failed to delete outfit.', backgroundColor: Colors.red);
    }
  }
}