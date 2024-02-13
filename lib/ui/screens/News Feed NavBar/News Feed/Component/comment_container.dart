import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

class CommentContainer extends StatelessWidget {
  const CommentContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
              radius: 17,
            ),
            horizontalGap(10),
            Container(
                width: 50.w,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: darkBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: poppinsText('Hi Cassie! Would you be available ', 12,
                    medium, appBlackColor,
                    maxlines: 5))
          ],
        ),
        Container(
          margin: EdgeInsets.only(left: 10.w, top: 5),
          width: 52.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              poppinsText('8:07', 12, regular, greyColor),
              poppinsText('Like', 12, regular, greyColor),
              poppinsText('Reply', 12, regular, greyColor),
              Row(
                children: [
                  poppinsText('4', 12, regular, greyColor),
                  horizontalGap(5),
                  SvgPicture.asset(
                    AppImage.multiplelike,
                    height: 14,
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
