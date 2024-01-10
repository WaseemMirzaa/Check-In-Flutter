import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../utils/Constants/images.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/gaps.dart';
import '../../../../../utils/styles.dart';
import '../../../../widgets/custom_appbar.dart';

class ChatAppbar extends StatelessWidget implements PreferredSizeWidget {
  String? name;
  String? image;
  bool? isgroup;
  Function()? ontap;
  ChatAppbar({super.key, this.name, this.isgroup, this.ontap, this.image});

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      title: GestureDetector(
        onTap: ontap,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(
            backgroundImage:
                NetworkImage(image == '' ? AppImage.userImagePath : image!),
            radius: 20,
          ),
          horizontalGap(15),
          isgroup!
              ? SvgPicture.asset(AppImage.chatgroupicon)
              : const SizedBox(),
          horizontalGap(5),
          Flexible(
              child: poppinsText(name ?? '', 15, FontWeight.bold, blackColor))
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
