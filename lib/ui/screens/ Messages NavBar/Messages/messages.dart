import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/message_model.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/chat_screen.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Messages/Component/appbar.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Messages/Component/message_list_tile.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Messages/Component/search_field.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';
import '../../../../utils/loader.dart';
import '../../../../controllers/Messages/chat_controller.dart';
import '../../../../controllers/Messages/messages_controller.dart';

class MessageScreen extends GetView<MessageController> {
  MessageScreen({super.key});
  final ChatController chatcontroller = Get.find<ChatController>();
  final UserController userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingactionButton(
      //   ontap: () {},
      // ),
      appBar: const MessageAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SearchField(
              onchange: (query) {
                controller.searchQuery.value = query;
              },
            ),
          ),
          verticalGap(20),
          Expanded(
              child: StreamBuilder<List<Messagemodel>>(
                  stream: controller
                      .getChatMessage(userController.userModel.value.uid!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return loaderView();
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text(TempLanguage.noMessageFound));
                    } else {
                      return ListView.separated(
                          // padding: const EdgeInsets.only(top: 14),
                          separatorBuilder: (_, __) {
                            return verticalGap(1.5.h);
                            // Padding(
                            //   padding: EdgeInsets.symmetric(vertical: 6),
                            //   child: Divider(
                            //     indent: 20,
                            //     endIndent: 20,
                            //     thickness: 2,
                            //   ),
                            // );
                          },
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var message = snapshot.data![index];
                            return Obx(() {
                              if (snapshot.data![index].name!
                                  .toLowerCase()
                                  .contains(
                                      controller.searchQuery.toLowerCase())) {
                                return MessageListTile(
                                  message: snapshot.data![index],
                                  ontap: () {
                                    chatcontroller.docId.value = message.id!;
                                    chatcontroller.name.value = message.name!;
                                    chatcontroller.isgroup = message.isgroup!;
                                    chatcontroller.image.value = message.image!;
                                    pushNewScreen(
                                      context,
                                      screen: ChatScreen(),
                                    );
                                  },
                                );
                              } else {
                                return Container();
                              }
                            });
                          });
                    }
                  }))
        ],
      ),
    );
  }
}
