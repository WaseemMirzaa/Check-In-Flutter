import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewsFeedController extends GetxController {
  late TextEditingController postController;
  late FocusNode postFocusNode;
  int index = 0;

  @override
  void onInit() {
    super.onInit();
    postController = TextEditingController();
    postFocusNode = FocusNode();
  }
}
