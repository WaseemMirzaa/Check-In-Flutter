import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

class CreatePost extends StatelessWidget {
  const CreatePost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 35.0),
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: greenColor,
          label: Row(
            children: [
              poppinsText('Send', 12, FontWeight.normal, whiteColor),
              horizontalGap(20),
              SvgPicture.asset(
                AppImage.messageappbaricon,
                color: whiteColor,
              ),
            ],
          ),
        ),
      ),
      appBar: CustomAppbar(
        title: poppinsText('Create Post', 15, FontWeight.bold, blackColor),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                verticalGap(10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365',
                        ),
                        radius: 30,
                      ),
                      horizontalGap(20),
                      poppinsText('Julian Dasilva', 18, bold, blackColor)
                    ],
                  ),
                ),
                verticalGap(8),
                Divider(
                  color: greyColor,
                ),
                const TextField(
                  maxLines: 6,
                  decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      border: InputBorder.none),
                )
              ],
            ),
          ),
          Divider(
            color: greyColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppImage.camera,
                  height: 13,
                  width: 14,
                ),
                horizontalGap(5),
                poppinsText('Photo', 13, medium, greyColor),
                horizontalGap(10.w),
                SvgPicture.asset(
                  AppImage.video,
                  height: 12,
                  width: 13,
                ),
                horizontalGap(5),
                poppinsText('Video', 13, medium, greyColor)
              ],
            ),
          )
        ],
      ),
    );
  }
}
