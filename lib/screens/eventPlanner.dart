import 'package:smart_wardrobe_new/screens/addEvent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 🎯 GetX Import
import 'package:intl/intl.dart';

import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import '../utils/constants/colors.dart'; // Date formatting के लिए

// --- Custom Colors ---
// class AppColors {
//   static const Color accentTeal = Color(0xFF00ADB5);
// // ⚠️ बाकी Hardcoded Colors हटा दिए गए हैं, वे Theme से आएंगे।
// }

// --- Data Model for an Event (unchanged) ---
// class Event {
//   final String title;
//   final DateTime date;
//   final String time;
//   final String timeLeft;
//   final List<String> outfitImageUrls;
//
//   Event({
//     required this.title,
//     required this.date,
//     required this.time,
//     required this.timeLeft,
//     required this.outfitImageUrls,
//   });
// }

// --- Main Event Planner Screen ---
class EventPlannerScreen extends StatefulWidget {
  const EventPlannerScreen({super.key});

  @override
  State<EventPlannerScreen> createState() => _EventPlannerScreenState();
}

class _EventPlannerScreenState extends State<EventPlannerScreen> {

  final EventController eventController = Get.put(EventController());
  // Mock Data (unchanged)
  // final List<Event> _events = [
  //   Event(
  //     title: "Gala Charity Event",
  //     date: DateTime(2024, 8, 10),
  //     time: "6:00 PM",
  //     timeLeft: "3 weeks left",
  //     outfitImageUrls: [
  //       'https://i.pravatar.cc/150?img=60',
  //       'https://i.pravatar.cc/150?img=62',
  //     ],
  //   ),
  //   Event(
  //     title: "Summer Fashion Show - Casual Collection",
  //     date: DateTime(2024, 9, 1),
  //     time: "2:30 PM",
  //     timeLeft: "5 weeks left",
  //     outfitImageUrls: [
  //       'https://i.pravatar.cc/150?img=4',
  //       'https://i.pravatar.cc/150?img=12',
  //     ],
  //   ),
  //   Event(
  //     title: "Networking Mixer - Professional Wear",
  //     date: DateTime(2024, 10, 25),
  //     time: "7:00 PM",
  //     timeLeft: "2 months left",
  //     outfitImageUrls: [
  //       'https://i.pravatar.cc/150?img=20',
  //     ],
  //   ),
  // ];

  // 🎯 Theme Getters
  Color get _primaryTextColor => Theme.of(context).textTheme.bodyLarge!.color!;
  Color get _scaffoldColor => Theme.of(context).scaffoldBackgroundColor;
  Color get _surfaceColor => Theme.of(context).colorScheme.surface;


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05;

    return Scaffold(
      // 🎯 Theme-Aware Background Color
      backgroundColor: _scaffoldColor,
      appBar: AppBar(
        // AppBar Background color Theme से आएगा
        elevation: 0,
        toolbarHeight: size.height * 0.08,
        title: Text(
          'Event Planner',
          style: TextStyle(
            // 🎯 Theme-Aware Text Color
            color: _primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: size.width * 0.05,
          ),
        ),
        centerTitle: true,
        // 🎯 Theme-Aware Icon Color
        iconTheme: IconThemeData(color: _primaryTextColor),
      ),
      body: Obx(() {
        // GetX needs to see 'eventController.events' being accessed right here
        if (eventController.events.isEmpty) {
          return const Center(
            child: Text("No events planned yet. Tap '+' to add one!"),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.02
          ),
          itemCount: eventController.events.length, // 🎯 Accessing the .obs variable
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.02),
              child: _EventCard(event: eventController.events[index]),
            );
          },
        );
      }),

      // Floating Action Button
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildAddEventButton(size),
    );
  }

  Widget _buildAddEventButton(Size size) {
    return FloatingActionButton.extended(
      onPressed: () {
        // 🎯 GetX Navigation
        Get.to(() => const AddEventScreen());
      },
      label: Text(
        'Add New Event',
        style: TextStyle(
          fontSize: size.width * 0.04,
          fontWeight: FontWeight.bold,
        ),
      ),
      icon: Icon(Icons.add, size: size.width * 0.06),
      backgroundColor: AppColors.accentTeal,
      foregroundColor: Colors.white, // Text color is white on teal
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.04),
      ),
      elevation: 6,
    );
  }
}

// --- Event Card Widget (Responsive and Theme-Aware) ---
class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard({required this.event});

  // 🎯 Theme Getters for StatelessWidget
  Color _primaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.color!;
  Color _secondaryTextColor(BuildContext context) => Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
  Color _surfaceColor(BuildContext context) => Theme.of(context).colorScheme.surface;
  Color _scaffoldColor(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor(context), // 🎯 Theme-Aware Card Background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // 🎯 Theme-Aware Shadow Color
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left Border/Indicator Line (Remains Accent Teal)
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: AppColors.accentTeal,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),

            // Event Details Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: TextStyle(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: _primaryTextColor(context), // 🎯 Theme-Aware Text Color
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.015),

                    // Date & Time
                    _buildIconText(
                      context: context, // Pass context
                      icon: Icons.calendar_today_outlined,
                      text: DateFormat('MMM d, yyyy').format(event.date), // Using intl for better formatting
                      size: size,
                    ),
                    _buildIconText(
                      context: context, // Pass context
                      icon: Icons.access_time,
                      text: event.time,
                      size: size,
                    ),

                    SizedBox(height: size.height * 0.01),

                    // Time Left Indicator (Remains Accent Teal)
                    Row(
                      children: [
                        const Icon(
                          Icons.query_builder,
                          size: 14, // Fixed size for consistency
                          color: AppColors.accentTeal,
                        ),
                        SizedBox(width: size.width * 0.01),
                        Text(
                          event.timeLeft,
                          style: TextStyle(
                            fontSize: size.width * 0.035,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentTeal,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.02),

                    // Linked Outfits
                    Text(
                      'Linked Outfits:',
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        color: _secondaryTextColor(context), // 🎯 Theme-Aware Secondary Text Color
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),

                    _buildOutfitAvatars(event.outfitImageUrls, size, context), // Pass context
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for Icon and Text rows
  Widget _buildIconText({required BuildContext context, required IconData icon, required String text, required Size size}) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.005),
      child: Row(
        children: [
          Icon(
            icon,
            size: size.width * 0.04,
            color: _secondaryTextColor(context), // 🎯 Theme-Aware Icon Color
          ),
          SizedBox(width: size.width * 0.02),
          Text(
            text,
            style: TextStyle(
              fontSize: size.width * 0.038,
              color: _primaryTextColor(context), // 🎯 Theme-Aware Text Color
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Outfit Avatars
  Widget _buildOutfitAvatars(List<String> urls, Size size, BuildContext context) {
    final double avatarRadius = size.width * 0.04;
    return Row(
      children: urls.map((url) {
        return Padding(
          padding: EdgeInsets.only(right: size.width * 0.015),
          child: CircleAvatar(
            radius: avatarRadius,
            // 🎯 Theme-Aware Placeholder Background
            backgroundColor: _scaffoldColor(context),
            backgroundImage: NetworkImage(url),
            onBackgroundImageError: (exception, stackTrace) {
              print('Error loading image: $url');
            },
            child: (url.isEmpty || url.contains('placehold') || url.contains('pravatar'))
            // 🎯 Theme-Aware Fallback Icon Color
                ? Icon(Icons.checkroom, color: _secondaryTextColor(context))
                : null,
          ),
        );
      }).toList(),
    );
  }
}