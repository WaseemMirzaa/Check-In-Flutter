import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class CreatePostController extends GetxController {
  late TextEditingController postController;

  late Rx<XFile?> fileImage = Rx<XFile?>(null);
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  RxString type = ''.obs;
  RxBool videoLoad = false.obs;
  @override
  void onInit() {
    super.onInit();
    postController = TextEditingController();
  }

  Future<bool> filePicker(String fileType) async {
    if (fileType == 'image') {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        fileImage.value = pickedFile;
        type.value = 'image';
        return true;
      } else {
        return false;
      }
    } else {
      final pickedFile =
          await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        videoLoad.value = true;

        /// video player initialize
        videoPlayerController =
            VideoPlayerController.file(File(pickedFile.path))
              ..initialize().then(
                (_) => videoLoad.value = false,
              );
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          allowMuting: false,
          allowFullScreen: false,
          showOptions: false,
        );
        type.value = 'video';
        return true;
      } else {
        return false;
      }
    }
  }
}
