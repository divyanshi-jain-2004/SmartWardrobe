// import 'package:smart_wardrobe_new/screens/addEvent.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart'; // 🎯 GetX Import
// import 'package:intl/intl.dart';
//
// import '../controllers/event_controller.dart';
// import '../models/event_model.dart';
// import '../utils/constants/colors.dart'; // Date formatting के लिए
//
// // --- Custom Colors ---
// // class AppColors {
// //   static const Color accentTeal = Color(0xFF00ADB5);
// // // ⚠️ बाकी Hardcoded Colors हटा दिए गए हैं, वे Theme से आएंगे।
// // }
//
// // --- Data Model for an Event (unchanged) ---
// // class Event {
// //   final String title;
// //   final DateTime date;
// //   final String time;
// //   final String timeLeft;
// //   final List<String> outfitImageUrls;
// //
// //   Event({
// //     required this.title,
// //     required this.date,
// //     required this.time,
// //     required this.timeLeft,
// //     required this.outfitImageUrls,
// //   });
// // }
//
// // --- Main Event Planner Screen ---
// class EventPlannerScreen extends StatefulWidget {
//   const EventPlannerScreen({super.key});
//
//   @override
//   State<EventPlannerScreen> createState() => _EventPlannerScreenState();
// }
//
// class _EventPlannerScreenState extends State<EventPlannerScreen> {
//
//   final EventController eventController = Get.put(EventController());
//   // Mock Data (unchanged)
//   // final List<Event> _events = [
//   //   Event(
//   //     title: "Gala Charity Event",
//   //     date: DateTime(2024, 8, 10),
//   //     time: "6:00 PM",
//   //     timeLeft: "3 weeks left",
//   //     outfitImageUrls: [
//   //       'https://i.pravatar.cc/150?img=60',
//   //       'https://i.pravatar.cc/150?img=62',
//   //     ],
//   //   ),
//   //   Event(
//   //     title: "Summer Fashion Show - Casual Collection",
//   //     date: DateTime(2024, 9, 1),
//   //     time: "2:30 PM",
//   //     timeLeft: "5 weeks left",
//   //     outfitImageUrls: [
//   //       'https://i.pravatar.cc/150?img=4',
//   //       'https://i.pravatar.cc/150?img=12',
//   //     ],
//   //   ),
//   //   Event(
//   //     title: "Networking Mixer - Professional Wear",
//   //     date: DateTime(2024, 10, 25),
//   //     time: "7:00 PM",
//   //     timeLeft: "2 months left",
//   //     outfitImageUrls: [
//   //       'https://i.pravatar.cc/150?img=20',
//   //     ],
//   //   ),
//   // ];
//
//   // 🎯 Theme Getters
//   Color get _primaryTextColor => Theme.of(context).textTheme.bodyLarge!.color!;
//   Color get _scaffoldColor => Theme.of(context).scaffoldBackgroundColor;
//   Color get _surfaceColor => Theme.of(context).colorScheme.surface;
//
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final horizontalPadding = size.width * 0.05;
//
//     return Scaffold(
//       // 🎯 Theme-Aware Background Color
//       backgroundColor: _scaffoldColor,
//       appBar: AppBar(
//         // AppBar Background color Theme से आएगा
//         elevation: 0,
//         toolbarHeight: size.height * 0.08,
//         title: Text(
//           'Event Planner',
//           style: TextStyle(
//             // 🎯 Theme-Aware Text Color
//             color: _primaryTextColor,
//             fontWeight: FontWeight.bold,
//             fontSize: size.width * 0.05,
//           ),
//         ),
//         centerTitle: true,
//         // 🎯 Theme-Aware Icon Color
//         iconTheme: IconThemeData(color: _primaryTextColor),
//       ),
//       body: Obx(() {
//         // GetX needs to see 'eventController.events' being accessed right here
//         if (eventController.events.isEmpty) {
//           return const Center(
//             child: Text("No events planned yet. Tap '+' to add one!"),
//           );
//         }
//
//         return ListView.builder(
//           padding: EdgeInsets.symmetric(
//               horizontal: size.width * 0.05,
//               vertical: size.height * 0.02
//           ),
//           itemCount: eventController.events.length, // 🎯 Accessing the .obs variable
//           itemBuilder: (context, index) {
//             return Padding(
//               padding: EdgeInsets.only(bottom: size.height * 0.02),
//               child: _EventCard(event: eventController.events[index]),
//             );
//           },
//         );
//       }),
//
//       // Floating Action Button
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       floatingActionButton: _buildAddEventButton(size),
//     );
//   }
//
//   Widget _buildAddEventButton(Size size) {
//     return FloatingActionButton.extended(
//       onPressed: () {
//         // 🎯 GetX Navigation
//         Get.to(() => const AddEventScreen());
//       },
//       label: Text(
//         'Add New Event',
//         style: TextStyle(
//           fontSize: size.width * 0.04,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       icon: Icon(Icons.add, size: size.width * 0.06),
//       backgroundColor: AppColors.accentTeal,
//       foregroundColor: Colors.white, // Text color is white on teal
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(size.width * 0.04),
//       ),
//       elevation: 6,
//     );
//   }
// }
//
// // --- Event Card Widget (Responsive and Theme-Aware) ---
// class _EventCard extends StatelessWidget {
//   final Event event;
//
//   const _EventCard({required this.event});
//
//   // 🎯 Theme Getters for StatelessWidget
//   Color _primaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.color!;
//   Color _secondaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
//   Color _surfaceColor(BuildContext context) => Theme.of(context).colorScheme.surface;
//   Color _scaffoldColor(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
//
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: _surfaceColor(context), // 🎯 Theme-Aware Card Background
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             // 🎯 Theme-Aware Shadow Color
//             color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: IntrinsicHeight(
//         child: Row(
//           children: [
//             // Left Border/Indicator Line (Remains Accent Teal)
//             Container(
//               width: 5,
//               decoration: const BoxDecoration(
//                 color: AppColors.accentTeal,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   bottomLeft: Radius.circular(12),
//                 ),
//               ),
//             ),
//
//             // Event Details Content
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.all(size.width * 0.04),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Title
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             event.title,
//                             style: TextStyle(
//                               fontSize: size.width * 0.045,
//                               fontWeight: FontWeight.bold,
//                               color: _primaryTextColor(context), // 🎯 Theme-Aware Text Color
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: size.height * 0.015),
//
//                     // Date & Time
//                     _buildIconText(
//                       context: context, // Pass context
//                       icon: Icons.calendar_today_outlined,
//                       text: DateFormat('MMM d, yyyy').format(event.date), // Using intl for better formatting
//                       size: size,
//                     ),
//                     _buildIconText(
//                       context: context, // Pass context
//                       icon: Icons.access_time,
//                       text: event.time,
//                       size: size,
//                     ),
//
//                     SizedBox(height: size.height * 0.01),
//
//                     // Time Left Indicator (Remains Accent Teal)
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.query_builder,
//                           size: 14, // Fixed size for consistency
//                           color: AppColors.accentTeal,
//                         ),
//                         SizedBox(width: size.width * 0.01),
//                         Text(
//                           event.timeLeft,
//                           style: TextStyle(
//                             fontSize: size.width * 0.035,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.accentTeal,
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: size.height * 0.02),
//
//                     // Linked Outfits
//                     Text(
//                       'Linked Outfits:',
//                       style: TextStyle(
//                         fontSize: size.width * 0.035,
//                         color: _secondaryTextColor(context), // 🎯 Theme-Aware Secondary Text Color
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.01),
//
//                     _buildOutfitAvatars(event.outfitImageUrls, size, context), // Pass context
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Helper for Icon and Text rows
//   Widget _buildIconText({required BuildContext context, required IconData icon, required String text, required Size size}) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: size.height * 0.005),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             size: size.width * 0.04,
//             color: _secondaryTextColor(context), // 🎯 Theme-Aware Icon Color
//           ),
//           SizedBox(width: size.width * 0.02),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: size.width * 0.038,
//               color: _primaryTextColor(context), // 🎯 Theme-Aware Text Color
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper for Outfit Avatars
//   Widget _buildOutfitAvatars(List<String> urls, Size size, BuildContext context) {
//     final double avatarRadius = size.width * 0.04;
//     return Row(
//       children: urls.map((url) {
//         return Padding(
//           padding: EdgeInsets.only(right: size.width * 0.015),
//           child: CircleAvatar(
//             radius: avatarRadius,
//             // 🎯 Theme-Aware Placeholder Background
//             backgroundColor: _scaffoldColor(context),
//             backgroundImage: NetworkImage(url),
//             onBackgroundImageError: (exception, stackTrace) {
//               print('Error loading image: $url');
//             },
//             child: (url.isEmpty || url.contains('placehold') || url.contains('pravatar'))
//             // 🎯 Theme-Aware Fallback Icon Color
//                 ? Icon(Icons.checkroom, color: _secondaryTextColor(context))
//                 : null,
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

import 'dart:ui';
import 'package:smart_wardrobe_new/screens/addEvent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import '../utils/constants/colors.dart';

class EventPlannerScreen extends StatefulWidget {
  const EventPlannerScreen({super.key});

  @override
  State<EventPlannerScreen> createState() => _EventPlannerScreenState();
}

class _EventPlannerScreenState extends State<EventPlannerScreen> {
  final EventController eventController = Get.put(EventController());

  Color get _primaryTextColor => Theme.of(context).textTheme.bodyLarge!.color!;
  Color get _scaffoldColor => Theme.of(context).scaffoldBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _scaffoldColor,
      extendBody: true, // 🎯 Essential to work with the shell's navigation
      appBar: AppBar(
        backgroundColor: _scaffoldColor.withOpacity(0.8),
        elevation: 0,
        flexibleSpace: ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(color: Colors.transparent))),
        title: Text(
          'UPCOMING EVENTS',
          style: TextStyle(
            color: _primaryTextColor,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: CircleAvatar(radius: 200, backgroundColor: AppColors.accentTeal.withOpacity(0.05)),
          ),

          Obx(() {
            if (eventController.events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    const Text("Your schedule is clear.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              // 🎯 Added significant bottom padding (150) so cards aren't blocked by the bar
              padding: EdgeInsets.fromLTRB(size.width * 0.05, 120, size.width * 0.05, 150),
              itemCount: eventController.events.length,
              itemBuilder: (context, index) {
                bool isLast = index == eventController.events.length - 1;
                return _ModernTimelineCard(
                  event: eventController.events[index],
                  isLast: isLast,
                );
              },
            );
          }),

          // 🎯 MANUALLY POSITIONED FAB
          // This ensures the button sits above the navigation bar instead of behind it
          Positioned(
            bottom: 120, // Adjusted to sit exactly above the floating nav bar
            right: 20,
            child: _buildAddEventButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddEventButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.accentTeal.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: FloatingActionButton.extended(
        heroTag: 'add_event_fab', // Unique tag to prevent hero errors
        onPressed: () => Get.to(() => const AddEventScreen()),
        label: const Text('SCHEDULE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        icon: const Icon(Icons.add_rounded, size: 24),
        backgroundColor: AppColors.accentTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}

// ... Keep _ModernTimelineCard class as it was ...

class _ModernTimelineCard extends StatelessWidget {
  final Event event;
  final bool isLast;

  const _ModernTimelineCard({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primaryColor = Theme.of(context).textTheme.bodyLarge!.color!;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Logic
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.accentTeal,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [BoxShadow(color: AppColors.accentTeal.withOpacity(0.4), blurRadius: 10)],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accentTeal.withOpacity(0.5), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),

          // Card Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accentTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            event.timeLeft.toUpperCase(),
                            style: const TextStyle(color: AppColors.accentTeal, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                        ),
                        Icon(Icons.more_horiz, color: primaryColor.withOpacity(0.3)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryColor, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 16),
                    // Row(
                    //   children: [
                    //     _infoBadge(context, Icons.calendar_today_rounded, DateFormat('MMM d').format(event.date)),
                    //     const SizedBox(width: 10),
                    //     _infoBadge(context, Icons.access_time_filled_rounded, event.time),
                    //
                    //     if (event.weatherInfo != null && event.weatherInfo!.isNotEmpty) ...[
                    //       const SizedBox(width: 10),
                    //       _infoBadge(context, Icons.cloud_outlined, event.weatherInfo!),
                    //     ],
                    //   ],
                    // ),
                    // REPLACE the Row containing _infoBadges with this:
                    Wrap(
                      spacing: 10, // Horizontal space between badges
                      runSpacing: 8, // Vertical space if it wraps to a new line
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _infoBadge(context, Icons.calendar_today_rounded, DateFormat('MMM d').format(event.date)),
                        _infoBadge(context, Icons.access_time_filled_rounded, event.time),

                        // Only show if weather exists
                        if (event.weatherInfo != null && event.weatherInfo!.isNotEmpty)
                          _infoBadge(context, Icons.cloud_outlined, event.weatherInfo!),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('OUTFIT LINEUP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: primaryColor.withOpacity(0.4), letterSpacing: 1)),
                        _buildStackedAvatars(event.outfitImageUrls),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.accentTeal),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildStackedAvatars(List<String> urls) {
    return SizedBox(
      height: 32,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(urls.length, (index) {
          return Align(
            widthFactor: 0.6, // This creates the "Stacked" effect
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(urls[index]),
                child: (urls[index].isEmpty || urls[index].contains('placehold'))
                    ? const Icon(Icons.checkroom, size: 14, color: Colors.grey)
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}