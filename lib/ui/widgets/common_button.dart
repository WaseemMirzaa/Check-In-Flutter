import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../utils/colors.dart';

Container fullWidthButton(String label, VoidCallback onTap) {
  return Container(
    height: 6.h,
    decoration: BoxDecoration(
      color: appGreenColor,
      borderRadius: BorderRadius.circular(11.0),
      boxShadow: [
        BoxShadow(
          color: blackTranslucentColor,
          offset: const Offset(0, 3),
          blurRadius: 6,
        ),
      ],
    ),
    child: Material(
      color: appTransparentColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(11.0),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 1.7.h,
              color: appWhiteColor,
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
