import 'package:check_in/utils/Constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/message_service.dart';
import '../utils/Constants/app_toast.dart';

class UsergroupDetailController extends GetxController {
  final MessageService messageService;
  UsergroupDetailController(this.messageService);
  var nameController = TextEditingController();
  var aboutController = TextEditingController();
  FocusNode namefocusNode = FocusNode();
  FocusNode aboutfocusNode = FocusNode();
  RxString networkImage = ''.obs;
  Rx<XFile?> fileImage = Rx<XFile?>(null);
  RxBool loading = false.obs;
  RxBool uploadDataLoading = false.obs;

//............ get detail
  void getGroupDetail(String docId) async {
    loading.value = true;
    DocumentSnapshot res = await messageService.getGroupDetails(docId);
    Map<String, dynamic> data = res.data() as Map<String, dynamic>;
    nameController.text = data[MessageField.GROUP_NAME];
    aboutController.text = data[MessageField.ABOUT_GROUP];
    networkImage.value = data[MessageField.GROUP_IMG];
    loading.value = false;
  }

//............ update group detail
  Future<void> updateGroupDetail(String docId) async {
    uploadDataLoading.value = true;
    // String imagePath = fileImage.value == null ? '' : fileImage.value!.path;
    final result = await messageService.updateGroupdetail(docId,
        nameController.text, aboutController.text, fileImage.value!.path);

    if (result) {
      uploadDataLoading.value = false;
      successMessage('Data update successfully');
    } else {
      uploadDataLoading.value = false;
      errorMessage('Error updating data');
    }
  }
}
