import 'package:check_in/Services/push_notification_service.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/chat_model.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/message_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../Services/message_service.dart';

class ChatController extends GetxController {
  final MessageService chatService;
  final RxString docId = ''.obs;
  RxString name = ''.obs;
  RxList memberId = [].obs;
  RxString image = ''.obs;
  RxString sendMsgField = ''.obs;
  Rx<XFile?> fileImage = Rx<XFile?>(null);
  bool isgroup = false;
  RxBool issticker = true.obs;
  late TextEditingController chatfieldController;

  late FocusNode chatFieldFocusNode;

  RxBool sendMsgLoader = false.obs;

  ChatController(this.chatService);
  var userController = Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    chatfieldController = TextEditingController();
    chatFieldFocusNode = FocusNode();
  }

  //............. get all conversation
  Stream<List<Chatmodel>> getConversation() {
    return chatService.getConversation(
        docId.value, userController.userModel.value.uid!);
  }

  //............. get message request status
  Stream<Messagemodel> getRequestStatus() {
    return chatService.getMessageRequest(docId.value);
  }

  //............. update request status
  void updateRequestStatus(String status, String msg, int unread) {
    chatService.updateRequestStatus(docId.value, status, msg, unread);
  }

//.............. send chat
  Future<void> sendMessage() async {
    sendMsgLoader.value = true;

    String time = DateTime.now().toString();
    String uid = userController.userModel.value.uid!;
    String message = '';
    String type = '';
    if (chatfieldController.text.isNotEmpty) {
      message = chatfieldController.text;
      type = 'message';
    } else {
      message = fileImage.value!.path;
      type = 'image';
    }
    Chatmodel chatmodel =
        Chatmodel(id: uid, message: message, time: time, type: type);
    await chatService.sendMessage(docId.value, chatmodel);

    sendMsgLoader.value = false;
  }

//.............. get device token
  Future<void> sendNotificationMethod(
      String notificationType, String title, String msg) async {
    for (var element in memberId) {
      if (element != userController.userModel.value.uid) {
      
        String deviceToken = await chatService.getDeviceToken(element);
        print(deviceToken);
            sendNotification(
        token: deviceToken,
        notificationType: notificationType,
        title: title,
        msg: msg);
      }
    }

  }

  @override
  void onClose() {
    super.onClose();
    chatfieldController.dispose();
    chatFieldFocusNode.dispose();
  }
}
