import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/chat_model.dart';
import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/message_model.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/Component/appbar.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/Component/button.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/Component/image_bottomsheet.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/Component/image_date_container.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/Component/sticker_keyboard.dart';
import 'package:check_in/utils/Constants/enums.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';
import '../../../../utils/gaps.dart';
import '../../../../utils/loader.dart';
import '../Group Detail/group_detail.dart';
import 'Component/message_date_container.dart';
import 'Component/send_message_container.dart';

class ChatScreen extends GetView<ChatController> {
  ChatScreen({super.key});
  var userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppbar(
          name: controller.name,
          isgroup: controller.isgroup,
          image: controller.image,
          ontap: controller.isgroup
              ? () {
                  pushNewScreen(context,
                          screen:
                              GroupdetailScreen(docId: controller.docId.value))
                      .then((_) => null);
                }
              : () {}),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<List<Chatmodel>>(
                  stream: controller.getConversation(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return loaderView();
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text(TempLanguage.noConversation));
                    } else {
                      return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 10),
                          reverse: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var chat = snapshot.data![index];
                            bool mymsg =
                                chat.id == userController.userModel.value.uid
                                    ? true
                                    : false;
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
                                          padding: const EdgeInsets.only(
                                              bottom: 22.0),
                                          child: CircleAvatar(
                                            backgroundColor:
                                                greenColor.withOpacity(0.6),
                                            backgroundImage:
                                                AssetImage(AppImage.user),
                                            radius: 17,
                                          ),
                                        ),
                                  horizontalGap(8),
                                  chat.type == 'message'
                                      ? MessageDateContainer(
                                          index: index,
                                          chat: chat,
                                          mymsg: mymsg)
                                      : GestureDetector(
                                          onTap: () {
                                            showGeneralDialog(
                                                barrierColor: greyColor,
                                                context: context,
                                                pageBuilder: (context,
                                                    animation,
                                                    secondaryAnimation) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 40.0),
                                                    child: Image.network(
                                                        chat.message!),
                                                  );
                                                });
                                          },
                                          child: ImageDateContainer(
                                              index: index,
                                              chat: chat,
                                              mymsg: mymsg),
                                        )
                                ],
                              ),
                            );
                          });
                    }
                  })),
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
                        color: whiteColor,
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
                              TempLanguage.inviteSent, 15, medium, blackColor),
                        ],
                      ),
                    );
                  } else if (snapshot.data!.senderId !=
                          controller.userController.userModel.value.uid &&
                      snapshot.data!.requestStatus ==
                          RequestStatusEnum.pending.name) {
                    return Container(
                      // height: 160,
                      width: 80.w,
                      padding: const EdgeInsets.all(13),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: whiteColor,
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
                              blackColor,
                              maxlines: 2),
                          verticalGap(15),
                          Row(
                            children: [
                              Flexible(
                                  child: ChatButton(
                                onTap: () {
                                  controller.updateRequestStatus(
                                      RequestStatusEnum.block.name, '', 0);
                                },
                                text: TempLanguage.block,
                                textColor: redColor,
                                buttonColor: greyColor.withOpacity(0.7),
                              )),
                              horizontalGap(2.w),
                              Flexible(
                                  child: ChatButton(
                                onTap: () async {
                                  controller.updateRequestStatus(
                                      RequestStatusEnum.delete.name, '', 0);
                                  Get.back();
                                },
                                text: TempLanguage.delete,
                                textColor: redColor,
                                buttonColor: greyColor.withOpacity(0.7),
                              )),
                              horizontalGap(2.w),
                              Flexible(
                                  child: ChatButton(
                                onTap: () {
                                  controller.updateRequestStatus(
                                      RequestStatusEnum.accept.name, '', 0);
                                },
                                text: TempLanguage.accept,
                                textColor: whiteColor,
                                buttonColor: greyColor.withOpacity(0.7),
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
                        color: whiteColor,
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
                                blackColor),
                          ),
                          ChatButton(
                            width: 35.w,
                            onTap: () {
                              controller.updateRequestStatus(
                                  RequestStatusEnum.pending.name,
                                  TempLanguage.messageRequest,
                                  1);
                            },
                            text: "${TempLanguage.requestAgain} ",
                            buttonColor: greenColor,
                            textColor: whiteColor,
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
                        color: whiteColor,
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
                                blackColor,
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
                        color: whiteColor,
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
                              medium, blackColor),
                          verticalGap(10),
                          ChatButton(
                            width: 35.w,
                            onTap: () {
                              controller.updateRequestStatus(
                                  RequestStatusEnum.accept.name, '', 0);
                            },
                            text: "${TempLanguage.unblock} ",
                            buttonColor: greenColor,
                            textColor: whiteColor,
                          )
                        ],
                      ),
                    );
                  } else {
                    return SendMessageContainer(
                      textFieldController: controller.chatfieldController,
                      imageontap: () {
                        showchatbottomSheet(context, controller);
                      },
                      textfieldontap: () {
                        controller.issticker.value = true;
                      },
                      iconontap: () {
                        controller.issticker.value =
                            !controller.issticker.value;
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      sendmsgontap: () {
                        if (controller.chatfieldController.text.isNotEmpty) {
                          controller.sendMessage();
                          controller.chatfieldController.clear();
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
        ],
      ),
    );
  }
}
