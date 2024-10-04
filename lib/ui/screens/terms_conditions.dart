import 'dart:io';
import 'package:check_in/auth_service.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../model/user_modal.dart';
import '../../utils/colors.dart';
import '../../utils/styles.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({Key? key, this.showButtons = false, this.fromSignup = false}) : super(key: key);
  final bool showButtons;
  final bool fromSignup;

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  late WebViewController _controller;
  bool _reachBottom = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            const SizedBox(
              width: 30,
            ),
            GestureDetector(
              onTap: () {
                if (widget.fromSignup && widget.showButtons) {
                  Get.back(result: false);
                } else if (widget.showButtons) {
                  closeApp();
                } else {
                  Navigator.pop(context);
                }
                // pushNewScreen(context, screen: Home(), withNavBar: false);
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
        centerTitle: true,
        backgroundColor: appWhiteColor,
        title: poppinsText(
            TempLanguage.termsAndConditions, 20, FontWeight.bold, appBlackColor),
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            decoration: BoxDecoration(
              color: appWhiteColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: greyColor.withOpacity(0.2),
                  blurRadius: 5,
                  //   spreadRadius: -12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Builder(builder: (BuildContext context) {
              return WebView(
                initialUrl:
                    // "https://www.freeprivacypolicy.com/live/0ccc6661-8efc-4732-b790-0663f523ed4a",
                    // "https://docs.google.com/document/d/12-ZJ7JYdvXfObKDzwxPn5G9Ca0xaWOM4/edit?usp=sharing&ouid=106501373238887852973&rtpof=true&sd=true",
                    "https://sites.google.com/view/checkin-hoops-terms",
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                },
                javascriptChannels: Set.from([
                  JavascriptChannel(
                    name: 'ScrollDetector',
                    onMessageReceived: (JavascriptMessage message) {
                      if (message.message == 'bottom') {
                        setState(() {
                          _reachBottom = true;
                        });
                      }
                    },
                  ),
                ]),
                navigationDelegate: (NavigationRequest request) {
                  if (request.url.startsWith('https://www.youtube.com/')) {
                    print('blocking navigation to $request}');
                    return NavigationDecision.prevent;
                  }
                  print('allowing navigation to $request');
                  return NavigationDecision.navigate;
                },
                onPageStarted: (String url) {
                  print('Page started loading: $url');
                },
                onPageFinished: (String url) {
                  _injectScrollDetectionJS();
                  print('Page finished loading: $url');
                },
                gestureNavigationEnabled: true,
              );
            }),
          ),
          widget.showButtons
              ? Positioned(
            bottom: 10,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                 child: InkWell(
                  onTap: _reachBottom
                      ? () {
                    if (widget.fromSignup && widget.showButtons) {
                      Get.back(result: false);
                    } else if (widget.showButtons) {
                      closeApp();
                    } else {
                      Navigator.pop(context);
                    }
                  }
                      : null,
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                        color: _reachBottom ? Colors.red : Colors.grey,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                 ),
                ),
                Expanded(
                  child: InkWell(
                  onTap: _reachBottom
                      ? () async {
                    if (widget.fromSignup && widget.showButtons) {
                      Get.back(result: true);
                    } else if (widget.showButtons) {
                      await FirebaseFirestore.instance
                          .collection(Collections.USER)
                          .doc(userController.userModel.value.uid)
                          .update({UserKey.IS_TERMS_VERIFIED: true});
                      DocumentSnapshot snapshot = await FirebaseFirestore.instance
                          .collection(Collections.USER)
                          .doc(userController.userModel.value.uid)
                          .get();
                      userController.userModel.value = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
                      Get.back();
                    } else {
                      Navigator.pop(context);
                    }
                  }
                      : null,
                   child: Container(
                    height: 45,
                     decoration: BoxDecoration(
                         color: _reachBottom ? Colors.green : Colors.grey,
                         borderRadius: const BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10))
                     ),
                    alignment: Alignment.center,
                    child: const Text('Agree',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                 ),
                ),
              ],
            ),
          )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  void _injectScrollDetectionJS() {
    _controller.runJavascript('''
      console.log('Injecting scroll detection script');
      function isScrolledToBottom() {
        const scrollPosition = window.pageYOffset;
        const windowSize = window.innerHeight;
        const bodyHeight = document.documentElement.scrollHeight;
        
        console.log('Scroll Position:', scrollPosition);
        console.log('Window Size:', windowSize);
        console.log('Body Height:', bodyHeight);
        
        return scrollPosition + windowSize >= bodyHeight - 100;
      }

      window.addEventListener('scroll', function() {
        console.log('Scroll event triggered');
        if (isScrolledToBottom()) {
          console.log('Detected scroll to bottom');
          ScrollDetector.postMessage('bottom');
        }
      });

      // Initial check in case the page is not scrollable
      if (isScrolledToBottom()) {
        console.log('Page is not scrollable or already at bottom');
        ScrollDetector.postMessage('bottom');
      }

      console.log('Scroll detection script injected successfully');
    ''');
  }

  void closeApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }
}
