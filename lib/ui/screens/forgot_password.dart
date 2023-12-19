import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart' as toast;
import 'package:sizer/sizer.dart';

import '../../auth_service.dart';
import '../../utils/colors.dart';
import '../../utils/gaps.dart';
import '../../utils/styles.dart';
import '../../val.dart';
import '../widgets/common_button.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email = '';

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
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        leading: Row(
          children: [
            const SizedBox(
              width: 30,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: SizedBox(
                height: 2.1.h,
                width: 2.9.w,
                child: Image.asset(AppAssets.LEFT_ARROW),
              ),
            )
          ],
        ),
        title: poppinsText(TempLanguage.forgotPassword, 20, FontWeight.bold, blackColor),
        centerTitle: true,
        elevation: 0,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.26,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Image.asset(
                          AppAssets.LOGO_NEW,
                          scale: 0.5.h,
                        ),
                      ),
                    ],
                  ),
                ),
                // SizedBox(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.28,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                            if (v == null || v.isEmpty || v.length < 6) {
                              return TempLanguage.enterText;
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
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.22,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: fullWidthButton(TempLanguage.sendEmail, () async {
                            if (Validate(email)) {
                              await resetPassword(emailText: email);
                            } else {
                              toast.Fluttertoast.showToast(
                                  msg: TempLanguage.validEmail);
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
