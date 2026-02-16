import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class BodyScanController extends GetxController {
  final box = GetStorage();

  var isScanning = false.obs;
  var scanningStage = "".obs;
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

  // Skin tone palette
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

  void setScanningStage(String stage) {
    scanningStage.value = stage;
  }

  // ✅ FIXED: Relaxed validation with better thresholds
  Future<bool> validateBodyPose(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return false;

      // Check 1: Image brightness (lighting check)
      if (!await _checkLighting(image)) {
        Get.snackbar(
          'Poor Lighting',
          'Please move to a well-lit area',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      // Check 2: Body visibility (distance check)
      final bodyVisibility = await _checkBodyVisibility(image);

      print('🔍 Body Visibility: $bodyVisibility'); // Debug log

      // ✅ RELAXED THRESHOLDS
      if (bodyVisibility < 0.12) { // Was 0.15 - now more forgiving
        Get.snackbar(
          '📏 Too Far',
          'Please move closer to the camera (3-4 feet)',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      } else if (bodyVisibility > 0.92) { // ✅ CHANGED from 0.80 to 0.92
        // Now only fails if EXTREMELY close (>92% body coverage)
        Get.snackbar(
          '📏 Too Close',
          'Please step back a bit (3-4 feet)',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      // Check 3: Partial body visible (relaxed - no longer requires feet)
      // ✅ CHANGED: Now only checks for upper body presence
      if (!await _checkUpperBodyVisible(image)) {
        Get.snackbar(
          'Upper Body Not Clear',
          'Ensure your face and torso are clearly visible',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      return true;
    } catch (e) {
      print('Validation error: $e');
      // ✅ Fail-open: Allow scan on error
      return true;
    }
  }

  // Check lighting conditions
  Future<bool> _checkLighting(img.Image image) async {
    int totalBrightness = 0;
    int sampleCount = 0;

    // Sample random pixels
    for (int y = 0; y < image.height; y += 20) {
      for (int x = 0; x < image.width; x += 20) {
        final pixel = image.getPixel(x, y);
        final brightness = (pixel.r + pixel.g + pixel.b) / 3;
        totalBrightness += brightness.toInt();
        sampleCount++;
      }
    }

    final avgBrightness = totalBrightness / sampleCount;

    // ✅ RELAXED: More forgiving lighting range
    return avgBrightness > 30 && avgBrightness < 245; // Was 40-240
  }

  // Check body visibility (distance)
  Future<double> _checkBodyVisibility(img.Image image) async {
    final width = image.width;
    final height = image.height;

    int bodyPixelCount = 0;
    int totalPixels = 0;

    // ✅ WIDER SAMPLING AREA - Check more of the frame
    final startY = (height * 0.10).toInt(); // Was 0.15 - now starts higher
    final endY = (height * 0.90).toInt();   // Was 0.85 - now goes lower
    final startX = (width * 0.20).toInt();  // Was 0.25 - now wider
    final endX = (width * 0.80).toInt();    // Was 0.75 - now wider

    for (int y = startY; y < endY; y += 8) {
      for (int x = startX; x < endX; x += 8) {
        final pixel = image.getPixel(x, y);
        if (_isBodyPixel(pixel)) {
          bodyPixelCount++;
        }
        totalPixels++;
      }
    }

    return bodyPixelCount / totalPixels;
  }

  // ✅ NEW: Check upper body only (more lenient than full body)
  Future<bool> _checkUpperBodyVisible(img.Image image) async {
    final width = image.width;
    final height = image.height;

    // Check head region (top 20%)
    bool hasHead = false;
    for (int y = (height * 0.10).toInt(); y < (height * 0.25).toInt(); y += 10) {
      for (int x = (width * 0.35).toInt(); x < (width * 0.65).toInt(); x += 10) {
        if (_isBodyPixel(image.getPixel(x, y))) {
          hasHead = true;
          break;
        }
      }
      if (hasHead) break;
    }

    // Check torso region (middle 30-60%)
    bool hasTorso = false;
    for (int y = (height * 0.30).toInt(); y < (height * 0.60).toInt(); y += 10) {
      for (int x = (width * 0.30).toInt(); x < (width * 0.70).toInt(); x += 10) {
        if (_isBodyPixel(image.getPixel(x, y))) {
          hasTorso = true;
          break;
        }
      }
      if (hasTorso) break;
    }

    // ✅ Only require head + torso (not feet)
    return hasHead && hasTorso;
  }

  // ✅ KEPT: Original full body check (optional, currently not used)
  Future<bool> _checkFullBodyVisible(img.Image image) async {
    final width = image.width;
    final height = image.height;

    // Check head region (top 20%)
    bool hasHead = false;
    for (int y = (height * 0.10).toInt(); y < (height * 0.25).toInt(); y += 10) {
      for (int x = (width * 0.35).toInt(); x < (width * 0.65).toInt(); x += 10) {
        if (_isBodyPixel(image.getPixel(x, y))) {
          hasHead = true;
          break;
        }
      }
      if (hasHead) break;
    }

    // Check feet region (bottom 20%)
    bool hasFeet = false;
    for (int y = (height * 0.75).toInt(); y < (height * 0.90).toInt(); y += 10) {
      for (int x = (width * 0.30).toInt(); x < (width * 0.70).toInt(); x += 10) {
        if (_isBodyPixel(image.getPixel(x, y))) {
          hasFeet = true;
          break;
        }
      }
      if (hasFeet) break;
    }

    return hasHead && hasFeet;
  }

  Future<void> analyzeBodyImage(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Detect skin tone
      await _detectSkinToneImproved(image);

      // Detect body type
      await _detectBodyTypeImproved(image);

      // Save to storage
      _saveDetectedData();

    } catch (e) {
      print('Analysis error: $e');
      Get.snackbar('Analysis Error', 'Failed to analyze image: $e');
      rethrow;
    }
  }

  // ✅ IMPROVED: Better skin tone detection
  Future<void> _detectSkinToneImproved(img.Image image) async {
    final width = image.width;
    final height = image.height;

    List<int> rValues = [];
    List<int> gValues = [];
    List<int> bValues = [];

    // Sample from face area (upper-center region)
    final startY = (height * 0.15).toInt();
    final endY = (height * 0.30).toInt();
    final startX = (width * 0.35).toInt();
    final endX = (width * 0.65).toInt();

    for (int y = startY; y < endY; y += 3) {
      for (int x = startX; x < endX; x += 3) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        // Only sample skin-like pixels
        if (_isSkinTonePixel(r, g, b)) {
          rValues.add(r);
          gValues.add(g);
          bValues.add(b);
        }
      }
    }

    if (rValues.isEmpty) {
      // Fallback: use medium tone
      detectedSkinTone.value = const Color(0xFFC69061);
      detectedSkinToneName.value = "Medium";
      return;
    }

    // Use median instead of average (more robust)
    rValues.sort();
    gValues.sort();
    bValues.sort();

    final medianR = rValues[rValues.length ~/ 2];
    final medianG = gValues[gValues.length ~/ 2];
    final medianB = bValues[bValues.length ~/ 2];

    // Calculate brightness
    final brightness = (0.299 * medianR + 0.587 * medianG + 0.114 * medianB).toInt();

    // Map to skin tone with better thresholds
    String toneName;
    Color toneColor;

    if (brightness > 200) {
      toneName = "Fair";
      toneColor = const Color(0xFFFFE7D1);
    } else if (brightness > 160) {
      toneName = "Light";
      toneColor = const Color(0xFFF3D5B5);
    } else if (brightness > 120) {
      toneName = "Medium";
      toneColor = const Color(0xFFC69061);
    } else if (brightness > 80) {
      toneName = "Tan";
      toneColor = const Color(0xFFA15D2D);
    } else {
      toneName = "Deep";
      toneColor = const Color(0xFF632E18);
    }

    detectedSkinTone.value = toneColor;
    detectedSkinToneName.value = toneName;
  }

  bool _isSkinTonePixel(int r, int g, int b) {
    // Improved skin tone detection
    return r > 95 && g > 40 && b > 20 &&
        r > g && r > b &&
        (r - g).abs() > 15 &&
        (r - b) > 15 &&
        r < 255 && g < 220 && b < 200; // Exclude very bright pixels
  }

  // ✅ IMPROVED: More accurate body type detection
  Future<void> _detectBodyTypeImproved(img.Image image) async {
    final width = image.width;
    final height = image.height;

    // Define measurement points with better positioning
    final shoulderY = (height * 0.25).toInt();
    final bustY = (height * 0.35).toInt();
    final waistY = (height * 0.50).toInt();
    final hipY = (height * 0.68).toInt();

    // Measure widths
    final shoulderWidth = _measureWidthAtHeight(image, shoulderY);
    final bustWidth = _measureWidthAtHeight(image, bustY);
    final waistWidth = _measureWidthAtHeight(image, waistY);
    final hipWidth = _measureWidthAtHeight(image, hipY);

    print('Measurements:');
    print('Shoulder: $shoulderWidth, Bust: $bustWidth, Waist: $waistWidth, Hip: $hipWidth');

    // Avoid division by zero
    if (hipWidth == 0 || waistWidth == 0 || shoulderWidth == 0) {
      detectedBodyType.value = "Rectangle";
      return;
    }

    // Calculate ratios
    final shoulderHipRatio = shoulderWidth / hipWidth;
    final waistHipRatio = waistWidth / hipWidth;
    final shoulderWaistRatio = shoulderWidth / waistWidth;

    print('Ratios:');
    print('Shoulder/Hip: $shoulderHipRatio, Waist/Hip: $waistHipRatio, Shoulder/Waist: $shoulderWaistRatio');

    // Determine body type with improved logic
    String bodyType;

    if (waistHipRatio < 0.75 && shoulderHipRatio >= 0.92 && shoulderHipRatio <= 1.08) {
      // Well-defined waist + balanced shoulders/hips
      bodyType = "Hourglass";
    } else if (shoulderHipRatio < 0.88) {
      // Hips significantly wider than shoulders
      bodyType = "Pear";
    } else if (shoulderHipRatio > 1.12) {
      // Shoulders significantly wider than hips
      bodyType = "Inverted Triangle";
    } else if (waistHipRatio > 0.85 && shoulderWaistRatio < 1.15) {
      // Wider waist, less definition
      bodyType = "Apple";
    } else {
      // Relatively straight silhouette
      bodyType = "Rectangle";
    }

    print('Detected body type: $bodyType');
    detectedBodyType.value = bodyType;
  }

  int _measureWidthAtHeight(img.Image image, int yPosition) {
    final width = image.width;
    final centerX = width ~/ 2;

    int leftEdge = centerX;
    int rightEdge = centerX;

    // Find left edge (scan from center to left)
    for (int x = centerX; x > 0; x--) {
      if (_isBodyPixel(image.getPixel(x, yPosition))) {
        leftEdge = x;
      } else {
        // Stop at first non-body pixel
        break;
      }
    }

    // Find right edge (scan from center to right)
    for (int x = centerX; x < width; x++) {
      if (_isBodyPixel(image.getPixel(x, yPosition))) {
        rightEdge = x;
      } else {
        // Stop at first non-body pixel
        break;
      }
    }

    return (rightEdge - leftEdge).abs();
  }

  bool _isBodyPixel(img.Pixel pixel) {
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();

    final brightness = (r + g + b) / 3;

    // Body pixel should not be pure black/white background
    return brightness > 30 && brightness < 240;
  }

  void _saveDetectedData() {
    box.write('body_type', detectedBodyType.value);
    box.write('skin_tone_name', detectedSkinToneName.value);
    box.write('skin_tone_color', detectedSkinTone.value?.value);
    box.write('has_completed_scan', true);

    print('Saved: Body Type: ${detectedBodyType.value}, Skin Tone: ${detectedSkinToneName.value}');
  }

  String getStoredBodyType() {
    return box.read('body_type') ?? '';
  }

  bool hasCompletedScan() {
    return box.read('has_completed_scan') ?? false;
  }

  String getBodyTypeDescription(String bodyType) {
    switch (bodyType) {
      case 'Pear':
        return 'Wider hips with narrower shoulders. Best suited for A-line and fit-and-flare styles.';
      case 'Apple':
        return 'Fuller midsection with narrower hips. Empire waists and V-necks work great.';
      case 'Rectangle':
        return 'Balanced proportions throughout. Most styles work well, belts create definition.';
      case 'Inverted Triangle':
        return 'Broader shoulders with narrower hips. A-line skirts and wide-leg pants balance proportions.';
      case 'Hourglass':
        return 'Defined waist with balanced bust and hips. Fitted styles highlight your curves.';
      default:
        return 'Your unique body shape is beautiful!';
    }
  }
}