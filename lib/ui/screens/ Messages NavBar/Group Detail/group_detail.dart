import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/controllers/Messages/group_detail_controller.dart';
import 'package:check_in/controllers/Messages/group_members_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/chat_screen.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Group%20Detail/Component/textfields.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Group%20Members/group_members.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/loader.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

import '../../../../controllers/user_controller.dart';
import '../../../../utils/Constants/global_variable.dart';
import 'Component/bottomsheet.dart';

// ignore: must_be_immutable
class GroupdetailScreen extends GetView<GroupDetailController> {
  bool? isGroup;
  String? image;
  List? memberId;
  String? senderName;
  String? docId;
  bool? showBtn;
  GroupdetailScreen(
      {super.key,
      this.isGroup,
      this.image,
      this.memberId,
      this.senderName,
      this.docId,
      this.showBtn = false});
  var groupmemberController = Get.find<GroupmemberController>();
  var userController = Get.find<UserController>();
  var chatcontroller = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    //   for making null docid
    GlobalVariable.docId = '';

    controller.getGroupDetail(docId!, userController.userModel.value.uid!);
    return Scaffold(
        floatingActionButton: showBtn!
            ? FloatingActionButton(
                backgroundColor: greenColor,
                child: const Icon(Icons.arrow_forward),
                onPressed: () {
                  controller.fileImage.value = null;
                  pushNewScreen(context, screen: ChatScreen())
                      .then((value) => Get.back());
                })
            : const SizedBox(),
        appBar: CustomAppbar(
          title: poppinsText(TempLanguage.groupDetail, 15, bold, blackColor),
          actions: [
            GestureDetector(
                onTap: () {
                  groupmemberController.docid = docId!;
                  pushNewScreen(context, screen: const GroupMember());
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: SvgPicture.asset(AppImage.peopleicon),
                ))
          ],
        ),
        body: Obx(
          () => controller.loading.value
              ? loaderView()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          children: [
                            verticalGap(40),
                            Row(
                              children: [
                                Expanded(
                                  child: NameTextfield(
                                    readOnly: controller.nameTapped.value,
                                    isAdmin:
                                        controller.groupDetailModel!.isAdmin,
                                    iconOnTap: () {
                                      //  controller.namefocusNode.requestFocus();
                                      controller.updateGroupName(docId!);
                                      chatcontroller.name.value =
                                          controller.nameController.text;

                                      controller.nameTapped.value =
                                          !controller.nameTapped.value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            verticalGap(26),
                            SizedBox(
                              width: 130,
                              height: 135,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        greenColor.withOpacity(0.6),
                                    backgroundImage: controller
                                                .fileImage.value !=
                                            null
                                        ? FileImage(File(
                                            controller.fileImage.value!.path))
                                        : controller.groupDetailModel!
                                                    .groupImg! ==
                                                ''
                                            ? AssetImage(AppImage.user)
                                                as ImageProvider
                                            : CachedNetworkImageProvider(
                                                controller.groupDetailModel!
                                                    .groupImg!),
                                    radius: 65,
                                  ),
                                  controller.groupDetailModel!.isAdmin!
                                      ? Positioned(
                                          right: 10,
                                          bottom: 1,
                                          child: GestureDetector(
                                            onTap: () {
                                              showbottomSheet(
                                                  context,
                                                  controller,
                                                  docId!,
                                                  chatcontroller);
                                            },
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                  color: greenColor,
                                                  shape: BoxShape.circle),
                                              child: Icon(
                                                Icons.camera_alt,
                                                color: whiteColor,
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox()
                                ],
                              ),
                            ),
                            verticalGap(60),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                poppinsText(TempLanguage.aboutGroup, 14,
                                    semiBold, blackColor),
                                controller.groupDetailModel!.isAdmin!
                                    ? GestureDetector(
                                        onTap: () {
                                          // controller.aboutfocusNode
                                          //     .requestFocus();
                                          controller.updateGroupAbout(docId!);
                                          controller.aboutTapped.value =
                                              !controller.aboutTapped.value;
                                        },
                                        child: Obx(
                                          () => controller.aboutTapped.value
                                              ? poppinsText(TempLanguage.save,
                                                  14, semiBold, greenColor)
                                              : SizedBox(
                                                  height: 2.4.h,
                                                  child: Image.asset(
                                                    AppAssets.EDIT_ICON,
                                                  ),
                                                ),
                                        ))
                                    : const SizedBox()
                              ],
                            ),
                            verticalGap(5),
                            AboutTextfield(
                              readOnly: controller.aboutTapped.value,
                              isAdmin: controller.groupDetailModel!.isAdmin,
                            ),
                            Divider(
                              // thickness: 1,
                              color: blackColor,
                            ),
                          ],
                        ),
                      )),
                      // controller.groupDetailModel!.isAdmin!
                      //     ? Padding(
                      //         padding:
                      //             const EdgeInsets.symmetric(vertical: 10.0),
                      //         child:
                      //             Obx(() => controller.uploadDataLoading.value
                      //                 ? loaderView()
                      //                 : fullWidthButton('Save', () {
                      //                     controller.updateGroupDetail(docId!);
                      //                   })),
                      //       )
                      //     : const SizedBox()
                    ],
                  ),
                ),
        ));
  }
}
