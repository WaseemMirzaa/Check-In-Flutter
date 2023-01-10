

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Text poppinsText(String label,double fontSize,FontWeight fontWeight,Color color){
  return Text(label,style: GoogleFonts.poppins(
    fontWeight: fontWeight,
    fontSize: fontSize,
    color: color,
  ),);
}


FontWeight semiBold = FontWeight.w600;
FontWeight regular = FontWeight.normal;
FontWeight bold = FontWeight.bold;
FontWeight medium = FontWeight.w500;
