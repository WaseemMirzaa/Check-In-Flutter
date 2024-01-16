import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/Constants/images.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/gaps.dart';
import '../../../../../utils/styles.dart';
import '../../../../widgets/custom_appbar.dart';

class ChatAppbar extends StatelessWidget implements PreferredSizeWidget {
  RxString? name;
  RxString? image;
  bool? isgroup;
  Function()? ontap;
  ChatAppbar({super.key, this.name, this.isgroup, this.ontap, this.image});

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      title: GestureDetector(
        onTap: ontap,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Obx(() => CircleAvatar(
                backgroundImage: image!.value == ''
                    ? AssetImage(AppImage.user) as ImageProvider
                    : CachedNetworkImageProvider(image!.value),
                radius: 20,
              )),
          horizontalGap(15),
          isgroup! ? Image.asset(AppImage.chatgroupicon) : const SizedBox(),
          horizontalGap(5),
          Obx(() => Flexible(
              child: poppinsText(
                  name!.value ?? '', 15, FontWeight.bold, blackColor)))
        ]),
      ),
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.only(right: 20),
      //     child: SvgPicture.asset(AppImage.callicon),
      //   )
      // ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
