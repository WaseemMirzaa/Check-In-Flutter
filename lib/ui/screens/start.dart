import 'dart:io';

import 'package:check_in/ui/screens/login.dart';
import 'package:check_in/ui/screens/signup.dart';
import 'package:check_in/ui/widgets/common_button.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

class StartView extends StatefulWidget {
  const StartView({super.key});

  @override
  State<StartView> createState() => _StartViewState();
}

class _StartViewState extends State<StartView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Center(
                  child: Image.asset(
                    "assets/images/logo-new.png",
                    scale: 3,
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 0.9.h, bottom: 0.9.h),
                    child: fullWidthButton("Log in", () {
                      pushNewScreen(context,
                          screen: const LoginView(), withNavBar: false);
                    }),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0.9.h, bottom: 0.9.h),
                    child: Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: const Color(0xffffffff),
                        borderRadius: BorderRadius.circular(11.0),
                        border: Border.all(
                            width: 1.0, color: const Color(0xff707070)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x29000000),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(11),
                          onTap: () {
                            pushNewScreen(context,
                                screen: const SignupView(), withNavBar: false);
                          },
                          child: Center(
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 1.7.h,
                                color: const Color(0xff000000),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'or login with',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 1.3.h,
                        color: const Color(0xff707070),
                        height: 1.4166666666666667,
                      ),
                      textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false),
                      textAlign: TextAlign.center,
                      softWrap: false,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0.9.h, bottom: 0.9.h),
                    child: Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: const Color(0xffffffff),
                        borderRadius: BorderRadius.circular(6.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x29000000),
                            offset: Offset(0, 1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 30,
                            ),
                            SizedBox(
                              width: 42.w,
                              child: Image.asset(
                                'assets/images/instagram.png',
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: Platform.isIOS,
                    child: Padding(
                      padding: EdgeInsets.only(top: 0.9.h, bottom: 0.9.h),
                      child: Container(
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: const Color(0xffffffff),
                          borderRadius: BorderRadius.circular(6.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x29000000),
                              offset: Offset(0, 1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/apple.png',
                              scale: 4,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Apple',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 1.8.h,
                                  color: const Color(0xff000000),
                                ),
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  verticalGap(3.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
