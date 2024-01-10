import 'package:check_in/model/Message%20and%20Group%20Message%20Model/group_detail_model.dart';
import 'package:check_in/utils/Constants/global_variable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../Services/message_service.dart';
import '../../utils/Constants/app_toast.dart';

class UsergroupDetailController extends GetxController {
  final MessageService messageService;
  UsergroupDetailController(this.messageService);

  GroupDetailModel? groupDetailModel = GroupDetailModel();
  Rx<XFile?> fileImage = Rx<XFile?>(null);

  /// TextEditingController
  late TextEditingController nameController;
  late TextEditingController aboutController;

  /// focusnode
  FocusNode namefocusNode = FocusNode();
  FocusNode aboutfocusNode = FocusNode();

  /// loading
  RxBool loading = false.obs;
  RxBool uploadDataLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    aboutController = TextEditingController();
  }

//............ get detail
  Future<void> getGroupDetail(String docId) async {
    loading.value = true;
    GroupDetailModel res =
        await messageService.getGroupDetails(docId, GlobalVariable.userid);

    /// store response in model
    groupDetailModel = res;

    /// store group name and about in textEditingController
    nameController.text = res.groupName!;
    aboutController.text = res.groupDesc!;

    loading.value = false;
  }

//............ update group detail
  Future<void> updateGroupDetail(String docId) async {
    uploadDataLoading.value = true;
    String imagePath = fileImage.value == null ? '' : fileImage.value!.path;
    final result = await messageService.updateGroupdetail(
        docId, nameController.text, aboutController.text, imagePath);

    if (result) {
      uploadDataLoading.value = false;
      successMessage('Data update successfully');
    } else {
      uploadDataLoading.value = false;
      errorMessage('Error updating data');
    }
  }

  @override
  void onClose() {
    super.onClose();
    nameController.dispose();
    aboutController.dispose();
  }
}
