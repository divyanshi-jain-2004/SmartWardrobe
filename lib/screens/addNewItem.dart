
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
  static const String baseUrl = 'https://smart-wardrobe-api-q42p.onrender.com';
  static const Duration timeout = Duration(seconds: 60);
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
  String? _detectedJeansType;
  String? _detectedFootwearType;
  double? _predictionConfidence;
  bool _isProcessing = false;
  bool _mlProcessingFailed = false; // Track ML failure

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _wakeUpServer();
  }

  Future<void> _wakeUpServer() async {
    try {
      await http.get(
        Uri.parse('${MLApiconfig.baseUrl}/health'),
      ).timeout(const Duration(seconds: 10));
      print('Server is awake!');
    } catch (e) {
      print('Server wake-up failed: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 🔧 ONLY WOMEN'S CATEGORIES 
  final Map<String, String> _categoryMapping = {
    'Tops': 'Topwear',
    'Bottoms': 'Bottomwear',
    'Dresses': 'Dresses',
    'Outerwear': 'Topwear',
    'Footwear': 'Footwear',
    'Accessories': 'Jewellery/Scarves',
  };

  final List<String> _categories = [
    'Topwear',
    'Bottomwear',
    'Dresses',
    'Footwear',
    'Jewellery/Scarves'
  ];

  // Theme Getters
  Color get _primaryTextColor => Theme.of(context).textTheme.bodyLarge!.color!;
  Color get _secondaryTextColor => Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.6);
  Color get _surfaceColor => Theme.of(context).colorScheme.surface;
  Color get _scaffoldColor => Theme.of(context).scaffoldBackgroundColor;
  Color get _dividerColor => Theme.of(context).dividerColor;

  // OPTIMIZED IMAGE COMPRESSION
  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';


      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 75,        // ✅ Reduced for faster upload
        minWidth: 600,      // ✅ Smaller size
        minHeight: 600,
        format: CompressFormat.jpeg, // ✅ JPEG instead of PNG
      );

      if (result != null) {
        final compressedFile = File(result.path);
        final compressedSize = await compressedFile.length();
        print('Compressed file size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB');
        return compressedFile;
      }
      return null;
    } catch (e) {
      print('Compression error: $e');
      return file; // ✅ Return original if compression fails
    }
  }

  Future<void> _handleBackgroundRemoval(bool shouldRemove) async {
    if (_originalImageFile == null) {
      Get.snackbar('Error', 'Please upload an image first.');
      setState(() => _removeBackground = false);
      return;
    }

    setState(() => _isProcessing = true);

    if (shouldRemove) {
      try {
        final bytes = await _originalImageFile!.readAsBytes();
        final base64Image = base64Encode(bytes);

        final response = await http.post(
            Uri.parse('${MLApiconfig.baseUrl}/api/remove-background'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'image': base64Image}),
        ).timeout(MLApiconfig.timeout);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['success'] == true && data['processed_image'] != null) {
            String rawImage = data['processed_image'];

            // 🔧 FIXED: Safer base64 decoding
            final processedBase64 = rawImage.contains(',')
                ? rawImage.split(',')[1]
                : rawImage;

            final processedBytes = base64Decode(processedBase64);
            final dir = await getTemporaryDirectory();
            final tempFile = File('${dir.path}/nobg_${DateTime.now().millisecondsSinceEpoch}.png');
            await tempFile.writeAsBytes(processedBytes);

            // Compress and Update UI
            final compressedFile = await _compressImage(tempFile);

            // 🔧 FIXED: Update the local file reference so the UI shows the new image
            setState(() {
              _selectedImageFile = compressedFile ?? tempFile;
            });

            await _updateLocalImage(_selectedImageFile!, shouldProcessML: false);

            Get.snackbar('Success', 'Background removed!');
          } else {
            throw Exception('Server returned success: false');
          }
        } else {
          throw Exception('Server Error: ${response.statusCode}');
        }
      } catch (e) {
        print('BG Removal Error: $e');
        Get.snackbar('Error', 'Failed to remove background. Server might be down.');
        setState(() => _removeBackground = false);
      }
    } else {
      // Restore original if toggle turned off
      if (_originalImageFile != null) {
        await _updateLocalImage(_originalImageFile!);
        setState(() => _selectedImageFile = _originalImageFile);
      }
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
      await _pickImageFromSource(source);
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
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
        print('Using compressed image');
      }

      _originalImageFile = imageFile;

      await _updateLocalImage(imageFile, shouldProcessML: true);
      Get.closeCurrentSnackbar();
    }
  }

  // IMPROVED ML PROCESSING with better error handling
// 🔧 FIX 2: Better ML processing with name update
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

      print('Calling ML API: ${MLApiconfig.baseUrl}/process-clothing');

      final response = await http.post(
          Uri.parse('${MLApiconfig.baseUrl}/api/process-clothing')
        ,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      ).timeout(MLApiconfig.timeout);

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          String mlCategory = data['category'];
          String uiCategory = _categoryMapping[mlCategory] ?? mlCategory;

          // ✅ FIX: Extract values first, then build name
          final String detectedColor = data['color'] ?? 'Fashion';
          final String? subType = (uiCategory == 'Bottomwear' && data['sub_type'] != null)
              ? data['sub_type']
              : null;
          // ✅ NEW: Extract footwear type if detected
          final String? footwearType = (uiCategory == 'Footwear' && data['footwear_type'] != null)
              ? data['footwear_type']
              : null;

          setState(() {
            _predictedCategory = uiCategory;
            _detectedColor = detectedColor;
            _detectedJeansType = subType;
            _detectedFootwearType = footwearType;
            _predictionConfidence = data['confidence'];

            if (_categories.contains(uiCategory)) {
              _selectedCategory = uiCategory;
            }

            // ✅ FIX: Build name AFTER setting all values
            String newName = detectedColor;
            if (subType != null) {
              newName += ' $subType';
            } else if(footwearType != null){
              newName += '$footwearType';
            }
            newName += ' $uiCategory';

            _itemName = newName.trim();
            _nameController.text = _itemName;
          });

          Get.closeCurrentSnackbar();

          String detectionDetails = 'Detected: $uiCategory';
          if (subType != null) {
            detectionDetails += ' • $subType';
          } else if (footwearType != null) {
            detectionDetails += ' • $footwearType';
          }
          detectionDetails += ' • Color: $detectedColor (${(data['confidence'] * 100).toStringAsFixed(1)}% confident)';

          Get.snackbar(
            'AI Analysis Complete!',
            'Detected: $uiCategory'
                '${subType != null ? " • $subType" : ""}'
                ' • Color: $detectedColor (${(data['confidence'] * 100).toStringAsFixed(1)}% confident)',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        }
      } else {
        throw Exception('API returned status ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      print('ML Processing Timeout');
      setState(() => _mlProcessingFailed = true);
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'AI Timeout',
        'Auto-detection took too long. Please select category manually.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      print('ML Processing Error: $e');
      setState(() => _mlProcessingFailed = true);
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Manual Selection Required',
        'AI detection unavailable. Please select category manually.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
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
        backgroundColor: Colors.red.withValues(alpha: 0.8),
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

      await Future.delayed(const Duration(milliseconds: 500));
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

        await _updateLocalImage(newImageFile, shouldProcessML: false);

        Get.closeCurrentSnackbar();
        Get.snackbar(
          'Success',
          'Image cropped and updated!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Crop Error: $e');
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Error',
        'Cropping failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _updateLocalImage(File imageFile, {bool shouldProcessML = false}) async {
    try {
      Get.showOverlay(
        asyncFunction: () async {
          if (shouldProcessML) {
            await _processImageWithML(imageFile);
          }

          setState(() {
            _selectedImageFile = imageFile;
            _isImageUploaded = true;
          });
        },
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: _kPrimaryTeal),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update image: $e', backgroundColor: Colors.red);
    }
  }



  // IMPROVED: Add item to wardrobe with proper validation
  void _addItemToWardrobe() async {
    if (_itemName.isEmpty || _selectedCategory == null || _selectedImageFile == null) {
      Get.snackbar(
        'Validation',
        'Please fill all details and upload an image.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isProcessing = true);

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

      // ✅ Upload with proper extension
      final extension = _removeBackground ? 'png' : 'jpg';
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.$extension';

      await supabase.storage.from('wardrobe_image').upload(
        fileName,
        _selectedImageFile!,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final finalPublicUrl = supabase.storage.from('wardrobe_image').getPublicUrl(fileName);
      String? finalSubType;
      if (_selectedCategory == 'Bottomwear') {
        finalSubType = _detectedJeansType;
      } else if (_selectedCategory == 'Footwear') {
        finalSubType = _detectedFootwearType; // ✅ NEW: Use footwear type for Footwear category
      }
      final newItem = {
        'user_id': userId,
        'item_name': _itemName.trim(),
        'category': _selectedCategory,
        'sub_type': finalSubType,
        'image_url': finalPublicUrl,
        'color': _detectedColor ?? 'Unknown',
        'remove_background': _removeBackground,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('Inserting item: $newItem');

      await supabase.from('wardrobe_items').insert(newItem);

      print('✅ Item Added Successfully!');

      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Success!',
        'Item added to your wardrobe',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      _resetForm();

    } on StorageException catch (e) {
      print('❌ Storage Error: ${e.message}');
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Upload Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } on PostgrestException catch (error) {
      print('❌ Database Error: ${error.message}');
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Database Error',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ General Error: $e');
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Error',
        'Failed to add item. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _resetForm() {
    _nameController.clear();
    setState(() {
      _isImageUploaded      = false;
      _removeBackground     = false;
      _itemName             = '';
      _selectedCategory     = null;
      _itemImageUrl         = 'https://placehold.co/100x100/CCCCCC/000000?text=No+Image';
      _selectedImageFile    = null;
      _originalImageFile    = null;
      _predictedCategory    = null;
      _detectedColor        = null;
      _detectedJeansType    = null;
      _detectedFootwearType = null;
      _predictionConfidence = null;
      _isProcessing         = false;
      _mlProcessingFailed   = false;
    });
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

        bottom: _isProcessing
            ? const PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: LinearProgressIndicator(color: _kPrimaryTeal),
        )
            : null,

      ),
      body: !_isImageUploaded
          // ── No image yet: center the upload card + button ──────────────
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildUploadImageCard(size),
                  SizedBox(height: size.height * 0.04)
                ],
              ),
            )
          // ── Image chosen: scrollable details + fixed bottom button ──────
          : Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: bottomSpace),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPreviewAndProcessingCard(size),
                        SizedBox(height: size.height * 0.03),
                        _buildItemDetailsSection(size),
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
    return Container(
      width: double.infinity,
      height: size.height * 0.26,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _kPrimaryTeal.withValues(alpha:0.07),
            _kPrimaryTeal.withValues(alpha:0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _kPrimaryTeal.withValues(alpha:0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: size.width * 0.16,
            height: size.width * 0.16,
            decoration: BoxDecoration(
              color: _kPrimaryTeal.withValues(alpha:0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_photo_alternate_outlined,
              size: size.width * 0.09,
              color: _kPrimaryTeal,
            ),
          ),
          SizedBox(height: size.height * 0.018),
          Text(
            'Upload Photo',
            style: TextStyle(
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.bold,
              color: _primaryTextColor,
            ),
          ),
          SizedBox(height: size.height * 0.006),
          Text(
            'Choose how you want to add your photo',
            style: TextStyle(
              fontSize: size.width * 0.032,
              color: _secondaryTextColor,
            ),
          ),
          SizedBox(height: size.height * 0.018),
          // Camera / Gallery pills — each opens directly
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _uploadPill(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                size: size,
                onTap: () => _pickImageFromSource(ImageSource.camera),
              ),
              SizedBox(width: size.width * 0.03),
              _uploadPill(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                size: size,
                onTap: () => _pickImageFromSource(ImageSource.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _uploadPill({
    required IconData icon,
    required String label,
    required Size size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.007,
        ),
        decoration: BoxDecoration(
          color: _kPrimaryTeal.withValues(alpha:0.12),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _kPrimaryTeal.withValues(alpha:0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: size.width * 0.038, color: _kPrimaryTeal),
            SizedBox(width: size.width * 0.015),
            Text(
              label,
              style: TextStyle(
                fontSize: size.width * 0.03,
                color: _kPrimaryTeal,
                fontWeight: FontWeight.w600,
              ),
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
        border: Border.all(color: _dividerColor.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: _dividerColor.withValues(alpha: 0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
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
                  image: DecorationImage(
                    image: _selectedImageFile != null 
                        ? FileImage(_selectedImageFile!) as ImageProvider 
                        : NetworkImage(_itemImageUrl), 
                    fit: BoxFit.cover
                  ),
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
        border: Border.all(color: _dividerColor.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: _dividerColor.withValues(alpha: 0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show AI detection status
          if (_predictedCategory != null) ...[
            Container(
              padding: EdgeInsets.all(size.width * 0.03),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: size.width * 0.05),
                      SizedBox(width: size.width * 0.02),
                      Expanded(
                        child: Text(
                          'AI detected: $_predictedCategory${_detectedColor != null ? " • $_detectedColor" : ""}',
                          style: TextStyle(color: Colors.green, fontSize: size.width * 0.035, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  // 🆕 Jeans type badge — sirf Bottomwear ke liye dikhega
                  if (_detectedJeansType != null) ...[
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.07),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _kPrimaryTeal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _kPrimaryTeal.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '👖 $_detectedJeansType',
                          style: TextStyle(
                            color: _kPrimaryTeal,
                            fontSize: size.width * 0.032,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ✅ NEW: Show Footwear type badge
                  if (_detectedFootwearType != null) ...[
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.07),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _kPrimaryTeal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _kPrimaryTeal.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '👟 $_detectedFootwearType',
                          style: TextStyle(
                            color: _kPrimaryTeal,
                            fontSize: size.width * 0.032,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: size.height * 0.02),
          ],
          if (_mlProcessingFailed) ...[
            Container(
              padding: EdgeInsets.all(size.width * 0.03),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
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
            controller: _nameController,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: isFormValid ? _addItemToWardrobe : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
            disabledBackgroundColor: _kPrimaryTeal.withValues(alpha:0.35),
            padding: EdgeInsets.zero,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: isFormValid
                  ? const LinearGradient(
                      colors: [Color(0xFF00C7B1), Color(0xFF009688)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: isFormValid ? null : _kPrimaryTeal.withValues(alpha:0.35),
              borderRadius: BorderRadius.circular(14),
              boxShadow: isFormValid
                  ? [
                      BoxShadow(
                        color: _kPrimaryTeal.withValues(alpha:0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.checkroom_rounded, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Add to Wardrobe',
                    style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
}