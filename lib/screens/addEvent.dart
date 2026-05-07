
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import '../services/weather_service.dart';
import '../utils/constants/colors.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final EventController eventController = Get.find();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Color get _primaryTextColor => Theme.of(context).textTheme.bodyLarge!.color!;
  Color get _secondaryTextColor => Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
  Color get _surfaceColor => Theme.of(context).colorScheme.surface;
  Color get _scaffoldColor => Theme.of(context).scaffoldBackgroundColor;

  @override
  void dispose() {
    _eventNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.accentTeal),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.accentTeal),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedTime) setState(() => _selectedTime = picked);
  }

  void _addEvent() async{
    if (_eventNameController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
      Get.snackbar('Required Fields Missing', 'Please fill in Event Name, Date, and Time.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    String fetchedWeather = "No data";
    if (_locationController.text.isNotEmpty) {
      fetchedWeather = await WeatherService().fetchWeather(_locationController.text);
    }
    final newEvent = Event(
      title: _eventNameController.text,
      date: _selectedDate!,
      time: _selectedTime!.format(context),
      timeLeft: "Upcoming",
      outfitImageUrls: [],
      location: _locationController.text,
      weatherInfo: fetchedWeather,
    );
    eventController.addEvent(newEvent);
    Get.back();
    Get.snackbar('Success', '${_eventNameController.text} added successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.accentTeal,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(15),
        icon: const Icon(Icons.check_circle, color: Colors.white));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _scaffoldColor,
      body: Stack(
        children: [
          // Background Gradient Element
          Positioned(
            top: -50,
            right: -50,
            child: CircleAvatar(radius: 150, backgroundColor: AppColors.accentTeal.withOpacity(0.05)),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Modern Flexible AppBar
              SliverAppBar(
                expandedHeight: 180,
                backgroundColor: _scaffoldColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.close_rounded, color: _primaryTextColor),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    "CREATE EVENT",
                    style: TextStyle(
                      color: _primaryTextColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(Icons.auto_awesome_rounded, color: AppColors.accentTeal.withOpacity(0.3), size: 50),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildModernFormSection(size),
                      const SizedBox(height: 120), // Spacer for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Pinned Bottom Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  decoration: BoxDecoration(
                    color: _scaffoldColor.withOpacity(0.8),
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                  ),
                  child: ElevatedButton(
                    onPressed: _addEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentTeal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      shadowColor: AppColors.accentTeal.withOpacity(0.4),
                    ),
                    child: const Text('CONFIRM EVENT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFormSection(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel("THE BASICS"),
        const SizedBox(height: 15),
        _buildInputField(
          controller: _eventNameController,
          hintText: 'What is the occasion?',
          label: 'Event Name',
          icon: Icons.edit_note_rounded,
        ),
        const SizedBox(height: 25),
        _sectionLabel("DATE & TIME"),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildClickableField(
              text: _selectedDate == null ? 'Select Date' : DateFormat('MMM d, yyyy').format(_selectedDate!),
              icon: Icons.calendar_today_rounded,
              onTap: () => _selectDate(context),
            )),
            const SizedBox(width: 15),
            Expanded(child: _buildClickableField(
              text: _selectedTime == null ? 'Select Time' : _selectedTime!.format(context),
              icon: Icons.access_time_rounded,
              onTap: () => _selectTime(context),
            )),
          ],
        ),
        const SizedBox(height: 25),
        _sectionLabel("LOCATION & DETAILS"),
        const SizedBox(height: 15),
        _buildInputField(
          controller: _locationController,
          hintText: 'Where is it happening?',
          label: 'Location',
          icon: Icons.place_rounded,
        ),
        const SizedBox(height: 15),
        _buildInputField(
          controller: _descriptionController,
          hintText: 'Any specific dress code or notes?',
          label: 'Description',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppColors.accentTeal.withOpacity(0.8),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required String label,
    IconData? icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _primaryTextColor.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.w600),
        cursorColor: AppColors.accentTeal,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _secondaryTextColor, fontSize: 13),
          hintText: hintText,
          hintStyle: TextStyle(color: _secondaryTextColor.withOpacity(0.3), fontSize: 14),
          border: InputBorder.none,
          suffixIcon: icon != null ? Icon(icon, color: AppColors.accentTeal.withOpacity(0.4), size: 20) : null,
        ),
      ),
    );
  }

  Widget _buildClickableField({required String text, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _primaryTextColor.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.accentTeal, size: 20),
            const SizedBox(height: 10),
            Text(text, style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}