import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import '../controllers/body_scan_controller.dart';
import '../utils/constants/colors.dart';

class BodyScanScreen extends StatefulWidget {
  const BodyScanScreen({super.key});

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends State<BodyScanScreen> {
  CameraController? _cameraController;
  final scanController = Get.put(BodyScanController());
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar('Error', 'No camera found on this device');
        return;
      }

      // Use front camera for body scan
      final camera = cameras.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      Get.snackbar('Camera Error', 'Failed to initialize camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureAndAnalyze() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      // Show loading
      scanController.setScanning(true);

      final image = await _cameraController!.takePicture();

      // Process the image and detect body type & skin tone
      await scanController.analyzeBodyImage(image.path);

      scanController.setScanning(false);

      // Navigate to profile or next screen
      Get.back();
      Get.snackbar(
        'Scan Complete',
        'Body type and skin tone detected successfully!',
        backgroundColor: AppColors.accentTeal,
        colorText: Colors.white,
      );
    } catch (e) {
      scanController.setScanning(false);
      Get.snackbar('Error', 'Failed to capture image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.accentTeal),
            ),

          // Overlay with body outline guide
          Positioned.fill(
            child: CustomPaint(
              painter: BodyOutlinePainter(),
            ),
          ),

          // Top Instructions
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    'Position Your Full Body',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Stand 3-4 feet away • Face the camera • Keep arms slightly away from body',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Obx(() => Column(
              children: [
                // Scanning indicator
                if (scanController.isScanning.value)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Analyzing your body type...',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                // Capture Button
                GestureDetector(
                  onTap: scanController.isScanning.value ? null : _captureAndAnalyze,
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scanController.isScanning.value
                          ? Colors.grey
                          : AppColors.accentTeal,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Skip button
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            )),
          ),

          // Close button
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for body outline guide
class BodyOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentTeal.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dashedPaint = Paint()
      ..color = AppColors.accentTeal.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw body outline guide (simplified human silhouette)
    final centerX = size.width / 2;
    final topY = size.height * 0.15;
    final bottomY = size.height * 0.85;

    // Head circle
    canvas.drawCircle(
      Offset(centerX, topY + 30),
      25,
      paint,
    );

    // Body outline rectangle with dashed lines
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, size.height / 2),
        width: size.width * 0.5,
        height: bottomY - topY - 60,
      ),
      const Radius.circular(15),
    );

    // Draw dashed outline
    _drawDashedRRect(canvas, bodyRect, dashedPaint);

    // Alignment markers
    final markerPaint = Paint()
      ..color = AppColors.accentTeal
      ..style = PaintingStyle.fill;

    // Top marker
    canvas.drawCircle(Offset(centerX, topY), 4, markerPaint);
    // Bottom marker
    canvas.drawCircle(Offset(centerX, bottomY), 4, markerPaint);
  }

  void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint) {
    final path = Path()..addRRect(rrect);
    const dashWidth = 10;
    const dashSpace = 5;

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final start = distance;
        final end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(start, end > metric.length ? metric.length : end),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}