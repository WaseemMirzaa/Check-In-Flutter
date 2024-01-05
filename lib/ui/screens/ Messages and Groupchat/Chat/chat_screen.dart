import 'package:check_in/model/chat_model.dart';
import 'package:check_in/controllers/chat_controller.dart';
import 'package:check_in/ui/screens/%20Messages%20and%20Groupchat/Chat/Widgets/appbar.dart';
import 'package:check_in/ui/screens/%20Messages%20and%20Groupchat/Chat/Widgets/sticker_keyboard.dart';
import 'package:check_in/utils/Constants/global_variable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import '../../../../utils/gaps.dart';
import '../../../../utils/loader.dart';
import '../Group Detail/group_detail.dart';
import 'Widgets/message_date_container.dart';
import 'Widgets/send_message_container.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});
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
                      screen: GroupdetailScreen(docId: controller.docId.value));
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
                      return const Center(child: Text('No Conversation.'));
                    } else {
                      return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 10),
                          reverse: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var chat = snapshot.data![index];
                            bool mymsg =
                                chat.id == GlobalVariable.userid ? true : false;
                            return Padding(
                              padding: EdgeInsets.only(
                                left: mymsg ? 0 : 14,
                                right: mymsg ? 14 : 0,
                                top: 12,
                              ),
                              child: Row(
                                mainAxisAlignment: mymsg
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  mymsg
                                      ? const SizedBox()
                                      : const CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
                                          radius: 17,
                                        ),
                                  horizontalGap(8),
                                  MessageDateContainer(
                                      index: index, chat: chat, mymsg: mymsg)
                                ],
                              ),
                            );
                          });
                    }
                  })),
          SendMessageContainer(
            controller: controller.chatfieldController,
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
