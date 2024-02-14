import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/chat_model.dart';
import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/edit_group_detail/edit_group_details.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../../model/Message and Group Message Model/message_model.dart';
import '../../../../utils/Constants/enums.dart';
import '../../../../utils/styles.dart';
import 'Component/appbar.dart';
import 'Component/button.dart';
import 'Component/image_date_container.dart';
import 'Component/message_date_container.dart';
import 'Component/send_message_container.dart';
import 'Component/sticker_keyboard.dart';

final chatQuery = FirebaseFirestore.instance.collection(Collections.MESSAGES).withConverter<Chatmodel>(
      fromFirestore: (snapshot, options) => Chatmodel.fromJson(snapshot.data()!),
      toFirestore: (value, options) => value.toJson(),
    );

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key, this.recieverImage, this.isFirstTime = false});
  String? recieverImage;
  bool isFirstTime;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var controller = Get.find<ChatController>();
  var userController = Get.find<UserController>();
  Timer? timer;
  StreamSubscription<QuerySnapshot>? _subscription;

  final StreamController<List<DocumentSnapshot>> _streamController = StreamController<List<DocumentSnapshot>>();
  final List<DocumentSnapshot> _chats = [];

  String onlineStatus = '';
  bool _isRequesting = false;
  bool _isFinish = false;

  void onChangeData(List<DocumentChange> documentChanges) {
    try {
      controller.chatService
          .updateUnreadCount(controller.docId.value, userController.userModel.value.uid!, 0, controller.memberId);

      var isChange = false;
      for (var productChange in documentChanges) {
        if (productChange.type == DocumentChangeType.removed) {
          _chats.removeWhere((product) {
            return productChange.doc.id == product.id;
          });
          isChange = true;
        } else if (productChange.type == DocumentChangeType.added) {
          String timestamp = productChange.doc.get('timeStamp');

          // Check if the timestamp is a String and convert it to a Timestamp
          Timestamp convertedTimestamp = Timestamp.fromDate(DateTime.parse(timestamp));
          int timeDifference = DateTime.now().difference(convertedTimestamp.toDate()).inSeconds;

          if (timeDifference < 2) {
            // Add the document to the beginning of the list
            _chats.insert(0, productChange.doc);
            isChange = true;
          }
        } else {
          if (productChange.type == DocumentChangeType.modified) {
            int indexWhere = _chats.indexWhere((product) {
              return productChange.doc.id == product.id;
            });

            if (indexWhere >= 0) {
              _chats[indexWhere] = productChange.doc;
            }
            isChange = true;
          }
        }
      }

      if (isChange) {
        _streamController.add(_chats);
      }
    } catch (e) {
      print(e);
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      controller.updateLastSeenMethod();
    });
  }

  void stopTimer() {
    if (timer != null) {
      timer!.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isFirstTime) {
      null;
    } else {
      fetchOnlineStatus(userController.userModel.value.uid!);
      _subscription = FirebaseFirestore.instance
          .collection(Collections.MESSAGES)
          .doc(controller.docId.value)
          .collection(Collections.CHAT)
          .orderBy(ChatField.TIME_STAMP, descending: true)
          .snapshots()
          .listen((data) => onChangeData(data.docChanges));

      // requestNextPage();
      startTimer();
    }
  }

  @override
  void dispose() {
    stopTimer();
    _subscription?.cancel();
    _streamController.close();
    // controller.chatService
    //     .updateOnlineStatus(controller.docId.value, DateTime.now().toString(), userController.userModel.value.uid!);
    super.dispose();
  }

  fetchOnlineStatus(String userId) async {
    // print('in method:$userId');
    // print(userId);
    try {
      // MessageService messageService = MessageService(); // Create an instance
      String status = await controller.chatService.getOnlineStatus(controller.docId.value); // Call the method
      controller.chatService.updateOnlineStatus(controller.docId.value, DateTime.now().toString(), userId);
      setState(() {});
      onlineStatus = status;
      print('kkk:$status');
    } catch (e) {
      print('Error fetching online status: $e');
    }
  }

  // Stream<String> getOnlineStatus(String docId) async* {
  //   final messageCollection = FirebaseFirestore.instance.collection(Collections.MESSAGES);
  //   DocumentSnapshot snapshot = await messageCollection.doc(controller.docId.value).get();
  //   if (snapshot.exists) {
  //     final Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
  //     if (data != null && data.containsKey('senderStatus')) {
  //       final status = data['senderStatus'];
  //       if (status == 'Online') {
  //         yield 'Online';
  //       } else if (status.isNotEmpty) {
  //         final lastSeen = DateTime.parse(status);
  //         yield 'Last Seen ${DateFormat('hh:mm a').format(lastSeen)}';
  //       }
  //     }
  //   }
  //   // Move the updateOnlineStatus call here, outside the if block
  //   updateOnlineStatus(controller.docId.value, 'Online', docId);
  // }

  void updateOnlineStatus(String docId, String status, String uId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(Collections.MESSAGES).doc(docId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.get(MessageField.SENDER_ID) == uId) {
          docRef.update({'senderStatus': status});
          onlineStatus = status;
        } else {
          docRef.update({'receiverStatus': status});
          onlineStatus = status;
        }
      });
      print('Online status updated successfully for user $docId');
    } catch (e) {
      print('Error updating online status: $e');
      // You can yield an error message or an empty string here if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(
            title: GestureDetector(
          onTap: controller.isgroup
              ? () {
                  pushNewScreen(context,
                      screen: EditGroupDetails(
                        docId: controller.docId.value,
                        memberId: controller.memberId,
                      )).then((_) => null);
                }
              : () {
                  // controller.updateLastSeenMethod();
                },
          child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
            Obx(() => CircleAvatar(
                  backgroundImage: controller.image.value == ''
                      ? AssetImage(AppImage.user) as ImageProvider
                      : CachedNetworkImageProvider(controller.image.value),
                  radius: 20,
                )),
            horizontalGap(10),
            controller.isgroup ? SvgPicture.asset(AppImage.chatgroupicon) : const SizedBox(),
            horizontalGap(2),
            Obx(() => Flexible(
                  child: controller.isgroup
                      ? poppinsText(controller.name.value ?? '', 16, FontWeight.bold, appBlackColor)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            poppinsText(controller.name.value ?? '', 16, FontWeight.bold, appBlackColor),
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

        // ChatAppbar(
        //     name: controller.name,
        //     isgroup: controller.isgroup,
        //     image: controller.image,
        //     // onlineStatus: getOnlineStatus(),
        //     widget: controller.isgroup
        //         ? null
        //         : StreamBuilder(
        //             stream: getOnlineStatus(userController.userModel.value.uid!),
        //             builder: (context, snapshot) {
        //               if (snapshot.connectionState == ConnectionState.waiting) {
        //                 // Handle loading state
        //                 return const CircularProgressIndicator();
        //               } else {
        //                 // Handle active state
        //                 if (snapshot.hasError) {
        //                   // Handle error state
        //                   return Text('Error: ${snapshot.error}');
        //                 } else {
        //                   print("888888 ${snapshot.data}");
        //                   onlineStatus = snapshot.data!;
        //                   print("status online is $onlineStatus");
        //                   // Handle data state
        //                   return Text(
        //                     onlineStatus ?? 'Unknown Status',
        //                     style: const TextStyle(
        //                       fontSize: 10,
        //                       fontWeight: FontWeight.normal,
        //                       color: Colors.black,
        //                     ),
        //                   );
        //                 }
        //               }
        //             },
        //           ),
        //     ontap: controller.isgroup
        //         ? () {
        //             pushNewScreen(context, screen: EditGroupDetails(docId: controller.docId.value)).then((_) => null);
        //           }
        //         : () {
        //             // controller.updateLastSeenMethod();
        //           }),

        body: Column(children: [
          // Container(child: Text(onlineStatus),),
          Expanded(
            child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.maxScrollExtent == scrollInfo.metrics.pixels) {
                    requestNextPage();
                  }
                  return true;
                },
                child: StreamBuilder<List<DocumentSnapshot>>(
                    stream: _streamController.stream,
                    builder: (context, snapshot) {
                      print("snapshot $snapshot");
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Display loading indicator only if there are messages
                        return _chats.isNotEmpty ? loaderView() : const SizedBox();
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text(TempLanguage.noConversation));
                      } else {
                        List<Chatmodel> chats = snapshot.data
                                ?.map((snapshot) => Chatmodel.fromJson(snapshot.data() as Map<String, dynamic>))
                                .toList() ??
                            [];

                        // Find the last seen message
                        // var lastSeenMessage = chats.firstWhere(
                        //     (message) =>
                        //         message.seenTimeStamp != "" &&
                        //         message.id == userController.userModel.value.uid,
                        //     orElse: () => Chatmodel());

                        return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 10),
                            reverse: true,
                            itemCount: chats.length,
                            itemBuilder: (context, index) {
                              final Chatmodel chat = chats[index];

                              print("chatting ${chat.message}");
                              // Check if the current message is the last seen message
                              // bool showLastSeen = chats[index] == lastSeenMessage;

                              // String seenTime = '';
                              // var chat = snapshot.data![index];
                              bool mymsg = chat.id == userController.userModel.value.uid ? true : false;
                              // if (chat.seenTimeStamp != '') {
                              //   DateTime dateTime =
                              //       DateTime.parse(chat.seenTimeStamp!);
                              //   seenTime =
                              //       DateFormat('d MMM hh:mm a').format(dateTime);
                              // }
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: mymsg ? 0 : 14,
                                  right: mymsg ? 14 : 0,
                                  top: 12,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: mymsg ? MainAxisAlignment.end : MainAxisAlignment.start,
                                  children: [
                                    mymsg
                                        ? const SizedBox()
                                        : Padding(
                                            padding: const EdgeInsets.only(bottom: 22.0),
                                            child: CircleAvatar(
                                              backgroundColor: appGreenColor.withOpacity(0.6),
                                              backgroundImage: widget.recieverImage!.isNotEmpty
                                                  ? NetworkImage(widget.recieverImage!)
                                                  : null,
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

                                            isGroup: controller.isgroup)
                                        : GestureDetector(
                                            onTap: () {
                                              showGeneralDialog(
                                                  barrierColor: greyColor,
                                                  context: context,
                                                  pageBuilder: (context, animation, secondaryAnimation) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(top: 40.0),
                                                      child: Image.network(chat.message!),
                                                    );
                                                  });
                                            },
                                            child: ImageDateContainer(
                                              chat: chat,
                                              mymsg: mymsg,

                                              // showLastSeen: showLastSeen,
                                            ),
                                          )
                                  ],
                                ),
                              );
                            });
                      }
                    })),
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
                  if (snapshot.data!.senderId == controller.userController.userModel.value.uid &&
                      snapshot.data!.requestStatus == RequestStatusEnum.pending.name) {
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
                          poppinsText(TempLanguage.inviteSent, 15, medium, appBlackColor),
                        ],
                      ),
                    );
                  } else if (snapshot.data!.senderId != controller.userController.userModel.value.uid &&
                      snapshot.data!.requestStatus == RequestStatusEnum.pending.name) {
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
                          poppinsText("${TempLanguage.acceptMessageRequest} ${snapshot.data!.senderName}?", 14, medium,
                              appBlackColor,
                              maxlines: 2),
                          verticalGap(15),
                          Row(
                            children: [
                              Flexible(
                                  child: ChatButton(
                                onTap: () {
                                  controller.updateRequestStatus(RequestStatusEnum.block.name, '', 0);
                                  controller.sendNotificationMethod(
                                      '', '${userController.userModel.value.userName!} block you');
                                },
                                text: TempLanguage.block,
                                textColor: appRedColor,
                                buttonColor: greyColor.withOpacity(0.7),
                              )),
                              horizontalGap(2.w),
                              Flexible(
                                  child: ChatButton(
                                onTap: () async {
                                  controller.updateRequestStatus(RequestStatusEnum.delete.name, '', 0);
                                  Get.back();
                                  controller.sendNotificationMethod(
                                      '', '${userController.userModel.value.userName!} delete message request');
                                },
                                text: TempLanguage.delete,
                                textColor: appRedColor,
                                buttonColor: greyColor.withOpacity(0.7),
                              )),
                              horizontalGap(2.w),
                              Flexible(
                                  child: ChatButton(
                                onTap: () {
                                  controller.updateRequestStatus(RequestStatusEnum.accept.name, '', 0);
                                  controller.sendNotificationMethod(
                                      '', '${userController.userModel.value.userName!} accept request');
                                },
                                text: TempLanguage.accept,
                                textColor: appWhiteColor,
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
                  if (snapshot.data!.senderId == controller.userController.userModel.value.uid &&
                      snapshot.data!.requestStatus == RequestStatusEnum.delete.name) {
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
                            child: poppinsText("${TempLanguage.requestDeleted} ${snapshot.data!.recieverName}", 15,
                                medium, appBlackColor),
                          ),
                          ChatButton(
                            width: 35.w,
                            onTap: () {
                              controller.updateRequestStatus(
                                  RequestStatusEnum.pending.name, TempLanguage.messageRequest, 1);
                              controller.sendNotificationMethod(
                                  '', '${userController.userModel.value.userName!} send a request message');
                            },
                            text: "${TempLanguage.requestAgain} ",
                            buttonColor: appGreenColor,
                            textColor: appWhiteColor,
                          )
                        ],
                      ),
                    );
                  } else if (snapshot.data!.senderId == controller.userController.userModel.value.uid &&
                      snapshot.data!.requestStatus == RequestStatusEnum.block.name) {
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
                                " ${snapshot.data!.recieverName} ${TempLanguage.blockedYou}", 15, medium, appBlackColor,
                                align: TextAlign.center),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.data!.senderId != controller.userController.userModel.value.uid &&
                      snapshot.data!.requestStatus == RequestStatusEnum.block.name) {
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
                          poppinsText(TempLanguage.youBlockThisAccount, 15, medium, appBlackColor),
                          verticalGap(10),
                          ChatButton(
                            width: 35.w,
                            onTap: () {
                              controller.updateRequestStatus(RequestStatusEnum.accept.name, '', 0);
                              controller.sendNotificationMethod(
                                  '', "${userController.userModel.value.userName!} unblock you");
                            },
                            text: "${TempLanguage.unblock} ",
                            buttonColor: appGreenColor,
                            textColor: appWhiteColor,
                          )
                        ],
                      ),
                    );
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
                        controller.issticker.value = !controller.issticker.value;
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      sendmsgontap: () async {
                        if (controller.chatfieldController.text.isNotEmpty) {
                          await controller.sendMessage();
                          controller.sendNotificationMethod('', controller.chatfieldController.text);
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
        ]));
  }

  void requestNextPage() async {
    if (!_isRequesting && !_isFinish) {
      QuerySnapshot querySnapshot;

      _isRequesting = true;
      if (_chats.isEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection(Collections.MESSAGES)
            .doc(controller.docId.value)
            .collection(Collections.CHAT)
            .orderBy(ChatField.TIME_STAMP, descending: true)
            .limit(20)
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection(Collections.MESSAGES)
            .doc(controller.docId.value)
            .collection(Collections.CHAT)
            .startAfterDocument(_chats[_chats.length - 1])
            .limit(20)
            .get();
      }

      List<DocumentSnapshot> newMessages = querySnapshot.docs;

      // Filter out messages that already exist in _chats
      newMessages.removeWhere((newMessage) => _chats.any((existingMessage) => newMessage.id == existingMessage.id));

      // Insert the new messages at the end of the list
      _chats.addAll(newMessages);

      if (querySnapshot.docs.isNotEmpty) {
        // Notify the StreamController with the updated _chats list
        _streamController.add(_chats);
      } else {
        // If there are no new messages, finish pagination
        _isFinish = true;
      }

      _isRequesting = false;
    }
  }

  Future<void> chatBottomSheet(BuildContext context, ChatController controller) {
    final picker = ImagePicker();

    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //.................Camera
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      controller.fileImage.value = pickedFile;
                      Navigator.pop(context);
                      await controller.sendMessage();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 2, color: black)),
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
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      controller.fileImage.value = pickedFile;
                      Navigator.pop(context);
                      await controller.sendMessage();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 2, color: black)),
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
