import 'dart:io';

import 'package:check_in/controllers/Messages/group_detail_controller.dart';
import 'package:check_in/controllers/Messages/group_members_controller.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Group%20Detail/Widgets/textfields.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Group%20Members/group_members.dart';
import 'package:check_in/ui/widgets/common_button.dart';
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

import 'Widgets/bottomsheet.dart';

// ignore: must_be_immutable
class GroupdetailScreen extends GetView<UsergroupDetailController> {
  String? docId;
  GroupdetailScreen({super.key, this.docId});
  var groupmemberController = Get.find<GroupmemberController>();
  @override
  Widget build(BuildContext context) {
    controller.getGroupDetail(docId!);
    return Scaffold(
        appBar: CustomAppbar(
          title: poppinsText('Group Details', 20, bold, blackColor),
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
                            NameTextfield(
                              isAdmin: controller.groupDetailModel!.isAdmin,
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
                                    backgroundImage:
                                        controller.fileImage.value != null
                                            ? FileImage(File(controller
                                                .fileImage
                                                .value!
                                                .path)) as ImageProvider
                                            : NetworkImage(controller
                                                        .groupDetailModel!
                                                        .groupImg! !=
                                                    ''
                                                ? controller
                                                    .groupDetailModel!.groupImg!
                                                : AppImage.userImagePath),
                                    radius: 65,
                                  ),
                                  controller.groupDetailModel!.isAdmin!
                                      ? Positioned(
                                          right: 10,
                                          bottom: 1,
                                          child: GestureDetector(
                                            onTap: () {
                                              showbottomSheet(
                                                  context, controller);
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
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  poppinsText(
                                      'About Group', 14, semiBold, blackColor),
                                  controller.groupDetailModel!.isAdmin!
                                      ? GestureDetector(
                                          onTap: () {
                                            controller.aboutfocusNode
                                                .requestFocus();
                                          },
                                          child: SvgPicture.asset(
                                            AppImage.penicon,
                                            height: 17,
                                            width: 17,
                                          ),
                                        )
                                      : const SizedBox()
                                ],
                              ),
                            ),
                            verticalGap(5),
                            const Divider(thickness: 2),
                            AboutTextfield(
                              isAdmin: controller.groupDetailModel!.isAdmin,
                            )
                          ],
                        ),
                      )),
                      controller.groupDetailModel!.isAdmin!
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child:
                                  Obx(() => controller.uploadDataLoading.value
                                      ? loaderView()
                                      : fullWidthButton('Save', () {
                                          controller.updateGroupDetail(docId!);
                                        })),
                            )
                          : const SizedBox()
                    ],
                  ),
                ),
        ));
  }
}
