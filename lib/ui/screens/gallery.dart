import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/court_data_models.dart';
import 'package:check_in/Services/court_data_service.dart';
import 'package:check_in/ui/widgets/upload_dialog.dart';
import 'package:check_in/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/user_controller.dart';

class GalleryScreen extends StatefulWidget {
  final String courtName;
  final String courtId;
  final bool isPremium;
  final bool isCheckedIn;

  const GalleryScreen({
    super.key,
    required this.courtName,
    required this.courtId,
    required this.isPremium,
    required this.isCheckedIn,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();

  // Static method to upload images from any page
  static Future<void> uploadImagesFromPreviousPage({
    required BuildContext context,
    required String courtId,
    required String courtName,
  }) async {
    final ImagePicker picker = ImagePicker();

    try {
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (images.isNotEmpty) {
        await _uploadImagesToFirebaseStatic(
          context: context,
          courtId: courtId,
          courtName: courtName,
          imageFiles: images.map((image) => File(image.path)).toList(),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error picking images: ${e.toString()}",
            style: TextStyle(fontFamily: TempLanguage.poppins),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Static method to show upload dialog from any page
  static void showUploadDialog({
    required BuildContext context,
    required String courtId,
    required String courtName,
  }) {
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
            "Choose how you want to upload images:\n\n• Gallery: Select multiple images\n• Camera: Take a single photo",
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
                uploadImagesFromPreviousPage(
                  context: context,
                  courtId: courtId,
                  courtName: courtName,
                );
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
                _takeCameraPhotoStatic(
                  context: context,
                  courtId: courtId,
                  courtName: courtName,
                );
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

  static Future<void> _takeCameraPhotoStatic({
    required BuildContext context,
    required String courtId,
    required String courtName,
  }) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image != null) {
        await _uploadImagesToFirebaseStatic(
          context: context,
          courtId: courtId,
          courtName: courtName,
          imageFiles: [File(image.path)],
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

  static Future<void> _uploadImagesToFirebaseStatic({
    required BuildContext context,
    required String courtId,
    required String courtName,
    required List<File> imageFiles,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(
                "Uploading images...",
                style: TextStyle(fontFamily: TempLanguage.poppins),
              ),
            ],
          ),
        );
      },
    );

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please login to upload images",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userController = Get.find<UserController>();
      final user = userController.userModel.value;

      int successCount = 0;
      int totalCount = imageFiles.length;

      for (int i = 0; i < imageFiles.length; i++) {
        try {
          final imageFile = imageFiles[i];
          final timestamp = DateTime.now().millisecondsSinceEpoch + i;
          final fileName = '$timestamp.jpg';

          // Upload to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('courts')
              .child(courtId)
              .child('gallery')
              .child(fileName);

          final uploadTask = storageRef.putFile(imageFile);
          final snapshot = await uploadTask;
          final downloadUrl = await snapshot.ref.getDownloadURL();

          // Save to Firestore
          await FirebaseFirestore.instance
              .collection(Collections.GOLDEN_LOCATIONS)
              .doc(courtId)
              .collection(Collections.GALLERY)
              .add({
            GalleryKey.IMAGE_URL: downloadUrl,
            GalleryKey.UPLOADED_BY: currentUser.uid,
            GalleryKey.UPLOADED_BY_NAME: user.userName,
            GalleryKey.UPLOADED_BY_PHOTO: user.photoUrl,
            GalleryKey.UPLOADED_AT: FieldValue.serverTimestamp(),
            GalleryKey.DESCRIPTION: '',
          });

          successCount++;
        } catch (e) {
          debugPrint("Error uploading image ${i + 1}: ${e.toString()}");
        }
      }

      Navigator.pop(context); // Close loading dialog

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$successCount of $totalCount images uploaded successfully!",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: successCount > 0 ? appGreenColor : Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error uploading images: ${e.toString()}",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<GalleryItem> galleryItems = [];
  bool isLoading = true;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadGalleryItems();
  }

  Future<void> _loadGalleryItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      final stream = CourtDataService(courtId: widget.courtId).galleryItems;
      stream.listen((items) {
        if (mounted) {
          setState(() {
            galleryItems = items;
            isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error loading gallery: ${e.toString()}",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return "${date.day}/${date.month}/${date.year}";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago";
    } else {
      return "Just now";
    }
  }

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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : galleryItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No images yet",
                              style: TextStyle(
                                fontFamily: TempLanguage.poppins,
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(20),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: galleryItems.length,
                          itemBuilder: (context, index) {
                            final item = galleryItems[index];
                            return GestureDetector(
                              onTap: () {
                                _showImagePreview(context, item);
                              },
                              onLongPress:
                                  widget.isPremium && widget.isCheckedIn
                                      ? () {
                                          _showDeleteConfirmation(item);
                                        }
                                      : null,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      offset: const Offset(0, 2),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        item.imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey.shade500,
                                              size: 40,
                                            ),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.7),
                                              ],
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.uploadedByName,
                                                style: TextStyle(
                                                  fontFamily:
                                                      TempLanguage.poppins,
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                _formatDate(item.uploadedAt),
                                                style: TextStyle(
                                                  fontFamily:
                                                      TempLanguage.poppins,
                                                  fontSize: 10,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
          if (widget.isPremium && widget.isCheckedIn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Long press on your uploaded images to delete them.",
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
          if (widget.isPremium && widget.isCheckedIn)
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: isUploading
                          ? null
                          : () {
                              UploadDialog.showUploadDialog(
                                context: context,
                                courtId: widget.courtId,
                                courtName: widget.courtName,
                              );
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: isUploading ? Colors.grey : appGreenColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isUploading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2,
                                ),
                              ),
                            if (isUploading) const SizedBox(width: 10),
                            Text(
                              isUploading ? "Uploading..." : "Upload Images",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: TempLanguage.poppins,
                                fontSize: 16,
                                color: appWhiteColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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

  void _showImagePreview(BuildContext context, GalleryItem item) {
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
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade500,
                            size: 40,
                          ),
                        );
                      },
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

  void _showDeleteConfirmation(GalleryItem item) {
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
            "Are you sure you want to delete this image?",
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
                Navigator.pop(context);
                _deleteImage(item);
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

  Future<void> _deleteImage(GalleryItem item) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || item.uploadedBy != currentUser.uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "You can only delete images you uploaded",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Delete from Firebase Storage
      final storageRef = FirebaseStorage.instance.refFromURL(item.imageUrl);
      await storageRef.delete();

      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection(Collections.GOLDEN_LOCATIONS)
          .doc(widget.courtId)
          .collection(Collections.GALLERY)
          .doc(item.id)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Image deleted successfully!",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: appGreenColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error deleting image: ${e.toString()}",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
