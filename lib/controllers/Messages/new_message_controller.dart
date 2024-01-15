import 'package:check_in/model/user_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Services/message_service.dart';

class NewMessageController extends GetxController {
  final MessageService chatService;
  late TextEditingController searchController;
  NewMessageController(this.chatService);
  late final RxList<UserModel> userDataList = RxList<UserModel>();
  // Messagemodel
  var searchQuery = ''.obs;
  RxMap<String, dynamic> mydata = <String, dynamic>{}.obs;
  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
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
}
