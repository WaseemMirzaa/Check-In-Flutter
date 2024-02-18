import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/ui/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sizer/sizer.dart';

import '../../utils/colors.dart';
import '../../utils/styles.dart';
import '../widgets/text_field.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _launchEmailApp() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'support@checkinhoops.net',
      query:
          'subject=Contact Us Inquiry&body=Name: ${nameController.text}\nEmail: ${emailController.text}',
    );

    final String url = params.toString();
    bool canLaunch = false;
    try {
      canLaunch = await canLaunchUrl(params);
    } catch (e) {
      print(e);
    }

    if (canLaunch) {
      await launchUrl(params);
    } else {
      Get.snackbar(TempLanguage.emailErrorToastTitle, TempLanguage.emailErrorToastMessage,
          backgroundColor: appWhiteColor,
          borderWidth: 4,
          borderColor: redColor,
          colorText: appBlackColor);
      print('Could not launch email app.');
    }
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
        title: poppinsText(TempLanguage.contactUs, 20, FontWeight.bold, appBlackColor),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 36),
            child: Column(
              children: [
                customTextField(TempLanguage.nameCap, appGreenColor, nameController),
                customTextField(TempLanguage.emailCap, appGreenColor, emailController),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 15,
            ),
            child: fullWidthButton(TempLanguage.submit, () {
              _launchEmailApp();
            }),
          )
        ],
      ),
    );
  }
}
