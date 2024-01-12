import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/utils/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../utils/Constants/images.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/gaps.dart';
import '../../../../../utils/styles.dart';

// ignore: must_be_immutable
class SendMessageContainer extends GetView<ChatController> {
  TextEditingController? textFieldController;
  Function()? textfieldontap;
  Function()? sendmsgontap;
  Function()? iconontap;
  Function()? imageontap;
  SendMessageContainer(
      {super.key,
      this.textFieldController,
      this.sendmsgontap,
      this.iconontap,
      this.textfieldontap,
      this.imageontap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: whiteColor, boxShadow: [
        BoxShadow(
          color: greyColor.withOpacity(0.4),
          offset: const Offset(0, -4),
          blurRadius: 10.0,
        ),
      ]),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
              onTap: imageontap,
              child: SvgPicture.asset(AppImage.chatfieldicon)),
          horizontalGap(15),
          GestureDetector(
              onTap: iconontap,
              child: SvgPicture.asset(AppImage.chatfieldsticker)),
          horizontalGap(11),
          Expanded(
              child: TextFormField(
            focusNode: controller.chatFieldFocusNode,
            onTap: textfieldontap,
            controller: textFieldController,
            decoration: InputDecoration(
                hintText: TempLanguage.typeSomething,
                hintStyle: TextStyle(
                    fontSize: 14, color: blackColor, fontWeight: medium),
                border: InputBorder.none,
                focusedBorder: InputBorder.none),
          )),
          horizontalGap(11),
          Obx(() => controller.sendMsgLoader.value
              ? loaderView()
              : GestureDetector(
                  onTap: sendmsgontap,
                  child: SvgPicture.asset(AppImage.sendmsgicon))),
        ],
      ),
    );
  }
}
