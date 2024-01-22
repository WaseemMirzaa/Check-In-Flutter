import 'package:cached_network_image/cached_network_image.dart';
import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/controllers/Messages/new_message_controller.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/chat_screen.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Group%20Detail/group_detail.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/ui/widgets/text_field.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

class NewMessageScreen extends GetView<NewMessageController> {
  NewMessageScreen({super.key});
  var userController = Get.find<UserController>();
  var chatcontroller = Get.find<ChatController>();
  @override
  Widget build(BuildContext context) {
    print("${controller.searchQuery.value}sarch");
    return Scaffold(
      appBar: CustomAppbar(
        title: poppinsText(TempLanguage.newMessage, 15, bold, blackColor),
        actions: [
          Obx(() => controller.mydata.isNotEmpty
              ? TextButton(
                  onPressed: () {
                    // clear searchQuery value
                    controller.searchQuery.value = '';

                    if (controller.mydata.length > 1) {
                      controller
                          .startNewGroupChat(
                              userController.userModel.value.uid!,
                              userController.userModel.value.userName!)
                          .then((value) {
                        chatcontroller.docId.value = value;
                        chatcontroller.senderName.value = "";
                        chatcontroller.image.value = "";
                        chatcontroller.isgroup = true;
                        chatcontroller.memberId.value =
                            controller.mydata.keys.toList();
                        chatcontroller.sendNotificationMethod('',
                            '${userController.userModel.value.userName!} created new group with you');
                        // clear map mydata
                        controller.mydata.clear();
                        pushNewScreen(context,
                            screen: GroupdetailScreen(
                              isGroup: true,
                              image: '',
                              memberId: controller.mydata.keys.toList().obs,
                              senderName: "",
                              showBtn: true,
                              docId: value,
                            )).then((value) => Get.back());
                      });
                    } else {
                      controller
                          .startNewChat(userController.userModel.value.uid!,
                              userController.userModel.value.userName!)
                          .then((value) {
                        UserModel model = controller.mydata.values.first;
                        chatcontroller.docId.value = value;
                        chatcontroller.name.value = model.userName!;
                        chatcontroller.senderName.value =
                            userController.userModel.value.userName!;
                        chatcontroller.isgroup = false;
                        chatcontroller.image.value = model.photoUrl!;
                        chatcontroller.memberId.value =
                            controller.mydata.keys.toList();
                        //....... send notification
                        chatcontroller.sendNotificationMethod('',
                            '${userController.userModel.value.userName!} send a request message');
                        // clear map mydata
                        controller.mydata.clear();
                        pushNewScreen(context,
                            screen: ChatScreen(
                              // name: model.userName!.obs,
                              // isGroup: false,
                              // image: model.photoUrl!.obs,
                              // memberId: controller.mydata.keys.toList().obs,
                              // senderName:
                              //     userController.userModel.value.userName!.obs,
                            )).then((value) => Get.back());
                      });
                    }
                  },
                  child: poppinsText(TempLanguage.chat, 12, medium, blackColor),
                )
              : const SizedBox())
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          verticalGap(10),
          verticalGap(5),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: poppinsText(TempLanguage.to, 15, medium, blackColor),
              ),
            ],
          ),
          Obx(() => Wrap(
                spacing: 8.0,
                runSpacing: 0.0,
                children: controller.mydata.values.map((value) {
                  UserModel model = value;
                  return Chip(
                    label: Text(model.userName!),
                    onDeleted: () {
                      controller.mydata
                          .removeWhere((key, value) => model.uid == key);
                    },
                  );
                }).toList(),
              )),
          verticalGap(5),
          Container(
            decoration: BoxDecoration(
                color: greyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25)),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: CustomTextfield1(
              controller: controller.searchController,
              hintText: TempLanguage.search,
              onChanged: (value) {
                controller.searchQuery.value = value;
                controller.updateSearchQuery(value);
              },
            ),
          ),
          verticalGap(10),
          Obx(() => controller.searchQuery.value == ''
              ? Center(
                  child: poppinsText(
                      TempLanguage.typeToFindMember, 12, regular, greyColor),
                )
              : Expanded(
                  child: FutureBuilder(
                  future: Future.value(controller.userDataList),
                  builder: (context, snapshot) {
                    return Obx(() => controller.userDataList.isEmpty
                        ? Center(
                            child: poppinsText(TempLanguage.noMemberFound, 12,
                                regular, greyColor),
                          )
                        : ListView.builder(
                            itemCount: controller.userDataList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: controller
                                                  .userDataList[index]
                                                  .photoUrl ==
                                              ''
                                          ? AssetImage(AppImage.user)
                                              as ImageProvider
                                          : CachedNetworkImageProvider(
                                              controller.userDataList[index]
                                                  .photoUrl!),
                                      radius: 25,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 60.w,
                                                  child: poppinsText(
                                                      controller
                                                              .userDataList[
                                                                  index]
                                                              .userName ??
                                                          '',
                                                      15,
                                                      FontWeight.bold,
                                                      blackColor,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                              ],
                                            ),
                                            // SizedBox(
                                            //   width: 45.w,
                                            //   child: poppinsText(
                                            //       'USerabout' ?? '',
                                            //       11,
                                            //       FontWeight.normal,
                                            //       blackColor.withOpacity(0.65),
                                            //       overflow:
                                            //           TextOverflow.ellipsis),
                                            // )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Obx(() => Checkbox(
                                          value: controller.mydata.containsKey(
                                              controller
                                                  .userDataList[index].uid),
                                          onChanged: (value) {
                                            controller.mydata.keys.contains(
                                                    controller
                                                        .userDataList[index]
                                                        .uid)
                                                ? controller.mydata.remove(
                                                    controller
                                                        .userDataList[index]
                                                        .uid!)
                                                : controller.mydata[controller
                                                        .userDataList[index]
                                                        .uid!] =
                                                    controller
                                                        .userDataList[index];
                                            controller.searchController.clear();
                                          },
                                          fillColor:
                                              MaterialStateProperty.resolveWith(
                                                  (states) {
                                            if (!states.contains(
                                                MaterialState.pressed)) {
                                              return greenColor;
                                            }
                                            return null;
                                          }),
                                        ))
                                  ],
                                ),
                              );
                            }));
                  },
                )))
        ]),
      ),
    );
  }
}
