import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import '../controllers/body_scan_controller.dart';
import '../utils/constants/colors.dart';
import 'HomeScreen.dart';

class BodyScanScreen extends StatefulWidget {
  const BodyScanScreen({super.key});

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends State<BodyScanScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  final scanController = Get.put(BodyScanController());
  bool _isCameraInitialized = false;
  bool _isDisposed = false;
  Future<void>? _initializeControllerFuture;

  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scanAnimationController = AnimationController(
      duration: const Duration(milliseconds: 4500),
      vsync: this,
    );

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanAnimationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCamera();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scanAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
      _cameraController = null;
      _isCameraInitialized = false;
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraController == null) {
        _initializeCamera();
      }
    }
  }

  Future<void> _initializeCamera() async {
    if (_isDisposed) return;

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        if (mounted) {
          Get.snackbar('Error', 'No camera found');
        }
        return;
      }

      CameraDescription? frontCamera;
      for (var camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      final selectedCamera = frontCamera ?? cameras.first;

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium, // Changed from high to medium for better fit
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      _initializeControllerFuture = _cameraController!.initialize();
      await _initializeControllerFuture;

      if (!_isDisposed && mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Camera error: $e');
      if (mounted) {
        Get.snackbar('Camera Error', 'Failed to start camera: $e');
      }
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      Get.snackbar('Error', 'Camera not ready');
      return;
    }

    try {
      scanController.setScanning(true);
      scanController.setScanningStage("Preparing scan...");
      _scanAnimationController.repeat();

      await Future.delayed(const Duration(milliseconds: 500));

      scanController.setScanningStage("Capturing image...");
      final image = await _cameraController!.takePicture();

      await Future.delayed(const Duration(milliseconds: 800));

      scanController.setScanningStage("Validating position...");
      final isValidPose = await scanController.validateBodyPose(image.path);

      if (!isValidPose) {
        _scanAnimationController.stop();
        scanController.setScanning(false);
        return;
      }

      await Future.delayed(const Duration(milliseconds: 800));

      scanController.setScanningStage("Analyzing skin tone...");
      await Future.delayed(const Duration(milliseconds: 1000));

      scanController.setScanningStage("Detecting body type...");
      await scanController.analyzeBodyImage(image.path);

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      _scanAnimationController.stop();
      scanController.setScanning(false);

      Get.snackbar(
        'Scan Complete!',
        'Body Type: ${scanController.detectedBodyType.value}\nSkin Tone: ${scanController.detectedSkinToneName.value}',
        backgroundColor: AppColors.accentTeal,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
      );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Get.offAll(() => const HomeScreen());
      }

    } catch (e) {
      print('Capture error: $e');
      _scanAnimationController.stop();
      scanController.setScanning(false);
      if (mounted) {
        Get.snackbar(' Error', 'Scan failed: $e');
      }
    }
  }

  void _skipScan() {
    Get.dialog(
      AlertDialog(
        title: const Text('Skip Body Scan?'),
        content: const Text('You can scan later from profile settings.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAll(() => const HomeScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentTeal,
            ),
            child: const Text('Skip', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _isCameraInitialized &&
              _cameraController != null &&
              _cameraController!.value.isInitialized) {
            return _buildCameraPreview();
          } else {
            return _buildLoadingScreen();
          }
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.accentTeal),
          SizedBox(height: 20),
          Text(
            'Starting camera...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ✅ FIXED CAMERA PREVIEW - No excessive zoom
        _buildFullScreenCameraAlt1(),

        // Scanning Animation
        Obx(() {
          if (scanController.isScanning.value) {
            return AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ScannerPainter(
                    scanProgress: _scanAnimation.value,
                    color: AppColors.accentTeal,
                  ),
                  child: Container(),
                );
              },
            );
          }
          return SizedBox.shrink();
        }),

        // Body Outline Guide
        Obx(() {
          if (!scanController.isScanning.value) {
            return Positioned.fill(
              child: CustomPaint(
                painter: BodyOutlinePainter(),
              ),
            );
          }
          return SizedBox.shrink();
        }),

        // Top Instructions
        Positioned(
          top: 60,
          left: 20,
          right: 20,
          child: Obx(() => Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: scanController.isScanning.value
                  ? AppColors.accentTeal.withOpacity(0.9)
                  : Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  scanController.isScanning.value
                      ? scanController.scanningStage.value
                      : 'Position Your Full Body',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!scanController.isScanning.value) ...[
                  SizedBox(height: 8),
                  Text(
                    'Stand 3-4 feet away • Face camera • Arms slightly away',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          )),
        ),

        // Bottom Controls
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Obx(() => Column(
            children: [
              if (scanController.isScanning.value)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.accentTeal,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Please hold still...',
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
                    boxShadow: scanController.isScanning.value
                        ? null
                        : [
                      BoxShadow(
                        color: AppColors.accentTeal.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),

              SizedBox(height: 15),

              if (!scanController.isScanning.value)
                TextButton(
                  onPressed: _skipScan,
                  child: Text(
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
            icon: Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: scanController.isScanning.value ? null : _skipScan,
          ),
        ),
      ],
    );
  }

  // ✅ FIXED: Better camera scaling with proper aspect ratio handling
  Widget _buildFullScreenCamera() {
    final size = MediaQuery.of(context).size;

    // Calculate scale to fill screen completely
    var scale = size.aspectRatio * _cameraController!.value.aspectRatio;

    // If camera aspect ratio is less than screen, scale up
    if (scale < 1) scale = 1 / scale;

    return ClipRect(
      child: Transform.scale(
        scale: scale,
        child: Center(
          child: AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
        ),
      ),
    );
  }

  // ALTERNATIVE METHOD 1: Fit camera to screen height (use this if above doesn't work)
  Widget _buildFullScreenCameraAlt1() {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    return OverflowBox(
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.width,
          height: size.width * _cameraController!.value.aspectRatio,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  // ALTERNATIVE METHOD 2: Use Transform.scale with better calculation
  Widget _buildFullScreenCameraAlt2() {
    final size = MediaQuery.of(context).size;
    final cameraAspectRatio = _cameraController!.value.aspectRatio;
    final screenAspectRatio = size.width / size.height;

    // Calculate scale to cover screen without excessive zoom
    // This ensures camera fills screen but doesn't zoom too much
    double scale;
    if (cameraAspectRatio > screenAspectRatio) {
      // Camera is wider - fit to height
      scale = 1.0;
    } else {
      // Camera is taller - fit to width
      scale = screenAspectRatio / cameraAspectRatio;
    }

    // Limit maximum scale to prevent excessive zoom
    scale = scale.clamp(1.0, 1.3);

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: size.width,
            height: size.width / cameraAspectRatio,
            child: CameraPreview(_cameraController!),
          ),
        ),
      ),
    );
  }
}

// Scanning Animation Painter
class ScannerPainter extends CustomPainter {
  final double scanProgress;
  final Color color;

  ScannerPainter({required this.scanProgress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);

    final scanY = size.height * scanProgress;

    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), glowPaint);
    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), paint);

    final gridPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, scanY), gridPaint);
    }

    for (double y = 0; y < scanY; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ScannerPainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress;
  }
}

// Body Outline Painter
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

    final centerX = size.width / 2;
    final topY = size.height * 0.15;
    final bottomY = size.height * 0.85;

    canvas.drawCircle(Offset(centerX, topY + 30), 25, paint);

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, size.height / 2),
        width: size.width * 0.5,
        height: bottomY - topY - 60,
      ),
      Radius.circular(15),
    );

    _drawDashedRRect(canvas, bodyRect, dashedPaint);

    final markerPaint = Paint()
      ..color = AppColors.accentTeal
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, topY), 4, markerPaint);
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