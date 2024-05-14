import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/controllers/Messages/group_detail_controller.dart';
import 'package:check_in/controllers/Messages/group_members_controller.dart';
import 'package:check_in/controllers/Messages/messages_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Group%20Members/group_members.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/edit_group_detail/Component/textfields.dart';
import 'package:check_in/ui/screens/persistent_nav_bar.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/loader.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

import '../../../../controllers/user_controller.dart';
import '../../../../utils/Constants/global_variable.dart';
import 'Component/bottomsheet.dart';

// ignore: must_be_immutable
class EditGroupDetails extends StatefulWidget {
  bool? isGroup;
  String? image;
  // List? members;
  String? senderName;
  String? docId;
  bool? showBtn;
  List<Map<String, dynamic>>? dataArray;
  EditGroupDetails(
      {super.key,
      this.isGroup,
      this.image,
      // this.members,
      this.senderName,
      this.docId,
      this.dataArray,
      this.showBtn = false});

  @override
  State<EditGroupDetails> createState() => _EditGroupDetailsState();
}

class _EditGroupDetailsState extends State<EditGroupDetails> {
  var controller = Get.find<GroupDetailController>();
  var groupmemberController = Get.find<GroupmemberController>();

  var userController = Get.find<UserController>();

  var chatcontroller = Get.find<ChatController>();

  var messageController = Get.find<MessageController>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getGroupDetail(widget.docId!, userController.userModel.value.uid!);
    });
  }

  @override
  Widget build(BuildContext context) {
    GlobalVariable.docId = '';

    return Scaffold(
        floatingActionButton: FloatingActionButton(
            backgroundColor: appRedColor,
            child: Icon(
              Icons.logout,
              color: appWhiteColor,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text(
                          'Leave Group',
                          style: TextStyle(fontWeight: FontWeight.w700, color: appBlackColor),
                        ),
                        content: Text(
                          'Do you really want to leave the group?',
                          style: TextStyle(fontSize: 14, color: appBlackColor),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('No')),
                          TextButton(
                              onPressed: () async {
                                await groupmemberController
                                    .leftGroup(userController.userModel.value.uid!, widget.docId!)
                                    .then((value) => pushNewScreen(context, screen: const Home()));
                              },
                              child: const Text('Yes')),
                        ],
                      ));
            }),
        appBar: CustomAppbar(
          title: poppinsText(TempLanguage.groupDetail, 15, bold, appBlackColor),
          actions: [
            GestureDetector(
                onTap: () {
                  groupmemberController.docid = widget.docId!;
                  pushNewScreen(context,
                      screen: GroupMember(
                        isAdmin: controller.groupDetailModel!.isAdmin ?? false,
                      ));
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
                                    readOnly: controller.nameTapped.value ? true : false,
                                    isAdmin: controller.groupDetailModel!.isAdmin ?? false,
                                    iconOnTap: controller.groupDetailModel!.isAdmin ?? false
                                        ? () {
                                            controller.updateGroupName(widget.docId!);
                                            chatcontroller.name.value = controller.nameController.text;

                                            controller.nameTapped.value = !controller.nameTapped.value;
                                          }
                                        : null,
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
                                    backgroundColor: appGreenColor.withOpacity(0.6),
                                    backgroundImage: controller.fileImage.value != null
                                        ? FileImage(File(controller.fileImage.value!.path))
                                        : controller.groupDetailModel!.groupImg.isEmptyOrNull
                                            ? AssetImage(AppImage.user) as ImageProvider
                                            : CachedNetworkImageProvider(controller.groupDetailModel!.groupImg!),
                                    radius: 65,
                                  ),
                                  controller.groupDetailModel!.isAdmin ?? false
                                      ? Positioned(
                                          right: 10,
                                          bottom: 1,
                                          child: GestureDetector(
                                            onTap: () {
                                              showbottomSheet(context, controller, widget.docId!, chatcontroller);
                                            },
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(color: appGreenColor, shape: BoxShape.circle),
                                              child: Icon(
                                                Icons.camera_alt,
                                                color: appWhiteColor,
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
                                poppinsText(TempLanguage.aboutGroup, 14, semiBold, appBlackColor),
                                controller.groupDetailModel!.isAdmin ?? false
                                    ? GestureDetector(
                                        onTap: () {
                                          // controller.aboutfocusNode
                                          //     .requestFocus();
                                          controller.updateGroupAbout(widget.docId!);
                                          controller.aboutTapped.value = !controller.aboutTapped.value;
                                        },
                                        child: Obx(
                                          () => controller.aboutTapped.value
                                              ? poppinsText(TempLanguage.save, 14, semiBold, appGreenColor)
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
                              isAdmin: controller.groupDetailModel!.isAdmin ?? false,
                            ),
                            Divider(
                              // thickness: 1,
                              color: appBlackColor,
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
