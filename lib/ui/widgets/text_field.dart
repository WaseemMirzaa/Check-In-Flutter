import 'package:check_in/utils/colors.dart';
import 'package:flutter/material.dart';

import '../../utils/styles.dart';

TextField customTextField(
    String hint, Color hintColor, TextEditingController controller) {
  return TextField(
    enableSuggestions: false,
    autocorrect: false,
    obscureText: false,
    controller: controller,
    decoration: InputDecoration(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: greyColor),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: greyColor),
      ),
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: hintColor,
        fontWeight: FontWeight.w600,
        height: 1.2142857142857142,
      ),
    ),
  );
}

class CustomTextfield1 extends StatelessWidget {
  Widget? suffixIcon;
  String? hintText;
  bool? readOnly;
  FocusNode? focusNode;
  TextEditingController? controller;
  Function()? onTap;
  Function(String)? onChanged;
  Function(PointerDownEvent)? onTapOutside;
  CustomTextfield1(
      {super.key,
      this.suffixIcon,
      this.hintText,
      this.controller,
      this.readOnly = false,
      this.focusNode,
      this.onTapOutside,
      this.onTap,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly!,
      focusNode: focusNode,
      controller: controller,
      onTapOutside: onTapOutside,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: TextStyle(
              fontSize: 13, fontWeight: medium, fontFamily: 'Poppins'),
          border: InputBorder.none,
          focusedBorder: InputBorder.none),
    );
  }
}
