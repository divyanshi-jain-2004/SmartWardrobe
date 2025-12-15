import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_wardrobe_new/models/outfit_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ⚠️ Ensure this path is correct for Supabase client access
import 'package:smart_wardrobe_new/main.dart';


class OutfitController extends GetxController {
  // Observable List (RxList) जो सभी सहेजे गए आउटफिट्स को रखेगी।
  // Mock Data को हटा दिया गया है, क्योंकि अब हम DB से लोड करेंगे।
  final RxList<OutfitModel> savedOutfits = <OutfitModel>[].obs;

  // 🎯 Init method को DB fetch लॉजिक से बदलें
  @override
  void onInit() {
    super.onInit();

    // 1. Supabase Auth State Listener
    supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        fetchOutfits(); // लॉगिन पर आउटफिट्स लोड करें
      } else if (data.event == AuthChangeEvent.signedOut) {
        savedOutfits.clear(); // लॉगआउट पर लिस्ट खाली करें
      }
    });
    fetchOutfits(); // ऐप शुरू होने पर भी एक बार कोशिश करें (यदि सत्र पहले से मौजूद है)
  }

  // 🎯 FETCH LOGIC: Supabase से डेटा लोड करें
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

    try {
      // डेटाबेस से हटाने के लिए user_id और outfit_name का उपयोग करें
      // (outfit_name को यूनिक होना चाहिए या आप ID का उपयोग करें)
      await supabase.from('saved_outfits')
          .delete()
          .eq('user_id', userId)
          .eq('outfit_name', outfit.name);

      // डेटाबेस से हटाने के बाद UI को अपडेट करने के लिए लिस्ट को फ़ेच करें
      await fetchOutfits();

      Get.snackbar('Unsaved!', 'Outfit removed from favorites.', backgroundColor: Colors.red);

    } catch (e) {
      Get.snackbar('Error', 'Failed to delete outfit.', backgroundColor: Colors.red);
    }
  }
}