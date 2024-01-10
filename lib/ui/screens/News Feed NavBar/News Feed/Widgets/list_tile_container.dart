import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/Full%20Screen%20Image/full_screen_image.dart';
import 'package:flutter/material.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Widgets/custom_paint.dart';
import 'package:check_in/ui/widgets/custom_container.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

class ListTileContainer extends GetView<NewsFeedController> {
  int? index;
  ListTileContainer({super.key, this.index});

  @override
  Widget build(BuildContext context) {
    return CustomContainer1(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 44,
                        width: 43,
                        child: CustomPaint(
                          painter: MyPainter(),
                          size: const Size(200, 200),
                        ),
                      ),
                      Positioned(
                        top: 1.5,
                        left: 1,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(
                                    'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
                              )),
                        ),
                      )
                    ],
                  ),
                  horizontalGap(10),
                  Expanded(
                    child: poppinsText(
                        'Daniela Fernández Rssssssss', 14, bold, darkBlue,
                        overflow: TextOverflow.ellipsis),
                  ),
                  horizontalGap(5),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: greyColor1),
                    child: Icon(
                      Icons.more_horiz,
                      color: greyColor,
                    ),
                  )
                ],
              ),
            ),
            verticalGap(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: poppinsText(
                  'Me encanto la sesión de fotos que me hizo mi amigo 😍🥺',
                  11,
                  medium,
                  darkBlue.withOpacity(0.8),
                  maxlines: 3),
            ),
            verticalGap(8),
            GestureDetector(
              onTap: () {
                pushNewScreen(context, screen: const FullScreenImage());
              },
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://img.freepik.com/free-vector/set-realistic-hoodies-mannequins-metal-poles-sweatshirt-model-with-long-sleeve_1441-2010.jpg?size=626&ext=jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            verticalGap(10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  poppinsText('30 ', 10, medium, darkBlue),
                  poppinsText('comments . ', 10, medium, darkBlue),
                  poppinsText('5 ', 10, medium, darkBlue),
                  poppinsText('shared', 10, medium, darkBlue),
                ],
              ),
            ),
            verticalGap(15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppImage.like,
                    height: 15,
                  ),
                  horizontalGap(8.w),
                  GestureDetector(
                    onTap: () {
                      controller.index = index!;
                    },
                    child: SvgPicture.asset(
                      AppImage.comment,
                      height: 15,
                    ),
                  ),
                  horizontalGap(8.w),
                  SvgPicture.asset(
                    AppImage.share,
                    height: 15,
                  ),
                  const Spacer(),
                  poppinsText('Liked by 50 People', 11, medium, greyColor),
                  horizontalGap(2.w),
                  SvgPicture.asset(
                    AppImage.multiplelike,
                    height: 14,
                  ),
                ],
              ),
            ),
            verticalGap(8),
            const Divider(),
         
          ],
        ),
      ),
    );
  }
}
