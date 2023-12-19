import 'package:flutter/material.dart';

import '../../utils/colors.dart';

Container fullWidthButton(String label, VoidCallback onTap) {
  return Container(
    height: 50,
    decoration: BoxDecoration(
      color: greenColor,
      borderRadius: BorderRadius.circular(11.0),
      boxShadow: [
        BoxShadow(
          color: blackTranslucentColor,
          offset: Offset(0, 3),
          blurRadius: 6,
        ),
      ],
    ),
    child: Material(
      color: transparentColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(11.0),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: whiteColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            softWrap: false,
          ),
        ),
      ),
    ),
  );
}
