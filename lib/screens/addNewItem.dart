import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// --- THEME COLORS ---
const Color _kPrimaryTeal = Color(0xFF00C7B1);
// const Color _kSoftMint = Color(0xFFE8F5E9); 
// const Color _kSoftMintBorder = Color(0xFF66BB6A);
// const Color _kBackground = Colors.white;

// Global accessor for the Supabase client
// ASSUMPTION: This must be correctly initialized in your main.dart file.
final supabase = Supabase.instance.client;

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}
class MLApiconfig{
  static const String baseUrl = 'http://172.8.2.79:5000/api';
}

class _AddItemScreenState extends State<AddItemScreen> {
  // State variables
  bool _isImageUploaded = false;
  bool _removeBackground = false;

  // Variables to hold form data and image info
  String _itemName = '';
  String? _selectedCategory;
  String _itemImageUrl = 'https://placehold.co/100x100/CCCCCC/000000?text=No+Image';

  File? _selectedImageFile;
  String? _predictedCategory;
  String? _detectedColor;
  double? _predictionConfidence;
  bool _isProcessing = false;

  // Mock list for categories
  final List<String> _categories = ['Tops', 'Bottoms', 'Dresses', 'Outerwear', 'Footwear'];



  // 🎯 Theme Getters
  Color get _primaryTextColor => Theme.of(context).textTheme.bodyLarge!.color!;
  Color get _secondaryTextColor => Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6);
  Color get _surfaceColor => Theme.of(context).colorScheme.surface;
  Color get _scaffoldColor => Theme.of(context).scaffoldBackgroundColor;
  Color get _dividerColor => Theme.of(context).dividerColor;


  // --- LOGIC FOR PICKING IMAGE (CAMERA/GALLERY) ---

  void _pickImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        // 🎯 SimpleDialog को Theme-Aware बनाएं
        return SimpleDialog(
          title: Text('Select Image Source', style: TextStyle(color: _primaryTextColor)),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Get.back(result: ImageSource.camera); // 🎯 GetX Navigation
              },
              child: Row(
                children: [
                  Icon(Icons.camera_alt, color: _secondaryTextColor), // 🎯 Theme-Aware Icon Color
                  const SizedBox(width: 10),
                  Text('Take a Photo (Camera)', style: TextStyle(color: _primaryTextColor)),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Get.back(result: ImageSource.gallery); // 🎯 GetX Navigation
              },
              child: Row(
                children: [
                  Icon(Icons.photo_library, color: _secondaryTextColor), // 🎯 Theme-Aware Icon Color
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
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);

        // Display initial loading indicator
        if (mounted) {
          // 🎯 GetX Snackbar
          Get.snackbar(
            'Uploading Image',
            'Processing and uploading image to storage...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: _kPrimaryTeal,
            colorText: Colors.white,
            showProgressIndicator: true,
            duration: const Duration(seconds: 30),
            progressIndicatorBackgroundColor: Colors.white,
          );
        }

        await _uploadImage(imageFile);

        // Clear the loading indicator
        if (mounted) {
          Get.closeCurrentSnackbar(); // 🎯 GetX Close Snackbar
        }
      } else {
        print('No image selected.');
      }
    }
  }

  Future<void> _processImageWithML(File imageFile) async {
    try {
      setState(() => _isProcessing = true);

      // Show loading
      Get.snackbar(
        'Processing',
        'AI is analyzing your clothing...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00C7B1),
        colorText: Colors.white,
        showProgressIndicator: true,
        duration: const Duration(seconds: 30),
      );

      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      print('📡 Calling API: ${MLApiconfig.baseUrl}/process-clothing');

      // Call ML API
      final response = await http.post(
        Uri.parse('${MLApiconfig.baseUrl}/process-clothing'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': base64Image,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - API took too long to respond');
        },
      );

      print('Response status: ${response.statusCode}');
      print(' Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          setState(() {
            _predictedCategory = data['category'];
            _detectedColor = data['color'];
            _predictionConfidence = data['confidence'];

            // Auto-fill category if it matches one in dropdown
            if (_categories.contains(data['category'])) {
              _selectedCategory = data['category'];
            }
          });

          Get.closeCurrentSnackbar();
          Get.snackbar(
            'AI Analysis Complete!',
            'Detected: ${data['category']} • Color: ${data['color']} (${(data['confidence'] * 100).toStringAsFixed(1)}% confident)',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );

          print(' ML Processing successful');
          print('   Category: ${data['category']}');
          print('   Color: ${data['color']}');
          print('   Confidence: ${data['confidence']}');
        }
      } else {
        throw Exception('API returned status ${response.statusCode}');
      }
    } catch (e) {
      print(' ML Processing Error: $e');
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Warning',
        'AI analysis failed. Please select category manually.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // --- NEW: Function to handle image cropping and re-upload ---
  Future<void> _cropImage() async {
    if (_selectedImageFile == null) {
      if (mounted) {
        Get.snackbar('Error', 'Please upload an image first.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      }
      return;
    }

    if (mounted) {
      Get.snackbar('Processing', 'Opening crop tool...', snackPosition: SnackPosition.BOTTOM, backgroundColor: _kPrimaryTeal, colorText: Colors.white);
    }

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _selectedImageFile!.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Your Item',
            toolbarColor: _kPrimaryTeal, // Toolbar color remains Accent Teal
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Your Item',
          ),
        ],
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
      );

      if (mounted) {
        Get.closeCurrentSnackbar();
      }

      if (croppedFile != null) {
        final newImageFile = File(croppedFile.path);

        // Show re-uploading indicator
        if (mounted) {
          Get.snackbar(
            'Re-uploading',
            'Re-uploading cropped image...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: _kPrimaryTeal,
            colorText: Colors.white,
            showProgressIndicator: true,
            duration: const Duration(seconds: 30),
            progressIndicatorBackgroundColor: Colors.white,
          );
        }

        // Re-upload the cropped image
        await _uploadImage(newImageFile);

        // Clear re-uploading indicator
        if (mounted) {
          Get.closeCurrentSnackbar();
          Get.snackbar('Success', 'Image cropped and updated!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
        }
      } else {
        print('Cropping cancelled.');
      }
    } catch (e) {
      print('Crop Error: $e');
      if (mounted) {
        Get.closeCurrentSnackbar();
        Get.snackbar('Error', 'Cropping failed: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      }
    }
  }

  // Function to upload the image to Supabase Storage
  Future<void> _uploadImage(File imageFile) async {
    try {
      // (Supabase logic remains unchanged)
      final userId = supabase.auth.currentUser!.id;
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      // Show uploading indicator
      if (mounted) {
        Get.snackbar(
          'Uploading Image',
          'Uploading to storage...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF00C7B1),
          colorText: Colors.white,
          showProgressIndicator: true,
          duration: const Duration(seconds: 30),
        );
      }
      await supabase.storage.from('wardrobe_image').upload(
        fileName,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final publicUrl = supabase.storage.from('wardrobe_image').getPublicUrl(fileName);
      if (mounted) {
        Get.closeCurrentSnackbar();
      }
      await _processImageWithML(imageFile);
      if (mounted) {
        setState(() {
          _itemImageUrl = publicUrl;
          _selectedImageFile = imageFile;
          _isImageUploaded = true;
        });
      }

      print('Image Uploaded successfully. URL: $publicUrl');

    } on StorageException catch (e) {
      print('Supabase Storage Error: ${e.message}');
      if (mounted) {
        Get.closeCurrentSnackbar();
        Get.snackbar('Storage Error', e.message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      }
    } catch (e) {
      print('General Image Upload Error: $e');
      if (mounted) {
        Get.closeCurrentSnackbar();
        Get.snackbar('Error', 'Failed to upload image: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white);
      }
    }
  }


  // Function to save item details to Supabase Database
  void _addItemToWardrobe() async {
    // 1. Validation Check
    if (_itemName.isEmpty || _selectedCategory == null || !_isImageUploaded) {
      if (mounted) {
        Get.snackbar('Validation', 'Please fill all details and upload an image.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange.withOpacity(0.8), colorText: Colors.white);
      }
      return;
    }

    // Show loading indicator for database insert
    if (mounted) {
      Get.snackbar(
        'Processing',
        'Adding item to database...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _kPrimaryTeal,
        colorText: Colors.white,
        showProgressIndicator: true,
        duration: const Duration(seconds: 10),
        progressIndicatorBackgroundColor: Colors.white,
      );
    }

    try {
      // (Supabase logic remains unchanged)
      final userId = supabase.auth.currentUser?.id;
      final newItem = {
        'user_id': userId,
        'item_name': _itemName,
        'category': _selectedCategory,
        'image_url': _itemImageUrl,
        'remove_background': _removeBackground,
      };

      await supabase
          .from('wardrobe_items')
          .insert(newItem);

      // 4. Success Handling
      print('✅ Item Added to Wardrobe Successfully!');

      if (mounted) {
        Get.closeCurrentSnackbar();
        Get.snackbar('Success', 'Item successfully added to Wardrobe!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);

        // Go back to the previous screen, indicating success
        Get.back(result: true); // 🎯 GetX Navigation
      }

    } on PostgrestException catch (error) {
      print('Supabase Insert Error: ${error.message}');
      if (mounted) {
        Get.closeCurrentSnackbar();
        Get.snackbar('Database Error', error.message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      }
    } catch (e) {
      print('General Error during item addition: $e');
    }
  }

  // --- BUILD METHODS ---

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.04;
    final bottomSpace = size.height * 0.10;

    return Scaffold(
      // 🎯 Theme-Aware Background Color
      backgroundColor: _scaffoldColor,
      appBar: AppBar(
        // AppBar color comes from Theme
        elevation: 0,
        title: Text(
          'Add New Item',
          // 🎯 Theme-Aware Text Color
          style: TextStyle(fontWeight: FontWeight.bold, color: _primaryTextColor),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Scrollable Content Area
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

          // Fixed Bottom Button
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

  // --- 1. Upload Image Card ---
  Widget _buildUploadImageCard(Size size) {
    final cardHeight = size.height * 0.22;
    final iconSize = size.width * 0.12;

    // 🎯 SoftMint/Green Colors Replacement (Use Theme Surface or Accent combination)
    // We use a lighter version of the scaffold/surface color for contrast
    final uploadCardColor = _scaffoldColor;
    final uploadCardBorderColor = _kPrimaryTeal.withOpacity(0.5); // Use a light accent border

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: uploadCardColor, // 🎯 Theme-Aware Color
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: uploadCardBorderColor, // 🎯 Theme-Aware Border
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: iconSize,
              color: _secondaryTextColor, // 🎯 Theme-Aware Icon Color
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              'Tap to upload or take a photo',
              style: TextStyle(
                fontSize: size.width * 0.04,
                color: _secondaryTextColor, // 🎯 Theme-Aware Text Color
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. Preview and Processing Card ---
  Widget _buildPreviewAndProcessingCard(Size size) {
    final previewSize = size.width * 0.20;

    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: _surfaceColor, // 🎯 Theme-Aware Color (Card Background)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _dividerColor.withOpacity(0.5)), // 🎯 Theme-Aware Border
        boxShadow: [
          BoxShadow(
            color: _dividerColor.withOpacity(0.2), // 🎯 Theme-Aware Shadow
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Thumbnail
              Container(
                width: previewSize,
                height: previewSize,
                decoration: BoxDecoration(
                  color: _scaffoldColor, // 🎯 Theme-Aware Placeholder Background
                  borderRadius: BorderRadius.circular(4),
                  image: DecorationImage(
                    image: NetworkImage(_itemImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.04),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Crop Image Preview',
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.w600,
                      color: _primaryTextColor, // 🎯 Theme-Aware Text Color
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  // Crop Image Button
                  OutlinedButton(
                    onPressed: _cropImage,
                    style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: _kPrimaryTeal, width: 1.5),
                        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.005)),
                    child: Text(
                      'Crop Image',
                      style: TextStyle(
                        color: _kPrimaryTeal,
                        fontSize: size.width * 0.035,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: size.height * 0.03),
          const Divider(), // Divider respects current theme
          SizedBox(height: size.height * 0.01),

          // Remove Background Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remove Background',
                style: TextStyle(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w600,
                    color: _primaryTextColor), // 🎯 Theme-Aware Text Color
              ),
              Switch.adaptive(
                value: _removeBackground,
                onChanged: (bool value) {
                  setState(() {
                    _removeBackground = value;
                  });
                },
                activeColor: _kPrimaryTeal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3. Item Details Section ---
  Widget _buildItemDetailsSection(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: _surfaceColor, // 🎯 Theme-Aware Color (Card Background)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: _dividerColor.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Name Input
          Text(
            'Item Name',
            style: TextStyle(
                fontSize: size.width * 0.04, fontWeight: FontWeight.w600, color: _primaryTextColor), // 🎯 Theme-Aware Text Color
          ),
          SizedBox(height: size.height * 0.01),
          TextField(
            onChanged: (value) {
              setState(() {
                _itemName = value;
              });
            },
            // 🎯 Input Text Color
            style: TextStyle(color: _primaryTextColor),
            decoration: InputDecoration(
              hintText: 'e.g., Blue Denim Jacket',
              hintStyle: TextStyle(color: _secondaryTextColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _dividerColor), // 🎯 Theme-Aware Border
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kPrimaryTeal, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          SizedBox(height: size.height * 0.03),

          // Category Dropdown
          Text(
            'Category',
            style: TextStyle(
                fontSize: size.width * 0.04, fontWeight: FontWeight.w600, color: _primaryTextColor), // 🎯 Theme-Aware Text Color
          ),
          SizedBox(height: size.height * 0.01),
          DropdownButtonFormField<String>(
            // 🎯 Dropdown menu text color
            style: TextStyle(color: _primaryTextColor, fontSize: size.width * 0.04),
            dropdownColor: _surfaceColor, // 🎯 Dropdown list background color
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kPrimaryTeal, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            value: _selectedCategory,
            hint: Text('Select a Category', style: TextStyle(color: _secondaryTextColor)),
            items: _categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category, style: TextStyle(color: _primaryTextColor)), // 🎯 Item Text Color
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  // --- 4. Fixed Bottom Button ---
  Widget _buildFixedActionButton(Size size, double padding) {
    final buttonHeight = size.height * 0.07;
    final fontSize = size.width * 0.045;
    final bool isFormValid = _isImageUploaded && _selectedCategory != null && _itemName.isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: size.height * 0.015),
      decoration: BoxDecoration(
        color: _surfaceColor, // 🎯 Theme-Aware Bottom Container Color
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: isFormValid ? _addItemToWardrobe : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kPrimaryTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            disabledBackgroundColor: _kPrimaryTeal.withOpacity(0.5),
          ),
          child: Text(
            'Add to Wardrobe',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}