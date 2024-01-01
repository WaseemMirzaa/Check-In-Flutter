import 'package:check_in/ui/screens/%20Messages%20and%20Groupchat/Group%20Members/group_members.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

class GroupdetailScreen extends StatelessWidget {
  String? name;
  GroupdetailScreen({super.key, this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: poppinsText('Group Details', 20, bold, blackColor),
        actions: [
          GestureDetector(
              onTap: () {
                pushNewScreen(context, screen: const GroupMember());
              },
              child: Image.asset(AppImage.peopleicon))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            verticalGap(40),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                poppinsText(name ?? '', 19, bold, blackColor),
              ],
            ),
            const Divider(thickness: 2),
            verticalGap(26),
            const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
              radius: 60,
            ),
            verticalGap(60),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                poppinsText('About Group', 14, regular, blackColor),
              ],
            ),
            verticalGap(10),
            const Divider(thickness: 2),
            poppinsText(
                'Money Market Account MC0628040080652344038362089 3I1QM5CGNW9V9IUCK3VZGFG6YDAFFGR9R9 capacity Multi-tiered Granite 256.00 Licensed Plastic Keyboard 274.00 Generic Plastic Computer 756.00 Shoes magenta indigo 78683 617 Real G’s move in silence like lasagna.',
                14,
                regular,
                greyColor,
                align: TextAlign.center)
          ],
        ),
      ),
    );
  }
}
