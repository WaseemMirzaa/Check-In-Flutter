import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../../utils/Constants/images.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/gaps.dart';
import '../../../../../utils/styles.dart';
import '../../../../widgets/custom_appbar.dart';

class ChatAppbar extends StatelessWidget implements PreferredSizeWidget {
  RxString? name;
  RxString? image;
  Widget? lastSeen;
  bool? isgroup;
  Widget? widget;
  String? onlineStatus;
  Function()? ontap;
  ChatAppbar({super.key, this.name, this.isgroup, this.ontap, this.image, this.onlineStatus, this.lastSeen, this.widget,});

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      title: GestureDetector(
        onTap: ontap,
        child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Obx(() => CircleAvatar(
                backgroundImage: image!.value == '' ? AssetImage(AppImage.user) as ImageProvider : CachedNetworkImageProvider(image!.value), radius: 20,
              )),
          horizontalGap(10),
          isgroup! ? SvgPicture.asset(AppImage.chatgroupicon) : const SizedBox(),
          horizontalGap(2),
          Obx(() => Flexible(
                child: isgroup!
                    ? poppinsText(name!.value ?? '', 16, FontWeight.bold, appBlackColor)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          poppinsText(name!.value ?? '', 16, FontWeight.bold, appBlackColor),
                          const SizedBox(height: 2),
                           widget ?? lastSeen ??
                              Text(
                                onlineStatus!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                        ],
                      ),
              )),
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
