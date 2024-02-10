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
  String? onlineStatus;
  Function()? ontap;
  ChatAppbar({super.key, this.name, this.isgroup, this.ontap, this.image, this.onlineStatus, this.lastSeen});

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
          isgroup! ? SvgPicture.asset(AppImage.chatgroupicon) : const SizedBox(),
          horizontalGap(5),
          Obx(() => Flexible(
                child: isgroup!
                    ? poppinsText(name!.value ?? '', 15, FontWeight.bold, blackColor)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          poppinsText(name!.value ?? '', 15, FontWeight.bold, blackColor),
                          const SizedBox(height: 8),
                          lastSeen ??
                              Text(
                                onlineStatus!,
                                style: const TextStyle(
                                  fontSize: 14,
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
