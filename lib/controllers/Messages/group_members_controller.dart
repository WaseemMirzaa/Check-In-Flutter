import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/group_member_model.dart';
import 'package:get/get.dart';

import '../../Services/message_service.dart';

class GroupmemberController extends GetxController {
  final MessageService messageService;
  String docid = '';
  GroupmemberController(this.messageService);
  var searchQuery = ''.obs;
  RxList memberIds = [].obs;
  // RxBool iAmAdmin = false.obs;

//............ get groupmember
  Stream<List<GroupMemberModel>> getGroupMember(String userId) {
    var data = messageService.getGroupMembers(docid, userId);
    data.listen((groupMembers) {
      memberIds.clear(); // Clear existing member IDs
      for (var member in groupMembers) {
        memberIds.add(member.memberId); // Add member IDs to the list
      }
    });
    return data;
  }

//............ make group admin
  Future<void> makeGroupAdmin(String memberId) async {
    messageService.makeGroupAdmin(docid, memberId, true);
  }

//............ remove group admin
  Future<void> removeGroupAdmin(String memberId) async {
    messageService.makeGroupAdmin(docid, memberId, false);
  }

//............ remove group members
  Future<void> removeGroupMember(String memberId) async {
    messageService.removeMember(memberId, docid);
  }

   Future<void> leftGroup(String memberId, String docID) async {
    messageService.removeMember(memberId, docID);
  }
}
