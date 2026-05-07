import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_wardrobe_new/main.dart';

class UserController extends GetxController {
  // Rx variables for reactive UI updates
  final userName = 'User Name'.obs;
  final userEmail = 'user.email@example.com'.obs;

  final avatarUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();

    fetchUserInfo();

    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.userUpdated) {

        fetchUserInfo();
      } else if (event == AuthChangeEvent.signedOut) {

        userName.value = 'Guest User';
        userEmail.value = 'guest@example.com';
        avatarUrl.value = '';
      }
    });
  }

  void fetchUserInfo() {
    final User? user = supabase.auth.currentUser;

    if (user != null) {

      userEmail.value = user.email ?? 'No Email Found';


      final metadata = user.userMetadata;

      final String? fullName = metadata?['full_name'] as String?;
      final String? currentAvatarUrl = metadata?['avatar_url'] as String?;

      if (fullName != null && fullName.isNotEmpty) {
        userName.value = fullName;
      } else {
        userName.value = user.email?.split('@').first ?? 'Unknown User';
      }

      avatarUrl.value = currentAvatarUrl ?? '';

    } else {
      userName.value = 'Please Login';
      userEmail.value = 'not_logged_in@example.com';
      avatarUrl.value = '';
    }
  }
}