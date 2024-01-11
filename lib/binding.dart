import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/controllers/Messages/messages_controller.dart';
import 'package:check_in/controllers/News%20Feed/create_post_controller.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:get/get.dart';

import 'Services/message_service.dart';
import 'controllers/Messages/group_members_controller.dart';
import 'controllers/Messages/group_detail_controller.dart';

class MyBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatController(MessageService()), fenix: true);
    Get.lazyPut(() => MessageController(MessageService()), fenix: true);
    Get.lazyPut(() => GroupmemberController(MessageService()), fenix: true);
    Get.lazyPut(() => UsergroupDetailController(MessageService()), fenix: true);
    Get.lazyPut(() => NewsFeedController(), fenix: true);
    Get.lazyPut(() => CreatePostController(), fenix: true);
  }
}
