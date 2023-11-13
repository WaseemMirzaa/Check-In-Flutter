import 'package:check_in/auth_service.dart';
import 'package:check_in/ui/screens/privacy_policy.dart';
import 'package:check_in/ui/screens/start.dart';
import 'package:check_in/ui/screens/terms_conditions.dart';
import 'package:check_in/ui/widgets/common_button.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/val.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  String userName = '';
  String email = '';
  String password = '';
  bool IsVerified = false;
  bool agreeToTerms = false;
  bool isSignUpButtonEnabled = false;

  int index = 0;

  void changeIndex() {
    if (index == 0) {
      index = 1;
    } else {
      index = 0;
    }
    setState(() {});
    print(index);
  }

  final auth = FirebaseAuth.instance;
  final snap = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Row(
          children: [
            const SizedBox(
              width: 30,
            ),
            GestureDetector(
              onTap: () {
                pushNewScreen(context,
                    screen: StartView(isBack: false), withNavBar: false);
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 3.h,
              ),
              Image.asset(
                "assets/images/logo-new.png",
                scale: 3,
              ),
              SizedBox(
                height: 5.h,
              ),
              SizedBox(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 0.9.h, bottom: 0.9.h),
                      child: TextFormField(
                        enableSuggestions: false,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () =>
                            FocusScope.of(context).nextFocus(),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          setState(() {
                            userName = val;
                          });
                        },
                        decoration: InputDecoration(
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff707070)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
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
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 0.9.h, bottom: 0.9.h),
                      child: TextFormField(
                        enableSuggestions: false,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () =>
                            FocusScope.of(context).nextFocus(),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty || !Validate(email)) {
                            return 'Please enter Valid Email address';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          setState(() {
                            email = val.trim();
                          });
                          Validate(email);
                        },
                        decoration: InputDecoration(
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff707070)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
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
                      child: TextFormField(
                        enableSuggestions: false,
                        autocorrect: false,
                        obscureText: index == 0 ? true : false,
                        validator: (v) {
                          if (v == null || v.isEmpty || v.length < 6) {
                            return 'Password must be 6 digits long';
                          }
                          return null;
                        },
                        onChanged: (v) {
                          setState(() {
                            password = v;
                          });
                        },
                        decoration: InputDecoration(
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff707070)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
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
                    Row(
                      children: [
                        Checkbox(
                          value: agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              agreeToTerms = value ?? false;
                              isSignUpButtonEnabled = agreeToTerms;
                            });
                          },
                        ),
                        // Expanded(
                        //   child:
                        Text(
                          "I agree to the ",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 1.2.h,
                            color: const Color(0xff707070),
                            fontWeight: FontWeight.w600,
                            // height: 1.2142857142857142,
                          ),
                        ),
                        // ),
                        GestureDetector(
                          onTap: () {
                            pushNewScreen(context,
                                screen: const PrivacyPolicy(),
                                withNavBar: false);
                          },
                          child: Text(
                            "Privacy Policy",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 1.2.h,
                            ),
                          ),
                        ),
                        Text(
                          " & ",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 1.2.h,
                            color: const Color(0xff707070),
                            fontWeight: FontWeight.w600,
                            // height: 1.2142857142857142,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            pushNewScreen(context,
                                screen: const TermsAndConditions(),
                                withNavBar:
                                    false); // Handle the action to open the Terms & Conditions screen
                          },
                          child: Text(
                            "Terms & Conditions",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 1.2.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.0.h),
                    // Add some spacing between the checkbox and the sign-up button
                    Padding(
                        padding: EdgeInsets.only(top: 3.6.h),
                        child: fullWidthButton('Sign up', () async {
                          if (!isSignUpButtonEnabled) {
                            Get.snackbar(
                                "Error", "Agree to terms & conditions");
                          } else if (userName != '') {
                            if (Validate(email)) {
                              signUp(email, password, userName, context);
                            }
                          } else if (userName == '') {
                            Get.snackbar("Error", "Enter User Name");
                          }
                        })),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
