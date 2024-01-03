import 'package:check_in/utils/Constants/app_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Services/message_service.dart';

class UsergroupDetailController extends GetxController {
  final MessageService messageService;
  UsergroupDetailController(this.messageService);
  var nameController = TextEditingController();
  var aboutController = TextEditingController();
  FocusNode namefocusNode = FocusNode();
  FocusNode aboutfocusNode = FocusNode();

//............ get detail
  void getGroupDetail(String docId) async {
    DocumentSnapshot res = await messageService.getGroupDetails(docId);
    Map<String, dynamic> data = res.data() as Map<String, dynamic>;
    nameController.text = data['groupName'];
    aboutController.text = data['aboutGroup'];
  }

//............ update group detail
  Future<void> updateGroupDetail(String docId) async {
    bool result = await messageService.updateGroupdetail(
        docId, nameController.text, aboutController.text);

    if (result) {
      successMessage('Data update successfully');
    } else {
      errorMessage('Error updating data');
    }
  }
}
