import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../controllers/Messages/group_detail_controller.dart';
import '../../../../../utils/Constants/images.dart';
import '../../../../../utils/colors.dart';

class NameTextfield extends GetView<UsergroupDetailController> {
  bool? isAdmin;

  NameTextfield({super.key, this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: !isAdmin!,
      focusNode: controller.namefocusNode,
      onTapOutside: (val) {
        controller.namefocusNode.unfocus();
      },
      controller: controller.nameController,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: greyColor.withOpacity(0.6))),
          suffixIcon: isAdmin!
              ? Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10, left: 30),
                  child: SvgPicture.asset(
                    AppImage.penicon,
                  ),
                )
              : const SizedBox()),
    );
  }
}

class AboutTextfield extends GetView<UsergroupDetailController> {
  bool? isAdmin;
  AboutTextfield({super.key, this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: !isAdmin!,
      onTapOutside: (val) {
        controller.aboutfocusNode.unfocus();
      },
      focusNode: controller.aboutfocusNode,
      enabled: true,
      textAlign: TextAlign.center,
      maxLines: 9,
      minLines: 1,
      controller: controller.aboutController,
      style: TextStyle(fontSize: 14, color: greyColor),
      decoration: const InputDecoration(
        border: UnderlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }
}
