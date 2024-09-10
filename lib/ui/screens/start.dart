import 'dart:io';

import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/ui/screens/login.dart';
import 'package:check_in/ui/screens/signup.dart';
import 'package:check_in/ui/widgets/common_button.dart';
import 'package:check_in/utils/common.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

import '../../tracking_status_service.dart';
import '../../utils/colors.dart';

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
        .addPostFrameCallback((_) => initTracking());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initTracking() async {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => _authStatus = '$status');
    // If the system can show an authorization request dialog
    if (status == TrackingStatus.notDetermined) {
      // Show a custom explainer dialog before the system dialog
      await TrackingStatusService.showCustomTrackingDialog(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhiteColor,
      appBar: widget.isBack
          ? AppBar(
              backgroundColor: appWhiteColor,
              leading: Row(
                children: [
                    SizedBox(
                    width: 2.5.w,
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
                    AppAssets.LOGO_NEW,
                    scale: 3,
                  ),
                ),
              ),
              Column(
                children: [


                  Padding(
                    padding: EdgeInsets.only(top: 0.9.h, bottom: 0.9.h),
                    child: fullWidthButton(TempLanguage.logInSpaced, () {
                      pushNewScreen(context,
                          screen: const LoginView(), withNavBar: false);
                    }),
                  ),



                  Padding(
                    padding: EdgeInsets.only(top: 0.9.h, bottom: 0.9.h),
                    child: Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: appWhiteColor,
                        borderRadius: BorderRadius.circular(11.0),
                        border: Border.all(
                            width: 1.0, color: greyColor),
                        boxShadow: [
                          BoxShadow(
                            color: blackTranslucentColor,
                            offset: const Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Material(
                        color: appTransparentColor,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(11),
                          onTap: () {
                            pushNewScreen(context,
                                screen: const SignupView(), withNavBar: false);
                          },
                          child: Center(
                            child: Text(
                              TempLanguage.signUp,
                              style: TextStyle(
                                fontFamily: TempLanguage.poppins,
                                fontSize: 1.7.h,
                                color: appBlackColor,
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
  // final FirebaseFirestore _db =  FirebaseFirestore.instance;

  // Future<void> getAllUsersWithoutParams() async {
  //   final collection = await FirebaseFirestore.instance.collection('USER').get();
  //   for (final doc in collection.docs) {
  //     final userData = doc.data();
  //     if (userData.containsKey("params")) {
  //
  //     } else {
  //      await _db.collection("OUT_PARAM").doc(doc.id).set(doc.data());
  //      print("Created");
  //     }
  //   }
  //
  // print("Nothings");
  // }
  //
  // Future<void> getOutUser() async {
  //   // Get documents from the OUT_PARAM collection
  //   final outParamSnapshot = await _db.collection('USER').get();
  //
  //   // Iterate through each document in the snapshot
  //   for (final doc in outParamSnapshot.docs) {
  //     final userName = doc['user name']; // Assuming 'user' is the field containing the user name
  //     final searchParams = setSearchParam(userName);
  //
  //     // Update the document in the OUT_PARAM collection with the generated search parameters
  //     await _db.collection('USER').doc(doc.id).update({
  //       'params': searchParams,
  //     });
  //   }
  //
  //   print("User search parameters updated."); // Optional: Notify when complete
  // }

}
