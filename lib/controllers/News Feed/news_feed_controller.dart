import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class NewsFeedController extends GetxController {
  late TextEditingController postController;
  late FocusNode postFocusNode;
  late Rx<XFile?> fileImage = Rx<XFile?>(null);

  @override
  void onInit() {
    super.onInit();
    postController = TextEditingController();
    postFocusNode = FocusNode();
  }
}
