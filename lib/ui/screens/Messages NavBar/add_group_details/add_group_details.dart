import 'dart:io';

import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/controllers/Messages/group_detail_controller.dart';
import 'package:check_in/controllers/Messages/new_message_controller.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/ui/screens/Messages%20NavBar/Chat/chat_screen.dart';
import 'package:check_in/ui/screens/Messages%20NavBar/Chat/chat_screen.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

import '../../../../utils/common.dart';

// ignore: must_be_immutable
class AddGroupDetails extends GetView<GroupDetailController> {
  String? image;
  List? memberId;
  String? senderName;
  String? docId;
  List<Map<String, dynamic>>? dataArray;
  AddGroupDetails({
    super.key,
    this.image,
    this.memberId,
    this.senderName,
    this.docId,
    this.dataArray,
  });
  // var groupmemberController = Get.find<GroupmemberController>();
  var userController = Get.find<UserController>();
  var chatcontroller = Get.find<ChatController>();
  var newMessageController = Get.find<NewMessageController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Obx(() => FloatingActionButton(
            backgroundColor: appGreenColor,
            child: controller.loadNewGroup.value
                ? const CircularProgressIndicator(
                    color: whiteColor,
                  )
                : const Icon(
                    Icons.arrow_forward,
                    color: whiteColor,
                  ),
            onPressed: () async {
              controller.loadNewGroup.value = true;
              if (controller.nameController.text.isEmpty) {
                Fluttertoast.showToast(msg: 'Group title is empty');
                controller.loadNewGroup.value = false;
              } else if (controller.aboutController.text.isEmpty) {
                Fluttertoast.showToast(msg: 'Fill in group info');
                controller.loadNewGroup.value = false;
              } else {
                final chatGood = await chatcontroller.chatService
                    .startNewGroupChat(
                        memberId!,
                        dataArray!,
                        controller.nameController.text,
                        controller.aboutController.text,
                        controller.fileImage.value?.path ?? '')
                    .then((value) {
                  chatcontroller.docId.value = value[MessageField.ID] ?? '';
                  chatcontroller.name.value = controller.nameController.text;
                  chatcontroller.image.value =
                      value[MessageField.GROUP_IMG] ?? '';
                  controller.nameController.clear();
                  controller.aboutController.clear();
                  controller.fileImage.value = null;
                  //
                  newMessageController.mydata.clear();
                  newMessageController.searchQuery.value = '';
                  controller.loadNewGroup.value = false;
                  chatcontroller.sendNotificationMethod('',
                      '${userController.userModel.value.userName!} created a new group with you');
                  pushNewScreen(context, screen: ChatScreen()).then((_) {
                    Get.back();
                    Get.back();
                  });
                });
                print('chatgood$chatGood');
                if (chatGood != null) {
                } else {
                  null;
                }
              }
            })),
        appBar: CustomAppbar(
          title: poppinsText(TempLanguage.groupDetail, 15, bold, appBlackColor),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    verticalGap(40),
                    TextFormField(
                      focusNode: controller.namefocusNode,
                      onFieldSubmitted: (data) {
                        chatcontroller.name.value =
                            controller.nameController.text;
                        chatcontroller.senderName.value =
                            controller.nameController.text;
                      },
                      onTapOutside: (val) {
                        controller.namefocusNode.unfocus();
                      },
                      controller: controller.nameController,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: greyColor.withOpacity(0.6))),
                      ),
                    ),
                    verticalGap(26),
                    SizedBox(
                      width: 130,
                      height: 135,
                      child: Stack(
                        children: [
                          // networkImage(controller.groupDetailModel!.groupImg!),

                          Obx(
                            () => CircleAvatar(
                              backgroundColor: appGreenColor.withOpacity(0.6),
                              backgroundImage: controller.fileImage.value !=
                                      null
                                  ? FileImage(
                                      File(controller.fileImage.value!.path))
                                  : AssetImage(AppImage.user) as ImageProvider,
                              radius: 65,
                            ),
                          ),

                          Positioned(
                            right: 10,
                            bottom: 1,
                            child: GestureDetector(
                              onTap: () {
                                pickImageSheet(
                                    context, controller, chatcontroller);
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: appGreenColor,
                                    shape: BoxShape.circle),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: appWhiteColor,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    verticalGap(60),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: poppinsText(
                          TempLanguage.aboutGroup, 14, semiBold, appBlackColor),
                    ),
                    verticalGap(5),
                    TextFormField(
                      onTapOutside: (val) {
                        controller.aboutfocusNode.unfocus();
                      },
                      focusNode: controller.aboutfocusNode,
                      enabled: true,
                      controller: controller.aboutController,
                      style: TextStyle(fontSize: 14, color: greyColor),
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: greyColor.withOpacity(0.6))),
                      ),
                    )
                  ],
                ),
              )),
            ],
          ),
        ));
  }

  Future<void> pickImageSheet(BuildContext context,
      GroupDetailController controller, ChatController chatController) {
    final picker = ImagePicker();

    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10), topLeft: Radius.circular(10))),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //.................Camera
                GestureDetector(
                  onTap: () async {
                    XFile? pickedFile =
                        await picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      File _imageFile = await compressImage(pickedFile,
                          quality: 20, height: 200, width: 200);
                      pickedFile = XFile(_imageFile.path);

                      controller.fileImage.value = pickedFile;
                      Navigator.pop(context);
                      // String imagePath = controller.fileImage.value == null ? '' : controller.fileImage.value!.path;
                      //  String? image =  await chatController.chatService.uploadImageToFirebase(userController.userModel.value.uid!, imagePath);
                      //  print("Camera $image");
                      // controller.groupDetailModel!.groupImg = image;
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 2, color: black)),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 40,
                    ),
                  ),
                ),
                horizontalGap(10.w),

                //.................Gallery
                GestureDetector(
                  onTap: () async {
                    XFile? pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      File _imageFile = await compressImage(pickedFile,
                          quality: 20, height: 200, width: 200);
                      pickedFile = XFile(_imageFile.path);

                      controller.fileImage.value = pickedFile;
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 2, color: black)),
                    child: const Icon(
                      Icons.image,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
