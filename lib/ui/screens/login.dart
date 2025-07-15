import 'package:check_in/auth_service.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/ui/screens/forgot_password.dart';
import 'package:check_in/ui/screens/start.dart';
import 'package:check_in/ui/widgets/common_button.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/val.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:sizer/sizer.dart';

import '../../utils/colors.dart';

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
  RxBool isLoading = false.obs;

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
      backgroundColor: appWhiteColor,
      appBar: AppBar(
        backgroundColor: appWhiteColor,
        leading: Row(
          children: [
            SizedBox(
              width: 2.5.w,
            ),
            GestureDetector(
              onTap: () {
                pushScreen(context,
                    screen: StartView(isBack: false), withNavBar: false);
              },
              child: SizedBox(
                height: 2.1.h,
                width: 2.9.w,
                child: Image.asset(AppAssets.LEFT_ARROW),
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
                  AppAssets.LOGO_NEW,
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
                              return "Please ${TempLanguage.validEmail}";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: greyColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: greyColor),
                            ),
                            hintText: TempLanguage.emailCap,
                            hintStyle: TextStyle(
                              fontFamily: TempLanguage.poppins,
                              fontSize: 1.7.h,
                              color: greyColor,
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
                              return TempLanguage.invalidPassword;
                            }
                            return null;
                          },
                          onChanged: (v) {
                            setState(() {
                              password = v;
                            });
                          },
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: greyColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: greyColor),
                            ),
                            hintText: TempLanguage.password,
                            hintStyle: TextStyle(
                              fontFamily: TempLanguage.poppins,
                              fontSize: 1.7.h,
                              color: greyColor,
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
                              pushScreen(context,
                                  screen: const ForgotPassword(),
                                  withNavBar: false);
                            },
                            child: Text(
                              TempLanguage.forgotPassword,
                              style: TextStyle(
                                fontFamily: TempLanguage.poppins,
                                fontSize: 1.7.h,
                                color: appBlackColor,
                                fontWeight: FontWeight.w500,
                              ),
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () {
                          return Padding(
                              padding: EdgeInsets.only(top: 3.6.h),
                              child: isLoading.value
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : fullWidthButton(TempLanguage.logInSpaced,
                                      () async {
                                      if (password != "" && email != "") {
                                        isLoading.value = true;
                                        await login(email, password, context);
                                        isLoading.value = false;
                                      } else if (password == "") {
                                        Get.snackbar(TempLanguage.error,
                                            TempLanguage.enterPassword,
                                            snackPosition: SnackPosition.TOP);
                                      } else if (email == "") {
                                        Get.snackbar(TempLanguage.error,
                                            TempLanguage.enterEmail,
                                            snackPosition: SnackPosition.TOP);
                                      }
                                    }));
                        },
                      ),
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
