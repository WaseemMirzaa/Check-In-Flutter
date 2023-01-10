import 'package:checkinmod/ui/screens/persistent_nav_bar.dart';
import 'package:checkinmod/ui/screens/start.dart';
import 'package:checkinmod/ui/widgets/common_button.dart';
import 'package:checkinmod/utils/gaps.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Row(
          children: [
            SizedBox(
              width: 30,
            ),
            GestureDetector(
              onTap: () {
                pushNewScreen(context, screen: StartView(), withNavBar: false);
              },
              child: SizedBox(
                height: 2.1.h,
                width: 2.9.w,
                child: Image.asset("assets/images/Path 6.png"),
              ),
            )
          ],
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset("assets/images/logo.jpeg",),
                SizedBox(height: 12.h,),
                SizedBox(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 0.9.h, bottom: 0.9.h),
                        child: TextField(
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff707070)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff707070)),
                            ),
                            hintText: 'Username',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 1.7.h,
                              color: const Color(0xff707070),
                              fontWeight: FontWeight.w600,
                              height: 1.2142857142857142,
                            ),
                          ),
                        ),
                      ),Padding(
                        padding: EdgeInsets.only(top: 0.9.h, bottom: 0.9.h),
                        child: TextField(
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff707070)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff707070)),
                            ),
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 1.7.h,
                              color: const Color(0xff707070),
                              fontWeight: FontWeight.w600,
                              height: 1.2142857142857142,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0.9.h, bottom: 0.9.h),
                        child: TextField(
                          enableSuggestions: false,
                          autocorrect: false,
                          obscureText: true,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff707070)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff707070)),
                            ),
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 1.7.h,
                              color: const Color(0xff707070),
                              fontWeight: FontWeight.w600,
                              height: 1.2142857142857142,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 3.6.h),
                          child: fullWidthButton('Sign up', () {
                            pushNewScreen(context,
                                screen: Home(), withNavBar: false);
                          })),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
