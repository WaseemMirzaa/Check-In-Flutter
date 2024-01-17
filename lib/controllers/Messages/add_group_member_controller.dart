import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Services/message_service.dart';

class AddGroupMembersController extends GetxController {
  final MessageService chatService;
  late TextEditingController searchController;
  AddGroupMembersController(this.chatService);
  late final RxList<UserModel> userDataList = RxList<UserModel>();

  RxString searchQuery = ''.obs;

  RxMap<String, dynamic> mydata = <String, dynamic>{}.obs;
  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
  }

//............ get user list for add new member
  Future<void> getUser() async {
    await chatService.getUsers(searchQuery.value).then((value) {
      userDataList.assignAll(value);
    });
  }

//............ add new member
  Future<bool> addMember(String docId) async {
    List<Map<String, dynamic>> dataArray = [];
    List memberIds = [];
    mydata.forEach((id, data) {
      UserModel value = data;

      String uid = value.uid!;
      String name = value.userName!;
      String about = value.aboutMe!;

      Map<String, dynamic> userData = {
        MessageField.MEMBER_UID: uid,
        MessageField.MEMBER_NAME: name,
        MessageField.ABOUT_USER: about,
        MessageField.MEMBER_IMG: '',
        MessageField.IS_ADMIN: false,
        MessageField.MEMBER_UNREAD_COUNT: 0
      };
      dataArray.add(userData);
      memberIds.add(value.uid);
    });

    return chatService.addNewMember(memberIds, dataArray, docId);
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }
}
