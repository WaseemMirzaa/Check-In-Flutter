import 'package:flutter/material.dart';

Container fullWidthButton(String label,VoidCallback onTap) {
  return Container(
    height: 50,
    decoration: BoxDecoration(
      color: const Color(0xff007a33),
      borderRadius: BorderRadius.circular(11.0),
      boxShadow: [
        BoxShadow(
          color: const Color(0x29000000),
          offset: Offset(0, 3),
          blurRadius: 6,
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(11.0),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: const Color(0xffffffff),
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