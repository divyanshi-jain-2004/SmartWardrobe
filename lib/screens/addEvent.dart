import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import '../utils/constants/colors.dart'; // 🎯 GetX Import

// --- Custom Colors ---
// class AppColors {
//   static const Color accentTeal = Color(0xFF00ADB5);
// // ⚠️ Hardcoded primaryText, secondaryText, lightGrayBackground, backgroundWhite हटा दिए गए हैं
// }

// --------------------------------------------------------------------------------
//                             ADD EVENT SCREEN
// --------------------------------------------------------------------------------

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final EventController eventController = Get.find();
  // State for form data
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // 🎯 Get current theme's text color for better readability in methods
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

  // --- Function to show Date Picker (Calendar) ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      // 🎯 Theme Builder हटा दिया गया, ताकि Picker ऐप की मुख्य थीम (Dark/Light) का पालन करे
      // यदि आप Picker को हमेशा Light या Dark रखना चाहते हैं, तो Theme Builder का उपयोग करें,
      // अन्यथा, इसे छोड़ दें ताकि यह GetMaterialApp की थीम को फॉलो करे।
      builder: (context, child) {
        // Picker को Theme-Aware बनाने के लिए, हम सिर्फ Accent Color को ओवरराइड कर सकते हैं
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.accentTeal, // Accent color हमेशा Teal रहेगा
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // --- Function to show Time Picker ---
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      // 🎯 Theme Builder हटा दिया गया, ताकि Picker ऐप की मुख्य थीम (Dark/Light) का पालन करे
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.accentTeal, // Accent color हमेशा Teal रहेगा
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // ... inside _AddEventScreenState ...

// Find the existing controller


  void _addEvent() {
    if (_eventNameController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
      Get.snackbar(
        'Required Fields Missing',
        'Please fill in Event Name, Date, and Time.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // 1. Create the New Event Object
    final newEvent = Event(
      title: _eventNameController.text,
      date: _selectedDate!,
      time: _selectedTime!.format(context),
      timeLeft: "Upcoming",
      outfitImageUrls: [],
    );

    // 2. Add it to the Controller
    eventController.addEvent(newEvent);

    // 3. Navigate back FIRST, then show the snackbar on the Planner screen
    Get.back();

    // This snackbar will now appear on top of the Event Planner screen
    Get.snackbar(
      'Success',
      '${_eventNameController.text} added successfully!',
      snackPosition: SnackPosition.TOP, // Top is often more visible after navigation
      backgroundColor: AppColors.accentTeal,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(15),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05;
    final cardMargin = size.height * 0.02;

    return Scaffold(
      // 🎯 Theme-Aware Background Color
      backgroundColor: _scaffoldColor,
      // --- AppBar ---
      appBar: AppBar(
        // AppBar background color Theme से आएगा
        elevation: 0,
        toolbarHeight: size.height * 0.08,
        leading: IconButton(
          // 🎯 Theme-Aware Icon Color
          icon: Icon(Icons.close, color: _primaryTextColor),
          onPressed: () => Get.back(), // 🎯 GetX Navigation
        ),
        title: Text(
          'Add New Event',
          style: TextStyle(
            // 🎯 Theme-Aware Text Color
            color: _primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: size.width * 0.05,
          ),
        ),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: cardMargin),
            child: Column(
              children: [
                // 1. Event Details Card
                _buildEventDetailsCard(size),

                // Extra padding to ensure scrollable content clears the Add Event button
                SizedBox(height: size.height * 0.15),
              ],
            ),
          ),

          // 2. Floating Add Event Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: _surfaceColor, // 🎯 Theme-Aware Color (White/Dark Card)
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: size.height * 0.02),
              child: ElevatedButton(
                onPressed: _addEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors.white, // Foreground color is always white for contrast on teal
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Add Event',
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailsCard(Size size) {
    return Card(
      elevation: 4,
      // 🎯 Card color Theme से आएगा
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Details',
              style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: _primaryTextColor, // 🎯 Theme-Aware Text Color
              ),
            ),
            SizedBox(height: size.height * 0.025),

            // Event Name
            _buildInputField(
              controller: _eventNameController,
              hintText: 'Event Name',
              size: size,
            ),
            SizedBox(height: size.height * 0.02),

            // Date Picker Field (Opens Calendar)
            _buildDateInput(size),
            SizedBox(height: size.height * 0.02),

            // Time Picker Field (Opens Time Picker)
            _buildTimeInput(size),
            SizedBox(height: size.height * 0.02),

            // Location
            _buildInputField(
              controller: _locationController,
              hintText: 'Location',
              icon: Icons.location_on_outlined,
              size: size,
            ),
            SizedBox(height: size.height * 0.02),

            // Description (Multi-line)
            _buildInputField(
              controller: _descriptionController,
              hintText: 'Description (Optional)',
              maxLines: 3,
              size: size,
            ),
          ],
        ),
      ),
    );
  }

  // --- Reusable Input Field Widget ---
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    int maxLines = 1,
    required Size size,
  }) {
    // 🎯 Input field fill color: Scaffold/Light background color
    final inputFillColor = _scaffoldColor;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(fontSize: size.width * 0.04, color: _primaryTextColor), // 🎯 Theme Text
      cursorColor: AppColors.accentTeal,
      decoration: InputDecoration(
        filled: true,
        fillColor: inputFillColor, // 🎯 Theme-Aware Fill Color
        hintText: hintText,
        hintStyle: TextStyle(color: _secondaryTextColor), // 🎯 Theme Secondary Text
        contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.02),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon: icon != null
            ? Padding(
          padding: EdgeInsets.only(right: size.width * 0.02),
          child: Icon(icon, color: _secondaryTextColor, size: size.width * 0.06), // 🎯 Theme Secondary Text
        )
            : null,
      ),
    );
  }

  // --- Date Input Field (Tappable) ---
  Widget _buildDateInput(Size size) {
    // 🎯 Input field fill color: Scaffold/Light background color
    final inputFillColor = _scaffoldColor;

    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: inputFillColor, // 🎯 Theme-Aware Fill Color
          contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.02),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          hintText: 'Date',
          hintStyle: TextStyle(color: _secondaryTextColor), // 🎯 Theme Secondary Text
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: size.width * 0.02),
            child: Icon(Icons.calendar_today_outlined, color: _secondaryTextColor, size: size.width * 0.06), // 🎯 Theme Secondary Text
          ),
        ),
        child: Text(
          _selectedDate == null
              ? 'Date'
              : DateFormat('EEEE, MMM d, yyyy').format(_selectedDate!),
          style: TextStyle(
            fontSize: size.width * 0.04,
            // 🎯 Theme-Aware Text Color
            color: _selectedDate == null ? _secondaryTextColor : _primaryTextColor,
          ),
        ),
      ),
    );
  }

  // --- Time Input Field (Tappable) ---
  Widget _buildTimeInput(Size size) {
    // 🎯 Input field fill color: Scaffold/Light background color
    final inputFillColor = _scaffoldColor;

    return InkWell(
      onTap: () => _selectTime(context),
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: inputFillColor, // 🎯 Theme-Aware Fill Color
          contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.02),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          hintText: 'Time',
          hintStyle: TextStyle(color: _secondaryTextColor), // 🎯 Theme Secondary Text
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: size.width * 0.02),
            child: Icon(Icons.access_time, color: _secondaryTextColor, size: size.width * 0.06), // 🎯 Theme Secondary Text
          ),
        ),
        child: Text(
          _selectedTime == null
              ? 'Time'
              : _selectedTime!.format(context),
          style: TextStyle(
            fontSize: size.width * 0.04,
            // 🎯 Theme-Aware Text Color
            color: _selectedTime == null ? _secondaryTextColor : _primaryTextColor,
          ),
        ),
      ),
    );
  }
}