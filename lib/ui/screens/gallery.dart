import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GalleryScreen extends StatefulWidget {
  final String courtName;
  final bool isPremium;

  const GalleryScreen({
    super.key,
    required this.courtName,
    required this.isPremium,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // Sample gallery images - replace with actual data
  List<String> galleryImages = List.generate(12, (index) => AppAssets.LOGO_NEW);
  final ImagePicker _picker = ImagePicker();
  List<File> uploadedImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhiteColor,
      appBar: AppBar(
        backgroundColor: appWhiteColor,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 10),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SizedBox(
            height: 2.1.h,
            width: 2.9.w,
            child: Image.asset(
              AppAssets.LEFT_ARROW,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          "Gallery",
          style: TextStyle(
            fontFamily: TempLanguage.poppins,
            fontSize: 20,
            color: appBlackColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.0,
                ),
                itemCount: galleryImages.length + uploadedImages.length,
                itemBuilder: (context, index) {
                  bool isUploadedImage = index >= galleryImages.length;
                  String imagePath = isUploadedImage
                      ? uploadedImages[index - galleryImages.length].path
                      : galleryImages[index];

                  return GestureDetector(
                    onTap: () {
                      _showImagePreview(
                          context, imagePath, index, isUploadedImage);
                    },
                    onLongPress: isUploadedImage
                        ? () {
                            _showDeleteConfirmation(
                                index - galleryImages.length);
                          }
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: isUploadedImage
                            ? Border.all(color: appGreenColor, width: 2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: isUploadedImage
                                ? Image.file(
                                    File(imagePath),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
                                : Image.asset(
                                    imagePath,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                          ),
                          if (isUploadedImage)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: appGreenColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (widget.isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Uploaded images have a green border and checkmark. Long press to delete uploaded images.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: TempLanguage.poppins,
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          if (widget.isPremium) const SizedBox(height: 10),
          if (widget.isPremium)
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _uploadImages,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: appGreenColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          "Upload Images",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: TempLanguage.poppins,
                            fontSize: 16,
                            color: appWhiteColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, String imagePath, int index,
      [bool isUploadedImage = false]) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isUploadedImage
                        ? Image.file(
                            File(imagePath),
                            fit: BoxFit.contain,
                          )
                        : Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _uploadImages() {
    // Implement image upload functionality
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Upload Images",
            style: TextStyle(
              fontFamily: TempLanguage.poppins,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            "Choose how you want to upload images:",
            style: TextStyle(
              fontFamily: TempLanguage.poppins,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: TempLanguage.poppins,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
              child: Text(
                "Gallery",
                style: TextStyle(
                  color: appGreenColor,
                  fontFamily: TempLanguage.poppins,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
              child: Text(
                "Camera",
                style: TextStyle(
                  color: appGreenColor,
                  fontFamily: TempLanguage.poppins,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image != null) {
        setState(() {
          uploadedImages.add(File(image.path));
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Image uploaded successfully!",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: appGreenColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error picking image: ${e.toString()}",
            style: TextStyle(fontFamily: TempLanguage.poppins),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image != null) {
        setState(() {
          uploadedImages.add(File(image.path));
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Image captured and uploaded successfully!",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: appGreenColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error capturing image: ${e.toString()}",
            style: TextStyle(fontFamily: TempLanguage.poppins),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(int uploadedImageIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Image",
            style: TextStyle(
              fontFamily: TempLanguage.poppins,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this uploaded image?",
            style: TextStyle(
              fontFamily: TempLanguage.poppins,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: TempLanguage.poppins,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  uploadedImages.removeAt(uploadedImageIndex);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Image deleted successfully!",
                      style: TextStyle(fontFamily: TempLanguage.poppins),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: TempLanguage.poppins,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
