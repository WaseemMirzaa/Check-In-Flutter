import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/All%20Comments/all_comments.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/All%20Likes/all_likes_screen.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/Full%20Screen%20Image/full_screen_image.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/comment_container.dart';
import 'package:check_in/ui/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/custom_paint.dart';
import 'package:check_in/ui/widgets/custom_container.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

class ListTileContainer extends GetView<NewsFeedController> {
  const ListTileContainer({super.key});

  @override
  Widget build(BuildContext context) {
    RxBool isVisible = false.obs;
    RxBool isLike = false.obs;
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
                  12,
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
                  poppinsText('30 ', 11, medium, darkBlue),
                  poppinsText('comments . ', 11, medium, darkBlue),
                  poppinsText('5 ', 11, medium, darkBlue),
                  poppinsText('shared', 11, medium, darkBlue),
                ],
              ),
            ),
            verticalGap(15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        isLike.value = !isLike.value;
                      },
                      child: Obx(() => isLike.value
                          ? CircleAvatar(
                              radius: 11,
                              backgroundColor: greenColor,
                              child: SvgPicture.asset(
                                AppImage.like,
                                color: whiteColor,
                                height: 10,
                              ),
                            )
                          : SvgPicture.asset(
                              AppImage.like,
                              height: 18,
                            ))),
                  horizontalGap(8.w),
                  GestureDetector(
                    onTap: () {
                      isVisible.value = !isVisible.value;
                    },
                    child: SvgPicture.asset(
                      AppImage.comment,
                      height: 16,
                    ),
                  ),
                  horizontalGap(8.w),
                  GestureDetector(
                    onTap: () {
                      Share.share('news feed post');
                    },
                    child: SvgPicture.asset(
                      AppImage.share,
                      height: 16,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                      onTap: () {
                        pushNewScreen(context, screen: const AllLikesScreen());
                      },
                      child: poppinsText(
                          'Liked by 50 People', 11, medium, greyColor)),
                  horizontalGap(2.w),
                  SvgPicture.asset(
                    AppImage.multiplelike,
                    height: 16,
                  ),
                ],
              ),
            ),
            verticalGap(8),
            const Divider(),
            verticalGap(7),
            Obx(() => Visibility(
                visible: isVisible.value,
                child: Column(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            color: greyColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: CustomTextfield1(
                          suffixIcon: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: SvgPicture.asset(
                              AppImage.messageappbaricon,
                              color: greenColor,
                            ),
                          ),
                          hintText: 'Write a comment',
                        )),
                    const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: CommentContainer()),
                    const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: CommentContainer()),
                    verticalGap(10),
                    Divider(
                      color: greyColor,
                      indent: 20.w,
                      endIndent: 20.w,
                    ),
                    verticalGap(10),
                    GestureDetector(
                        onTap: () {
                          pushNewScreen(context,
                              screen: const AllCommentsScreen());
                        },
                        child: poppinsText('Show more', 15, bold, greenColor))
                  ],
                )))
          ],
        ),
      ),
    );
  }
}
