import 'package:check_in/model/message_model.dart';
import 'package:check_in/ui/screens/%20Messages%20and%20Groupchat/Chat/chat_screen.dart';
import 'package:check_in/ui/screens/%20Messages%20and%20Groupchat/Messages/Widgets/appbar.dart';
import 'package:check_in/ui/screens/%20Messages%20and%20Groupchat/Messages/Widgets/message_list_tile.dart';
import 'package:check_in/ui/screens/%20Messages%20and%20Groupchat/Messages/Widgets/search_field.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:screenshot/screenshot.dart';
import '../../../../utils/loader.dart';
import '../../../../controllers/chat_controller.dart';
import '../../../../controllers/messages_controller.dart';
import 'Widgets/floating_action_button.dart';

class MessageScreen extends GetView<MessageController> {
  MessageScreen({super.key});
  final ChatController chatcontroller = Get.find<ChatController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingactionButton(
        ontap: () {
        
        },
      ),
      appBar: const MessageAppBar(),
      body: Column(
        children: [
          SearchField(
            onchange: (query) {
              controller.searchQuery.value = query;
            },
          ),
          verticalGap(20),
          Expanded(
              child: StreamBuilder<List<Messagemodel>>(
                  stream: controller.getChatMessage(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return loaderView();
                    } else if (!snapshot.hasData) {
                      return const Center(child: Text('No messages found.'));
                    } else {
                      return ListView.separated(
                          padding: const EdgeInsets.only(top: 14, bottom: 70),
                          separatorBuilder: (_, __) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Divider(
                                indent: 20,
                                endIndent: 20,
                                thickness: 2,
                              ),
                            );
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
                                    chatcontroller.name = message.name!;
                                    chatcontroller.isgroup = message.isgroup!;
                                    pushNewScreen(context,
                                        screen: const ChatScreen());
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

  // Widget floatingActionButton() {
  //   return FloatingActionButton.extended(
  //     backgroundColor: greenColor,
  //     label: Row(
  //       children: [
  //         poppinsText('Send message', 12, FontWeight.normal, white),
  //         horizontalGap(35),
  //         SvgPicture.asset(
  //           AppImage.messageappbaricon,
  //           color: whiteColor,
  //         ),
  //       ],
  //     ),
  //     onPressed: () {},
  //   );
  // }

  // PreferredSizeWidget appBar() {
  //   return CustomAppbar(
  //     showicon: false,
  //     title: Row(mainAxisSize: MainAxisSize.min, children: [
  //       SvgPicture.asset(AppImage.messageappbaricon),
  //       horizontalGap(15),
  //       poppinsText('Messages', 20, FontWeight.bold, blackColor)
  //     ]),
  //     actions: [
  //       Padding(
  //         padding: const EdgeInsets.only(right: 20.0),
  //         child: SvgPicture.asset(
  //           AppImage.messagecircle,
  //         ),
  //       )
  //     ],
  //   );
  // }

  // Widget searchTextfield() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 10),
  //     child: Material(
  //       elevation: 8,
  //       borderRadius: BorderRadius.circular(40),
  //       child: TextFormField(
  //         decoration: InputDecoration(
  //             hintText: 'Search',
  //             enabledBorder: OutlineInputBorder(
  //               borderSide: BorderSide.none,
  //               borderRadius: BorderRadius.circular(40),
  //             ),
  //             focusedBorder: OutlineInputBorder(
  //               borderSide: BorderSide.none,
  //               borderRadius: BorderRadius.circular(40),
  //             ),
  //             suffixIcon: const Icon(Icons.search)),
  //       ),
  //     ),
  //   );
  // }
}
