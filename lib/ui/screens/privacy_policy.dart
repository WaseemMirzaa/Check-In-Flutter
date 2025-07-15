import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:flutter/material.dart';
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
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              print('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            print('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
        ),
      )
      ..loadRequest(
          Uri.parse("https://sites.google.com/view/checkinhoops-privacy"));
  }

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
                // pushScreen(context, screen: Home(), withNavBar: false);
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
            TempLanguage.privacyPolicy, 20, FontWeight.bold, appBlackColor),
      ),
      body: Container(
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
              offset: const Offset(0, -3), // changes position of shadow
            ),
          ],
        ),
        child: Builder(builder: (BuildContext context) {
          return WebViewWidget(controller: controller);
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
