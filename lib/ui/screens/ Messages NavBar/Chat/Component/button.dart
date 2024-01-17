import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';

class ChatButton extends StatelessWidget {
  Function()? onTap;
  String? text;
  Color? textColor;
  Color? buttonColor;
  double? width;
  ChatButton(
      {super.key,
      this.buttonColor,
      required this.onTap,
      required this.text,
      this.textColor,
      this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor ?? greyColor,
        ),
        child: poppinsText(text ?? '', 12, medium, textColor!),
      ),
    );
  }
}
