import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sizer/sizer.dart';

class NewsFeedOnboarding extends StatelessWidget {
  const NewsFeedOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -15.h,
          child: Container(
            height: 100.h,
            width: 100.w,
            decoration: const BoxDecoration(image: DecorationImage(image: AssetImage(AppAssets.NEWS_FEED),fit: BoxFit.cover)),
          ),
    ),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 40),child: poppinsText('Skip', 12.sp, medium, textPrimaryColor),)
    ])
    );
  }
}
