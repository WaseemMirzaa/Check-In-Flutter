import 'package:check_in/Services/user_services.dart';
import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/message_model.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/chat_screen.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Messages/Component/appbar.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Messages/Component/delete_chat_dialog.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Messages/Component/message_list_tile.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Messages/Component/search_field.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import '../../../../utils/Constants/global_variable.dart';
import '../../../../utils/loader.dart';
import '../../../../controllers/Messages/messages_controller.dart';

class MessageScreen extends GetView<MessageController> {
  MessageScreen({super.key});
  final ChatController chatcontroller = Get.find<ChatController>();
  final UserController userController = Get.find<UserController>();
  final userServices = UserServices();
  @override
  Widget build(BuildContext context) {
    //   for making null docid

    GlobalVariable.docId = '';
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
                // print(userController.userModel.value.deviceTokes!.first);
                controller.searchQuery.value = query;
              },
            ),
          ),
          verticalGap(20),
          Expanded(
              child: StreamBuilder<List<Messagemodel>>(
                  stream: controller.getChatMessage(FirebaseAuth.instance.currentUser?.uid??''),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return loaderView();
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text(TempLanguage.noMessageFound));
                    }else if(snapshot.hasError){
                      return Center(child: Text(snapshot.error.toString()),);
                    } else {
                      return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var message = snapshot.data?[index];
                            if (message!.showMessageTile!) {
                              return (snapshot.data![index].isgroup == false)
                                  ? FutureBuilder(
                              future: userServices.getUserData(
                                  snapshot.data![index].recieverId == FirebaseAuth.instance.currentUser!.uid ? snapshot.data![index].senderId! : snapshot.data![index].recieverId!),
                                  builder: (context, userSnap) {
                                if(userSnap.connectionState == ConnectionState.waiting){
                                  return SizedBox();
                                }else if(!userSnap.hasData){
                                  return SizedBox();
                                }
                                return Obx(() {
                                  if (snapshot.data![index].name!
                                      .toLowerCase().contains(controller.searchQuery.toLowerCase())) {
                                    return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child: Slidable(
                                          endActionPane: ActionPane(
                                            extentRatio: 0.27,
                                            motion: const ScrollMotion(),
                                            children: [
                                              SlidableAction(
                                                onPressed: (_) {
                                                  messageDeleteDialog(onTap: () {
                                                    controller.deleteMessage(
                                                        message.id!, userController.userModel.value.uid!).then((_) => Get.back());});
                                                  },
                                                backgroundColor: appRedColor,
                                                foregroundColor: appWhiteColor,
                                                borderRadius: BorderRadius.only(
                                                    topLeft: const Radius.circular(5),
                                                    bottomLeft: radiusCircular(5)),
                                                icon: Icons.delete,
                                                label: 'Delete',
                                              ),
                                            ],
                                          ),
                                          child: MessageListTile(
                                            message: snapshot.data![index],
                                            ontap: () {
                                              GlobalVariable.docId = chatcontroller.docId.value =
                                              message.id!;
                    //.........................
                    chatcontroller.name.value = message.name ?? '';
                    chatcontroller.isgroup = message.isgroup ?? false;
                    chatcontroller.image.value = userSnap.data?.photoUrl ?? '';
                    chatcontroller.memberId.value = message.memberIds ?? [];
                    chatcontroller.senderName.value = message.yourname ?? '';
                    chatcontroller.members.value = message.members ?? [];
                    //...............
                    // chatcontroller.updateLastSeenMethod();
                    pushNewScreen(
                      context,
                      screen: ChatScreen(
                        image: userSnap.data?.photoUrl ?? '',
                        //   name: message.name!.obs,isGroup: message.isgroup,
                        // image:message.image!.obs,memberId: message.memberIds!.obs,senderName: message.senderName!.obs,
                      ),
                    );
                  },
                  userModel: userSnap.data,
                ),
              ));
        } else {
          return Container();
        }
      });
    }
                              )
                                  : Obx(() {
                                if (snapshot.data![index].name!.toLowerCase().contains(controller.searchQuery.toLowerCase())) {
                                  return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Slidable(
                                        endActionPane: ActionPane(
                                          extentRatio: 0.27,
                                          motion: const ScrollMotion(),
                                          children: [
                                            SlidableAction(
                                              onPressed: (_) {
                                                messageDeleteDialog(onTap: () {
                                                  controller.deleteMessage(
                                                      message.id!, userController.userModel.value.uid!).then((_) => Get.back());});
                                              },
                                              backgroundColor: appRedColor,
                                              foregroundColor: appWhiteColor,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: const Radius.circular(5),
                                                  bottomLeft: radiusCircular(5)),
                                              icon: Icons.delete,
                                              label: 'Delete',
                                            ),
                                          ],
                                        ),
                                        child: MessageListTile(
                                          message: snapshot.data![index],
                                          ontap: () {
                                            GlobalVariable.docId = chatcontroller.docId.value =
                                            message.id!;
                                            //.........................
                                            chatcontroller.name.value = message.name ?? '';
                                            chatcontroller.isgroup = message.isgroup ?? false;
                                            chatcontroller.image.value = message.image ?? '';
                                            chatcontroller.memberId.value = message.memberIds ?? [];
                                            chatcontroller.senderName.value = message.yourname ?? '';
                                            chatcontroller.members.value = message.members ?? [];
                                            //...............
                                            // chatcontroller.updateLastSeenMethod();
                                            pushNewScreen(
                                              context,
                                              screen: ChatScreen(
                                                //   name: message.name!.obs,isGroup: message.isgroup,
                                                // image:message.image!.obs,memberId: message.memberIds!.obs,senderName: message.senderName!.obs,
                                              ),
                                            );
                                          },
                                          userModel: UserModel(),
                                        ),
                                      ));
                                } else {
                                  return Container();
                                }
                              }
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          });
                    }
                  }))
        ],
      ),
    );
  }
}
