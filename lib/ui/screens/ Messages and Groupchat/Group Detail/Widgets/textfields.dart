import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../controllers/group_detail_controller.dart';
import '../../../../../utils/Constants/images.dart';
import '../../../../../utils/colors.dart';

class NameTextfield extends GetView<UsergroupDetailController> {
  const NameTextfield({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: controller.namefocusNode,
      onTapOutside: (val) {
        controller.namefocusNode.unfocus();
      },
      controller: controller.nameController,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
          suffixIcon: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10, left: 30),
        child: SvgPicture.asset(
          AppImage.penicon,
        ),
      )),
    );
  }
}

class AboutTextfield extends GetView<UsergroupDetailController> {
  const AboutTextfield({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
          border: UnderlineInputBorder(borderSide: BorderSide.none)),
    );
  }
}
