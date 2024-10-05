import 'package:check_in/Services/push_notification_service.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/chat_model.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/message_model.dart';
import 'package:check_in/utils/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';

import '../../Services/message_service.dart';

class ChatController extends GetxController {
  final MessageService chatService;
  RxString docId = ''.obs;
  RxString name = ''.obs;
  RxList memberId = [].obs;
  RxList members = [].obs;
  RxString otherUserId = ''.obs;
  RxString image = ''.obs;
  RxString senderName = ''.obs;
  RxString sendMsgField = ''.obs;
  Rx<XFile?> fileImage = Rx<XFile?>(null);
  bool isgroup = false;
  RxBool issticker = true.obs;
  late TextEditingController chatfieldController;

  late FocusNode chatFieldFocusNode;

  RxBool sendMsgLoader = false.obs;
  RxBool sendMessageCall = false.obs;

  ChatController(this.chatService);
  var userController = Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    chatfieldController = TextEditingController();
    chatFieldFocusNode = FocusNode();
  }


  //............. get message with docID
  Future<void> getSingleMessage() async {
    var res = await chatService.getSingleMessage(docId.value, userController.userModel.value.uid!);
    Messagemodel model = res;
    if (isgroup) {
      members.value = model.members ?? [];
    } else {
      userController.userModel.value.uid == model.senderId
          ? otherUserId.value = model.recieverId ?? ''
          : otherUserId.value = model.senderId ?? '';
    }
    image.value = model.image ?? '';
  }

  Stream<List<Chatmodel>> getConversation() async* {
    Timestamp? timeStamp = await chatService.getDeleteTimeStamp(docId.value, userController.userModel.value.uid!);
    yield* chatService.getConversation(docId.value, userController.userModel.value.uid!, members, timeStamp);
  }

  //............. get message request status
  Stream<Messagemodel> getRequestStatus() {
    return chatService.getMessageRequest(docId.value);
  }

  //............. update request status
  void updateRequestStatus(String status, String msg, int unread) {
    chatService.updateRequestStatus(
        docId.value, status, msg, unread, userController.userModel.value.uid!);
  }

  String thumbnailPath = '';
  String originalPath = '';
  //.............. send chat
  Future<DocumentSnapshot?> sendMessage() async {
    sendMsgLoader.value = true;

    //String time = DateTime.now().toString();
    String uid = userController.userModel.value.uid!;
    String message = '';
    String type = '';

    if (chatfieldController.text.isNotEmpty) {
      message = chatfieldController.text;
      type = 'message';
    } else {
      await compressImage();
      message = originalPath;
      type = 'image';
    }

    Chatmodel? chatmodel = Chatmodel(
        id: uid,
        message: message,
        time: Timestamp.now(),
        type: type,
        thumbnail: thumbnailPath,
        seenTimeStamp: null);
    // try {
    DocumentSnapshot? newMessageDoc =
        await chatService.sendMessage(docId.value, chatmodel, members);
    sendMsgLoader.value = false;

    /// Purpose of this code is to make deleted user undeleted
    /// (It means they can again send and receive messages)
    ///
    /// [updateDelete] method was called again and again on every message send
    /// that was adding unnecessary overload
    /// That's why when a user first time come to chat screen and send a first message
    /// this method will call only once and for other messages it will no call.

    if (newMessageDoc != null && !sendMessageCall.value) {
      sendMessageCall.value = true;
      await chatService.updateDelete(docId.value, uid);
    }
    //await chatService.readReceipts(chatcontroller.docId.value, userController.userModel.value.uid.toString());

    return newMessageDoc;
    // } catch (e) {
    //   print('--------- Err0rrrrrrrr');
    // }

    // return null;
  }

//........Delete Chat
  Future<bool> deleteMessage(String messageDoc, String docID) async {
    return await chatService.deleteChatAndUpdateModel(messageDoc, docID);
  }


//........... Compress images
  Future<void> compressImage() async {
    // final lastIndex = fileImage.value!.path.lastIndexOf(RegExp(r'.'));
    // final splitted = fileImage.value!.path.substring(0, (lastIndex));
    thumbnailPath = "${fileImage.value!.path}_thumbnail";
    originalPath = "${fileImage.value!.path}_original";
    FlutterImageCompress.validator.ignoreCheckExtName = true;
    print('thumbnailpath =$thumbnailPath');
//............. for thumbnail
    await FlutterImageCompress.compressAndGetFile(
      fileImage.value!.path,
      thumbnailPath,
      quality: 20,
      minHeight: 300,
      minWidth: 300,
    );
//............. for original image
    await FlutterImageCompress.compressAndGetFile(
      fileImage.value!.path,
      originalPath,
      quality: 60,
      minHeight: 600,
      minWidth: 600,
    );
  }

//.............. get device token
  Future<void> sendNotificationMethod(String notificationType, String msg,
      {String? image}) async {
    // print(senderName);
    // print(memberId);
    for (var element in memberId) {
      if (element != userController.userModel.value.uid) {
        List<dynamic> deviceToken = await chatService.getDeviceToken(element);
        // print(deviceToken.first);
        // print(deviceToken.first.runtimeType);
        sendNotification(
            token: deviceToken,
            notificationType: notificationType,
            title: senderName.value,
            msg: msg,
            docId: docId.value,
            isGroup: isgroup,
            image: image ?? userController.userModel.value.photoUrl ?? '',
            name: senderName.value,
            memberIds: memberId,
            uid: element);
      }
    }
  }


  Future<bool> reportMessage(String docId, String messageId, String reportedBy, String reason) async {
    return chatService.reportMessage(docId, messageId, reportedBy, reason);
  }

  Future<bool> hideMessage(String docId, String messageId, String userId) async {
    return chatService.hideMessage(docId, messageId, userId);
  }

  @override
  void onClose() {
    chatfieldController.dispose();
    chatFieldFocusNode.dispose();
    super.onClose();
  }
}
