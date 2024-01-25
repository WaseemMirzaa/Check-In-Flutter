import 'dart:async';

import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

import '../../Services/message_service.dart';

class NewMessageController extends GetxController {
  final MessageService chatService;
  late TextEditingController searchController;
  NewMessageController(this.chatService);
  late final RxList<UserModel> userDataList = RxList<UserModel>();
  RxString searchQuery = ''.obs;
  DocumentSnapshot? _lastDocument;

  final DOCUMENT_PER_PAGE = 20;
  final DELAY_IN_MILLISECONDS = 300;

  RxMap<String, dynamic> mydata = <String, dynamic>{}.obs;

  // StreamController to manage the text input stream
  final _searchQuerySubject = BehaviorSubject<String>();
  // StreamSubscription to clean up the subscription when the controller is disposed
  late StreamSubscription<List<DocumentSnapshot>> _userSubscription;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();

    // Listen to changes in the search query stream and call getUser with a debounce
    _userSubscription = _searchQuerySubject
        .debounceTime(Duration(milliseconds: DELAY_IN_MILLISECONDS))
        .distinct()
        .switchMap((query) => Stream.fromFuture(chatService.getUsersDocsWithPagination(query, DOCUMENT_PER_PAGE, null)))
        .listen((docs) {

          List<UserModel> users = docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

          if (docs.isNotEmpty) {
             userDataList.clear();
             _lastDocument = docs.last;
             userDataList.addAll(users);
          }
    });
  }

//............ get user list for start new chat
  // Future<void> getUser() async {
  //   // chatService.getUsers(searchQuery.value).forEach((element) {
  //   //   print(element);
  //   // });
  //   await chatService.getUsers(searchQuery.value).then((value) {
  //     userDataList.assignAll(value);
  //   });
  // }

//............ start new chat

  Future<void> fetchMore() async {
    List<DocumentSnapshot> docs = await chatService.getUsersDocsWithPagination(searchController.text, DOCUMENT_PER_PAGE, _lastDocument);

    List<UserModel> users = docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    if (docs.isNotEmpty) {
      _lastDocument = docs.last;
      userDataList.addAll(users);
    }
  }

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

  // Method to update the search query
  void updateSearchQuery(String value) {
    _searchQuerySubject.add(value);
  }

  @override
  void dispose() {
    searchController.dispose();
    _userSubscription.cancel();
    _searchQuerySubject.close();
    super.dispose();
  }
}
