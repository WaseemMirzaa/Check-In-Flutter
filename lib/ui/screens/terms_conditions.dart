import 'dart:async';

import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/colors.dart';
import '../../utils/styles.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({Key? key}) : super(key: key);

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
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
                Navigator.pop(context);
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
        backgroundColor: whiteColor,
        title: poppinsText(
            TempLanguage.termsAndConditions, 20, FontWeight.bold, blackColor),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        decoration: BoxDecoration(
          color: whiteColor,
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
                "https://sites.google.com/view/checkin-terms",
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
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
              print('Page finished loading: $url');
            },
            gestureNavigationEnabled: true,
          );
        }),
      ),
    );
  }
}
