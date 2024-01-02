import 'package:check_in/controllers/chat_controller.dart';
import 'package:check_in/controllers/messages_controller.dart';
import 'package:get/get.dart';

import 'Services/message_service.dart';
import 'controllers/group_members_controller.dart';

class MyBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatController(MessageService()), fenix: true);
    Get.lazyPut(() => MessageController(MessageService()), fenix: true);
    Get.lazyPut(() => GroupmemberController(MessageService()), fenix: true);
  }
}
