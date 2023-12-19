import 'package:check_in/utils/colors.dart';
import 'package:flutter/material.dart';

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
