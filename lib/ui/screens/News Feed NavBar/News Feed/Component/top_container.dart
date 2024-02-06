// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:check_in/controllers/News%20Feed/create_post_controller.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/Create%20Post/create_post_screen.dart';
import 'package:check_in/ui/widgets/custom_container.dart';
import 'package:check_in/ui/widgets/text_field.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

import '../../../../../utils/colors.dart';

class TopContainer extends GetView<NewsFeedController> {
  Function()? ontap;
  TopContainer({super.key, this.ontap});
  var createPostController = Get.find<CreatePostController>();
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
                  child: CustomTextfield1(
                    focusNode: controller.postFocusNode,
                    readOnly: true,
                    hintText: 'Write something...',
                    onTap: () {
                      createPostController.type.value = 'text';
                      pushNewScreen(context, screen: const CreatePost());
                    },
                    onTapOutside: (_) {
                      controller.postFocusNode.unfocus();
                    },
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
                  GestureDetector(
                      onTap: () async {
                        bool checkNavigate =
                            await createPostController.filePicker('image');
                        checkNavigate
                            ? pushNewScreen(context, screen: const CreatePost())
                            : null;
                      },
                      child: poppinsText('Photo', 12, regular, greyColor)),
                  horizontalGap(10.w),
                  SvgPicture.asset(AppImage.video),
                  horizontalGap(5),
                  GestureDetector(
                      onTap: () async {
                        bool checkNavigate =
                            await createPostController.filePicker('video');
                        checkNavigate
                            ? pushNewScreen(context, screen: const CreatePost())
                            : null;
                      },
                      child: poppinsText('Video', 12, regular, greyColor))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
