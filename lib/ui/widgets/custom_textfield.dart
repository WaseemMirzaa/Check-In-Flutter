import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/styles.dart';

// ignore: must_be_immutable
class ChatTextfield extends StatelessWidget {
  Function()? ontap;
  TextEditingController? controller;
  ChatTextfield({super.key, this.controller, this.ontap});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: ontap,
      controller: controller,
      decoration: InputDecoration(
          hintText: 'Type something',
          hintStyle:
              TextStyle(fontSize: 14, color: blackColor, fontWeight: medium),
          border: InputBorder.none,
          focusedBorder: InputBorder.none),
    );
  }
}
