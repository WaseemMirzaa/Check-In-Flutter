import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Services/message_service.dart';

class NewMessageController extends GetxController {
  final MessageService chatService;
  late TextEditingController searchController;
  NewMessageController(this.chatService);

  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
  }
//............ get messages
  // Stream<List<Messagemodel>> getChatMessage() {
  //   return chatService.getChatMessage(userId.value);
  // }
}
