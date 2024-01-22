import 'package:check_in/utils/DateTimeUtils.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../model/Message and Group Message Model/chat_model.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/gaps.dart';
import '../../../../../utils/styles.dart';

// ignore: must_be_immutable
class ImageDateContainer extends StatelessWidget {
  int? index;
  Chatmodel? chat;
  bool? mymsg;
  bool? showLastSeen;
  String? seenTime;
  bool? isGroup;
  ImageDateContainer(
      {super.key,
      this.index,
      this.chat,
      this.mymsg,
      this.seenTime,
      this.showLastSeen,
      this.isGroup});

  @override
  Widget build(BuildContext context) {
    String timeseperate = chat!.time!.split(' ')[1];
    String time = DateTimeUtils.time24to12(timeseperate);
    return Column(
      crossAxisAlignment:
          mymsg! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          width: 40.w,
          decoration: BoxDecoration(
              color: greenColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: greenColor, width: 2)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: chat!.message!,
              fit: BoxFit.cover,
            ),
          ),
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
            //         backgroundImage: CachedNetworkImageProvider(
            //             'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
            //         radius: 8,
            //       )
            //     : const SizedBox()
          ],
        ),
        chat!.seenTimeStamp != '' && showLastSeen == true && isGroup == false
            ? Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: poppinsText("Seen $seenTime", 9, medium, greyColor),
              )
            : const SizedBox()
      ],
    );
  }
}
