import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/styles.dart';

// ignore: must_be_immutable
class ChatTextfield extends StatelessWidget {
  TextEditingController? controller;
  ChatTextfield({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
