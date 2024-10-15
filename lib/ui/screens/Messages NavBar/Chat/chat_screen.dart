import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/controllers/Messages/messages_controller.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/chat_model.dart';
import 'package:check_in/ui/screens/Messages%20NavBar/edit_group_detail/edit_group_details.dart';
import 'package:check_in/ui/screens/Messages%20NavBar/other_profile/other_profile_view.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/custom/custom_firebase_chat_pagination.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

import '../../../../model/Message and Group Message Model/message_model.dart';
import '../../../../utils/Constants/enums.dart';
import '../../../../utils/styles.dart';
import 'Component/button.dart';
import 'Component/image_date_container.dart';
import 'Component/message_date_container.dart';
import 'Component/send_message_container.dart';
import 'Component/sticker_keyboard.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key, this.image = '', this.isBlocked = false
      // this.docId,
      });
  String? image;
  bool isBlocked;
  // final String? docId;

  // bool isFirstTime;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var controller = Get.find<ChatController>();
  var messageController = Get.find<MessageController>();
  var userController = Get.find<UserController>();
  String onlineStatus = '';

  bool isBlocked = false;

  @override
  void initState() {
    super.initState();

    isBlocked = widget.isBlocked;
    controller.sendMessageCall.value = false;
    controller.getSingleMessage();
    controller.issticker.value = true;
    controller.chatfieldController.addListener(() {
      controller.sendMsgField.value = controller.chatfieldController.text;
    });

    !controller.isgroup
        ? fetchOnlineStatus(userController.userModel.value.uid!)
        : null;
  }

  fetchOnlineStatus(String userId) async {
    // print('in method:$userId');
    // print(userId);
    try {
      // MessageService messageService = MessageService(); // Create an instance
      String status = await controller.chatService
          .getOnlineStatus(controller.docId.value); // Call the method
      controller.chatService.updateOnlineStatus(
          controller.docId.value, DateTime.now().toString(), userId);
      if (mounted) setState(() {});
      onlineStatus = status;
    } catch (e) {
      print('Error fetching online status: $e');
    }
  }

  Future<bool> _onBackPressed() async {
    if (controller.issticker.value == false) {
      controller.issticker.value = true;
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          appBar: CustomAppbar(
              title: GestureDetector(
            onTap: controller.isgroup
                ? () {
                    pushNewScreen(context,
                        screen: EditGroupDetails(
                          docId: controller.docId.value,
                          // members: controller.memberId,
                        )).then((_) => null);
                  }
                : () {
                    pushNewScreen(context,
                        screen: OtherProfileView(
                            uid: controller.otherUserId.value));
                  },
            child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  controller.isgroup
                      ? Obx(() => CircleAvatar(
                            backgroundImage: widget.image.isEmptyOrNull &&
                                    controller.image.value.isEmptyOrNull
                                ? AssetImage(AppImage.user) as ImageProvider
                                : CachedNetworkImageProvider(controller.isgroup
                                    ? controller.image.value
                                    : widget.image ?? ''),
                            radius: 20,
                          ))
                      : CircleAvatar(
                          backgroundImage: widget.image.isEmptyOrNull &&
                                  controller.image.value.isEmptyOrNull
                              ? AssetImage(AppImage.user) as ImageProvider
                              : CachedNetworkImageProvider(controller.isgroup
                                  ? controller.image.value
                                  : widget.image ?? ''),
                          radius: 20,
                        ),
                  horizontalGap(10),
                  controller.isgroup
                      ? SvgPicture.asset(AppImage.chatgroupicon)
                      : const SizedBox(),
                  horizontalGap(2),
                  Obx(() => Flexible(
                        child: controller.isgroup
                            ? poppinsText(controller.name.value ?? '', 16,
                                FontWeight.bold, appBlackColor)
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  poppinsText(controller.name.value ?? '', 16,
                                      FontWeight.bold, appBlackColor),
                                  const SizedBox(height: 2),
                                  Text(
                                    onlineStatus,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                      )),
                ]),
          )),
          body: Column(children: [
            Expanded(
              child: CustomFirebaseChatPagination(
                key: UniqueKey(),
                limit: 20,
                viewType: ViewType.list,
                isLive: true,
                reverse: true,
                onEmpty: const Center(
                  child: Text('No message found'),
                ),
                query: FirebaseFirestore.instance
                    .collection(Collections.MESSAGES)
                    .doc(controller.docId.value)
                    .collection(Collections.CHAT)
                    .orderBy(ChatField.TIME_STAMP, descending: true),
                itemBuilder:
                    (BuildContext context, List<Chatmodel> list, int index) {
                  final chat = list[index];
                  bool mymsg = chat.id == userController.userModel.value.uid
                      ? true
                      : false;

                  var hiddenBy = List<String>.from(chat.hiddenBy ?? []);

                  // If current user has hidden the message, don't display it
                  if (hiddenBy.contains(userController.userModel.value.uid)) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: EdgeInsets.only(
                      left: mymsg ? 0 : 14,
                      right: mymsg ? 14 : 0,
                      top: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: mymsg
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        mymsg
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 22.0),
                                child: CircleAvatar(
                                  backgroundColor:
                                      appGreenColor.withOpacity(0.6),
                                  backgroundImage: !controller.isgroup
                                      ? controller.image.value.isEmptyOrNull
                                          ? const NetworkImage(
                                              AppAssets.defaulImg)
                                          : NetworkImage(controller.image.value)
                                      : _showGroupImage(chat.id!),
                                  radius: 17,
                                ),
                              ),
                        horizontalGap(8),
                        chat.type == 'message'
                            ? MessageDateContainer(
                                // index: index,
                                chat: chat,
                                mymsg: mymsg,
                                // showLastSeen: showLastSeen,
                                docId: controller.docId.value,
                                isGroup: controller.isgroup)
                            : ImageDateContainer(
                                chat: chat,
                                mymsg: mymsg,
                                docId: controller.docId.value,
                                isGroup: controller.isgroup
                                // showLastSeen: showLastSeen,
                                )
                      ],
                    ),
                  );
                },
                docId: controller.docId.value,
                uId: userController.userModel.value.uid!,
                mem: controller.members,
              ),
            ),

            // for show request status dialog
            StreamBuilder<Messagemodel>(
                stream: controller.getRequestStatus(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text(''));
                  } else {
                    if (snapshot.data!.senderId ==
                            controller.userController.userModel.value.uid &&
                        snapshot.data!.requestStatus ==
                            RequestStatusEnum.pending.name) {
                      return Container(
                        // height: 160,
                        width: 50.w,
                        padding: const EdgeInsets.all(13),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: appWhiteColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: blackTranslucentColor,
                              offset: const Offset(0, 1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            poppinsText(TempLanguage.inviteSent, 15, medium,
                                appBlackColor),
                          ],
                        ),
                      );
                    } else if (snapshot.data!.senderId !=
                            controller.userController.userModel.value.uid &&
                        snapshot.data!.requestStatus ==
                            RequestStatusEnum.pending.name) {
                      return Container(
                        // height: 160,
                        width: 90.w,
                        padding: const EdgeInsets.all(13),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: appWhiteColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: blackTranslucentColor,
                              offset: const Offset(0, 1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            poppinsText(
                                "${TempLanguage.acceptMessageRequest} ${snapshot.data!.senderName}?",
                                14,
                                medium,
                                appBlackColor,
                                maxlines: 2),
                            verticalGap(15),
                            Row(
                              children: [
                                Flexible(
                                    child: ChatButton(
                                  onTap: () {
                                    controller.updateRequestStatus(
                                        RequestStatusEnum.block.name,
                                        'Blocked',
                                        0);
                                    // controller.sendNotificationMethod(
                                    //     '', '${userController.userModel.value.userName!} block you');
                                  },
                                  text: TempLanguage.block,
                                  textColor: appRedColor,
                                  buttonColor: Colors.white.withOpacity(0.7),
                                )),
                                horizontalGap(2.w),
                                Flexible(
                                    child: ChatButton(
                                  onTap: () async {
                                    controller.updateRequestStatus(
                                        RequestStatusEnum.delete.name,
                                        'Request Deleted',
                                        0);
                                    Get.back();
                                    controller.sendNotificationMethod('',
                                        '${userController.userModel.value.userName!} denied message request');
                                  },
                                  text: TempLanguage.delete,
                                  textColor: appRedColor,
                                  buttonColor: Colors.white.withOpacity(0.7),
                                )),
                                horizontalGap(2.w),
                                Flexible(
                                    child: ChatButton(
                                  onTap: () {
                                    controller.updateRequestStatus(
                                        RequestStatusEnum.accept.name,
                                        'Request Accepted',
                                        1);
                                    controller.sendNotificationMethod('',
                                        '${userController.userModel.value.userName!} accepted request');
                                  },
                                  text: TempLanguage.accept,
                                  textColor: Colors.blue,
                                  buttonColor: Colors.white.withOpacity(0.7),
                                )),
                              ],
                            )
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  }
                }),

            StreamBuilder<Messagemodel>(
                stream: controller.getRequestStatus(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text(''));
                  } else {
                    if (snapshot.data!.senderId ==
                            controller.userController.userModel.value.uid &&
                        snapshot.data!.requestStatus ==
                            RequestStatusEnum.delete.name) {
                      return Container(
                        // height: 160,
                        // width: 50.w,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: appWhiteColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: blackTranslucentColor,
                              offset: const Offset(0, 1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: poppinsText(
                                  "${TempLanguage.requestDeleted} ${snapshot.data!.recieverName}",
                                  15,
                                  medium,
                                  appBlackColor),
                            ),
                            ChatButton(
                              width: 35.w,
                              onTap: () {
                                controller.updateRequestStatus(
                                    RequestStatusEnum.pending.name,
                                    TempLanguage.messageRequest,
                                    1);
                                controller.sendNotificationMethod('',
                                    '${userController.userModel.value.userName!} sent a message request');
                              },
                              text: "${TempLanguage.requestAgain} ",
                              buttonColor: appGreenColor,
                              textColor: appWhiteColor,
                            )
                          ],
                        ),
                      );
                    } else if (snapshot.data!.senderId ==
                            controller.userController.userModel.value.uid &&
                        snapshot.data!.requestStatus ==
                            RequestStatusEnum.block.name) {
                      return Container(
                        // height: 160,
                        // width: 50.w,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: appWhiteColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: blackTranslucentColor,
                              offset: const Offset(0, 1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: poppinsText(
                                  " ${snapshot.data!.recieverName} ${TempLanguage.blockedYou}",
                                  15,
                                  medium,
                                  appBlackColor,
                                  align: TextAlign.center),
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.data!.senderId !=
                            controller.userController.userModel.value.uid &&
                        snapshot.data!.requestStatus ==
                            RequestStatusEnum.block.name) {
                      return Container(
                        // height: 160,
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: appWhiteColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: blackTranslucentColor,
                              offset: const Offset(0, 1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            poppinsText(TempLanguage.youBlockThisAccount, 15,
                                medium, appBlackColor),
                            verticalGap(10),
                            ChatButton(
                              width: 35.w,
                              onTap: () {
                                controller.updateRequestStatus(
                                    RequestStatusEnum.accept.name,
                                    'Unblocked',
                                    0);
                                // controller.sendNotificationMethod(
                                //     '', "${userController.userModel.value.userName!} unblock you");
                              },
                              text: "${TempLanguage.unblock} ",
                              buttonColor: appGreenColor,
                              textColor: appWhiteColor,
                            )
                          ],
                        ),
                      );
                    } else if (isBlocked) {
                      if (snapshot.data?.blockId ==
                          controller.userController.userModel.value.uid) {
                        String name = '';
                        if (snapshot.data?.blockId == snapshot.data?.senderId) {
                          name = snapshot.data?.senderName ?? '';
                        } else {
                          name = snapshot.data?.recieverName ?? '';
                        }
                        return Container(
                          // height: 160,
                          // width: 50.w,
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: appWhiteColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: blackTranslucentColor,
                                offset: const Offset(0, 1),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: poppinsText(
                                    " $name ${TempLanguage.blockedYou}",
                                    15,
                                    medium,
                                    appBlackColor,
                                    align: TextAlign.center),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container(
                          // height: 160,
                          width: double.infinity,
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: appWhiteColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: blackTranslucentColor,
                                offset: const Offset(0, 1),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              poppinsText(TempLanguage.youBlockThisAccount, 15,
                                  medium, appBlackColor),
                              verticalGap(10),
                              ChatButton(
                                width: 35.w,
                                onTap: () async {
                                  final res =
                                      await messageController.blockContact(
                                          snapshot.data?.id! ?? '', '');
                                  if (res) {
                                    setState(() {
                                      isBlocked = false;
                                    });
                                  } else {
                                    toast(
                                        'Something went wrong. Try again later');
                                  }
                                  // controller.updateRequestStatus(
                                  //     RequestStatusEnum.accept.name,
                                  //     'Unblocked',
                                  //     0);
                                  // controller.sendNotificationMethod(
                                  //     '', "${userController.userModel.value.userName!} unblock you");
                                },
                                text: "${TempLanguage.unblock} ",
                                buttonColor: appGreenColor,
                                textColor: appWhiteColor,
                              )
                            ],
                          ),
                        );
                      }
                    } else {
                      return SendMessageContainer(
                        textFieldController: controller.chatfieldController,
                        imageontap: () async {
                          chatBottomSheet(context, controller);
                        },
                        textfieldontap: () {
                          controller.issticker.value = true;
                        },
                        iconontap: () {
                          controller.issticker.value =
                              !controller.issticker.value;
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        sendmsgontap: () async {
                          if (controller.chatfieldController.text.isNotEmpty) {
                            await controller.sendMessage();
                            controller.sendMsgField.value = '';
                            controller.sendNotificationMethod(
                                '', controller.chatfieldController.text);
                            controller.chatfieldController.clear();
                            // if (newMessageDoc != null) {
                            //   _chats.insert(0, newMessageDoc);
                            //   _streamController.add(_chats);
                            // }
                          }
                        },
                      );
                    }
                  }
                }),

            Obx(() => Offstage(
                  offstage: controller.issticker.value,
                  child: StickerKeyboard(
                    controller: controller.chatfieldController,
                  ),
                ))
          ])),
    );
  }

  NetworkImage? _showGroupImage(String chatId) {
    // Iterate through the members list to find the user with matching ID
    for (var member in controller.members) {
      print("group member image --->  ${member['image']}");
      if (member['uid'] == chatId) {
        // Return the user image URL if found
        return (member['image'] == null || member['image'] == '')
            ? const NetworkImage(AppAssets.defaulImg)
            : NetworkImage(member['image']);
      }
    }
    // Return null if no user with matching ID is found
    return null;
  }

  Future<void> chatBottomSheet(
      BuildContext context, ChatController controller) {
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
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      controller.fileImage.value = pickedFile;
                      Navigator.pop(context);
                      await controller.sendMessage();
                      controller.sendNotificationMethod(
                        '',
                        'Photo',
                      );
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
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      controller.fileImage.value = pickedFile;
                      Navigator.pop(context);
                      await controller.sendMessage();
                      controller.sendNotificationMethod(
                        '',
                        'Photo',
                      );
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
