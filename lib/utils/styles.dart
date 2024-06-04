import 'package:check_in/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

Text poppinsText(
    String label, double fontSize, FontWeight fontWeight, Color color,
    {TextAlign? align, TextOverflow? overflow, int maxlines = 1}) {
  return Text(
    label,
    textAlign: align,
    overflow: overflow,
    maxLines: maxlines,
    
    style: GoogleFonts.poppins(
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color,
    
    ),
  );
}

RichText richText(
    String boldText,String normalText,{FontStyle fontStyle = FontStyle.italic}) {
  return RichText(text: TextSpan(children: [
    TextSpan(text: boldText,style: GoogleFonts.poppins(fontSize: 12.sp,fontWeight: FontWeight.w600,color: appDarkBlue)),
    TextSpan(text: " $normalText",style: GoogleFonts.poppins(fontSize: 9.sp,fontStyle: fontStyle,fontWeight: FontWeight.w400,color: appBlackColor))
  ]));
}

FontWeight semiBold = FontWeight.w600;
FontWeight regular = FontWeight.normal;
FontWeight bold = FontWeight.bold;
FontWeight medium = FontWeight.w500;
