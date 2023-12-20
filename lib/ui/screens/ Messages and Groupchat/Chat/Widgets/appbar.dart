import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

import '../../../../../utils/Constants/images.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/gaps.dart';
import '../../../../../utils/styles.dart';
import '../../../../widgets/custom_appbar.dart';
import '../../Group Detail/group_detail.dart';

class ChatAppbar extends StatelessWidget implements PreferredSizeWidget {
  String? name;
  bool? isgroup;
  ChatAppbar({super.key, this.name, this.isgroup});

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      title: GestureDetector(
        onTap: () {
          pushNewScreen(context, screen: const GroupdetailScreen());
        },
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const CircleAvatar(
            backgroundImage: NetworkImage(
                'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=1365'),
            radius: 20,
          ),
          horizontalGap(15),
          isgroup!
              ? SvgPicture.asset(AppImage.chatgroupicon)
              : const SizedBox(),
          horizontalGap(5),
          poppinsText(name ?? '', 15, FontWeight.bold, blackColor)
        ]),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: SvgPicture.asset(AppImage.callicon),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
