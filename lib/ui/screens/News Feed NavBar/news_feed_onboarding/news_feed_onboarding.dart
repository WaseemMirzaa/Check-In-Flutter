import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/Create%20Post/create_post_screen.dart';
import 'package:check_in/ui/screens/persistent_nav_bar.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

class NewsFeedOnboarding extends StatelessWidget {
  const NewsFeedOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    setValue('first', 'no');
    return Scaffold(body: SingleChildScrollView(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -7.h,
            child: Container(
              height: 85.h,
              width: 100.w,
              decoration: const BoxDecoration(image: DecorationImage(image: AssetImage(AppAssets.NEWS_FEED),fit: BoxFit.cover)),
            ),
      ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20),child: Column(
            children: [
      
              SizedBox(height: 3.h,),
              Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                      onTap: (){
                        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>Home()));
                      },
                      child: poppinsText('Skip', 12.sp, medium, textPrimaryColor))),
              SizedBox( height:55.h),
              RichText(text: TextSpan(children: [
                TextSpan(text: 'Welcome ',style: GoogleFonts.poppins(fontSize: 22.sp,fontWeight: medium,color: appGreenColor)),
                TextSpan(text: 'to',style: GoogleFonts.poppins(fontSize: 22.sp,fontWeight: medium,color: greyColor)),
              ])),
              poppinsText('Check In Hoops Live News Feed!', 15.sp, medium, appBlackColor),
      
              RichText(text: TextSpan(children: [
                TextSpan(text: 'View the  ',style: GoogleFonts.poppins(fontSize: 20.sp,fontWeight: medium,color: appGreenColor)),
                TextSpan(text: "Community's",style: GoogleFonts.poppins(fontSize: 20.sp,fontWeight: medium,color: greyColor)),
              ])),
              poppinsText('Top Hoop Content', 15.sp, medium, appBlackColor),
              poppinsText('Grow your following and brand by posting photos, videos, and interacting with other hoop enthusiasts!', 12.sp, regular, appBlackColor,maxlines: 3,align: TextAlign.center),
              SizedBox(height: 3.h,),
              ElevatedButton(onPressed: (){
                pushNewScreen(context, screen: CreatePost(isOnboard: true,)).then((value) async=> await setValue('first', 'no'));
              },style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => appGreenColor)), child: Center(child: poppinsText('Create My First News Feed Post', 12.sp, medium, appWhiteColor)),)
      
      
            ],
          ),)
      ]),
    )
    );
  }
}
