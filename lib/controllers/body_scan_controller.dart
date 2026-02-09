import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class BodyScanController extends GetxController {
  final box = GetStorage();

  var isScanning = false.obs;
  var detectedBodyType = "".obs;
  var detectedSkinTone = Rxn<Color>();
  var detectedSkinToneName = "".obs;

  // Body type categories
  final List<String> bodyTypes = [
    'Pear',
    'Apple',
    'Rectangle',
    'Inverted Triangle',
    'Hourglass'
  ];

  // Skin tone palette (must match EditProfileController)
  final List<Map<String, dynamic>> skinToneData = [
    {"name": "Fair", "color": const Color(0xFFFFE7D1)},
    {"name": "Light", "color": const Color(0xFFF3D5B5)},
    {"name": "Medium", "color": const Color(0xFFC69061)},
    {"name": "Tan", "color": const Color(0xFFA15D2D)},
    {"name": "Deep", "color": const Color(0xFF632E18)},
  ];

  void setScanning(bool value) {
    isScanning.value = value;
  }

  Future<void> analyzeBodyImage(String imagePath) async {
    try {
      // Load the image
      final imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Detect skin tone from image
      await _detectSkinTone(image);

      // Detect body type (this would normally use an ML model)
      // For now, using a placeholder - you'll need to integrate TensorFlow Lite or similar
      await _detectBodyType(image);

      // Save to storage
      _saveDetectedData();

    } catch (e) {
      Get.snackbar('Analysis Error', 'Failed to analyze image: $e');
      rethrow;
    }
  }

  Future<void> _detectSkinTone(img.Image image) async {
    // Sample pixels from face region (upper 1/3 of image, center area)
    final width = image.width;
    final height = image.height;

    int totalR = 0, totalG = 0, totalB = 0;
    int sampleCount = 0;

    // Sample from the upper-center region (face area)
    final startY = (height * 0.15).toInt();
    final endY = (height * 0.30).toInt();
    final startX = (width * 0.35).toInt();
    final endX = (width * 0.65).toInt();

    for (int y = startY; y < endY; y += 5) {
      for (int x = startX; x < endX; x += 5) {
        final pixel = image.getPixel(x, y);
        totalR += pixel.r.toInt();
        totalG += pixel.g.toInt();
        totalB += pixel.b.toInt();
        sampleCount++;
      }
    }

    if (sampleCount > 0) {
      final avgR = totalR ~/ sampleCount;
      final avgG = totalG ~/ sampleCount;
      final avgB = totalB ~/ sampleCount;

      // Calculate brightness/luminance
      final brightness = (0.299 * avgR + 0.587 * avgG + 0.114 * avgB).toInt();

      // Map brightness to skin tone category
      String toneName;
      Color toneColor;

      if (brightness > 220) {
        toneName = "Fair";
        toneColor = const Color(0xFFFFE7D1);
      } else if (brightness > 180) {
        toneName = "Light";
        toneColor = const Color(0xFFF3D5B5);
      } else if (brightness > 140) {
        toneName = "Medium";
        toneColor = const Color(0xFFC69061);
      } else if (brightness > 100) {
        toneName = "Tan";
        toneColor = const Color(0xFFA15D2D);
      } else {
        toneName = "Deep";
        toneColor = const Color(0xFF632E18);
      }

      detectedSkinTone.value = toneColor;
      detectedSkinToneName.value = toneName;
    }
  }

  Future<void> _detectBodyType(img.Image image) async {
    // PLACEHOLDER: In production, you would use TensorFlow Lite or an ML model
    // For now, using a simple heuristic based on image analysis

    // This is where you'd integrate:
    // 1. TensorFlow Lite model for body shape classification
    // 2. Or call an API service like Google Vision API, Azure Computer Vision
    // 3. Or use MediaPipe for pose detection and measurement ratios

    final width = image.width;
    final height = image.height;

    // Simplified detection - analyze body proportions
    // In reality, you'd use pose detection to find key points

    // Sample different vertical sections to estimate body shape
    final shoulderWidth = _measureWidth(image, (height * 0.25).toInt());
    final waistWidth = _measureWidth(image, (height * 0.50).toInt());
    final hipWidth = _measureWidth(image, (height * 0.70).toInt());

    // Determine body type based on ratios
    final shoulderHipRatio = shoulderWidth / hipWidth;
    final waistHipRatio = waistWidth / hipWidth;

    if (hipWidth > shoulderWidth * 1.05 && waistWidth < hipWidth) {
      detectedBodyType.value = "Pear";
    } else if (waistWidth > hipWidth * 0.9 && shoulderWidth < hipWidth * 1.1) {
      detectedBodyType.value = "Apple";
    } else if (shoulderWidth > hipWidth * 1.05 && waistWidth < shoulderWidth) {
      detectedBodyType.value = "Inverted Triangle";
    } else if ((shoulderWidth / hipWidth).abs() < 1.05 && waistWidth < shoulderWidth * 0.75) {
      detectedBodyType.value = "Hourglass";
    } else {
      detectedBodyType.value = "Rectangle";
    }
  }

  int _measureWidth(img.Image image, int yPosition) {
    // Find the width of the body at a specific height
    final width = image.width;
    int leftEdge = 0;
    int rightEdge = width - 1;

    // Find left edge (scanning from left)
    for (int x = 0; x < width ~/ 2; x++) {
      if (_isBodyPixel(image.getPixel(x, yPosition))) {
        leftEdge = x;
        break;
      }
    }

    // Find right edge (scanning from right)
    for (int x = width - 1; x > width ~/ 2; x--) {
      if (_isBodyPixel(image.getPixel(x, yPosition))) {
        rightEdge = x;
        break;
      }
    }

    return rightEdge - leftEdge;
  }

  bool _isBodyPixel(img.Pixel pixel) {
    // Simple check - in production, use background subtraction or ML segmentation
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();

    // Skin tone range detection (simplified)
    return (r > 80 && r < 255 && g > 50 && g < 240 && b > 40 && b < 220);
  }

  void _saveDetectedData() {
    // Save to GetStorage
    box.write('body_type', detectedBodyType.value);
    box.write('skin_tone_name', detectedSkinToneName.value);
    box.write('skin_tone_color', detectedSkinTone.value?.value);
    box.write('has_completed_scan', true);
  }

  String getStoredBodyType() {
    return box.read('body_type') ?? '';
  }

  bool hasCompletedScan() {
    return box.read('has_completed_scan') ?? false;
  }
}