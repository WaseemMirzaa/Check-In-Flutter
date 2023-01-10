import 'package:checkinmod/ui/screens/add_home_court.dart';
import 'package:checkinmod/utils/colors.dart';
import 'package:checkinmod/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

import '../../utils/gaps.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: whiteColor,
        title: poppinsText("Profile", 20, FontWeight.bold, blackColor),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  verticalGap(3.h),
                  Container(
                    width: 35.9.w,
                    //   padding: EdgeInsets.all(10),
                    child: Stack(
                      //  clipBehavior: Clip.antiAliasWithSaveLayer,
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          height: 15.h,
                          width: 32.9.w,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: AssetImage(
                                      "assets/images/Mask Group 1.png"))),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            height: 5.5.h,
                            width: 12.1.w,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/instagram-verification-badge.png"))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalGap(0.5.h),
                  poppinsText("Benjamin", 32, FontWeight.bold, blackColor),
                  poppinsText(
                      "@Alexhales", 12, FontWeight.normal, blackColor),
                ],
              ),
              Column(
                children: [
                  poppinsText("Home Court", 14, semiBold, greenColor),
                  verticalGap(0.8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            poppinsText("Morse Kelley Park - Somerville Ma", 14,
                                semiBold, blackColor),
                            GestureDetector(
                              onTap: () {
                                pushNewScreen(context,
                                    screen: AddHomeCourt(), withNavBar: false);
                              },
                              child: SizedBox(
                                height: 2.3.h,
                                width: 4.47.w,
                                child: Image.asset(
                                    "assets/images/Icon feather-map-pin.png"),
                              ),
                            )
                          ],
                        ),
                        verticalGap(1.3.h),
                        Container(
                          height: 1,
                          color: greyColor,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 3.5.h,
                  ),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 30, right: 30, top: 30),
                        height: 200,
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 1,
                              //   spreadRadius: -12,
                              offset:
                                  Offset(0, -3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                poppinsText(
                                    "About me", 14, semiBold, blackColor),
                                SizedBox(
                                  height: 1.8.h,
                                  width: 4.w,
                                  child: Image.asset(
                                      "assets/images/Icon feather-edit-2.png"),
                                )
                              ],
                            ),
                            TextFormField(
                              maxLines: 5,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  hintText:
                                      "617 Real G’s move in silence like lasagna.",
                                  helperStyle: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: regular,
                                      color: Color(0xff777777))),
                            ),
                            verticalGap(15),
                            Container(
                              height: 1,
                              color: greyColor,
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: 100,
                        color: greenColor,
                        height: 2,
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
