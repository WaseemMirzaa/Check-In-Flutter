import 'package:check_in/auth_service.dart';
import 'package:check_in/ui/screens/forgot_password.dart';
import 'package:check_in/ui/screens/start.dart';
import 'package:check_in/ui/widgets/common_button.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/val.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String email = '';
  String password = '';

  final auth = FirebaseAuth.instance;
  final snap = FirebaseFirestore.instance;

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
      body: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 4.h,
                ),
                Image.asset(
                  "assets/images/logo-new.png",
                  scale: 3,
                ),
                SizedBox(
                  height: 12.h,
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
                            if (v == null ||
                                v.isEmpty ||
                                v.length < 6 ||
                                !Validate(email)) {
                              return 'Please enter Valid Email Address';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              pushNewScreen(context,
                                  screen: const ForgotPassword(),
                                  withNavBar: false);
                            },
                            child: Text(
                              'Forgot Password',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 1.7.h,
                                color: const Color(0xff000000),
                                fontWeight: FontWeight.w500,
                              ),
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 3.6.h),
                          child: fullWidthButton('Log in', () async {
                            if (password != "" && email != "") {
                              login(email, password, context);
                            } else if (password == "") {
                              Get.snackbar("Error", "Enter Password",
                                  snackPosition: SnackPosition.BOTTOM);
                            } else if (email == "") {
                              Get.snackbar("Error", "Enter Email",
                                  snackPosition: SnackPosition.BOTTOM);
                            }
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
