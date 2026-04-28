// // // lib/screens/outfit_suggestion.dart
// //
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:smart_wardrobe_new/controllers/outfit_controller.dart'; // 🎯 Controller Import
// // import 'package:smart_wardrobe_new/models/outfit_model.dart';
// //
// // import '../utils/constants/colors.dart'; // 🎯 Model Import
// //
// // // --- Custom Colors ---
// // // class AppColors {
// // //   static const Color accentTeal = Color(0xFF00C7B1);
// // //   static const Color cardGradientStart = Color(0xFFB0F4E8);
// // //   static const Color cardGradientEnd = Color(0xFF8ED2C7);
// // // }
// //
// // // --- Main Screen Class (Stateful) ---
// // class OutfitSuggestionScreen extends StatefulWidget {
// //   final String? initialOutfitName;
// //   final String? initialOutfitImagePath;
// //
// //   const OutfitSuggestionScreen({super.key, this.initialOutfitName, this.initialOutfitImagePath});
// //
// //   @override
// //   State<OutfitSuggestionScreen> createState() => _OutfitSuggestionScreenState();
// // }
// //
// // class _OutfitSuggestionScreenState extends State<OutfitSuggestionScreen> {
// //   final OutfitController outfitController = Get.find<OutfitController>();
// //
// //   // 🎯 NEW: यह ट्रैक करने के लिए कि क्या हम किसी सेव्ड आउटफिट को देख रहे हैं
// //   late bool _isViewingSavedOutfit;
// //
// //   // 🎯 आंतरिक स्टेट वेरिएबल्स जो डिस्प्ले को नियंत्रित करते हैं
// //   late String _displayedOutfitName;
// //   late String _displayedOutfitAssetPath;
// //
// //   int _currentOutfitIndex = 0; // मॉक लिस्ट इंडेक्स (सिर्फ़ डिफ़ॉल्ट सुझावों के लिए)
// //
// //
// //   final List<String> _outfitNames = [
// //     'Spring Casual Look',
// //     'Evening Dinner Look',
// //     'Office Chic',
// //     'Weekend Comfort',
// //   ];
// //
// //   final Map<String, String> _outfitData = {
// //     'Spring Casual Look': 'assets/outfit_spring_casual.jpg',
// //     'Evening Dinner Look': 'assets/outfit_evening_dinner.jpg',
// //     'Office Chic': 'assets/outfit_office_chic.jpg',
// //     'Weekend Comfort': 'assets/outfit_weekend_comfort.jpg',
// //   };
// //
// //   // 🎯 Theme Getters
// //   Color get _primaryTextColor => Theme.of(context).textTheme.bodyLarge!.color!;
// //   Color get _secondaryTextColor => Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.6);
// //   Color get _surfaceColor => Theme.of(context).colorScheme.surface;
// //   Color get _scaffoldColor => Theme.of(context).scaffoldBackgroundColor;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     // 🎯 INIT FIX: चेक करें कि क्या नेविगेशन से डेटा आया है
// //     if (widget.initialOutfitName != null && widget.initialOutfitImagePath != null) {
// //       _displayedOutfitName = widget.initialOutfitName!;
// //       _displayedOutfitAssetPath = widget.initialOutfitImagePath!;
// //       _isViewingSavedOutfit = true; // इसे सेव्ड आउटफिट से खोला गया है
// //     } else {
// //       // यदि डेटा नहीं आया, तो डिफ़ॉल्ट मॉक लॉजिक का उपयोग करें
// //       _currentOutfitIndex = 0;
// //       _displayedOutfitName = _outfitNames[_currentOutfitIndex];
// //       _displayedOutfitAssetPath = _outfitData[_displayedOutfitName] ?? 'assets/placeholder_error.png';
// //       _isViewingSavedOutfit = false; // इसे नया सुझाव माना जाएगा
// //     }
// //   }
// //
// //   // Helper function to load the next outfit from the mock list
// //   void _loadNextOutfit() {
// //     // अगर Saved Outfit view में हैं, तो अगले स्किप से सामान्य सुझाव मोड में चले जाएँ
// //     if (_isViewingSavedOutfit) {
// //       _isViewingSavedOutfit = false;
// //       _currentOutfitIndex = 0; // सामान्य मॉक लिस्ट के पहले आइटम पर रीसेट करें
// //     }
// //
// //     // इंडेक्स को अगले आउटफिट पर ले जाएँ
// //     _currentOutfitIndex = (_currentOutfitIndex + 1) % _outfitNames.length;
// //     _displayedOutfitName = _outfitNames[_currentOutfitIndex];
// //     _displayedOutfitAssetPath = _outfitData[_displayedOutfitName] ?? 'assets/placeholder_error.png';
// //   }
// //
// //   void _skipOutfit() {
// //     setState(() {
// //       _loadNextOutfit(); // 🎯 अब यह नया लॉजिक कॉल करता है
// //     });
// //     Get.snackbar(
// //       'Skipped',
// //       'Loading next look!',
// //       snackPosition: SnackPosition.BOTTOM,
// //       backgroundColor: _secondaryTextColor.withValues(alpha:0.8),
// //       colorText: Colors.white,
// //     );
// //   }
// //
// //   void _saveOutfit() {
// //     // 🎯 FIX: वर्तमान में प्रदर्शित हो रहे आउटफिट को सेव करें
// //     final String currentOutfitName = _displayedOutfitName;
// //     final String currentOutfitAssetPath = _displayedOutfitAssetPath;
// //
// //     // 🎯 नया OutfitModel ऑब्जेक्ट बनाएं
// //     final newOutfit = OutfitModel(
// //       name: currentOutfitName,
// //       imageUrl: currentOutfitAssetPath, // Saving asset path
// //       season: 'Current',
// //       gender: 'F',
// //     );
// //
// //     // 🎯 OutfitController में आउटफिट जोड़ें
// //     outfitController.addOutfit(newOutfit);
// //
// //     // मैन्युअल रूप से इंडेक्स बदलें ताकि सेव के बाद यूजर को नया आउटफिट दिखे
// //     setState(() {
// //       _loadNextOutfit();
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // बिल्ड के लिए अब आंतरिक स्टेट वेरिएबल्स का उपयोग करता है
// //     final String currentOutfitName = _displayedOutfitName;
// //     final String currentOutfitAssetPath = _displayedOutfitAssetPath;
// //
// //     return Scaffold(
// //       backgroundColor: _scaffoldColor,
// //       appBar: AppBar(
// //         elevation: 1,
// //         title: Text(
// //           'AI Outfit Suggestions',
// //           style: TextStyle(
// //             color: _primaryTextColor,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //         iconTheme: IconThemeData(color: _primaryTextColor),
// //         actions: [
// //           IconButton(
// //             icon: Icon(Icons.filter_list, color: _primaryTextColor),
// //             onPressed: () {
// //               Get.snackbar(
// //                 'Filter',
// //                 'Opening filter settings...',
// //                 snackPosition: SnackPosition.TOP,
// //                 backgroundColor: _secondaryTextColor.withValues(alpha:0.8),
// //                 colorText: Colors.white,
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.stretch,
// //           children: [
// //             Expanded(
// //               child: OutfitCard(
// //                 outfitName: currentOutfitName, // 🎯 Displayed Name
// //                 outfitImagePath: currentOutfitAssetPath, // 🎯 Displayed Path
// //               ),
// //             ),
// //             const SizedBox(height: 30),
// //             ControlButtons(
// //               onSkip: _skipOutfit,
// //               onSave: _saveOutfit,
// //             ),
// //             const SizedBox(height: 20),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // --- Component Widgets (Theme-Aware - Unchanged) ---
// //
// // class OutfitCard extends StatelessWidget {
// //   final String outfitName;
// //   final String outfitImagePath;
// //
// //   const OutfitCard({required this.outfitName, required this.outfitImagePath, super.key});
// //
// //   Color _primaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.color!;
// //   Color _secondaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.6);
// //   Color _surfaceColor(BuildContext context) => Theme.of(context).colorScheme.surface;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: _surfaceColor(context),
// //         borderRadius: BorderRadius.circular(20),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withValues(alpha:Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.1),
// //             blurRadius: 20,
// //             offset: const Offset(0, 1),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.stretch,
// //         children: [
// //           Expanded(
// //             child: ClipRRect(
// //               borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
// //               child: Image.asset(
// //                 outfitImagePath,
// //                 fit: BoxFit.cover,
// //                 errorBuilder: (context, error, stackTrace) {
// //                   return Container(
// //                     decoration: const BoxDecoration(
// //                       gradient: LinearGradient(
// //                         colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
// //                         begin: Alignment.topCenter,
// //                         end: Alignment.bottomCenter,
// //                       ),
// //                     ),
// //                     alignment: Alignment.center,
// //                     child: const Text('Error: Missing asset path', style: TextStyle(color: Colors.white, fontSize: 16)),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ),
// //
// //           Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   outfitName,
// //                   style: TextStyle(
// //                     fontSize: 22,
// //                     fontWeight: FontWeight.bold,
// //                     color: _primaryTextColor(context),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Text(
// //                   'Perfect for a sunny 24°C day!',
// //                   style: TextStyle(
// //                     fontSize: 14,
// //                     color: _secondaryTextColor(context),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class ControlButtons extends StatelessWidget {
// //   final VoidCallback onSkip;
// //   final VoidCallback onSave;
// //
// //   const ControlButtons({required this.onSkip, required this.onSave, super.key,});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         FloatingActionButton(
// //           onPressed: onSave,
// //           backgroundColor: AppColors.accentTeal,
// //           foregroundColor: Colors.white,
// //           elevation: 5,
// //           child: const Icon(Icons.favorite_border, size: 30),
// //         ),
// //         const SizedBox(width: 25),
// //         FloatingActionButton.extended(
// //           onPressed: onSkip,
// //           backgroundColor: AppColors.accentTeal,
// //           foregroundColor: Colors.white,
// //           elevation: 8,
// //           label: const Text(
// //             'Generate New',
// //             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
// //           ),
// //           icon: const Icon(Icons.refresh),
// //         ),
// //       ],
// //     );
// //   }
// // }
//
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:smart_wardrobe_new/controllers/outfit_controller.dart';
// import 'package:smart_wardrobe_new/models/outfit_model.dart';
// import '../utils/constants/colors.dart';
//
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
//   late bool _isViewingSavedOutfit;
//   late String _displayedOutfitName;
//   late String _displayedOutfitAssetPath;
//   int _currentOutfitIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.initialOutfitName != null && widget.initialOutfitImagePath != null) {
//       _displayedOutfitName = widget.initialOutfitName!;
//       _displayedOutfitAssetPath = widget.initialOutfitImagePath!;
//       _isViewingSavedOutfit = true;
//     } else {
//       _isViewingSavedOutfit = false;
//       _displayedOutfitName = 'Generating...';
//       _displayedOutfitAssetPath = '';
//
//       // Post-frame callback to trigger generation without blocking init
//       WidgetsBinding.instance.addPostFrameCallback((_) async {
//         await outfitController.generateAIOutfits();
//         if (outfitController.generatedOutfits.isNotEmpty) {
//           _updateDisplayFromGenerated();
//         }
//       });
//     }
//   }
//
//   void _updateDisplayFromGenerated() {
//     if (outfitController.generatedOutfits.isEmpty) return;
//
//     var combo = outfitController.generatedOutfits[_currentOutfitIndex];
//     var top = combo['top'];
//     var bot = combo['bottom'];
//
//     _displayedOutfitName = combo['name'] ?? 'Stylish Outfit';
//     // Combine both URLs with a comma for the model/storage
//     _displayedOutfitAssetPath = '${top['image_url']},${bot['image_url']}';
//   }
//
//   void _loadNextOutfit() {
//     if (_isViewingSavedOutfit) {
//       _isViewingSavedOutfit = false;
//       _currentOutfitIndex = 0;
//     } else {
//       if (outfitController.generatedOutfits.isNotEmpty) {
//         _currentOutfitIndex = (_currentOutfitIndex + 1) % outfitController.generatedOutfits.length;
//       }
//     }
//
//     if (outfitController.generatedOutfits.isNotEmpty && !_isViewingSavedOutfit) {
//       _updateDisplayFromGenerated();
//     }
//   }
//
//   void _skipOutfit() {
//     setState(() => _loadNextOutfit());
//     Get.snackbar(
//       'Refreshing',
//       'Scanning your wardrobe for a better match...',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.black.withValues(alpha:0.7),
//       colorText: Colors.white,
//       borderRadius: 15,
//       margin: const EdgeInsets.all(15),
//       icon: const Icon(Icons.auto_awesome, color: AppColors.accentTeal),
//     );
//   }
//
//   void _saveOutfit() {
//     final newOutfit = OutfitModel(
//       name: _displayedOutfitName,
//       imageUrl: _displayedOutfitAssetPath,
//       season: 'Current',
//       gender: 'F',
//     );
//     outfitController.addOutfit(newOutfit);
//     setState(() => _loadNextOutfit());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           'AI STYLIST',
//           style: TextStyle(
//             letterSpacing: 2,
//             fontWeight: FontWeight.w900,
//             fontSize: 16,
//             color: Colors.black87,
//           ),
//         ),
//         leading: CircleAvatar(
//           backgroundColor: Colors.white.withValues(alpha:0.5),
//           child: IconButton(
//             icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
//             onPressed: () => Get.back(),
//           ),
//         ).paddingAll(8),
//         actions: [
//           CircleAvatar(
//             backgroundColor: Colors.white.withValues(alpha:0.5),
//             child: IconButton(
//               icon: const Icon(Icons.tune_rounded, color: Colors.black87),
//               onPressed: () {},
//             ),
//           ).paddingAll(8),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Background Aesthetic Mesh Gradient
//           Positioned.fill(
//             child: Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFFFDFCFB), Color(0xFFE2D1C3), Color(0xFFF8F9FD)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             top: -50,
//             right: -50,
//             child: CircleAvatar(radius: 120, backgroundColor: AppColors.accentTeal.withValues(alpha:0.1)),
//           ),
//
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
//               child: Obx(() {
//                 if (outfitController.isGenerating.value) {
//                   return Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Center(child: CircularProgressIndicator(color: AppColors.accentTeal)),
//                       const SizedBox(height: 20),
//                       Text(
//                         "AI Styling Your Wardrobe...",
//                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black.withValues(alpha:0.6)),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         "Matching your Body Type & Skin Tone",
//                         style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha:0.4)),
//                       ),
//                     ],
//                   );
//                 }
//
//                 if (outfitController.generatedOutfits.isEmpty && !_isViewingSavedOutfit) {
//                   return const Center(
//                     child: Text(
//                       "Not enough items in your wardrobe to form an outfit!\nAdd more Tops and Bottoms.",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold),
//                     ),
//                   );
//                 }
//
//                 return Column(
//                   children: [
//                     Expanded(
//                       child: OutfitCard(
//                         outfitName: _displayedOutfitName,
//                         outfitImagePath: _displayedOutfitAssetPath,
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     _buildControlPanel(),
//                     const SizedBox(height: 10),
//                   ],
//                 );
//               }),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildControlPanel() {
//     return Row(
//       children: [
//         // Skip / Refresh Button
//         Expanded(
//           flex: 2,
//           child: GestureDetector(
//             onTap: _skipOutfit,
//             child: Container(
//               height: 65,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 15, offset: const Offset(0, 5))
//                 ],
//               ),
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.refresh_rounded, color: Colors.grey),
//                   SizedBox(width: 10),
//                   Text("Next Look", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 15),
//         // Love / Save Button
//         GestureDetector(
//           onTap: _saveOutfit,
//           child: Container(
//             height: 65,
//             width: 75,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [AppColors.accentTeal, Color(0xFF00A392)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(color: AppColors.accentTeal.withValues(alpha:0.3), blurRadius: 15, offset: const Offset(0, 8))
//               ],
//             ),
//             child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class OutfitCard extends StatelessWidget {
//   final String outfitName;
//   final String outfitImagePath;
//
//   const OutfitCard({required this.outfitName, required this.outfitImagePath, super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     List<String> images = outfitImagePath.split(',');
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(32),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.10),
//             blurRadius: 30,
//             offset: const Offset(0, 15),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(32),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // ── Outfit Flat-lay Section ──────────────────────────────
//             Expanded(
//               flex: 7,
//               child: Container(
//                 color: const Color(0xFFF4F4F4), // Clean, unified, sleek background
//                 width: double.infinity,
//                 child: images.length > 1
//                     ? Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // Top clothing item
//                           Expanded(
//                             flex: 5,
//                             child: Container(
//                               alignment: Alignment.bottomCenter,
//                               padding: const EdgeInsets.only(bottom: 2), // Keep them visually close
//                               child: ColorFiltered(
//                                 colorFilter: const ColorFilter.mode(
//                                   Color(0xFFF4F4F4), // Blends any white background into the container
//                                   BlendMode.multiply,
//                                 ),
//                                 child: _buildImage(
//                                   images[0],
//                                   isNetwork: images[0].startsWith('http'),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           // Bottom clothing item
//                           Expanded(
//                             flex: 6,
//                             child: Container(
//                               alignment: Alignment.topCenter,
//                               padding: const EdgeInsets.only(top: 2),
//                               child: ColorFiltered(
//                                 colorFilter: const ColorFilter.mode(
//                                   Color(0xFFF4F4F4), // Blends any white background into the container
//                                   BlendMode.multiply,
//                                 ),
//                                 child: _buildImage(
//                                   images[1],
//                                   isNetwork: images[1].startsWith('http'),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       )
//                     : Padding(
//                         padding: const EdgeInsets.all(24.0),
//                         child: ColorFiltered(
//                           colorFilter: const ColorFilter.mode(
//                             Color(0xFFF4F4F4),
//                             BlendMode.multiply,
//                           ),
//                           child: _buildImage(
//                             images[0],
//                             isNetwork: images[0].startsWith('http'),
//                           ),
//                         ),
//                       ),
//               ),
//             ),
//
//             // ── Info Panel ───────────────────────────────────
//             Container(
//               padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border(
//                   top: BorderSide(color: Colors.grey.shade100, width: 1),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: AppColors.accentTeal.withValues(alpha:0.12),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Text(
//                           "PERFECT MATCH",
//                           style: TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.w900,
//                             color: AppColors.accentTeal,
//                           ),
//                         ),
//                       ),
//                       const Icon(Icons.wb_sunny_rounded, color: Colors.orangeAccent, size: 20),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     outfitName,
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w900,
//                       color: Color(0xFF1A1A1A),
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Tailored to your body type & skin tone!',
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.black.withValues(alpha:0.45),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildImage(String path, {required bool isNetwork}) {
//     if (path.isEmpty) return const SizedBox();
//
//     return isNetwork
//         ? Image.network(
//       path,
//       fit: BoxFit.contain,
//       alignment: Alignment.center,
//       errorBuilder: (context, error, stackTrace) =>
//       const Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.white70),
//     )
//         : Image.asset(
//       path,
//       fit: BoxFit.contain,
//       alignment: Alignment.center,
//       errorBuilder: (context, error, stackTrace) =>
//       const Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.white70),
//     );
//   }
// }

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

              final box = GetStorage();
              final String profileGender = box.read('user_gender') ?? 'Women';

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

// class ShoppableGrid extends StatelessWidget {
//   final String category;
//   final String subType;
//   final String gender;
//
//   const ShoppableGrid({
//     super.key,
//     required this.category,
//     required this.subType,
//     required this.gender,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: Supabase.instance.client
//           .from('shopping_deals')
//           .stream(primaryKey: ['id']),
//           // .eq('category', category)
//           // .eq('gender', gender),
//       // We use .ilike on the item_name to find the specific sub-type (e.g., 'Wide Leg')
//       // .ilike('item_name', '%$subType%'),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) print("Supabase Error: ${snapshot.error}");
//
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         final List<Map<String, dynamic>> items =
//             (snapshot.data as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
//         // final filteredItems = items.where((item) => item['category'].toString().toLowerCase() == category).toList();
//         final filteredItems = items.where((item) {
//           // 🎯 Use lowercase and trim to ignore any spelling/space issues
//           String dbCategory = (item['category'] ?? "").toString().toLowerCase().trim();
//           String uiCategory = category.toLowerCase().trim();
//
//           String dbGender = (item['gender'] ?? "").toString().toLowerCase().trim();
//           String uiGender = gender.toLowerCase().trim();
//
//           return dbCategory == uiCategory && dbGender == uiGender;
//         }).toList();
//         if (filteredItems.isEmpty) {
//           return Center(
//             child: Text("No items found for $gender's $category"),
//           );
//         }
//
//         if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
//           return Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 20),
//               child: Text(
//                 "No $gender's $subType $category found.",
//                 style: const TextStyle(color: Colors.grey, fontSize: 12),
//               ),
//             ),
//           );
//         }
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Shop the Look", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
//             const SizedBox(height: 16),
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: items.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
//                 crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.65,
//               ),
//               itemBuilder: (context, index) => _buildProductCard(items[index]),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildProductCard(Map<String, dynamic> item) {
//     return GestureDetector(
//       onTap: () => launchUrl(Uri.parse(item['link']), mode: LaunchMode.externalApplication),
//       child: Container(
//         decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//                 child: ClipRRect(
//                     borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                     child: Image.network(
//                       item['image_url'],
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
//                     )
//                 )
//             ),
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(item['platform'].toString().toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.accentTeal)),
//                   Text(item['item_name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
//                   Text("₹${item['price']}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('shopping_deals')
          .stream(primaryKey: ['id'])
          .eq('gender', gender),
        // .limit(20),// Filter by Gender at the DB level
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text("Error: ${snapshot.error}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<Map<String, dynamic>> allItems = snapshot.data ?? [];


        print("---------------------------------------");
        print("🔍 DEBUGGING SHOPPABLE GRID");
        print("🎯 UI is looking for Category: '$topCategory'");
        print("🎯 UI is looking for Gender: '$gender'");
        print("📦 Total items received from Supabase: ${allItems.length}");

        if (allItems.isNotEmpty) {
          print("📋 Sample DB Category from first item: '${allItems[0]['category']}'");
          print("📋 Sample DB Gender from first item: '${allItems[0]['gender']}'");
        }
        print("---------------------------------------");

        // 🎯 1. FILTER LOGIC
        // This matches 'Jeans' with 'Jeans' and 'Women' with 'Women'
        final filteredItems = allItems.where((item) {
          String dbCat = (item['category'] ?? "").toString().toLowerCase().trim();
          String targetTop = topCategory.toLowerCase().trim();
          String targetBottom = bottomCategory.toLowerCase().trim();

          // Match if it's a top OR a bottom for this outfit
          return dbCat == targetTop || dbCat == targetBottom;
        }).toList();
        filteredItems.shuffle();
        // final filteredItems = allItems.where((item) {
        //   String dbCat = (item['category'] ?? "").toString().toLowerCase().trim();
        //   String uiCat = category.toLowerCase().trim();
        //
        //   // 🎯 THE FIX: If UI says 'bottomwear', treat it as 'jeans'
        //   // because that's what your Python script saved.
        //   if (uiCat == 'bottomwear') {
        //     return dbCat == 'jeans';
        //   }
        //
        //   return dbCat == uiCat;
        // }).toList();

        // 🎯 2. DEBUG PRINT
        // Look at your VS Code terminal to see these values!
        print("🔍 UI Category: $topCategory | DB Items Found: ${filteredItems.length}");

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

  // Widget _buildImage(String path) {
  //   if (path.isEmpty) return const SizedBox();
  //   return path.startsWith('http') ? Image.network(path, fit: BoxFit.contain) : Image.asset(path, fit: BoxFit.contain);
  // }

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