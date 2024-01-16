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
      this.onTap,
      this.text,
      this.textColor,
      this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: width,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
        ),
        child: poppinsText(text!, 12, regular, textColor!),
      ),
    );
  }
}
