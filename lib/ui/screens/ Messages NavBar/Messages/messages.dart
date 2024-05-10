import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/chat_model.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/message_model.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/chat_screen.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Messages/Component/appbar.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Messages/Component/delete_chat_dialog.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Messages/Component/message_list_tile.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Messages/Component/search_field.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/common.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import '../../../../core/constant/constant.dart';
import '../../../../utils/Constants/global_variable.dart';
import '../../../../utils/loader.dart';
import '../../../../controllers/Messages/messages_controller.dart';

class MessageScreen extends GetView<MessageController> {
  MessageScreen({super.key});
  final ChatController chatcontroller = Get.find<ChatController>();
  final UserController userController = Get.find<UserController>();
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
                  stream: controller.getChatMessage(userController.userModel.value.uid!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return loaderView();
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text(TempLanguage.noMessageFound));
                    } else {
                      return ListView.builder(
                          // padding: const EdgeInsets.only(top: 14),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var message = snapshot.data![index];

                            if (message.showMessageTile!) {
                              return Obx(() {
                                if (snapshot.data![index].name!
                                    .toLowerCase()
                                    .contains(controller.searchQuery.toLowerCase())) {
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
                                                  controller
                                                      .deleteMessage(message.id!, userController.userModel.value.uid!)
                                                      .then((_) => Get.back());
                                                });
                                              },
                                              backgroundColor: appRedColor,
                                              foregroundColor: appWhiteColor,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: const Radius.circular(5), bottomLeft: radiusCircular(5)),
                                              icon: Icons.delete,
                                              label: 'Delete',
                                            ),
                                          ],
                                        ),
                                        child: MessageListTile(
                                          message: snapshot.data![index],
                                          ontap: () {
                                            GlobalVariable.docId = chatcontroller.docId.value = message.id!;
                                            //.........................
                                            chatcontroller.name.value = message.name!;
                                            chatcontroller.isgroup = message.isgroup!;
                                            chatcontroller.image.value = message.image!;
                                            chatcontroller.memberId.value = message.memberIds!;
                                            chatcontroller.senderName.value = message.yourname!;
                                            chatcontroller.members.value = message.members ?? [];
                                            //...............
                                            // chatcontroller.updateLastSeenMethod();
                                            pushNewScreen(
                                              context,
                                              screen: const ChatScreen(

                                                  //   name: message.name!.obs,isGroup: message.isgroup,
                                                  // image:message.image!.obs,memberId: message.memberIds!.obs,senderName: message.senderName!.obs,
                                                  ),
                                            );
                                          },
                                        ),
                                      ));
                                } else {
                                  return Container();
                                }
                              });
                            } else {
                              return const SizedBox.shrink();
                            }
                          });
                    }
                  }))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          //correctTimestamp();
          //correctDeletedIdsTime();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  
  // Future<void> correctTimestamp() async {
  //   final firebase = FirebaseFirestore.instance;
  //
  //   QuerySnapshot result = await firebase
  //       .collection('messages')
  //       //.where('memberIds' , arrayContains: 'xiGmBmHJfZPWb7TKJeHJe2Jw77E2')
  //       .get();
  //
  //
  //   // result.docs.forEach((doc) async {
  //   //   if (doc.data() != null) {
  //   //     if((doc.data()! as Map<String, dynamic>)['timeStamp'] is Timestamp){
  //   //       return;
  //   //     }
  //   //     final message = Messagemodel.fromJson(doc.data()! as Map<String, dynamic>);
  //   //
  //   //     if (message.timeStamp is !Timestamp) {
  //   //       final timestamp = convertDateToTimeStamp(message.timeStamp ?? '');
  //   //       await firebase.collection('messages').doc(message.id ?? '').update({
  //   //         'timeStamp': timestamp
  //   //       });
  //   //     }
  //   //   }
  //   // });
  //
  //   result.docs.forEach((doc) async {
  //     if (doc.data() != null) {
  //
  //       QuerySnapshot snap = await firebase.collection('messages')
  //           .doc(doc.id ?? '')
  //           .collection("chat")
  //           .get();
  //
  //       snap.docs.forEach((element) async {
  //
  //         if ((element.data()! as Map<String, dynamic>)['timeStamp'] is Timestamp) {
  //           return;
  //         }
  //
  //         final chat = Chatmodel.fromJson(element.data() as Map<String, dynamic>);
  //         if (chat.time is !Timestamp) {
  //           print('iii ${chat.time}  ### ${chat.seenTimeStamp}');
  //           if (chat.time == null) {
  //             return;
  //           }
  //
  //           if (chat.seenTimeStamp != null && chat.seenTimeStamp!.isNotEmpty) {
  //             await firebase
  //                 .collection('messages')
  //                 .doc(doc.id ?? '')
  //                 .collection('chat')
  //                 .doc(element.id ?? '').update({
  //               'timeStamp': convertDateToTimeStamp(chat.time ?? ''),
  //               'seenTimeStamp': chat.seenTimeStamp == null ? null : convertDateToTimeStamp(chat.seenTimeStamp!)
  //             });
  //           } else {
  //             final timestamp = convertDateToTimeStamp(chat.time!);
  //             await firebase
  //                 .collection('messages')
  //                 .doc(doc.id ?? '')
  //                 .collection('chat')
  //                 .doc(element.id ?? '').update({
  //               'timeStamp': timestamp,
  //               //'seenTimeStamp': chat.seenTimeStamp == null ? null : convertDateToTimeStamp(chat.seenTimeStamp ?? '')
  //             });
  //           }
  //
  //         }
  //
  //       });
  //     }
  //   });
  // }

 // Future<void> correctDeletedIdsTime() async {
 //     final firebase = FirebaseFirestore.instance;
 //
 //     QuerySnapshot result = await firebase
 //         .collection('messages')
 //         //.where('memberIds' , arrayContains: 'xiGmBmHJfZPWb7TKJeHJe2Jw77E2')
 //         .get();
 //
 //     result.docs.forEach((doc) async {
 //       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
 //       List<dynamic> updatedDeleteIds = [];
 //
 //       if (data.containsKey(MessageField.DELETE_IDS) && data[MessageField.DELETE_IDS] != null) {
 //         print('iii ${data[MessageField.DELETE_IDS]}');
 //         for (var deleteIdMap in data[MessageField.DELETE_IDS]) {
 //           if (deleteIdMap['deleteTimeStamp'] is !Timestamp) {
 //             deleteIdMap['deleteTimeStamp'] = convertDateToTimeStamp(deleteIdMap['deleteTimeStamp']);
 //             updatedDeleteIds.add(deleteIdMap);
 //           }
 //         }
 //         if (updatedDeleteIds.isNotEmpty) {
 //           // Update the document with the modified deleteIds array
 //           await firebase.collection('messages').doc(doc.id).update({
 //             MessageField.DELETE_IDS: updatedDeleteIds,
 //           });
 //         }
 //       }
 //     });
 // }

}
