import 'package:check_in/model/Message%20and%20Group%20Message%20Model/group_member_model.dart';
import 'package:get/get.dart';

import '../../Services/message_service.dart';

class GroupmemberController extends GetxController {
  final MessageService messageService;
  String docid = '';
  GroupmemberController(this.messageService);
  var searchQuery = ''.obs;

//............ get groupmember
  Stream<List<GroupMemberModel>> getGroupMember() {
    return messageService.getGroupMembers(docid);
  }

//............ make group admin
  Future<void> makeGroupAdmin(String memberId) async {
    messageService.makeGroupAdmin(docid, memberId,true);
  }

//............ remove group admin
  Future<void> removeGroupAdmin(String memberId) async {
    messageService.makeGroupAdmin(docid, memberId,false);
  }
}
