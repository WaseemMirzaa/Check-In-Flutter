import 'package:cached_network_image/cached_network_image.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/chat_model.dart';
import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/Component/appbar.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/Component/image_bottomsheet.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/Component/image_date_container.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/Component/sticker_keyboard.dart';
import 'package:check_in/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
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
                                                const CachedNetworkImageProvider(
                                                    'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
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
          // Container(
          //   height: 160,
          //   width: 85.w,
          //   decoration: BoxDecoration(
          //     color: whiteColor,
          //     borderRadius: BorderRadius.circular(10),
          //     boxShadow: [
          //       BoxShadow(
          //         color: blackTranslucentColor,
          //         offset: const Offset(0, 1),
          //         blurRadius: 6,
          //       ),
          //     ],
          //   ),
          //   child: Padding(
          //     padding: const EdgeInsets.all(13),
          //     child: Column(
          //       children: [
          //         poppinsText(
          //             TempLanguage.sendMessageRequest, 14, bold, blackColor),
          //         verticalGap(7),
          //         poppinsText(TempLanguage.sendMessageRequestToCall, 11,
          //             regular, greyColor,
          //             maxlines: 2, align: TextAlign.center),
          //         verticalGap(7),
          //         Divider(
          //           color: blackColor,
          //         ),
          //         Row(
          //           children: [
          //             ChatButton(
          //               text: TempLanguage.sendRequest,
          //               textColor: whiteColor,
          //               buttonColor: greenColor,
          //               width: 50.w,
          //               onTap: () {},
          //             ),
          //             horizontalGap(7),
          //             ChatButton(
          //               text: TempLanguage.ignore,
          //               textColor: blackColor,
          //               buttonColor: greyColor.withOpacity(0.23),
          //               width: 25.w,
          //               onTap: () {},
          //             )
          //           ],
          //         )
          //       ],
          //     ),
          //   ),
          // ),

          SendMessageContainer(
            textFieldController: controller.chatfieldController,
            imageontap: () {
              showchatbottomSheet(context, controller);
            },
            textfieldontap: () {
              controller.issticker.value = true;
            },
            iconontap: () {
              controller.issticker.value = !controller.issticker.value;
              FocusManager.instance.primaryFocus?.unfocus();
            },
            sendmsgontap: () {
              if (controller.chatfieldController.text.isNotEmpty) {
                controller.sendMessage();
                controller.chatfieldController.clear();
              }
            },
          ),
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
