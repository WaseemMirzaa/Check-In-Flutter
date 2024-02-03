import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/comment_container.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/ui/widgets/text_field.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AllCommentsScreen extends StatelessWidget {
  const AllCommentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: Row(
          children: [
            SvgPicture.asset(
              AppImage.comment,
              height: 20,
            ),
            const Spacer(),
            poppinsText('Comments', 15, bold, blackColor),
            const Spacer(
              flex: 3,
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: 12,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 7.0, horizontal: 10),
                    child: CommentContainer(),
                  );
                }),
          ),
          Container(
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                    color: greyColor.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(1, 1))
              ],
            ),
            child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: greyColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomTextfield1(
                  hintText: 'Write a comment',
                  suffixIcon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: SvgPicture.asset(
                      AppImage.messageappbaricon,
                      color: greenColor,
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
