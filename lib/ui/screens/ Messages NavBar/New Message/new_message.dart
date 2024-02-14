import 'package:cached_network_image/cached_network_image.dart';
import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/controllers/Messages/group_detail_controller.dart';
import 'package:check_in/controllers/Messages/new_message_controller.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/add_group_details/add_group_details.dart';
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
import '../Chat/chat_screen.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  var userController = Get.find<UserController>();
  var controller = Get.find<NewMessageController>();
  var chatcontroller = Get.find<ChatController>();
  var groupDetailController = Get.find<GroupDetailController>();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      controller.fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("${controller.searchQuery.value} sarch");
    return Scaffold(
      appBar: CustomAppbar(
        title: poppinsText(TempLanguage.newMessage, 15, bold, appBlackColor),
        actions: [
          Obx(() => controller.mydata.isNotEmpty
              ? TextButton(
                  onPressed: () {
                    // clear searchQuery value

                    if (controller.mydata.length > 1) {
                      controller
                          .startNewGroupChat(
                              userController.userModel.value.uid!,
                              userController.userModel.value.userName!,
                              userController.userModel.value.photoUrl!,
                              userController.userModel.value.aboutMe!)
                          .then((value) {
                        chatcontroller.isgroup = true;
                        chatcontroller.memberId.value == controller.mydata.keys.toList();
                        //
                        groupDetailController.nameController.clear();
                        groupDetailController.aboutController.clear();
                        groupDetailController.fileImage.value = null;

                        pushNewScreen(context,
                            screen: AddGroupDetails(
                              image: '',
                              memberId: controller.memberIds,
                              senderName: "",
                              docId: value,
                              dataArray: controller.dataArray,
                            ));
                      });
                    } else {
                      controller.searchQuery.value = '';

                      controller
                          .startNewChat(
                        userController.userModel.value.uid!,
                        userController.userModel.value.userName!,
                        userController.userModel.value.photoUrl!,
                      )
                          .then((value) {
                        UserModel model = controller.mydata.values.first;
                        chatcontroller.docId.value = value;
                        chatcontroller.name.value = model.userName!;
                        chatcontroller.senderName.value = userController.userModel.value.userName!;
                        chatcontroller.isgroup = false;
                        chatcontroller.image.value = model.photoUrl!;
                        chatcontroller.memberId.value = controller.mydata.keys.toList();
                        //....... send notification
                        chatcontroller.sendNotificationMethod(
                            '', '${userController.userModel.value.userName!} send a request message');
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
                                    ))
                            .then((value) => Get.back());
                      });
                    }
                  },
                  child: poppinsText(TempLanguage.chat, 12, medium, appBlackColor),
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
                child: poppinsText(TempLanguage.to, 15, medium, appBlackColor),
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
                      controller.mydata.removeWhere((key, value) => model.uid == key);
                    },
                  );
                }).toList(),
              )),
          verticalGap(5),
          Container(
            decoration: BoxDecoration(color: greyColor.withOpacity(0.1), borderRadius: BorderRadius.circular(25)),
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
                  child: poppinsText(TempLanguage.typeToFindMember, 12, regular, greyColor),
                )
              : Expanded(
                  child: FutureBuilder(
                  future: Future.value(controller.userDataList),
                  builder: (context, snapshot) {
                    return Obx(() => controller.userDataList.isEmpty
                        ? Center(
                            child: poppinsText(TempLanguage.noMemberFound, 12, regular, greyColor),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: controller.userDataList.length,
                            itemBuilder: (context, index) {
                              bool isCurrentUser =
                                  controller.userDataList[index].uid == userController.userModel.value.uid;
                              if (!isCurrentUser) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: controller.userDataList[index].photoUrl == null ||
                                                controller.userDataList[index].photoUrl == ''
                                            ? AssetImage(AppImage.user) as ImageProvider
                                            : CachedNetworkImageProvider(controller.userDataList[index].photoUrl!),
                                        radius: 25,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 60.w,
                                                    child: poppinsText(controller.userDataList[index].userName ?? '',
                                                        15, FontWeight.bold, appBlackColor,
                                                        overflow: TextOverflow.ellipsis),
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
                                            value: controller.mydata.containsKey(controller.userDataList[index].uid),
                                            onChanged: (value) {
                                              controller.mydata.keys.contains(controller.userDataList[index].uid)
                                                  ? controller.mydata.remove(controller.userDataList[index].uid!)
                                                  : controller.mydata[controller.userDataList[index].uid!] =
                                                      controller.userDataList[index];
                                              controller.searchController.clear();
                                            },
                                            side: BorderSide(width: 1, color: appBlackColor),
                                            activeColor: appGreenColor,

                                            // fillColor:MaterialStateProperty.resolveWith(
                                            // (states) {
                                            //   if (!states.contains(
                                            //       MaterialState.pressed)) {
                                            //     return Colors.transparent;
                                            //   }
                                            //   return Colors.black;
                                            // }),
                                          ))
                                    ],
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            }));
                  },
                )))
        ]),
      ),
    );
  }
}
