// lib/screens/profile.dart

import 'dart:io';
import 'package:smart_wardrobe_new/screens/HomeScreen.dart';
import 'package:smart_wardrobe_new/screens/OutfitSuggestion.dart';
import 'package:smart_wardrobe_new/screens/changePassword.dart';
import 'package:smart_wardrobe_new/screens/editProfile.dart';
import 'package:smart_wardrobe_new/screens/eventPlanner.dart';
import 'package:smart_wardrobe_new/screens/my_wardrobe.dart';
import 'package:flutter/material.dart';

// 🎯 GetX/Supabase Imports
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_wardrobe_new/main.dart'; // supabase client के लिए

// 🎯 Controller Imports
import 'package:smart_wardrobe_new/controllers/theme_controller.dart';
import 'package:smart_wardrobe_new/controllers/user_controller.dart';

import 'package:smart_wardrobe_new/screens/login.dart';
import 'package:smart_wardrobe_new/screens/saved_outfits.dart'; // SavedOutfitsScreen का इम्पोर्ट
import 'package:smart_wardrobe_new/models/outfit_model.dart'; // 🎯 कॉमन मॉडल इम्पोर्ट


// 🎯 Mock Data (अब इम्पोर्ट किए गए मॉडल का उपयोग करता है)
final List<OutfitModel> _mockSavedOutfits = [
  OutfitModel(
    name: "Classic Workday",
    imageUrl: 'https://i.pravatar.cc/150?img=50',
    season: 'All',
    gender: 'F',
  ),
  OutfitModel(
    name: "Weekend Wanderer",
    imageUrl: 'https://i.pravatar.cc/150?img=53',
    season: 'Summer',
    gender: 'M',
  ),
];

// --- App Colors (Unchanged) ---
class AppColors {
  static const Color accentTeal = Color(0xFF00ADB5);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF8D8D8D);
  static const Color lightGrayBackground = Color(0xFFF5F5F5);
  static const Color backgroundWhite = Colors.white;
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkPrimaryText = Colors.white;
  static const Color darkSecondaryText = Color(0xFFAAAAAA);
  static const Color mintGreen = Color(0xFFA8E6CF);
}
// --------------------------------------------------------------------------------

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ThemeController themeController = Get.find<ThemeController>();
  final UserController userController = Get.find<UserController>();
  final ImagePicker _picker = ImagePicker();

  int _selectedIndex = 4;

  // New state to hold image file temporarily during upload (optimistic view)
  File? _tempImageFile;

  // ######################################################################
  //                   🎯 PROFILE PIC UPLOAD LOGIC
  // ######################################################################
  Future<void> _updateProfilePicture() async {
    // 1. Image Source Dialog
    final XFile? pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () async {
                  final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                  // Using Get.back to dismiss the modal
                  Get.back(result: file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                  Get.back(result: file);
                },
              ),
            ],
          ),
        );
      },
    );

    if (pickedFile == null) return;

    // Show image immediately (optimistic update)
    setState(() {
      _tempImageFile = File(pickedFile.path);
    });

    // Show uploading snackbar
    Get.snackbar('Uploading', 'Updating profile picture...', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.accentTeal, colorText: Colors.white, showProgressIndicator: true);

    try {
      final file = File(pickedFile.path);
      final fileExtension = pickedFile.name.split('.').last;
      final userId = supabase.auth.currentUser!.id;
      final fileName = '$userId/avatar/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // 2. Upload to Supabase Storage
      await supabase.storage.from('avatars').upload(
        fileName,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      // 3. Get Public URL
      final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      // 4. Update User Metadata (avatar_url)
      await supabase.auth.updateUser(
        UserAttributes(
          data: {'avatar_url': publicUrl},
        ),
      );

      // 5. Update Local State and Controller
      if (mounted) {
        setState(() {
          _tempImageFile = null;
        });

        // Refresh user info to get the new URL in the controller
        userController.fetchUserInfo();

        Get.closeCurrentSnackbar();
        Get.snackbar('Success', 'Profile picture updated!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      }

    } on StorageException catch (e) {
      Get.closeCurrentSnackbar();
      _showErrorSnackbar('Upload failed: ${e.message}');
    } on AuthException catch (e) {
      Get.closeCurrentSnackbar();
      _showErrorSnackbar('Auth failed: ${e.message}');
    } catch (e) {
      Get.closeCurrentSnackbar();
      _showErrorSnackbar('An unexpected error occurred.');
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
  }


  // ######################################################################
  //                   🎯 LOGOUT IMPLEMENTATION (Unchanged)
  // ######################################################################
  Future<void> _performLogout() async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6))),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      Get.snackbar(
          'Success',
          'Logged out successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: AppColors.backgroundWhite
      );
      Get.offAll(() => const LoginScreen());
    }
  }


  // --- Reusable Widget for Profile List Items (Unchanged) ---
  Widget _buildProfileListItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    bool hasNavigation = true,
    Widget? trailing,
    VoidCallback? onTap,
    Color titleColor = AppColors.primaryText,
  }) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.04;
    final verticalPadding = size.height * 0.015;
    final iconSize = size.width * 0.06;
    final fontSize = size.width * 0.04;

    final itemBackgroundColor = Theme.of(context).colorScheme.surface;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: itemBackgroundColor,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: titleColor == Colors.red
                  ? Colors.red
                  : AppColors.accentTeal.withOpacity(0.8),
              size: iconSize,
            ),
            SizedBox(width: size.width * 0.04),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  color: titleColor == Colors.red
                      ? Colors.red
                      : Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
            ),
            if (trailing != null) trailing!,
            if (hasNavigation)
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5),
                size: iconSize * 0.8,
              ),
          ],
        ),
      ),
    );
  }

  // --- Custom Bottom Navigation Bar Widget (Unchanged) ---
  Widget _buildCustomBottomNavBar() {
    final size = MediaQuery.of(context).size;
    final double iconSize = size.width * 0.06;
    final double labelSize = size.width * 0.03;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
        selectedItemColor: AppColors.accentTeal,
        unselectedItemColor: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5),
        selectedLabelStyle: TextStyle(fontSize: labelSize, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: labelSize),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 0) {
            Get.to(() => const HomeScreen());
          } else if (index == 1) {
            Get.to(() => const MyWardrobeScreen());
          } else if (index == 2) {
            Get.to(() => const OutfitSuggestionScreen());
          } else if (index == 3) {
            Get.to(() => EventPlannerScreen());
          }
          // index 4: Stay on Profile Screen
        },
        items:[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled, size: iconSize),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom, size: iconSize),
            label: 'Wardrobe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_half_rounded, size: iconSize),
            label: 'AI Stylist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined, size: iconSize),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: iconSize),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final verticalPadding = size.height * 0.025;
    final imageSize = size.width * 0.2;

    final background = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: size.width * 0.05,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Profile Header Section ---
            Container(
              color: cardColor,
              padding: EdgeInsets.symmetric(vertical: verticalPadding),
              child: Center(
                child: Column(
                  children: [
                    // Profile Image
                    GestureDetector( // 🎯 GestureDetector जोड़ा गया
                      onTap: _updateProfilePicture, // 🎯 ऑन टैप फ़ंक्शन
                      child: ClipOval(
                        child: Container(
                          width: imageSize,
                          height: imageSize,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          // 🎯 Image Source: Temp file, then User Avatar URL from Controller, then placeholder
                          child: Obx(() {
                            // Controller से Avatar URL प्राप्त करें
                            final avatarUrl = userController.avatarUrl.value;

                            ImageProvider imageProvider;

                            if (_tempImageFile != null) {
                              // 1. If currently uploading (optimistic view)
                              imageProvider = FileImage(_tempImageFile!) as ImageProvider;
                            } else if (avatarUrl.isNotEmpty) {
                              // 2. If URL exists in Supabase metadata
                              imageProvider = NetworkImage(avatarUrl);
                            } else {
                              // 3. Fallback Placeholder
                              imageProvider = const NetworkImage('https://i.pravatar.cc/150?img=1');
                            }

                            return Image(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            );
                          }),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.015),

                    // 🎯 Name - Obx का उपयोग करके UserController से डेटा प्राप्त करें
                    Obx(
                          () => Text(
                        userController.userName.value,
                        style: TextStyle(
                          fontSize: size.width * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ),

                    // 🎯 Email - Obx का उपयोग करके UserController से डेटा प्राप्त करें
                    Obx(
                          () => Text(
                        userController.userEmail.value,
                        style: TextStyle(
                          fontSize: size.width * 0.038,
                          color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),

            // --- Profile List Items Section ---
            Column(
              children: [
                _buildProfileListItem(
                  context: context,
                  icon: Icons.person_outline,
                  title: 'Edit Personal Info',
                  onTap: () {
                    Get.to(()=>EditPersonalInfoScreen());
                  },
                ),

                _buildProfileListItem(
                  context: context,
                  icon: Icons.favorite_border,
                  title: 'Saved Outfits',
                  onTap: () {
                    Get.to(() => const SavedOutfitsScreen());
                  },
                ),
                SizedBox(height: size.height * 0.02),
                _buildProfileListItem(
                    context: context,
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {
                      Get.to(()=>ChangePasswordScreen());
                    }
                ),
                // 🎯 Theme Switching Item (Unchanged)
                GetBuilder<ThemeController>(
                  builder: (controller) {
                    return _buildProfileListItem(
                      context: context,
                      icon: Icons.wb_sunny_outlined,
                      title: 'App Theme',
                      hasNavigation: false,
                      trailing: Switch(
                        value: controller.isDarkMode,
                        onChanged: (val) {
                          controller.switchTheme();
                        },
                        activeColor: AppColors.accentTeal,
                      ),
                    );
                  },
                ),

                // 🎯 LOGOUT ITEM (Unchanged)
                _buildProfileListItem(
                  context: context,
                  icon: Icons.logout,
                  title: 'Logout',
                  titleColor: Colors.red,
                  hasNavigation: false,
                  onTap: _performLogout,
                ),
              ],
            ),
          ],
        ),
      ),
      // --- Bottom Navigation Bar ---
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }
}