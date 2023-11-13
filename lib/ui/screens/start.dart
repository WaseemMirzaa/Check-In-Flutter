import 'dart:io';

import 'package:check_in/ui/screens/login.dart';
import 'package:check_in/ui/screens/signup.dart';
import 'package:check_in/ui/widgets/common_button.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class StartView extends StatefulWidget {
  bool isBack = false;
  StartView({super.key, required this.isBack});

  @override
  State<StartView> createState() => _StartViewState();
}

class _StartViewState extends State<StartView> {
  String _authStatus = 'Unknown';

  @override
  void initState() {
    super.initState();

    // It is safer to call native code using addPostFrameCallback after the widget has been fully built and initialized.
    // Directly calling native code from initState may result in errors due to the widget tree not being fully built at that point.
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((_) => initPlugin());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlugin() async {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => _authStatus = '$status');
    // If the system can show an authorization request dialog
    if (status == TrackingStatus.notDetermined) {
      // Show a custom explainer dialog before the system dialog
      await showCustomTrackingDialog(context);
      // Wait for dialog popping animation
      await Future.delayed(const Duration(milliseconds: 200));
      // Request system's tracking authorization dialog
      final TrackingStatus status =
          await AppTrackingTransparency.requestTrackingAuthorization();
      setState(() => _authStatus = '$status');
    }

    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("UUID: $uuid");
  }

  Future<void> showCustomTrackingDialog(BuildContext context) async =>
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dear User'),
          content: const Text(
            'We care about your privacy and data security. We use your email to maintain your own profile against it. '
            'Also we use your location to show you the nearest basketball courts in your area. '
            'Can we continue to use your data to give you best experience ?\n\nYou can change your choice anytime in the app settings. ',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.isBack
          ? AppBar(
              backgroundColor: Colors.white,
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
                      child: Image.asset("assets/images/Path 6.png"),
                    ),
                  )
                ],
              ),
              elevation: 0,
            )
          : null,
      body: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
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
                  // Visibility(
                  //   visible: Platform.isIOS,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Text(
                  //       'or login with',
                  //       style: TextStyle(
                  //         fontFamily: 'Poppins',
                  //         fontSize: 1.3.h,
                  //         color: const Color(0xff707070),
                  //         height: 1.4166666666666667,
                  //       ),
                  //       textHeightBehavior: const TextHeightBehavior(
                  //           applyHeightToFirstAscent: false),
                  //       textAlign: TextAlign.center,
                  //       softWrap: false,
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.only(top: 0.9.h, bottom: 0.9.h),
                  //   child: Container(
                  //     height: 6.h,
                  //     decoration: BoxDecoration(
                  //       color: const Color(0xffffffff),
                  //       borderRadius: BorderRadius.circular(6.0),
                  //       boxShadow: const [
                  //         BoxShadow(
                  //           color: Color(0x29000000),
                  //           offset: Offset(0, 1),
                  //           blurRadius: 6,
                  //         ),
                  //       ],
                  //     ),
                  //     child: Center(
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           SizedBox(
                  //             width: 30,
                  //           ),
                  //           SizedBox(
                  //             width: 42.w,
                  //             child: Image.asset(
                  //               'assets/images/instagram.png',
                  //               fit: BoxFit.fitWidth,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // Visibility(
                  //   visible: Platform.isIOS,
                  //   child: Padding(
                  //     padding: EdgeInsets.only(top: 0.9.h, bottom: 0.9.h),
                  //     child: Container(
                  //       height: 6.h,
                  //       decoration: BoxDecoration(
                  //         color: const Color(0xffffffff),
                  //         borderRadius: BorderRadius.circular(6.0),
                  //         boxShadow: const [
                  //           BoxShadow(
                  //             color: Color(0x29000000),
                  //             offset: Offset(0, 1),
                  //             blurRadius: 6,
                  //           ),
                  //         ],
                  //       ),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Padding(
                  //             padding: const EdgeInsets.all(8.0),
                  //             child: Image.asset(
                  //               'assets/images/apple.png',
                  //               scale: 2,
                  //             ),
                  //           ),
                  //           Padding(
                  //             padding: const EdgeInsets.all(0.0),
                  //             child: Text(
                  //               'Apple',
                  //               style: TextStyle(
                  //                 fontFamily: 'Helvetica',
                  //                 fontSize: 1.8.h,
                  //                 color: const Color(0xff000000),
                  //               ),
                  //               softWrap: false,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
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
