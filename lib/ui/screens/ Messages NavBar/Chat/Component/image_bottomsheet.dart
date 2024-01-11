// ignore_for_file: use_build_context_synchronously

import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sizer/sizer.dart';

Future<void> showchatbottomSheet(
    BuildContext context, ChatController controller) {
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
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    controller.fileImage.value = pickedFile;
                    Navigator.pop(context);
                    controller.sendMessage();
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
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    controller.fileImage.value = pickedFile;
                    Navigator.pop(context);
                    controller.sendMessage();
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
