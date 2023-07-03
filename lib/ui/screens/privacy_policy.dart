import 'dart:async';

import 'package:check_in/ui/screens/persistent_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/colors.dart';
import '../../utils/styles.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            SizedBox(
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
                child: Image.asset("assets/images/Path 6.png"),
              ),
            )
          ],
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: whiteColor,
        title: poppinsText("Privacy Policy", 20, FontWeight.bold, blackColor),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              //   spreadRadius: -12,
              offset: Offset(0, -3), // changes position of shadow
            ),
          ],
        ),
        child: Builder(builder: (BuildContext context) {
          return WebView(
            initialUrl:
                // "https://www.freeprivacypolicy.com/live/fc6c8c08-7126-407d-b16b-5ac249c71a80",
                "https://docs.google.com/document/d/1ILdrqJL3AYxTZ7zA-QQoPJbFafoE3FscMrKROymN4y0/edit?usp=sharing",
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
      // Container(
      //   margin: EdgeInsets.only(top: 10),
      //   padding: EdgeInsets.only(top: 30, left: 30, right: 30),
      //   decoration: BoxDecoration(
      //     color: Colors.white,
      //     borderRadius: BorderRadius.only(
      //       topRight: Radius.circular(30),
      //       topLeft: Radius.circular(30),
      //     ),
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.grey.withOpacity(0.2),
      //         blurRadius: 5,
      //         //   spreadRadius: -12,
      //         offset: Offset(0, -3), // changes position of shadow
      //       ),
      //     ],
      //   ),
      //   child: poppinsText(
      //       "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore.Enim diam vulputate ut pharetra sit amet. In hac habitasse platea dictumst quisque sagittis purus. Vel risus commodo viverra maecenas accumsan lacus vel. Arcu non sodales neque sodales ut etiam. Lectus arcu bibendum at varius vel pharetra vel turpis nunc. Fusce id velit ut tortor pretium viverra suspendisse potenti nullam. Risus quis varius quam quisque id diam. Blandit aliquam etiam erat velit scelerisque in. Sed felis eget velit aliquet sagittis id consectetur purus. Est placerat in egestas erat imperdiet sed. Elit pellentesque habitant morbi tristique senectus et netus. Porttitor leo a diam sollicitudin tempor id eu. Turpis massa tincidunt dui ut ornare lectus sit ",
      //       14,
      //       regular,
      //       textColor),
      // ),
    );
  }
}
