import 'package:check_in/model/chat_model.dart';
import 'package:check_in/utils/Constants/global_variable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Services/message_service.dart';

class ChatController extends GetxController {
  final MessageService chatService;
  final RxString docId = ''.obs;
  String name = '';
  bool isgroup = false;
  RxBool issticker = true.obs;
  late TextEditingController chatfieldController;

  ChatController(this.chatService);

  @override
  void onInit() {
    super.onInit();
    chatfieldController = TextEditingController();
  }

  //............. get all conversation
  Stream<List<Chatmodel>> getConversation() {
    return chatService.getConversation(docId.value, GlobalVariable.userid);
  }

//.............. send chat
  Future<void> sendMessage() async {
    String time = DateTime.now().toString();
    String uid = GlobalVariable.userid;
    String message = chatfieldController.text;
    Chatmodel chatmodel = Chatmodel(id: uid, message: message, time: time);

    await chatService.sendMessage(docId.value, chatmodel);
  }

  @override
  void onClose() {
    super.onClose();
    chatfieldController.dispose();
  }
}
