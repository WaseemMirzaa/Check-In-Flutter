import 'package:check_in/auth_service.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../Services/message_service.dart';

class MessageController extends GetxController {
  final MessageService chatService;
  // final RxString userId = GlobalVariable.userid.obs;
  MessageController(this.chatService);

  var searchQuery = ''.obs;
//............ get messages
  Stream<List<Messagemodel>> getChatMessage(String userId) {
    return chatService.getChatMessage(userId);
  }

  Future<bool> updateCollection(String collectionName, String docID, Map<String, dynamic> list) async {
    final update = await chatService.updateCollection(collectionName, docID, list);
    return update;
  }

  Future<String?> getLastMessage(String docId) async {
    Timestamp? timeStamp = await chatService.getDeleteTimeStamp(docId, userController.userModel.value.uid!);
    return await chatService.getLastMessage(docId, userController.userModel.value.uid!, timeStamp);
  }

  // Future<bool> leftGroup(String docID) async {
  //   final left = await chatService.removeGroupUser(docID,uid);
  //   return left;
  // }

  Future deleteMessage(String docID, String userID) async {
    await chatService.deleteMessage(docID, userID);
  }

  Future<bool> blockContact(String docID, String userID) async {
    return await chatService.blockContact(docID, userID);
  }
}
