// FIXED VERSION OF addNewItem.dart
// Changes:
// 1. Better error handling for ML API timeouts
// 2. Fallback to manual category if ML fails
// 3. Optimized image compression
// 4. Proper database insertion with validation
// 5. Background removal made optional and faster

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

const Color _kPrimaryTeal = Color(0xFF00C7B1);
final supabase = Supabase.instance.client;

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class MLApiconfig {
  static const String baseUrl = 'http://172.8.5.226:5000/api';
  // 🆕 Reduced timeout for better UX
  static const Duration timeout = Duration(seconds: 15);
}

class _AddItemScreenState extends State<AddItemScreen> {
  bool _isImageUploaded = false;
  bool _removeBackground = false;

  String _itemName = '';
  String? _selectedCategory;
  String _itemImageUrl = 'https://placehold.co/100x100/CCCCCC/000000?text=No+Image';

  File? _selectedImageFile;
  File? _originalImageFile;
  String? _predictedCategory;
  String? _detectedColor;
  double? _predictionConfidence;
  bool _isProcessing = false;
  bool _mlProcessingFailed = false; // 🆕 Track ML failure

  // 🔧 FIXED: Updated categories to match your UI
  final Map<String, String> _categoryMapping = {
    'Tops': 'Topwear',
    'Bottoms': 'Bottomwear',
    'Dresses': 'Dresses',
    'Outerwear': 'Outerwear',
    'Footwear': 'Footwear',
    'Accessories': 'Accessories',
  };

  final List<String> _categories = [
    'Topwear',
    'Bottomwear',
    'Dresses',
    'Outerwear',
    'Footwear',
    'Accessories'
  ];

  // Theme Getters
  Color get _primaryTextColor => Theme.of(context).textTheme.bodyLarge!.color!;
  Color get _secondaryTextColor => Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
  Color get _surfaceColor => Theme.of(context).colorScheme.surface;
  Color get _scaffoldColor => Theme.of(context).scaffoldBackgroundColor;
  Color get _dividerColor => Theme.of(context).dividerColor;

  // 🆕 OPTIMIZED IMAGE COMPRESSION
  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

      print('📦 Original file size: ${(await file.length() / 1024 / 1024).toStringAsFixed(2)} MB');

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 80, // Reduced from 85 for faster upload
        minWidth: 800, // Reduced from 1024
        minHeight: 800,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        final compressedFile = File(result.path);
        final compressedSize = await compressedFile.length();
        print('✅ Compressed file size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB');

        // More aggressive compression if still too large
        if (compressedSize > 3 * 1024 * 1024) {
          print('⚠️ Still too large, compressing more aggressively...');
          final targetPath2 = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed2.jpg';
          final result2 = await FlutterImageCompress.compressAndGetFile(
            compressedFile.absolute.path,
            targetPath2,
            quality: 60,
            minWidth: 600,
            minHeight: 600,
            format: CompressFormat.jpeg,
          );
          return result2 != null ? File(result2.path) : compressedFile;
        }

        return compressedFile;
      }
      return null;
    } catch (e) {
      print('Compression error: $e');
      return null;
    }
  }

  // 🆕 IMPROVED BACKGROUND REMOVAL with timeout handling
  Future<void> _handleBackgroundRemoval(bool shouldRemove) async {
    if (_originalImageFile == null) {
      Get.snackbar(
        'Error',
        'Please upload an image first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      setState(() => _removeBackground = false);
      return;
    }

    setState(() => _isProcessing = true);

    if (shouldRemove) {
      try {
        Get.snackbar(
          'Processing',
          'Removing background... This may take a moment.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: _kPrimaryTeal,
          colorText: Colors.white,
          showProgressIndicator: true,
          duration: const Duration(seconds: 20),
        );

        final bytes = await _originalImageFile!.readAsBytes();
        final base64Image = base64Encode(bytes);

        // 🔧 FIXED: Reduced timeout to 15 seconds
        final response = await http.post(
          Uri.parse('${MLApiconfig.baseUrl}/remove-background'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'image': base64Image}),
        ).timeout(MLApiconfig.timeout);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['success'] == true) {
            final processedBase64 = data['processed_image'].split(',')[1];
            final processedBytes = base64Decode(processedBase64);

            final dir = await getTemporaryDirectory();
            final tempPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_nobg.png';
            final tempFile = File(tempPath);
            await tempFile.writeAsBytes(processedBytes);

            final compressedFile = await _compressImage(tempFile);

            Get.closeCurrentSnackbar();
            await _uploadImage(compressedFile ?? tempFile);

            Get.snackbar(
              'Success',
              'Background removed successfully!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.withOpacity(0.8),
              colorText: Colors.white,
            );
          } else {
            throw Exception('Background removal failed');
          }
        } else {
          throw Exception('API returned status ${response.statusCode}');
        }
      } on TimeoutException catch (_) {
        print('⏱️ Background removal timeout');
        Get.closeCurrentSnackbar();
        Get.snackbar(
          'Timeout',
          'Background removal took too long. Please try again or continue without it.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
        setState(() => _removeBackground = false);
      } catch (e) {
        print('Background removal error: $e');
        Get.closeCurrentSnackbar();
        Get.snackbar(
          'Error',
          'Failed to remove background. You can continue without it.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
        setState(() => _removeBackground = false);
      }
    } else {
      Get.snackbar(
        'Restoring',
        'Restoring original image...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _kPrimaryTeal,
        colorText: Colors.white,
      );

      await _uploadImage(_originalImageFile!);
      Get.closeCurrentSnackbar();
    }

    setState(() => _isProcessing = false);
  }

  void _pickImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select Image Source', style: TextStyle(color: _primaryTextColor)),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Get.back(result: ImageSource.camera),
              child: Row(
                children: [
                  Icon(Icons.camera_alt, color: _secondaryTextColor),
                  const SizedBox(width: 10),
                  Text('Take a Photo (Camera)', style: TextStyle(color: _primaryTextColor)),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Get.back(result: ImageSource.gallery),
              child: Row(
                children: [
                  Icon(Icons.photo_library, color: _secondaryTextColor),
                  const SizedBox(width: 10),
                  Text('Choose from Gallery', style: TextStyle(color: _primaryTextColor)),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (source != null) {
      final picker = ImagePicker();

      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        Get.snackbar(
          'Processing',
          'Optimizing image...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: _kPrimaryTeal,
          colorText: Colors.white,
          showProgressIndicator: true,
          duration: const Duration(seconds: 10),
        );

        final compressedFile = await _compressImage(imageFile);

        if (compressedFile != null) {
          imageFile = compressedFile;
          print('✅ Using compressed image');
        }

        _originalImageFile = imageFile;

        await _uploadImage(imageFile);
        Get.closeCurrentSnackbar();
      }
    }
  }

  // 🆕 IMPROVED ML PROCESSING with better error handling
  Future<void> _processImageWithML(File imageFile) async {
    try {
      setState(() {
        _isProcessing = true;
        _mlProcessingFailed = false;
      });

      Get.snackbar(
        'AI Analysis',
        'Detecting clothing category...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00C7B1),
        colorText: Colors.white,
        showProgressIndicator: true,
        duration: const Duration(seconds: 15),
      );

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      print('📡 Calling ML API: ${MLApiconfig.baseUrl}/process-clothing');

      // 🔧 FIXED: Reduced timeout to 15 seconds
      final response = await http.post(
        Uri.parse('${MLApiconfig.baseUrl}/process-clothing'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      ).timeout(MLApiconfig.timeout);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          String mlCategory = data['category'];

          // 🔧 FIXED: Map ML category to UI category
          String uiCategory = _categoryMapping[mlCategory] ?? mlCategory;

          setState(() {
            _predictedCategory = uiCategory;
            _detectedColor = data['color'];
            _predictionConfidence = data['confidence'];

            // Auto-select if category matches
            if (_categories.contains(uiCategory)) {
              _selectedCategory = uiCategory;
            }
          });

          Get.closeCurrentSnackbar();
          Get.snackbar(
            'AI Analysis Complete! ✨',
            'Detected: $uiCategory • Color: ${data['color']} (${(data['confidence'] * 100).toStringAsFixed(1)}% confident)',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        }
      } else {
        throw Exception('API returned status ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      print('⏱️ ML Processing Timeout');
      setState(() => _mlProcessingFailed = true);
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'AI Timeout',
        'Auto-detection took too long. Please select category manually.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      print('❌ ML Processing Error: $e');
      setState(() => _mlProcessingFailed = true);
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Manual Selection Required',
        'AI detection unavailable. Please select category manually.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _cropImage() async {
    if (_selectedImageFile == null) {
      Get.snackbar(
        'Error',
        'Please upload an image first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Processing',
      'Opening crop tool...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _kPrimaryTeal,
      colorText: Colors.white,
    );

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _selectedImageFile!.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Your Item',
            toolbarColor: _kPrimaryTeal,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Your Item'),
        ],
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
      );

      Get.closeCurrentSnackbar();

      if (croppedFile != null) {
        File newImageFile = File(croppedFile.path);

        final compressedFile = await _compressImage(newImageFile);
        if (compressedFile != null) {
          newImageFile = compressedFile;
        }

        _originalImageFile = newImageFile;

        Get.snackbar(
          'Re-uploading',
          'Updating image...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: _kPrimaryTeal,
          colorText: Colors.white,
          showProgressIndicator: true,
          duration: const Duration(seconds: 10),
        );

        await _uploadImage(newImageFile);

        Get.closeCurrentSnackbar();
        Get.snackbar(
          'Success',
          'Image cropped and updated!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Crop Error: $e');
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Error',
        'Cropping failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final fileSize = await imageFile.length();
      final fileSizeMB = fileSize / 1024 / 1024;
      print('📤 Uploading file size: ${fileSizeMB.toStringAsFixed(2)} MB');

      if (fileSizeMB > 10) {
        throw Exception('File too large (${fileSizeMB.toStringAsFixed(1)}MB). Maximum is 10MB.');
      }

      Get.snackbar(
        'Uploading',
        'Uploading image to cloud...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00C7B1),
        colorText: Colors.white,
        showProgressIndicator: true,
        duration: const Duration(seconds: 15),
      );

      await supabase.storage.from('wardrobe_image').upload(
        fileName,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final publicUrl = supabase.storage.from('wardrobe_image').getPublicUrl(fileName);

      Get.closeCurrentSnackbar();

      // Try ML processing (non-blocking)
      await _processImageWithML(imageFile);

      if (mounted) {
        setState(() {
          _itemImageUrl = publicUrl;
          _selectedImageFile = imageFile;
          _isImageUploaded = true;
        });
      }

      print('✅ Image uploaded successfully. URL: $publicUrl');

    } on StorageException catch (e) {
      print('❌ Supabase Storage Error: ${e.message}');
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Storage Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ General Image Upload Error: $e');
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Error',
        'Failed to upload image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  // 🆕 IMPROVED: Add item to wardrobe with proper validation
  void _addItemToWardrobe() async {
    if (_itemName.isEmpty || _selectedCategory == null || !_isImageUploaded) {
      Get.snackbar(
        'Validation',
        'Please fill all details and upload an image.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Saving',
      'Adding item to your wardrobe...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _kPrimaryTeal,
      colorText: Colors.white,
      showProgressIndicator: true,
      duration: const Duration(seconds: 10),
    );

    try {
      final userId = supabase.auth.currentUser?.id;

      // 🔧 FIXED: Proper data structure for database
      final newItem = {
        'user_id': userId,
        'item_name': _itemName.trim(),
        'category': _selectedCategory,
        'image_url': _itemImageUrl,
        'color': _detectedColor ?? 'Unknown',
        'remove_background': _removeBackground,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('📝 Inserting item: $newItem');

      await supabase.from('wardrobe_items').insert(newItem);

      print('✅ Item Added to Wardrobe Successfully!');

      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Success! 🎉',
        'Item added to your wardrobe',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      // 🔧 FIXED: Return with result flag to trigger refresh
      Get.back(result: true);

    } on PostgrestException catch (error) {
      print('❌ Supabase Insert Error: ${error.message}');
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Database Error',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ General Error: $e');
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Error',
        'Failed to add item. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.04;
    final bottomSpace = size.height * 0.10;

    return Scaffold(
      backgroundColor: _scaffoldColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Add New Item',
          style: TextStyle(fontWeight: FontWeight.bold, color: _primaryTextColor),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: bottomSpace),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUploadImageCard(size),
                  if (_isImageUploaded) ...[
                    SizedBox(height: size.height * 0.03),
                    _buildPreviewAndProcessingCard(size),
                    SizedBox(height: size.height * 0.03),
                    _buildItemDetailsSection(size),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFixedActionButton(size, horizontalPadding),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadImageCard(Size size) {
    final cardHeight = size.height * 0.22;
    final iconSize = size.width * 0.12;
    final uploadCardColor = _scaffoldColor;
    final uploadCardBorderColor = _kPrimaryTeal.withOpacity(0.5);

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: uploadCardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: uploadCardBorderColor, style: BorderStyle.solid, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: iconSize, color: _secondaryTextColor),
            SizedBox(height: size.height * 0.01),
            Text(
              'Tap to upload or take a photo',
              style: TextStyle(fontSize: size.width * 0.04, color: _secondaryTextColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewAndProcessingCard(Size size) {
    final previewSize = size.width * 0.20;
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _dividerColor.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: _dividerColor.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: previewSize,
                height: previewSize,
                decoration: BoxDecoration(
                  color: _scaffoldColor,
                  borderRadius: BorderRadius.circular(4),
                  image: DecorationImage(image: NetworkImage(_itemImageUrl), fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: size.width * 0.04),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Image Preview', style: TextStyle(fontSize: size.width * 0.04, fontWeight: FontWeight.w600, color: _primaryTextColor)),
                  SizedBox(height: size.height * 0.01),
                  OutlinedButton(
                    onPressed: _cropImage,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: const BorderSide(color: _kPrimaryTeal, width: 1.5),
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.005),
                    ),
                    child: Text('Crop Image', style: TextStyle(color: _kPrimaryTeal, fontSize: size.width * 0.035, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: size.height * 0.03),
          const Divider(),
          SizedBox(height: size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Remove Background', style: TextStyle(fontSize: size.width * 0.04, fontWeight: FontWeight.w600, color: _primaryTextColor)),
              Switch.adaptive(
                value: _removeBackground,
                onChanged: _isProcessing ? null : (bool value) async {
                  setState(() => _removeBackground = value);
                  await _handleBackgroundRemoval(value);
                },
                activeColor: _kPrimaryTeal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetailsSection(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _dividerColor.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: _dividerColor.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🆕 Show AI detection status
          if (_predictedCategory != null) ...[
            Container(
              padding: EdgeInsets.all(size.width * 0.03),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: size.width * 0.05),
                  SizedBox(width: size.width * 0.02),
                  Expanded(
                    child: Text(
                      'AI detected: $_predictedCategory${_detectedColor != null ? " ($_detectedColor)" : ""}',
                      style: TextStyle(color: Colors.green, fontSize: size.width * 0.035, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.02),
          ],
          if (_mlProcessingFailed) ...[
            Container(
              padding: EdgeInsets.all(size.width * 0.03),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: size.width * 0.05),
                  SizedBox(width: size.width * 0.02),
                  Expanded(
                    child: Text(
                      'Please select category manually',
                      style: TextStyle(color: Colors.orange, fontSize: size.width * 0.035, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.02),
          ],
          Text('Item Name', style: TextStyle(fontSize: size.width * 0.04, fontWeight: FontWeight.w600, color: _primaryTextColor)),
          SizedBox(height: size.height * 0.01),
          TextField(
            onChanged: (value) => setState(() => _itemName = value),
            style: TextStyle(color: _primaryTextColor),
            decoration: InputDecoration(
              hintText: 'e.g., Blue Denim Jacket',
              hintStyle: TextStyle(color: _secondaryTextColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _dividerColor)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _kPrimaryTeal, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          SizedBox(height: size.height * 0.03),
          Text('Category', style: TextStyle(fontSize: size.width * 0.04, fontWeight: FontWeight.w600, color: _primaryTextColor)),
          SizedBox(height: size.height * 0.01),
          DropdownButtonFormField<String>(
            style: TextStyle(color: _primaryTextColor, fontSize: size.width * 0.04),
            dropdownColor: _surfaceColor,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _dividerColor)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _kPrimaryTeal, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            value: _selectedCategory,
            hint: Text('Select a Category', style: TextStyle(color: _secondaryTextColor)),
            items: _categories.map((String category) => DropdownMenuItem<String>(value: category, child: Text(category, style: TextStyle(color: _primaryTextColor)))).toList(),
            onChanged: (String? newValue) => setState(() => _selectedCategory = newValue),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedActionButton(Size size, double padding) {
    final buttonHeight = size.height * 0.07;
    final fontSize = size.width * 0.045;
    final bool isFormValid = _isImageUploaded && _selectedCategory != null && _itemName.isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: size.height * 0.015),
      decoration: BoxDecoration(
        color: _surfaceColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: isFormValid ? _addItemToWardrobe : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kPrimaryTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            disabledBackgroundColor: _kPrimaryTeal.withOpacity(0.5),
          ),
          child: Text('Add to Wardrobe', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}