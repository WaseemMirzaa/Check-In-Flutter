import 'package:check_in/utils/DateTimeUtils.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../model/chat_model.dart';
import '../../../../../utils/chat_customshape.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/gaps.dart';
import '../../../../../utils/styles.dart';

// ignore: must_be_immutable
class MessageDateContainer extends StatelessWidget {
  int? index;
  Chatmodel? chat;
  bool? mymsg;
  MessageDateContainer({super.key, this.index, this.chat, this.mymsg});

  @override
  Widget build(BuildContext context) {
    String timeseperate = chat!.time!.split(' ')[1];
    String time = DateTimeUtils.time24to12(timeseperate);
    // String dateseperate = chat!.time!.split(' ')[0];
    // String date = DateTimeUtils.formatTimestamp(c);
    return Column(
      crossAxisAlignment:
          mymsg! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            mymsg!
                ? const SizedBox()
                : CustomPaint(
                    painter: CustomShape(bgcolor: greyColor1.withOpacity(1)),
                  ),
            Container(
              constraints: BoxConstraints(maxWidth: 65.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(15),
                    topRight: const Radius.circular(15),
                    bottomLeft: Radius.circular(mymsg! ? 15 : 0),
                    bottomRight: Radius.circular(mymsg! ? 0 : 15)),
                color: mymsg! ? greenColor : greyColor1.withOpacity(1),
              ),
              padding: const EdgeInsets.all(15),
              child: poppinsText(chat!.message!, 12, FontWeight.normal,
                  mymsg! ? whiteColor : greyColor.withOpacity(1)),
            ),
            mymsg!
                ? CustomPaint(
                    painter: CustomShape(bgcolor: greenColor),
                  )
                : const SizedBox()
          ],
        ),
        verticalGap(8),
        Row(
          children: [
            poppinsText(time, 10, medium, greyColor.withOpacity(1)),
            horizontalGap(5),
            mymsg!
                ? poppinsText('✓', 10, medium, greyColor.withOpacity(1))
                : const SizedBox(),
            horizontalGap(5),
            mymsg!
                ? const CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
                    radius: 8,
                  )
                : const SizedBox()
          ],
        )
      ],
    );
  }
}
