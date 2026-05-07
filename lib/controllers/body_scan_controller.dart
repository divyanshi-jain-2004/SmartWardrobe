import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class BodyScanController extends GetxController {
  final box = GetStorage();

  var isScanning = false.obs;
  var scanningStage = "".obs;
  var detectedBodyType = "".obs;
  var detectedSkinTone = Rxn<Color>();
  var detectedSkinToneName = "".obs;
  var detectionConfidence = 0.0.obs; // ✅ NEW: Confidence score

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

  void setScanning(bool value) => isScanning.value = value;
  void setScanningStage(String stage) => scanningStage.value = stage;

  // --- CORE ANALYSIS WITH MULTI-FRAME DETECTION ---

  Future<void> analyzeBodyImage(String imagePath, {List<String>? additionalFrames}) async {
    try {
      final imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) throw Exception('Failed to decode image');

      // 1. Detect Skin Tone using Face Detection
      await _detectSkinToneWithFaceML(imagePath, decodedImage);

      // 2. Multi-frame Body Type Detection for better accuracy
      if (additionalFrames != null && additionalFrames.isNotEmpty) {
        await _detectBodyTypeMultiFrame([imagePath, ...additionalFrames]);
      } else {
        await _detectBodyTypeSingleFrame(imagePath);
      }

      _saveDetectedData();
    } catch (e) {
      print('Analysis error: $e');
      Get.snackbar('Analysis Error', 'Failed to analyze image: $e');
      rethrow;
    }
  }

  // Skin tone detection using Face Detection
  Future<void> _detectSkinToneWithFaceML(String imagePath, img.Image decodedImage) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableClassification: false,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    try {
      final List<Face> faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        _mapBrightnessToTone(130); // Fallback to Medium
        return;
      }

      final faceRect = faces.first.boundingBox;

      // Sample from forehead and cheeks (avoid shadows from nose/eyes)
      int startX = (faceRect.left + faceRect.width * 0.3).toInt();
      int startY = (faceRect.top + faceRect.height * 0.2).toInt();
      int w = (faceRect.width * 0.4).toInt();
      int h = (faceRect.height * 0.3).toInt();

      List<int> brightnessValues = [];

      for (int y = startY; y < startY + h; y += 2) {
        for (int x = startX; x < startX + w; x += 2) {
          if (x >= 0 && x < decodedImage.width && y >= 0 && y < decodedImage.height) {
            final pixel = decodedImage.getPixel(x, y);
            final r = pixel.r.toInt();
            final g = pixel.g.toInt();
            final b = pixel.b.toInt();

            // Filter out non-skin pixels
            if (_isSkinTonePixel(r, g, b)) {
              double lum = (0.299 * r + 0.587 * g + 0.114 * b);
              brightnessValues.add(lum.toInt());
            }
          }
        }
      }

      if (brightnessValues.isNotEmpty) {
        brightnessValues.sort();
        // Use median to ignore outliers
        double medianBrightness = brightnessValues[brightnessValues.length ~/ 2].toDouble();
        _mapBrightnessToTone(medianBrightness);
      } else {
        _mapBrightnessToTone(130); // Fallback
      }
    } finally {
      faceDetector.close();
    }
  }

  bool _isSkinTonePixel(int r, int g, int b) {
    // Enhanced skin tone detection rules
    return r > 95 && g > 40 && b > 20 &&
        r > g && r > b &&
        (r - g).abs() > 15 &&
        r < 255 && g < 220 && b < 200;
  }

  void _mapBrightnessToTone(double brightness) {
    if (brightness > 195) {
      detectedSkinToneName.value = "Fair";
      detectedSkinTone.value = const Color(0xFFFFE7D1);
    } else if (brightness > 160) {
      detectedSkinToneName.value = "Light";
      detectedSkinTone.value = const Color(0xFFF3D5B5);
    } else if (brightness > 120) {
      detectedSkinToneName.value = "Medium";
      detectedSkinTone.value = const Color(0xFFC69061);
    } else if (brightness > 80) {
      detectedSkinToneName.value = "Tan";
      detectedSkinTone.value = const Color(0xFFA15D2D);
    } else {
      detectedSkinToneName.value = "Deep";
      detectedSkinTone.value = const Color(0xFF632E18);
    }
  }


  Future<void> _detectBodyTypeMultiFrame(List<String> imagePaths) async {
    List<Map<String, dynamic>> detections = [];

    for (String path in imagePaths) {
      final result = await _detectSingleFrame(path);
      if (result != null) {
        detections.add(result);
      }
    }

    if (detections.isEmpty) {
      detectedBodyType.value = "Unknown";
      detectionConfidence.value = 0.0;
      Get.snackbar(
        'Detection Failed',
        'Could not detect body type. Please try again with better lighting and pose.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }


    Map<String, int> typeCounts = {};
    double totalConfidence = 0;

    for (var detection in detections) {
      String type = detection['type'];
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
      totalConfidence += detection['confidence'];
    }

    // Get most common type
    String finalType = typeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Average confidence
    double avgConfidence = totalConfidence / detections.length;

    detectedBodyType.value = finalType;
    detectionConfidence.value = avgConfidence;

    // Show warning if confidence is low
    if (avgConfidence < 0.65) {
      Get.snackbar(
        'Low Confidence',
        'Detection confidence is low. You can manually adjust in Edit Profile.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // ✅ IMPROVED: Single frame detection with better measurements
  Future<void> _detectBodyTypeSingleFrame(String imagePath) async {
    final result = await _detectSingleFrame(imagePath);

    if (result == null) {
      detectedBodyType.value = "Unknown";
      detectionConfidence.value = 0.0;
      Get.snackbar(
        'Detection Failed',
        'Could not detect body type. Please ensure full body is visible.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    detectedBodyType.value = result['type'];
    detectionConfidence.value = result['confidence'];

    if (result['confidence'] < 0.65) {
      Get.snackbar(
        'Low Confidence',
        'Detection confidence is ${(result['confidence'] * 100).toStringAsFixed(0)}%. You can manually adjust in Edit Profile.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // ✅ CORE: Single frame detection logic
  Future<Map<String, dynamic>?> _detectSingleFrame(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.single,
        model: PoseDetectionModel.accurate,
      ),
    );

    try {
      final List<Pose> poses = await poseDetector.processImage(inputImage);

      if (poses.isEmpty) return null;

      final pose = poses.first;

      // Get essential landmarks
      final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final lHip = pose.landmarks[PoseLandmarkType.leftHip];
      final rHip = pose.landmarks[PoseLandmarkType.rightHip];
      final lElbow = pose.landmarks[PoseLandmarkType.leftElbow];
      final rElbow = pose.landmarks[PoseLandmarkType.rightElbow];
      final nose = pose.landmarks[PoseLandmarkType.nose];

      // Check if essential landmarks are detected
      if (lShoulder == null || rShoulder == null || lHip == null || rHip == null) {
        return null;
      }

      // ✅ VALIDATION 1: Check pose confidence
      double avgConfidence = (
          lShoulder.likelihood +
              rShoulder.likelihood +
              lHip.likelihood +
              rHip.likelihood
      ) / 4;

      if (avgConfidence < 0.6) {
        return null; // Too low confidence
      }

      // ✅ VALIDATION 2: Check if front-facing
      if (nose != null) {
        double shoulderCenterX = (lShoulder.x + rShoulder.x) / 2;
        double noseOffset = (nose.x - shoulderCenterX).abs();
        double shoulderWidth = (lShoulder.x - rShoulder.x).abs();

        // Nose should be roughly centered between shoulders
        if (noseOffset > shoulderWidth * 0.3) {
          return null; // Not front-facing
        }
      }

      // ✅ VALIDATION 3: Check if arms are down (not raised)
      if (lElbow != null && rElbow != null) {
        // Elbows should be below shoulders
        if (lElbow.y < lShoulder.y || rElbow.y < rShoulder.y) {
          return null; // Arms raised
        }
      }

      // ✅ MEASUREMENTS: Calculate body proportions
      double shoulderWidth = (lShoulder.x - rShoulder.x).abs();
      double hipWidth = (lHip.x - rHip.x).abs();

      // Estimate waist position (between ribs and hips)
      final lWaistX = lShoulder.x * 0.3 + lHip.x * 0.7;
      final rWaistX = rShoulder.x * 0.3 + rHip.x * 0.7;
      double waistWidth = (lWaistX - rWaistX).abs();

      // Calculate ratios
      double shoulderHipRatio = shoulderWidth / hipWidth;
      double waistHipRatio = waistWidth / hipWidth;
      double shoulderWaistRatio = shoulderWidth / waistWidth;

      print('📊 Body Measurements:');
      print('   Shoulder/Hip: ${shoulderHipRatio.toStringAsFixed(2)}');
      print('   Waist/Hip: ${waistHipRatio.toStringAsFixed(2)}');
      print('   Shoulder/Waist: ${shoulderWaistRatio.toStringAsFixed(2)}');
      print('   Confidence: ${(avgConfidence * 100).toStringAsFixed(1)}%');

      // ✅ IMPROVED: Body type classification with ranges
      String bodyType;
      double confidence;

      if (shoulderHipRatio < 0.88) {
        // Pear: Hips wider than shoulders
        bodyType = "Pear";
        confidence = _calculateConfidence(shoulderHipRatio, 0.85, 0.88, avgConfidence);

      } else if (shoulderHipRatio > 1.12) {
        // Inverted Triangle: Shoulders wider than hips
        bodyType = "Inverted Triangle";
        confidence = _calculateConfidence(shoulderHipRatio, 1.12, 1.15, avgConfidence);

      } else if (waistHipRatio < 0.75 && shoulderHipRatio >= 0.90 && shoulderHipRatio <= 1.10) {
        // Hourglass: Defined waist with balanced shoulders/hips
        bodyType = "Hourglass";
        confidence = _calculateConfidence(waistHipRatio, 0.70, 0.75, avgConfidence);

      } else if (waistHipRatio > 0.88 && shoulderWaistRatio < 1.15) {
        // Apple: Less defined waist, fuller midsection
        bodyType = "Apple";
        confidence = _calculateConfidence(waistHipRatio, 0.88, 0.92, avgConfidence);

      } else {
        // Rectangle: Balanced proportions, less definition
        bodyType = "Rectangle";
        confidence = avgConfidence * 0.85; // Slightly lower confidence for default
      }

      return {
        'type': bodyType,
        'confidence': confidence,
        'measurements': {
          'shoulderHipRatio': shoulderHipRatio,
          'waistHipRatio': waistHipRatio,
          'shoulderWaistRatio': shoulderWaistRatio,
        }
      };

    } finally {
      poseDetector.close();
    }
  }

  // ✅ NEW: Calculate confidence score based on how well measurements fit the type
  double _calculateConfidence(double ratio, double idealMin, double idealMax, double baseConfidence) {
    double distance;

    if (ratio < idealMin) {
      distance = (idealMin - ratio).abs();
    } else if (ratio > idealMax) {
      distance = (ratio - idealMax).abs();
    } else {
      // Within ideal range
      return baseConfidence * 0.95;
    }

    // Reduce confidence based on distance from ideal range
    double penalty = (distance * 2).clamp(0.0, 0.4);
    return (baseConfidence - penalty).clamp(0.5, 1.0);
  }

  // ✅ IMPROVED: Better lighting validation
  Future<bool> validateBodyPose(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return false;

      // Check lighting across multiple regions
      List<double> brightnessValues = [];

      // Sample 9 regions (3x3 grid)
      for (double y = 0.25; y <= 0.75; y += 0.25) {
        for (double x = 0.25; x <= 0.75; x += 0.25) {
          final pixel = image.getPixel(
            (image.width * x).toInt(),
            (image.height * y).toInt(),
          );
          double brightness = (pixel.r + pixel.g + pixel.b) / 3;
          brightnessValues.add(brightness);
        }
      }

      brightnessValues.sort();
      double medianBrightness = brightnessValues[brightnessValues.length ~/ 2];

      print("🔆 Median Brightness: ${medianBrightness.toStringAsFixed(1)}");

      if (medianBrightness < 35) {
        Get.snackbar(
          'Poor Lighting',
          'Please move to a well-lit area for better detection',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }

      // Check if lighting is too uneven (harsh shadows)
      double minBrightness = brightnessValues.first;
      double maxBrightness = brightnessValues.last;
      double contrast = maxBrightness - minBrightness;

      if (contrast > 180) {
        Get.snackbar(
          'Uneven Lighting',
          'Try to avoid harsh shadows. Use soft, even lighting.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        // Don't block, just warn
      }

      return true;
    } catch (e) {
      print('Validation error: $e');
      return true; // Fail open
    }
  }

  // --- STORAGE & RETRIEVAL ---

  void _saveDetectedData() {
    box.write('body_type', detectedBodyType.value);
    box.write('body_type_confidence', detectionConfidence.value);
    box.write('skin_tone_name', detectedSkinToneName.value);
    box.write('skin_tone_color', detectedSkinTone.value?.value);
    box.write('has_completed_scan', true);
    box.write('scan_timestamp', DateTime.now().toIso8601String());

    print('✅ Saved: ${detectedBodyType.value} (${(detectionConfidence.value * 100).toStringAsFixed(0)}% confidence)');
  }

  String getStoredBodyType() => box.read('body_type') ?? '';

  double getStoredConfidence() => box.read('body_type_confidence') ?? 0.0;

  bool hasCompletedScan() => box.read('has_completed_scan') ?? false;

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

  // ✅ NEW: Get confidence level as text
  String getConfidenceLevel() {
    double conf = detectionConfidence.value;
    if (conf >= 0.85) return 'High';
    if (conf >= 0.70) return 'Good';
    if (conf >= 0.55) return 'Medium';
    return 'Low';
  }

  // ✅ NEW: Should suggest manual verification?
  bool shouldSuggestManualVerification() {
    return detectionConfidence.value < 0.65;
  }
}