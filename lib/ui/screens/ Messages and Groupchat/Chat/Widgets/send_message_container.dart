import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../utils/Constants/images.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/gaps.dart';
import '../../../../widgets/custom_textfield.dart';

// ignore: must_be_immutable
class SendMessageContainer extends StatelessWidget {
  TextEditingController? controller;
  Function()? textfieldontap;
  Function()? sendmsgontap;
  Function()? iconontap;
  SendMessageContainer(
      {super.key,
      this.controller,
      this.sendmsgontap,
      this.iconontap,
      this.textfieldontap});

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
          SvgPicture.asset(AppImage.chatfieldicon),
          horizontalGap(15),
          GestureDetector(
              onTap: iconontap,
              child: SvgPicture.asset(AppImage.chatfieldsticker)),
          horizontalGap(11),
          Expanded(
              child: ChatTextfield(
            ontap: textfieldontap,
            controller: controller,
          )),
          horizontalGap(11),
          GestureDetector(
              onTap: sendmsgontap,
              child: SvgPicture.asset(AppImage.sendmsgicon)),
        ],
      ),
    );
  }
}
