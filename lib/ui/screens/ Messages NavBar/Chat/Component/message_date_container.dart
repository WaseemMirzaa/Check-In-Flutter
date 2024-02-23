import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
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
    List<InlineSpan> spans = [];

    for (int runeValue in chat!.message!.runes) {
      final character = String.fromCharCode(runeValue);
      final isEmoji = isEmojiCharacter(runeValue);

      spans.add(TextSpan(
        text: character,
        style: TextStyle(fontSize: isEmoji ? 16 : 12), // Set font size based on character type
      ));
    }
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
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
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
                      padding: const EdgeInsets.all(12),
                      child: RichText(
                        text: TextSpan(
                          children: spans,
                          style: TextStyle(
                            fontFamily: TempLanguage.poppins,
                            fontWeight: FontWeight.normal,
                            color: chat!.isDelete == true
                                ? appBlackColor.withOpacity(0.2)
                                : mymsg!
                                    ? appWhiteColor
                                    : greyColor.withOpacity(1),
                          ),
                        ),
                      )

                      // poppinsText(
                      //     chat!.message!,
                      //     12,
                      //     FontWeight.normal,
                      //     chat!.isDelete == true
                      //         ? appBlackColor.withOpacity(0.2)
                      //         : mymsg!
                      //             ? appWhiteColor
                      //             : greyColor.withOpacity(1)),
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

  bool containsSpecialCharacters(String message) {
    RegExp specialChars = RegExp(r'[^\w\s]');
    return specialChars.hasMatch(message);
  }

  bool containsAlphanumeric(String message) {
    RegExp alphanumeric = RegExp(r'[a-zA-Z0-9]');
    return alphanumeric.hasMatch(message);
  }

  int determineFontSize(String message) {
    if (containsSpecialCharacters(message) || containsAlphanumeric(message)) {
      return 14; // Set font size to 14 if message contains alphanumeric or special characters
    } else {
      return 20; // Set font size to 20 otherwise
    }
  }

  bool isEmojiCharacter(int codePoint) {
    // Check if the code point represents an emoji
    return (codePoint >= 0x1F600 && codePoint <= 0x1F64F) ||
        (codePoint >= 0x1F300 && codePoint <= 0x1F5FF) ||
        (codePoint >= 0x1F680 && codePoint <= 0x1F6FF) ||
        (codePoint >= 0x2600 && codePoint <= 0x26FF) ||
        (codePoint >= 0x2700 && codePoint <= 0x27BF);
  }
}
