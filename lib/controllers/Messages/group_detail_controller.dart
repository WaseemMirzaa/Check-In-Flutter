import 'package:check_in/model/Message%20and%20Group%20Message%20Model/group_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../Services/message_service.dart';

class GroupDetailController extends GetxController {
  final MessageService messageService;
  GroupDetailController(this.messageService);

  GroupDetailModel? groupDetailModel = GroupDetailModel();
  Rx<XFile?> fileImage = Rx<XFile?>(null);
  late RxBool nameTapped;
  late RxBool aboutTapped;

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
    nameTapped = false.obs;
    aboutTapped = false.obs;
    nameController = TextEditingController();
    aboutController = TextEditingController();
  }

//............ get detail
  Future<void> getGroupDetail(String docId, String userId) async {
    loading.value = true;
    GroupDetailModel res = await messageService.getGroupDetails(docId, userId);

    /// store response in model
    groupDetailModel = res;

    /// store group name and about in textEditingController
    nameController.text = res.groupName!;
    aboutController.text = res.groupDesc!;

    loading.value = false;
  }

//............ update group about
  Future<void> updateGroupAbout(String docId) async {
    await messageService.updateGroupAbout(docId, aboutController.text);
  }

//............ update group name
  Future<void> updateGroupName(String docId) async {
    await messageService.updateGroupName(docId, nameController.text);
  }

//............ update group image
  Future<void> updateGroupImage(String docId) async {
    uploadDataLoading.value = true;

    String imagePath = fileImage.value == null ? '' : fileImage.value!.path;

    await messageService.updateGroupImage(docId, imagePath);
    uploadDataLoading.value = false;
  }

//............ update group detail
  // Future<void> updateGroupDetail(String docId) async {
  //   uploadDataLoading.value = true;
  //   String imagePath = fileImage.value == null ? '' : fileImage.value!.path;
  //   final result = await messageService.updateGroupdetail(
  //       docId, nameController.text, aboutController.text, imagePath);
  //   if (result) {
  //     uploadDataLoading.value = false;
  //     successMessage('Data update successfully');
  //   } else {
  //     uploadDataLoading.value = false;
  //     errorMessage('Error updating data');
  //   }
  // }

  @override
  void onClose() {
    super.onClose();
    nameController.dispose();
    aboutController.dispose();
  }
}
