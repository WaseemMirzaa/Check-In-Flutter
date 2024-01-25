import 'dart:async';

import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/Message%20and%20Group%20Message%20Model/chat_model.dart';
import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/Component/image_date_container.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/Component/message_date_container.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

import '../../../../model/Message and Group Message Model/message_model.dart';
import '../../../../utils/Constants/enums.dart';
import '../../../../utils/styles.dart';
import '../Group Detail/group_detail.dart';
import 'Component/appbar.dart';
import 'Component/button.dart';
import 'Component/image_bottomsheet.dart';
import 'Component/send_message_container.dart';
import 'Component/sticker_keyboard.dart';

final chatQuery = FirebaseFirestore.instance
    .collection(Collections.MESSAGES)
    .withConverter<Chatmodel>(
      fromFirestore: (snapshot, options) =>
          Chatmodel.fromJson(snapshot.data()!),
      toFirestore: (value, options) => value.toJson(),
    );

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

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

  bool _isRequesting = false;
  bool _isFinish = false;

  void onChangeData(List<DocumentChange> documentChanges) {
    try {
      controller.chatService.updateUnreadCount(controller.docId.value, userController.userModel.value.uid!, 0);

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
    _subscription = FirebaseFirestore.instance
        .collection(Collections.MESSAGES)
        .doc(controller.docId.value)
        .collection(Collections.CHAT)
        .orderBy(ChatField.TIME_STAMP, descending: true)
        .snapshots()
        .listen((data) => onChangeData(data.docChanges));

    requestNextPage();

    startTimer();
  }

  @override
  void dispose() {
    stopTimer();
    _subscription?.cancel();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppbar(
          name: controller.name,
          isgroup: controller.isgroup,
          image: controller.image,
          ontap: controller.isgroup
              ? () {
                  pushNewScreen(context, screen: GroupdetailScreen(docId: controller.docId.value)).then((_) => null);
                }
              : () {
                  // controller.updateLastSeenMethod();
                }),
      body: Column(
          children: [
           Expanded(
        child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.maxScrollExtent ==
                  scrollInfo.metrics.pixels) {
                requestNextPage();
              }
              return true;
            },
            child: StreamBuilder<List<DocumentSnapshot>>(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return loaderView();
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(TempLanguage.noConversation));
                  } else {
                    List<Chatmodel> chats = snapshot.data
                            ?.map((snapshot) => Chatmodel.fromJson(
                                snapshot.data() as Map<String, dynamic>))
                            .toList() ??
                        [];

                    // Find the last seen message
                    var lastSeenMessage = chats.firstWhere(
                        (message) =>
                            message.seenTimeStamp != "" &&
                            message.id == userController.userModel.value.uid,
                        orElse: () => Chatmodel());

                    return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 10),
                        reverse: true,
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final Chatmodel chat = chats[index];
                          print(chat);
                          // Check if the current message is the last seen message
                          bool showLastSeen = chats[index] == lastSeenMessage;

                          String seenTime = '';
                          // var chat = snapshot.data![index];
                          bool mymsg =
                              chat.id == userController.userModel.value.uid
                                  ? true
                                  : false;
                          if (chat.seenTimeStamp != '') {
                            DateTime dateTime =
                                DateTime.parse(chat.seenTimeStamp!);
                            seenTime =
                                DateFormat('d MMM hh:mm a').format(dateTime);
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
                                        padding:
                                            const EdgeInsets.only(bottom: 22.0),
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
                                        // index: index,
                                        chat: chat,
                                        mymsg: mymsg,
                                        showLastSeen: showLastSeen,
                                        seenTime: seenTime,
                                        isGroup: controller.isgroup)
                                    : GestureDetector(
                                        onTap: () {
                                          showGeneralDialog(
                                              barrierColor: greyColor,
                                              context: context,
                                              pageBuilder: (context, animation,
                                                  secondaryAnimation) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 40.0),
                                                  child: Image.network(
                                                      chat.message!),
                                                );
                                              });
                                        },
                                        child: ImageDateContainer(
                                          // index: index,
                                          chat: chat,
                                          mymsg: mymsg,
                                          seenTime: seenTime,
                                          showLastSeen: showLastSeen,
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
                                        controller.sendNotificationMethod('',
                                            '${userController.userModel.value.userName!} block you');
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
                                        controller.sendNotificationMethod('',
                                            '${userController.userModel.value.userName!} delete message request');
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
                                        controller.sendNotificationMethod('',
                                            '${userController.userModel.value.userName!} accept request');
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
                                controller.sendNotificationMethod('',
                                    '${userController.userModel.value.userName!} send a request message');
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
                                controller.sendNotificationMethod('',
                                    "${userController.userModel.value.userName!} unblock you");
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
                        sendmsgontap: () async {
                          if (controller.chatfieldController.text.isNotEmpty) {
                            DocumentSnapshot? newMessageDoc = await controller.sendMessage();
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
        ]
      )
    );
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

      int oldSize = _chats.length;
      _chats.addAll(querySnapshot.docs);
      int newSize = _chats.length;
      if (oldSize != newSize) {
        _streamController.add(_chats);
      } else {
        _isFinish = true;
      }
      _isRequesting = false;
    }
  }
}

///previous code
// class _ChatScreenState extends State<ChatScreen> {
//   // RxString? name;
//   // bool? isGroup;
//   // RxString? image;
//   // RxList? memberId;
//   // RxString? senderName;
//   // ChatScreen({super.key}
//   // {super.key,
//   // this.name,
//   // this.isGroup,
//   // this.image,
//   // this.memberId,
//   // this.senderName}
//   // );
// //



//   var userController = Get.find<UserController>();
//   var controller = Get.find<ChatController>();
//   Timer? timer;
//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//   }

//   void startTimer() {
//     timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
//       controller.updateLastSeenMethod();
//     });
//   }

//   void stopTimer() {
//     if (timer != null) {
//       timer!.cancel();
//     }
//   }

//   @override
//   void dispose() {
//     stopTimer();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     //  for update last seen
//     // controller.updateLastSeenMethod();
//     return Scaffold(
//       appBar: ChatAppbar(
//           name: controller.name,
//           isgroup: controller.isgroup,
//           image: controller.image,
//           ontap: controller.isgroup
//               ? () {
//                   pushNewScreen(context,
//                           screen:
//                               GroupdetailScreen(docId: controller.docId.value))
//                       .then((_) => null);
//                 }
//               : () {
//                   // controller.updateLastSeenMethod();
//                 }),
//       body: Column(
//         children: [
//           Expanded(
//               child: FirestoreListView(
//                   reverse: true,
//                   query: chatQuery
//                       .doc(controller.docId.value)
//                       .collection(Collections.CHAT)
//                       .orderBy(ChatField.TIME_STAMP, descending: true),
//                   pageSize: 10,
//                   emptyBuilder: (context) =>
//                       const Center(child: Text('no data')),
//                   errorBuilder: (context, error, stackTrace) =>
//                       const Center(child: Text('error')),
//                   loadingBuilder: (context) =>
//                       const Center(child: CircularProgressIndicator()),
//                   itemBuilder: (context, snapshot) {
//                     Chatmodel chatmodel = Chatmodel.fromJson(snapshot.data());

//                     // var lastSeenMessage = snapshot.data().firstWhere(
//                     //     (message) =>
//                     //         message.seenTimeStamp != "" &&
//                     //         message.id == userController.userModel.value.uid,
//                     //     orElse: () => Chatmodel());    
                
//                     var lastSeenMessage = chatmodel.seenTimeStamp != '' &&
//                             chatmodel.id == userController.userModel.value.uid 
//                         ? chatmodel
//                         : Chatmodel();

//                     // Check if the current message is the last seen message
//                     bool showLastSeen = chatmodel == lastSeenMessage;

//                     String seenTime = '';
//                     var chat = chatmodel;
//                     bool mymsg = chat.id == userController.userModel.value.uid
//                         ? true
//                         : false;
//                     if (chat.seenTimeStamp != '') {
//                       DateTime dateTime = DateTime.parse(chat.seenTimeStamp!);
//                       seenTime = DateFormat('d MMM hh:mm a').format(dateTime);
//                     }
//                     return Padding(
//                       padding: EdgeInsets.only(
//                         left: mymsg ? 0 : 14,
//                         right: mymsg ? 14 : 0,
//                         top: 12,
//                       ),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         mainAxisAlignment: mymsg
//                             ? MainAxisAlignment.end
//                             : MainAxisAlignment.start,
//                         children: [
//                           mymsg
//                               ? const SizedBox()
//                               : Padding(
//                                   padding: const EdgeInsets.only(bottom: 22.0),
//                                   child: CircleAvatar(
//                                     backgroundColor:
//                                         greenColor.withOpacity(0.6),
//                                     backgroundImage: AssetImage(AppImage.user),
//                                     radius: 17,
//                                   ),
//                                 ),
//                           horizontalGap(8),
//                           chat.type == 'message'
//                               ? MessageDateContainer(
//                                   // index: index,
//                                   chat: chat,
//                                   mymsg: mymsg,
//                                   showLastSeen: showLastSeen,
//                                   seenTime: seenTime,
//                                   isGroup: controller.isgroup)
//                               : GestureDetector(
//                                   onTap: () {
//                                     showGeneralDialog(
//                                         barrierColor: greyColor,
//                                         context: context,
//                                         pageBuilder: (context, animation,
//                                             secondaryAnimation) {
//                                           return Padding(
//                                             padding: const EdgeInsets.only(
//                                                 top: 40.0),
//                                             child: Image.network(chat.message!),
//                                           );
//                                         });
//                                   },
//                                   child: ImageDateContainer(
//                                     // index: index,
//                                     chat: chat,
//                                     mymsg: mymsg,
//                                     seenTime: seenTime,
//                                     showLastSeen: showLastSeen,
//                                   ),
//                                 )
//                         ],
//                       ),
//                     );
//                   })),

//           //  StreamBuilder<List<Chatmodel>>(
//           //     stream: controller.getConversation(),
//           //     builder: (context, snapshot) {
//           //       if (snapshot.connectionState == ConnectionState.waiting) {
//           //         return loaderView();
//           //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           //         return Center(child: Text(TempLanguage.noConversation));
//           //       } else {
//           //         // Find the last seen message
//           // var lastSeenMessage = snapshot.data!.firstWhere(
//           //     (message) =>
//           //         message.seenTimeStamp != "" &&
//           //         message.id == userController.userModel.value.uid,
//           //     orElse: () => Chatmodel());
//           //         return ListView.builder(
//           //             padding: const EdgeInsets.only(bottom: 10),
//           //             reverse: true,
//           //             itemCount: snapshot.data!.length,
//           //             itemBuilder: (context, index) {
//           //               // Check if the current message is the last seen message
//           //               bool showLastSeen =
//           //                   snapshot.data![index] == lastSeenMessage;

//           //               String seenTime = '';
//           //               var chat = snapshot.data![index];
//           //               bool mymsg =
//           //                   chat.id == userController.userModel.value.uid
//           //                       ? true
//           //                       : false;
//           //               if (chat.seenTimeStamp != '') {
//           //                 DateTime dateTime =
//           //                     DateTime.parse(chat.seenTimeStamp!);
//           //                 seenTime =
//           //                     DateFormat('d MMM hh:mm a').format(dateTime);
//           //               }
//           //               return Padding(
//           //                 padding: EdgeInsets.only(
//           //                   left: mymsg ? 0 : 14,
//           //                   right: mymsg ? 14 : 0,
//           //                   top: 12,
//           //                 ),
//           //                 child: Row(
//           //                   crossAxisAlignment: CrossAxisAlignment.end,
//           //                   mainAxisAlignment: mymsg
//           //                       ? MainAxisAlignment.end
//           //                       : MainAxisAlignment.start,
//           //                   children: [
//           //                     mymsg
//           //                         ? const SizedBox()
//           //                         : Padding(
//           //                             padding: const EdgeInsets.only(
//           //                                 bottom: 22.0),
//           //                             child: CircleAvatar(
//           //                               backgroundColor:
//           //                                   greenColor.withOpacity(0.6),
//           //                               backgroundImage:
//           //                                   AssetImage(AppImage.user),
//           //                               radius: 17,
//           //                             ),
//           //                           ),
//           //                     horizontalGap(8),
//           //                     chat.type == 'message'
//           //                         ? MessageDateContainer(
//           //                             index: index,
//           //                             chat: chat,
//           //                             mymsg: mymsg,
//           //                             showLastSeen: showLastSeen,
//           //                             seenTime: seenTime,
//           //                             isGroup: controller.isgroup)
//           //                         : GestureDetector(
//           //                             onTap: () {
//           //                               showGeneralDialog(
//           //                                   barrierColor: greyColor,
//           //                                   context: context,
//           //                                   pageBuilder: (context,
//           //                                       animation,
//           //                                       secondaryAnimation) {
//           //                                     return Padding(
//           //                                       padding:
//           //                                           const EdgeInsets.only(
//           //                                               top: 40.0),
//           //                                       child: Image.network(
//           //                                           chat.message!),
//           //                                     );
//           //                                   });
//           //                             },
//           //                             child: ImageDateContainer(
//           //                               index: index,
//           //                               chat: chat,
//           //                               mymsg: mymsg,
//           //                               seenTime: seenTime,
//           //                               showLastSeen: showLastSeen,
//           //                             ),
//           //                           )
//           //                   ],
//           //                 ),
//           //               );
//           //             });
//           //       }
//           //     })),

//           //.....





          // // for show request status dialog
          // StreamBuilder<Messagemodel>(
          //     stream: controller.getRequestStatus(),
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return const SizedBox();
          //       } else if (!snapshot.hasData) {
          //         return const Center(child: Text(''));
          //       } else {
          //         if (snapshot.data!.senderId ==
          //                 controller.userController.userModel.value.uid &&
          //             snapshot.data!.requestStatus ==
          //                 RequestStatusEnum.pending.name) {
          //           return Container(
          //             // height: 160,
          //             width: 50.w,
          //             padding: const EdgeInsets.all(13),
          //             margin: const EdgeInsets.all(10),
          //             decoration: BoxDecoration(
          //               color: whiteColor,
          //               borderRadius: BorderRadius.circular(10),
          //               boxShadow: [
          //                 BoxShadow(
          //                   color: blackTranslucentColor,
          //                   offset: const Offset(0, 1),
          //                   blurRadius: 6,
          //                 ),
          //               ],
          //             ),
          //             child: Column(
          //               children: [
          //                 poppinsText(
          //                     TempLanguage.inviteSent, 15, medium, blackColor),
          //               ],
          //             ),
          //           );
          //         } else if (snapshot.data!.senderId !=
          //                 controller.userController.userModel.value.uid &&
          //             snapshot.data!.requestStatus ==
          //                 RequestStatusEnum.pending.name) {
          //           return Container(
          //             // height: 160,
          //             width: 80.w,
          //             padding: const EdgeInsets.all(13),
          //             margin: const EdgeInsets.all(10),
          //             decoration: BoxDecoration(
          //               color: whiteColor,
          //               borderRadius: BorderRadius.circular(10),
          //               boxShadow: [
          //                 BoxShadow(
          //                   color: blackTranslucentColor,
          //                   offset: const Offset(0, 1),
          //                   blurRadius: 6,
          //                 ),
          //               ],
          //             ),
          //             child: Column(
          //               children: [
          //                 poppinsText(
          //                     "${TempLanguage.acceptMessageRequest} ${snapshot.data!.senderName}?",
          //                     14,
          //                     medium,
          //                     blackColor,
          //                     maxlines: 2),
          //                 verticalGap(15),
          //                 Row(
          //                   children: [
          //                     Flexible(
          //                         child: ChatButton(
          //                       onTap: () {
          //                         controller.updateRequestStatus(
          //                             RequestStatusEnum.block.name, '', 0);
          //                         controller.sendNotificationMethod('',
          //                             '${userController.userModel.value.userName!} block you');
          //                       },
          //                       text: TempLanguage.block,
          //                       textColor: redColor,
          //                       buttonColor: greyColor.withOpacity(0.7),
          //                     )),
          //                     horizontalGap(2.w),
          //                     Flexible(
          //                         child: ChatButton(
          //                       onTap: () async {
          //                         controller.updateRequestStatus(
          //                             RequestStatusEnum.delete.name, '', 0);
          //                         Get.back();
          //                         controller.sendNotificationMethod('',
          //                             '${userController.userModel.value.userName!} delete message request');
          //                       },
          //                       text: TempLanguage.delete,
          //                       textColor: redColor,
          //                       buttonColor: greyColor.withOpacity(0.7),
          //                     )),
          //                     horizontalGap(2.w),
          //                     Flexible(
          //                         child: ChatButton(
          //                       onTap: () {
          //                         controller.updateRequestStatus(
          //                             RequestStatusEnum.accept.name, '', 0);
          //                         controller.sendNotificationMethod('',
          //                             '${userController.userModel.value.userName!} accept request');
          //                       },
          //                       text: TempLanguage.accept,
          //                       textColor: whiteColor,
          //                       buttonColor: greyColor.withOpacity(0.7),
          //                     )),
          //                   ],
          //                 )
          //               ],
          //             ),
          //           );
          //         } else {
          //           return const SizedBox();
          //         }
          //       }
          //     }),
          // StreamBuilder<Messagemodel>(
          //     stream: controller.getRequestStatus(),
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return const SizedBox();
          //       } else if (!snapshot.hasData) {
          //         return const Center(child: Text(''));
          //       } else {
          //         if (snapshot.data!.senderId ==
          //                 controller.userController.userModel.value.uid &&
          //             snapshot.data!.requestStatus ==
          //                 RequestStatusEnum.delete.name) {
          //           return Container(
          //             // height: 160,
          //             // width: 50.w,
          //             padding: const EdgeInsets.all(13),
          //             decoration: BoxDecoration(
          //               color: whiteColor,
          //               borderRadius: BorderRadius.circular(10),
          //               boxShadow: [
          //                 BoxShadow(
          //                   color: blackTranslucentColor,
          //                   offset: const Offset(0, 1),
          //                   blurRadius: 6,
          //                 ),
          //               ],
          //             ),
          //             child: Row(
          //               children: [
          //                 Expanded(
          //                   child: poppinsText(
          //                       "${TempLanguage.requestDeleted} ${snapshot.data!.recieverName}",
          //                       15,
          //                       medium,
          //                       blackColor),
          //                 ),
          //                 ChatButton(
          //                   width: 35.w,
          //                   onTap: () {
          //                     controller.updateRequestStatus(
          //                         RequestStatusEnum.pending.name,
          //                         TempLanguage.messageRequest,
          //                         1);
          //                     controller.sendNotificationMethod('',
          //                         '${userController.userModel.value.userName!} send a request message');
          //                   },
          //                   text: "${TempLanguage.requestAgain} ",
          //                   buttonColor: greenColor,
          //                   textColor: whiteColor,
          //                 )
          //               ],
          //             ),
          //           );
          //         } else if (snapshot.data!.senderId ==
          //                 controller.userController.userModel.value.uid &&
          //             snapshot.data!.requestStatus ==
          //                 RequestStatusEnum.block.name) {
          //           return Container(
          //             // height: 160,
          //             // width: 50.w,
          //             padding: const EdgeInsets.all(13),
          //             decoration: BoxDecoration(
          //               color: whiteColor,
          //               borderRadius: BorderRadius.circular(10),
          //               boxShadow: [
          //                 BoxShadow(
          //                   color: blackTranslucentColor,
          //                   offset: const Offset(0, 1),
          //                   blurRadius: 6,
          //                 ),
          //               ],
          //             ),
          //             child: Row(
          //               children: [
          //                 Expanded(
          //                   child: poppinsText(
          //                       " ${snapshot.data!.recieverName} ${TempLanguage.blockedYou}",
          //                       15,
          //                       medium,
          //                       blackColor,
          //                       align: TextAlign.center),
          //                 ),
          //               ],
          //             ),
          //           );
          //         } else if (snapshot.data!.senderId !=
          //                 controller.userController.userModel.value.uid &&
          //             snapshot.data!.requestStatus ==
          //                 RequestStatusEnum.block.name) {
          //           return Container(
          //             // height: 160,
          //             width: double.infinity,
          //             padding: const EdgeInsets.all(13),
          //             decoration: BoxDecoration(
          //               color: whiteColor,
          //               borderRadius: BorderRadius.circular(10),
          //               boxShadow: [
          //                 BoxShadow(
          //                   color: blackTranslucentColor,
          //                   offset: const Offset(0, 1),
          //                   blurRadius: 6,
          //                 ),
          //               ],
          //             ),
          //             child: Column(
          //               children: [
          //                 poppinsText(TempLanguage.youBlockThisAccount, 15,
          //                     medium, blackColor),
          //                 verticalGap(10),
          //                 ChatButton(
          //                   width: 35.w,
          //                   onTap: () {
          //                     controller.updateRequestStatus(
          //                         RequestStatusEnum.accept.name, '', 0);
          //                     controller.sendNotificationMethod('',
          //                         "${userController.userModel.value.userName!} unblock you");
          //                   },
          //                   text: "${TempLanguage.unblock} ",
          //                   buttonColor: greenColor,
          //                   textColor: whiteColor,
          //                 )
          //               ],
          //             ),
          //           );
          //         } else {
          //           return SendMessageContainer(
          //             textFieldController: controller.chatfieldController,
          //             imageontap: () {
          //               showchatbottomSheet(context, controller);
          //             },
          //             textfieldontap: () {
          //               controller.issticker.value = true;
          //             },
          //             iconontap: () {
          //               controller.issticker.value =
          //                   !controller.issticker.value;
          //               FocusManager.instance.primaryFocus?.unfocus();
          //             },
          //             sendmsgontap: () {
          //               if (controller.chatfieldController.text.isNotEmpty) {
          //                 controller.sendMessage();
          //                 controller.sendNotificationMethod(
          //                     '', controller.chatfieldController.text);
          //                 controller.chatfieldController.clear();
          //               }
          //             },
          //           );
          //         }
          //       }
          //     }),
          // Obx(() => Offstage(
          //       offstage: controller.issticker.value,
          //       child: StickerKeyboard(
          //         controller: controller.chatfieldController,
          //       ),
          //     ))
        // ],
//       ),
//     );
//   }
// }
///previous code