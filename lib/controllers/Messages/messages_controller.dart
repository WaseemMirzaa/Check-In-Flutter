import 'package:check_in/model/Message%20and%20Group%20Message%20Model/message_model.dart';
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
}
