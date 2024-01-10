import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/ui/widgets/custom_container.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../../utils/colors.dart';

class TopContainer extends GetView<NewsFeedController> {
  Function()? ontap;
  TopContainer({super.key, this.ontap});

  @override
  Widget build(BuildContext context) {
    return CustomContainer1(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(children: [
              const CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365',
                ),
              ),
              horizontalGap(10),
              Expanded(
                child: Container(
                  width: 50.w,
                  decoration: BoxDecoration(
                      color: greyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25)),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    readOnly: true,
                    onTap: ontap,
                    onTapOutside: (_) {
                      controller.postFocusNode.unfocus();
                    },
                    decoration: InputDecoration(
                        hintText: 'Write something...',
                        hintStyle: TextStyle(
                            fontSize: 12,
                            color: blackColor.withOpacity(0.5),
                            fontWeight: medium),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none),
                  ),
                ),
              )
            ]),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                children: [
                  SvgPicture.asset(AppImage.camera),
                  horizontalGap(5),
                  poppinsText('Photo', 12, regular, greyColor),
                  horizontalGap(10.w),
                  SvgPicture.asset(AppImage.video),
                  horizontalGap(5),
                  poppinsText('Video', 12, regular, greyColor)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
