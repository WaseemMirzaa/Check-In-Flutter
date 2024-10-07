import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class CustomContainer1 extends StatelessWidget {
  Widget? child;
  CustomContainer1({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
          color: appWhiteColor,
          boxShadow: [
            BoxShadow(
                color: greyColor.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(1, 4))
          ],
          borderRadius: BorderRadius.circular(10)),
      child: child,
    );
  }
}



class CustomContainer2 extends StatelessWidget {
  Widget? child;
  CustomContainer2({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      // decoration: BoxDecoration(
      //     color: appWhiteColor,
      //     // boxShadow: [
      //     //   BoxShadow(
      //     //       color: greyColor.withOpacity(0.3),
      //     //       spreadRadius: 2,
      //     //       blurRadius: 6,
          //       offset: const Offset(1, 4))
          // ],
          // borderRadius: BorderRadius.circular(10)),
      child: child,
    );
  }
}
