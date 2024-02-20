import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/utils/DateTimeUtils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sizer/sizer.dart';

import '../../../../../model/Message and Group Message Model/chat_model.dart';
import 'chat_customshape.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/gaps.dart';
import '../../../../../utils/styles.dart';

// ignore: must_be_immutable
class MessageDateContainer extends StatelessWidget {
  // int? index;
  Chatmodel? chat;
  bool? mymsg;
  bool? showLastSeen;
  bool? isGroup;
  MessageDateContainer(
      {super.key,
      // this.index,
      this.chat,
      this.mymsg,
      this.showLastSeen,
      this.isGroup});

  final chatController = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    String timeseperate = chat!.time!.split(' ')[1];
    String time = DateTimeUtils.time24to12(timeseperate);

    //....
    // String dateseperate = chat!.time!.split(' ')[0];
    // String date = DateTimeUtils.formatTimestamp(c);
    return Column(
      crossAxisAlignment: mymsg! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            chat!.isDelete == true
                ? const SizedBox()
                : mymsg!
                    ? const SizedBox()
                    : CustomPaint(
                        painter: CustomShape(bgcolor: greyColor1.withOpacity(1)),
                      ),
            InkWell(
              onLongPress: mymsg! && chat!.isDelete == null || chat!.isDelete == false
                  ? () {
                      showAdaptiveDialog(
                          context: context,
                          builder: (context) => AlertDialog.adaptive(
                                title: Text(
                                  'Delete Message',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: appBlackColor),
                                ),
                                content: Text('Do you want to delete this message?',
                                    style: TextStyle(fontWeight: FontWeight.w400, color: appBlackColor, fontSize: 14)),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('No')),
                                  TextButton(
                                      onPressed: () async {
                                        await chatController
                                            .deleteMessage(chatController.docId.value, chat!.docID!)
                                            .then((value) => Navigator.pop(context));
                                      },
                                      child: const Text('Yes'))
                                ],
                              ));
                    }
                  : null,
              child: chat!.isDelete == true
                  ? Container(
                      constraints: BoxConstraints(maxWidth: 65.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: chat!.isDelete == true
                            ? greyColor.withOpacity(0.3)
                            : mymsg!
                                ? appGreenColor
                                : greyColor1.withOpacity(1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        chat!.message!,
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: chat!.isDelete == true
                                  ? appWhiteColor
                                  : mymsg!
                                      ? appWhiteColor
                                      : greyColor.withOpacity(1)),
                        ),
                      ),
                    )
                  : Container(
                      constraints: BoxConstraints(maxWidth: 65.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15),
                            topRight: const Radius.circular(15),
                            bottomLeft: Radius.circular(mymsg! ? 15 : 0),
                            bottomRight: Radius.circular(mymsg! ? 0 : 15)),
                        color: chat!.isDelete == true
                            ? greyColor.withOpacity(0.2)
                            : mymsg!
                                ? appGreenColor
                                : greyColor1.withOpacity(1),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: poppinsText(
                          chat!.message!,
                          chatController.chatfieldController.value.text.isEmptyOrNull ? 12 : 18,
                          FontWeight.normal,
                          chat!.isDelete == true
                              ? appBlackColor.withOpacity(0.2)
                              : mymsg!
                                  ? appWhiteColor
                                  : greyColor.withOpacity(1)),
                    ),
            ),
            chat!.isDelete == true
                ? const SizedBox()
                : mymsg!
                    ? CustomPaint(
                        painter:
                            CustomShape(bgcolor: chat!.isDelete == true ? greyColor.withOpacity(0.2) : appGreenColor),
                      )
                    : const SizedBox()
          ],
        ),
        verticalGap(8),
        Row(
          children: [
            poppinsText(time, 10, medium, greyColor.withOpacity(1)),
            horizontalGap(5),
            // mymsg!
            //     ? poppinsText('✓', 10, medium, greyColor.withOpacity(1))
            //     : const SizedBox(),
            // horizontalGap(5),
            // mymsg!
            //     ? const CircleAvatar(
            //         backgroundImage: NetworkImage(
            //             'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
            //         radius: 8,
            //       )
            //     : const SizedBox()
          ],
        ),
        // chat!.seenTimeStamp != '' && showLastSeen == true && isGroup == false
        //     ? Container(
        //         padding: const EdgeInsets.all(5),
        //         decoration: BoxDecoration(
        //           border: Border.all(),
        //           borderRadius: BorderRadius.circular(15),
        //         ),
        //         child: poppinsText("Seen $seenTime", 9, medium, greyColor),
        //       )
        //     : const SizedBox()
      ],
    );
  }
}
