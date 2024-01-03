import 'package:get/get.dart';

import '../Services/message_service.dart';

class GroupmemberController extends GetxController {
  final MessageService messageService;
  String docid = '';
  GroupmemberController(this.messageService);

  var searchQuery = ''.obs;

//............ get groupmember
  Stream<List<dynamic>> getGroupMember() {
    return messageService.getGroupMembers(docid);
  }
}
