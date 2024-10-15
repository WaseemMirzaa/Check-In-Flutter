import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/ui/screens/Messages%20NavBar/New%20Message/new_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

import '../../../../../utils/Constants/images.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/gaps.dart';
import '../../../../../utils/styles.dart';
import '../../../../widgets/custom_appbar.dart';

class MessageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MessageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      showicon: false,
      title: Row(mainAxisSize: MainAxisSize.min, children: [
        SvgPicture.asset(AppImage.messageappbaricon),
        horizontalGap(15),
        poppinsText(TempLanguage.messages, 15, FontWeight.bold, appBlackColor)
      ]),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: () {
              pushNewScreen(context, screen: const NewMessageScreen());
            },
            child: Image.asset(
              AppImage.addPeople,
              height: 24,
              width: 24,
            ),
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
