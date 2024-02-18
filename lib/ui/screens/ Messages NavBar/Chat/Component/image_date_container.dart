import 'package:check_in/utils/DateTimeUtils.dart';
import 'package:check_in/utils/loader.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../model/Message and Group Message Model/chat_model.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/gaps.dart';
import '../../../../../utils/styles.dart';

// ignore: must_be_immutable
class ImageDateContainer extends StatefulWidget {
  // int? index;
  Chatmodel? chat;
  bool? mymsg;
  bool? showLastSeen;

  bool? isGroup;
  ImageDateContainer(
      {super.key,
      // this.index,
      this.chat,
      this.mymsg,
      this.showLastSeen,
      this.isGroup});

  @override
  State<ImageDateContainer> createState() => _ImageDateContainerState();
}

class _ImageDateContainerState extends State<ImageDateContainer> {
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   setState(() {
  //
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    String timeseperate = widget.chat!.time!.split(' ')[1];
    String time = DateTimeUtils.time24to12(timeseperate);
    return Column(
      crossAxisAlignment: widget.mymsg! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          width: 40.w,
          decoration: BoxDecoration(
              color: appGreenColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: appGreenColor, width: 2)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: widget.chat!.thumbnail!,
              fit: BoxFit.cover,
              placeholder: (context, url) => loaderView(loaderColor: whiteColor),
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
        // widget.chat!.seenTimeStamp != '' && widget.showLastSeen == true && widget.isGroup == false
        //     ? Container(
        //         padding: const EdgeInsets.all(5),
        //         decoration: BoxDecoration(
        //           border: Border.all(),
        //           borderRadius: BorderRadius.circular(15),
        //         ),
        //         child: poppinsText("Seen ${widget.seenTime}", 9, medium, greyColor),
        //       )
        //     : const SizedBox()
      ],
    );
  }
}
