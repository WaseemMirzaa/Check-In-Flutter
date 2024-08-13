import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/Services/user_services.dart';
import 'package:check_in/controllers/Messages/add_group_member_controller.dart';
import 'package:check_in/controllers/Messages/messages_controller.dart';
import 'package:check_in/controllers/Messages/new_message_controller.dart';
import 'package:check_in/controllers/News%20Feed/create_post_controller.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/controller.dart';
import 'package:get/get.dart';
import 'Services/message_service.dart';
import 'controllers/Messages/chat_controller.dart';
import 'controllers/Messages/group_members_controller.dart';
import 'controllers/Messages/group_detail_controller.dart';

class MyBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatController(MessageService()), fenix: true);
    Get.lazyPut(() => MessageController(MessageService()), fenix: true);
    Get.lazyPut(() => GroupmemberController(MessageService()), fenix: true);
    Get.lazyPut(() => GroupDetailController(MessageService()), fenix: true);
    Get.lazyPut(() => NewMessageController(MessageService()), fenix: true);
    Get.lazyPut(() => NewsFeedController(NewsFeedService()), fenix: true);
    Get.lazyPut(() => AddGroupMembersController(MessageService()), fenix: true);
    Get.lazyPut(() => UserController(UserServices()), fenix: true);
  }
}
