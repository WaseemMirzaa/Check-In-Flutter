// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/controllers/Messages/group_detail_controller.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sizer/sizer.dart';

import '../../../../../utils/common.dart';

Future<void> showbottomSheet(
    BuildContext context,
    GroupDetailController controller,
    String docId,
    ChatController chatController) {
  final picker = ImagePicker();

  return showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 150,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10), topLeft: Radius.circular(10))),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //.................Camera
              GestureDetector(
                onTap: () async {
                  XFile? pickedFile =
                      await picker.pickImage(source: ImageSource.camera,);


                  if (pickedFile != null) {
                    File imageFile = await compressImage(pickedFile, quality: 20, height: 200, width: 200);
                    pickedFile = XFile(imageFile.path);

                    controller.fileImage.value = pickedFile;
                    Navigator.pop(context);
                    String image = await controller.updateGroupImage(docId);
                    chatController.image.value = image;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: black)),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 40,
                  ),
                ),
              ),
              horizontalGap(10.w),

              //.................Gallery
              GestureDetector(
                onTap: () async {
                  XFile? pickedFile =
                      await picker.pickImage(source: ImageSource.gallery,);
                  if (pickedFile != null) {
                    File imageFile = await compressImage(pickedFile, quality: 20, height: 200, width: 200);
                    pickedFile = XFile(imageFile.path);

                    controller.fileImage.value = pickedFile;
                    Navigator.pop(context);
                    String image = await controller.updateGroupImage(docId);
                    chatController.image.value = image;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: black)),
                  child: const Icon(
                    Icons.image,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
