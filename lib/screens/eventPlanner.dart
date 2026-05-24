

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import '../services/event_outfit_service.dart'; // 🆕
import '../utils/constants/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'addEvent.dart';
import 'OutfitSuggestion.dart';

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
  void initState() {
    super.initState();
    eventController.removeExpiredEvents();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _scaffoldColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: _scaffoldColor,
        elevation: 0,
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
            child: CircleAvatar(
              radius: 200,
              backgroundColor: AppColors.accentTeal.withValues(alpha: 0.05),
            ),
          ),
          Obx(() {
            if (eventController.events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 64, color: Colors.grey.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    const Text("Your schedule is clear.",
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              );
            }
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                  size.width * 0.05, 120, size.width * 0.05, 150),
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
          Positioned(
            bottom: 120,
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
          BoxShadow(
              color: AppColors.accentTeal.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: FloatingActionButton.extended(
        heroTag: 'add_event_fab',
        onPressed: () => Get.to(() => const AddEventScreen()),
        label: const Text('SCHEDULE',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        icon: const Icon(Icons.add_rounded, size: 24),
        backgroundColor: AppColors.accentTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}


class _ModernTimelineCard extends StatelessWidget {
  final Event event;
  final bool isLast;

  const _ModernTimelineCard({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    //final size = MediaQuery.of(context).size;
    final primaryColor = Theme.of(context).textTheme.bodyLarge!.color!;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final service = EventOutfitService();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + line
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.accentTeal,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.accentTeal.withValues(alpha: 0.4),
                        blurRadius: 10)
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentTeal.withValues(alpha: 0.5),
                          Colors.transparent
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),

          // Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: timeLeft chip + menu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accentTeal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            event.timeLeft.toUpperCase(),
                            style: const TextStyle(
                                color: AppColors.accentTeal,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_horiz,
                              color: primaryColor.withValues(alpha: 0.3)),
                          onSelected: (value) {
                            if (value == 'delete') _confirmDelete(context);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete Event')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      event.title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 8),

                    // 🆕 Occasion chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        service.occasionLabel(event.title),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryColor.withValues(alpha: 0.6)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date / time / weather badges
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _infoBadge(context, Icons.calendar_today_rounded,
                            DateFormat('MMM d').format(event.date)),
                        _infoBadge(context, Icons.access_time_filled_rounded,
                            event.time),
                        if (event.weatherInfo != null &&
                            event.weatherInfo!.isNotEmpty)
                          _infoBadge(
                              context, Icons.cloud_outlined, event.weatherInfo!),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('OUTFIT LINEUP',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: primaryColor.withValues(alpha: 0.4),
                                letterSpacing: 1)),
                        _buildStackedAvatars(event.outfitImageUrls),
                      ],
                    ),
                    const SizedBox(height: 16),


                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showOutfitSuggestions(context),
                        icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                        label: const Text('SUGGEST OUTFIT',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentTeal,
                          side: BorderSide(
                              color: AppColors.accentTeal.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
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


  void _showOutfitSuggestions(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.accentTeal)),
    );

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        Get.back();
        Get.snackbar('Error', 'Please log in first.');
        return;
      }

      final response = await supabase
          .from('wardrobe_items')
          .select('*')
          .eq('user_id', userId);

      final List<Map<String, dynamic>> wardrobe = List<Map<String, dynamic>>.from(response);

      Get.back();

      if (wardrobe.isEmpty) {
        Get.snackbar(
          'Wardrobe Empty',
          'Please add clothes to your wardrobe first!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      final service = EventOutfitService();
      final outfits = service.generateOutfitsForEvent(
        event: event,
        wardrobeItems: wardrobe,
        count: 3,
      );

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _EventOutfitBottomSheet(event: event, outfits: outfits),
      );
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to fetch wardrobe items.');
    }
  }

  Widget _infoBadge(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accentTeal),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final controller = Get.find<EventController>();
    Get.defaultDialog(
      title: "Delete Event",
      middleText: "Are you sure you want to delete this event?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteEventByObject(event);
        Get.back();
      },
    );
  }

  Widget _buildStackedAvatars(List<String> urls) {
    return SizedBox(
      height: 32,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(urls.length, (index) {
          return Align(
            widthFactor: 0.6,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)
                ],
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(urls[index]),
                child: (urls[index].isEmpty ||
                    urls[index].contains('placehold'))
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


class _EventOutfitBottomSheet extends StatelessWidget {
  final Event event;
  final List<Map<String, dynamic>> outfits;

  const _EventOutfitBottomSheet(
      {required this.event, required this.outfits});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).textTheme.bodyLarge!.color!;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final service = EventOutfitService();

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI OUTFIT PICKS',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: AppColors.accentTeal)),
                  const SizedBox(height: 4),
                  Text(event.title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: primaryColor)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(service.occasionLabel(event.title),
                          style: TextStyle(
                              fontSize: 13,
                              color: primaryColor.withValues(alpha: 0.5))),
                      if (event.weatherInfo != null &&
                          event.weatherInfo!.isNotEmpty) ...[
                        Text(' · ',
                            style: TextStyle(
                                color: primaryColor.withValues(alpha: 0.3))),
                        Icon(Icons.thermostat_rounded,
                            size: 14,
                            color: primaryColor.withValues(alpha: 0.5)),
                        Text(' ${event.weatherInfo}',
                            style: TextStyle(
                                fontSize: 13,
                                color: primaryColor.withValues(alpha: 0.5))),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Outfit cards list
            Expanded(
              child: outfits.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.checkroom_outlined,
                        size: 48,
                        color: primaryColor.withValues(alpha: 0.2)),
                    const SizedBox(height: 12),
                    Text('No matching outfits found',
                        style: TextStyle(
                            color: primaryColor.withValues(alpha: 0.5))),
                    const SizedBox(height: 6),
                    Text('Try adding more clothes!',
                        style: TextStyle(
                            fontSize: 12,
                            color: primaryColor.withValues(alpha: 0.3))),
                  ],
                ),
              )
                  : ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: outfits.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, index) =>
                    _OutfitSuggestionCard(outfit: outfits[index], rank: index + 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _OutfitSuggestionCard extends StatelessWidget {
  final Map<String, dynamic> outfit;
  final int rank;

  const _OutfitSuggestionCard({required this.outfit, required this.rank});

  @override
  @override
Widget build(BuildContext context) {
  final primaryColor = Theme.of(context).textTheme.bodyLarge!.color!;

  final top = outfit['top'] as Map<String, dynamic>;
  final bottom = outfit['bottom'] as Map<String, dynamic>?;
  final footwear = outfit['footwear'] as Map<String, dynamic>?;

  final score = outfit['score'] as int;
  final season = outfit['season'] as String? ?? '';
  final subType = outfit['sub_type'] as String? ?? '';

  String seasonEmoji = switch (season) {
    'Hot' => '☀️',
    'Warm' => '🌤️',
    'Cool' => '🍂',
    'Cold' => '❄️',
    _ => '🌡️',
  };

  return GestureDetector(
    onTap: () {
      Get.back();
      Get.to(
        () => OutfitSuggestionScreen(
          initialOutfitData: outfit,
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rank == 1
            ? AppColors.accentTeal.withValues(alpha: 0.08)
            : primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: rank == 1
              ? AppColors.accentTeal.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Rank + Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (rank == 1)
                    const Text(
                      '👑 ',
                      style: TextStyle(fontSize: 16),
                    ),

                  Text(
                    rank == 1
                        ? 'TOP PICK'
                        : 'OPTION $rank',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: rank == 1
                          ? AppColors.accentTeal
                          : primaryColor.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Text(
                    '$seasonEmoji ',
                    style: const TextStyle(fontSize: 12),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Score: $score',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentTeal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// Top / Dress
          _itemRow(
            context: context,
            icon: Icons.checkroom_rounded,
            label: outfit['is_dress'] == true
                ? 'DRESS'
                : 'TOP',
            name: top['item_name'] ??
                (outfit['is_dress'] == true
                    ? 'Dress'
                    : 'Top'),
            color: top['color'] ?? '',
            extra: top['style'] ?? '',
          ),

          /// Bottom
          if (bottom != null) ...[
            const SizedBox(height: 10),

            _itemRow(
              context: context,
              icon: Icons.accessibility_new_rounded,
              label: 'BOTTOM',
              name: bottom['item_name'] ?? 'Bottom',
              color: bottom['color'] ?? '',
              extra: subType.isNotEmpty &&
                      subType != 'Unknown'
                  ? subType
                  : (bottom['style'] ?? ''),
            ),
          ],

          /// Footwear
          if (footwear != null) ...[
            const SizedBox(height: 10),

            _itemRow(
              context: context,
              icon: Icons.snowshoeing_rounded,
              label: 'FOOTWEAR',
              name: footwear['item_name'] ?? 'Footwear',
              color: footwear['color'] ?? '',
              extra: footwear['style'] ?? '',
            ),
          ],
        ],
      ),
    ),
  );
}

  Widget _itemRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String name,
    required String color,
    required String extra,
  }) {
    final primaryColor = Theme.of(context).textTheme.bodyLarge!.color!;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _parseColor(color).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon,
              size: 20, color: _parseColor(color).withValues(alpha: 0.8)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: primaryColor.withValues(alpha: 0.4))),
              const SizedBox(height: 2),
              Text(name,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: primaryColor)),
              if (color.isNotEmpty || extra.isNotEmpty)
                Text(
                    [color, extra]
                        .where((s) => s.isNotEmpty)
                        .join(' · ')
                        .capitalizeFirst!,
                    style: TextStyle(
                        fontSize: 11,
                        color: primaryColor.withValues(alpha: 0.5))),
            ],
          ),
        ),
      ],
    );
  }


  Color _parseColor(String colorStr) {
    final c = colorStr.toLowerCase();
    if (c.contains('red'))    return Colors.red;
    if (c.contains('blue'))   return Colors.blue;
    if (c.contains('green'))  return Colors.green;
    if (c.contains('black'))  return Colors.black87;
    if (c.contains('white'))  return Colors.grey;
    if (c.contains('yellow')) return Colors.amber;
    if (c.contains('orange')) return Colors.orange;
    if (c.contains('pink'))   return Colors.pink;
    if (c.contains('purple') || c.contains('violet')) return Colors.purple;
    if (c.contains('brown') || c.contains('caramel')) return Colors.brown;
    if (c.contains('teal') || c.contains('cyan'))     return Colors.teal;
    if (c.contains('navy'))   return const Color(0xFF001F5B);
    if (c.contains('grey') || c.contains('gray'))     return Colors.grey;
    if (c.contains('beige') || c.contains('cream'))   return const Color(0xFFF5F0E8);
    return AppColors.accentTeal;
  }
}
