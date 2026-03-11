// // lib/screens/outfit_suggestion.dart
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:smart_wardrobe_new/controllers/outfit_controller.dart'; // 🎯 Controller Import
// import 'package:smart_wardrobe_new/models/outfit_model.dart';
//
// import '../utils/constants/colors.dart'; // 🎯 Model Import
//
// // --- Custom Colors ---
// // class AppColors {
// //   static const Color accentTeal = Color(0xFF00C7B1);
// //   static const Color cardGradientStart = Color(0xFFB0F4E8);
// //   static const Color cardGradientEnd = Color(0xFF8ED2C7);
// // }
//
// // --- Main Screen Class (Stateful) ---
// class OutfitSuggestionScreen extends StatefulWidget {
//   final String? initialOutfitName;
//   final String? initialOutfitImagePath;
//
//   const OutfitSuggestionScreen({super.key, this.initialOutfitName, this.initialOutfitImagePath});
//
//   @override
//   State<OutfitSuggestionScreen> createState() => _OutfitSuggestionScreenState();
// }
//
// class _OutfitSuggestionScreenState extends State<OutfitSuggestionScreen> {
//   final OutfitController outfitController = Get.find<OutfitController>();
//
//   // 🎯 NEW: यह ट्रैक करने के लिए कि क्या हम किसी सेव्ड आउटफिट को देख रहे हैं
//   late bool _isViewingSavedOutfit;
//
//   // 🎯 आंतरिक स्टेट वेरिएबल्स जो डिस्प्ले को नियंत्रित करते हैं
//   late String _displayedOutfitName;
//   late String _displayedOutfitAssetPath;
//
//   int _currentOutfitIndex = 0; // मॉक लिस्ट इंडेक्स (सिर्फ़ डिफ़ॉल्ट सुझावों के लिए)
//
//
//   final List<String> _outfitNames = [
//     'Spring Casual Look',
//     'Evening Dinner Look',
//     'Office Chic',
//     'Weekend Comfort',
//   ];
//
//   final Map<String, String> _outfitData = {
//     'Spring Casual Look': 'assets/outfit_spring_casual.jpg',
//     'Evening Dinner Look': 'assets/outfit_evening_dinner.jpg',
//     'Office Chic': 'assets/outfit_office_chic.jpg',
//     'Weekend Comfort': 'assets/outfit_weekend_comfort.jpg',
//   };
//
//   // 🎯 Theme Getters
//   Color get _primaryTextColor => Theme.of(context).textTheme.bodyLarge!.color!;
//   Color get _secondaryTextColor => Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
//   Color get _surfaceColor => Theme.of(context).colorScheme.surface;
//   Color get _scaffoldColor => Theme.of(context).scaffoldBackgroundColor;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // 🎯 INIT FIX: चेक करें कि क्या नेविगेशन से डेटा आया है
//     if (widget.initialOutfitName != null && widget.initialOutfitImagePath != null) {
//       _displayedOutfitName = widget.initialOutfitName!;
//       _displayedOutfitAssetPath = widget.initialOutfitImagePath!;
//       _isViewingSavedOutfit = true; // इसे सेव्ड आउटफिट से खोला गया है
//     } else {
//       // यदि डेटा नहीं आया, तो डिफ़ॉल्ट मॉक लॉजिक का उपयोग करें
//       _currentOutfitIndex = 0;
//       _displayedOutfitName = _outfitNames[_currentOutfitIndex];
//       _displayedOutfitAssetPath = _outfitData[_displayedOutfitName] ?? 'assets/placeholder_error.png';
//       _isViewingSavedOutfit = false; // इसे नया सुझाव माना जाएगा
//     }
//   }
//
//   // Helper function to load the next outfit from the mock list
//   void _loadNextOutfit() {
//     // अगर Saved Outfit view में हैं, तो अगले स्किप से सामान्य सुझाव मोड में चले जाएँ
//     if (_isViewingSavedOutfit) {
//       _isViewingSavedOutfit = false;
//       _currentOutfitIndex = 0; // सामान्य मॉक लिस्ट के पहले आइटम पर रीसेट करें
//     }
//
//     // इंडेक्स को अगले आउटफिट पर ले जाएँ
//     _currentOutfitIndex = (_currentOutfitIndex + 1) % _outfitNames.length;
//     _displayedOutfitName = _outfitNames[_currentOutfitIndex];
//     _displayedOutfitAssetPath = _outfitData[_displayedOutfitName] ?? 'assets/placeholder_error.png';
//   }
//
//   void _skipOutfit() {
//     setState(() {
//       _loadNextOutfit(); // 🎯 अब यह नया लॉजिक कॉल करता है
//     });
//     Get.snackbar(
//       'Skipped',
//       'Loading next look!',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: _secondaryTextColor.withOpacity(0.8),
//       colorText: Colors.white,
//     );
//   }
//
//   void _saveOutfit() {
//     // 🎯 FIX: वर्तमान में प्रदर्शित हो रहे आउटफिट को सेव करें
//     final String currentOutfitName = _displayedOutfitName;
//     final String currentOutfitAssetPath = _displayedOutfitAssetPath;
//
//     // 🎯 नया OutfitModel ऑब्जेक्ट बनाएं
//     final newOutfit = OutfitModel(
//       name: currentOutfitName,
//       imageUrl: currentOutfitAssetPath, // Saving asset path
//       season: 'Current',
//       gender: 'F',
//     );
//
//     // 🎯 OutfitController में आउटफिट जोड़ें
//     outfitController.addOutfit(newOutfit);
//
//     // मैन्युअल रूप से इंडेक्स बदलें ताकि सेव के बाद यूजर को नया आउटफिट दिखे
//     setState(() {
//       _loadNextOutfit();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // बिल्ड के लिए अब आंतरिक स्टेट वेरिएबल्स का उपयोग करता है
//     final String currentOutfitName = _displayedOutfitName;
//     final String currentOutfitAssetPath = _displayedOutfitAssetPath;
//
//     return Scaffold(
//       backgroundColor: _scaffoldColor,
//       appBar: AppBar(
//         elevation: 1,
//         title: Text(
//           'AI Outfit Suggestions',
//           style: TextStyle(
//             color: _primaryTextColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         iconTheme: IconThemeData(color: _primaryTextColor),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.filter_list, color: _primaryTextColor),
//             onPressed: () {
//               Get.snackbar(
//                 'Filter',
//                 'Opening filter settings...',
//                 snackPosition: SnackPosition.TOP,
//                 backgroundColor: _secondaryTextColor.withOpacity(0.8),
//                 colorText: Colors.white,
//               );
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Expanded(
//               child: OutfitCard(
//                 outfitName: currentOutfitName, // 🎯 Displayed Name
//                 outfitImagePath: currentOutfitAssetPath, // 🎯 Displayed Path
//               ),
//             ),
//             const SizedBox(height: 30),
//             ControlButtons(
//               onSkip: _skipOutfit,
//               onSave: _saveOutfit,
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // --- Component Widgets (Theme-Aware - Unchanged) ---
//
// class OutfitCard extends StatelessWidget {
//   final String outfitName;
//   final String outfitImagePath;
//
//   const OutfitCard({required this.outfitName, required this.outfitImagePath, super.key});
//
//   Color _primaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.color!;
//   Color _secondaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
//   Color _surfaceColor(BuildContext context) => Theme.of(context).colorScheme.surface;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: _surfaceColor(context),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Expanded(
//             child: ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//               child: Image.asset(
//                 outfitImagePath,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                       ),
//                     ),
//                     alignment: Alignment.center,
//                     child: const Text('Error: Missing asset path', style: TextStyle(color: Colors.white, fontSize: 16)),
//                   );
//                 },
//               ),
//             ),
//           ),
//
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   outfitName,
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: _primaryTextColor(context),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Perfect for a sunny 24°C day!',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: _secondaryTextColor(context),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class ControlButtons extends StatelessWidget {
//   final VoidCallback onSkip;
//   final VoidCallback onSave;
//
//   const ControlButtons({required this.onSkip, required this.onSave, super.key,});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         FloatingActionButton(
//           onPressed: onSave,
//           backgroundColor: AppColors.accentTeal,
//           foregroundColor: Colors.white,
//           elevation: 5,
//           child: const Icon(Icons.favorite_border, size: 30),
//         ),
//         const SizedBox(width: 25),
//         FloatingActionButton.extended(
//           onPressed: onSkip,
//           backgroundColor: AppColors.accentTeal,
//           foregroundColor: Colors.white,
//           elevation: 8,
//           label: const Text(
//             'Generate New',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           icon: const Icon(Icons.refresh),
//         ),
//       ],
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  final List<String> _outfitNames = [
    'Spring Casual Look',
    'Evening Dinner Look',
    'Office Chic',
    'Weekend Comfort',
  ];

  final Map<String, String> _outfitData = {
    'Spring Casual Look': 'assets/outfit_spring_casual.jpg',
    'Evening Dinner Look': 'assets/outfit_evening_dinner.jpg',
    'Office Chic': 'assets/outfit_office_chic.jpg',
    'Weekend Comfort': 'assets/outfit_weekend_comfort.jpg',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialOutfitName != null && widget.initialOutfitImagePath != null) {
      _displayedOutfitName = widget.initialOutfitName!;
      _displayedOutfitAssetPath = widget.initialOutfitImagePath!;
      _isViewingSavedOutfit = true;
    } else {
      _currentOutfitIndex = 0;
      _displayedOutfitName = _outfitNames[_currentOutfitIndex];
      _displayedOutfitAssetPath = _outfitData[_displayedOutfitName] ?? 'assets/placeholder_error.png';
      _isViewingSavedOutfit = false;
    }
  }

  void _loadNextOutfit() {
    if (_isViewingSavedOutfit) {
      _isViewingSavedOutfit = false;
      _currentOutfitIndex = 0;
    }
    _currentOutfitIndex = (_currentOutfitIndex + 1) % _outfitNames.length;
    _displayedOutfitName = _outfitNames[_currentOutfitIndex];
    _displayedOutfitAssetPath = _outfitData[_displayedOutfitName] ?? 'assets/placeholder_error.png';
  }

  void _skipOutfit() {
    setState(() => _loadNextOutfit());
    Get.snackbar(
      'Refreshing',
      'Scanning your wardrobe for a better match...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.7),
      colorText: Colors.white,
      borderRadius: 15,
      margin: const EdgeInsets.all(15),
      icon: const Icon(Icons.auto_awesome, color: AppColors.accentTeal),
    );
  }

  void _saveOutfit() {
    final newOutfit = OutfitModel(
      name: _displayedOutfitName,
      imageUrl: _displayedOutfitAssetPath,
      season: 'Current',
      gender: 'F',
    );
    outfitController.addOutfit(newOutfit);
    setState(() => _loadNextOutfit());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'AI STYLIST',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.5),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
        ).paddingAll(8),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.5),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, color: Colors.black87),
              onPressed: () {},
            ),
          ).paddingAll(8),
        ],
      ),
      body: Stack(
        children: [
          // Background Aesthetic Mesh Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFDFCFB), Color(0xFFE2D1C3), Color(0xFFF8F9FD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            top: -50,
            right: -50,
            child: CircleAvatar(radius: 120, backgroundColor: AppColors.accentTeal.withOpacity(0.1)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: Column(
                children: [
                  Expanded(
                    child: OutfitCard(
                      outfitName: _displayedOutfitName,
                      outfitImagePath: _displayedOutfitAssetPath,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildControlPanel(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Row(
      children: [
        // Skip / Refresh Button
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _skipOutfit,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.grey),
                  SizedBox(width: 10),
                  Text("Next Look", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        // Love / Save Button
        GestureDetector(
          onTap: _saveOutfit,
          child: Container(
            height: 65,
            width: 75,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentTeal, Color(0xFF00A392)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppColors.accentTeal.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
              ],
            ),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }
}

class OutfitCard extends StatelessWidget {
  final String outfitName;
  final String outfitImagePath;

  const OutfitCard({required this.outfitName, required this.outfitImagePath, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Main Image
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.asset(
              outfitImagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey),
              ),
            ),
          ),

          // Bottom Glassmorphic Info Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.5))),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "MATCHING 98%",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.accentTeal),
                            ),
                          ),
                          const Icon(Icons.wb_sunny_rounded, color: Colors.orangeAccent, size: 20),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        outfitName,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A), letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Perfect for a sunny 24°C day!',
                        style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.5), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}