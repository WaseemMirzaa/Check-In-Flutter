import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Services/message_service.dart';

class NewMessageController extends GetxController {
  final MessageService chatService;
  late TextEditingController searchController;
  NewMessageController(this.chatService);
  late final RxList<UserModel> userDataList = RxList<UserModel>();
  var searchQuery;

  RxMap<String, dynamic> mydata = <String, dynamic>{}.obs;
  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    searchQuery = ''.obs;
  }

//............ get user list for start new chat
  Stream<List<UserModel>> getUser() {
    // chatService.getUsers(searchQuery.value).forEach((element) {
    //   print(element);
    // });
    chatService.getUsers(searchQuery.value).listen((event) {
      userDataList.assignAll(event);
    });
    return chatService.getUsers(searchQuery.value);
  }

//............ start new chat
  Future<String> startNewChat(String myUid, String uNAme) async {
    UserModel model = mydata.values.first;

    return chatService
        .startNewChat([myUid, mydata.keys.first], uNAme, model.userName!);
  }

  Future<String> startNewGroupChat(String myUid, String uNAme) async {
    List<Map<String, dynamic>> dataArray = [
      {
        MessageField.MEMBER_UID: myUid,
        MessageField.MEMBER_NAME: uNAme,
        MessageField.ABOUT_USER: '',
        MessageField.MEMBER_IMG: '',
        MessageField.IS_ADMIN: true,
        MessageField.MEMBER_UNREAD_COUNT: 0
      }
    ];
    List memberIds = [myUid];
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

    return chatService.startNewGroupChat(memberIds, dataArray);
  }
}
