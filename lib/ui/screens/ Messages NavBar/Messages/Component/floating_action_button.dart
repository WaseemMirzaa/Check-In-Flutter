// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../utils/Constants/images.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/gaps.dart';
import '../../../../../utils/styles.dart';

class FloatingactionButton extends StatelessWidget {
  Function()? ontap;
  FloatingactionButton({super.key, this.ontap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: greenColor,
      label: Row(
        children: [
          poppinsText('Send message', 12, FontWeight.normal, whiteColor),
          horizontalGap(35),
          SvgPicture.asset(
            AppImage.messageappbaricon,
            color: whiteColor,
          ),
        ],
      ),
      onPressed: ontap,
    );
  }
}
