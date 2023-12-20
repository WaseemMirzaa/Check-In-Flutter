import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
        poppinsText('Messages', 20, FontWeight.bold, blackColor)
      ]),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: SvgPicture.asset(
            AppImage.messagecircle,
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
