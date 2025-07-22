import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/utils/colors.dart';

class UploadDialog {
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
            "Upload Image",
            style: TextStyle(
              fontFamily: TempLanguage.poppins,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose how you want to upload images to $courtName gallery",
                style: TextStyle(
                  fontFamily: TempLanguage.poppins,
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _uploadImagesFromGallery(
                          context: context,
                          courtId: courtId,
                          courtName: courtName,
                        );
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: appGreenColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Gallery",
                              style: TextStyle(
                                fontFamily: TempLanguage.poppins,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _takeCameraPhoto(
                          context: context,
                          courtId: courtId,
                          courtName: courtName,
                        );
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: appGreenColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Camera",
                              style: TextStyle(
                                fontFamily: TempLanguage.poppins,
                                color: Colors.white,
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
            ],
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
          ],
        );
      },
    );
  }

  static Future<void> _uploadImagesFromGallery({
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
        await _uploadImagesToFirebase(
          context: context,
          courtId: courtId,
          courtName: courtName,
          imageFiles: images.map((image) => File(image.path)).toList(),
        );
      }
    } catch (e) {
      if (context.mounted) {
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
  }

  static Future<void> _takeCameraPhoto({
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
        await _uploadImagesToFirebase(
          context: context,
          courtId: courtId,
          courtName: courtName,
          imageFiles: [File(image.path)],
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error taking photo: ${e.toString()}",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> _uploadImagesToFirebase({
    required BuildContext context,
    required String courtId,
    required String courtName,
    required List<File> imageFiles,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Please login to upload images",
                style: TextStyle(fontFamily: TempLanguage.poppins),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final userController = Get.find<UserController>();
      final user = userController.userModel.value;

      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: appGreenColor),
                  const SizedBox(height: 16),
                  Text(
                    "Uploading photo...",
                    style: TextStyle(fontFamily: TempLanguage.poppins),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please wait, do not close the app",
                    style: TextStyle(
                      fontFamily: TempLanguage.poppins,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }

      List<String> uploadedUrls = [];

      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final fileName =
            'gallery_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('courts/$courtId/gallery/$fileName');

        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        uploadedUrls.add(downloadUrl);
      }

      // Save metadata to Firestore using new separate collection approach
      final batch = FirebaseFirestore.instance.batch();
      for (final url in uploadedUrls) {
        final docRef = FirebaseFirestore.instance
            .collection(Collections.COURT_GALLERY)
            .doc();

        batch.set(docRef, {
          GalleryKey.IMAGE_URL: url,
          GalleryKey.UPLOADED_BY: currentUser.uid,
          GalleryKey.UPLOADED_BY_NAME: user.userName,
          GalleryKey.UPLOADED_BY_PHOTO: user.photoUrl,
          GalleryKey.UPLOADED_AT: FieldValue.serverTimestamp(),
          GalleryKey.DESCRIPTION: "",
          GalleryKey.COURT_ID:
              courtId, // Add courtId field for separate collection
        });
      }

      await batch.commit();

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${uploadedUrls.length} image(s) uploaded successfully!",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: appGreenColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (context.mounted) {
        Navigator.pop(context);

        debugPrint("Error uploading images: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to upload images. Please try again.",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
