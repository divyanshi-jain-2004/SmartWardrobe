import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_wardrobe_new/main.dart'; // Supabase client के लिए

class UserController extends GetxController {
  // Rx variables for reactive UI updates
  final userName = 'User Name'.obs;
  final userEmail = 'user.email@example.com'.obs;

  // 🎯 नया RxString फ़ील्ड जो Supabase metadata से Avatar URL को स्टोर करेगा
  final avatarUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // सुनिश्चित करें कि यह हमेशा ताज़ा जानकारी लोड करे
    fetchUserInfo();

    // Supabase auth state changes को सुनें (जैसे लॉग इन/आउट)
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.userUpdated) {
        // userUpdated event तब होता है जब metadata (जैसे avatar_url) बदलता है
        fetchUserInfo();
      } else if (event == AuthChangeEvent.signedOut) {
        // Log out पर डेटा रीसेट करें
        userName.value = 'Guest User';
        userEmail.value = 'guest@example.com';
        avatarUrl.value = ''; // 🎯 Log out पर URL रीसेट करें
      }
    });
  }

  void fetchUserInfo() {
    final User? user = supabase.auth.currentUser;

    if (user != null) {
      // 1. Email को सेट करें
      userEmail.value = user.email ?? 'No Email Found';

      // 2. Name और Avatar URL को मेटाडेटा से प्राप्त करें
      final metadata = user.userMetadata;

      final String? fullName = metadata?['full_name'] as String?;
      final String? currentAvatarUrl = metadata?['avatar_url'] as String?; // 🎯 Avatar URL प्राप्त करें

      if (fullName != null && fullName.isNotEmpty) {
        userName.value = fullName;
      } else {
        userName.value = user.email?.split('@').first ?? 'Unknown User';
      }

      // 🎯 Avatar URL को सेट करें
      avatarUrl.value = currentAvatarUrl ?? '';

    } else {
      userName.value = 'Please Login';
      userEmail.value = 'not_logged_in@example.com';
      avatarUrl.value = '';
    }
  }
}