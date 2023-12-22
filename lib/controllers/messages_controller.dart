import 'package:check_in/model/message_model.dart';
import 'package:check_in/utils/Constants/global_variable.dart';
import 'package:get/get.dart';

import '../Services/message_service.dart';

class MessageController extends GetxController {
  final MessageService chatService;
  final RxString userId = GlobalVariable.userid.obs;

  MessageController(this.chatService);

  var searchQuery = ''.obs;
//............ get messages
  Stream<List<Messagemodel>> getChatMessage() {
    return chatService.getChatMessage(userId.value);
  }
}
