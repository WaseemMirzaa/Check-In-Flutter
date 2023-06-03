import 'package:check_in/ui/screens/persistent_nav_bar.dart';
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
      path: 'recipient@example.com',
      query: 'subject=Contact Us Inquiry&body=Name: ${nameController.text}\nEmail: ${emailController.text}',
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
      Get.snackbar("Alert", "Could not launch email app.",
          backgroundColor: Colors.white,
          borderWidth: 4,
          borderColor: Colors.red,
          colorText: Colors.black);
      print('Could not launch email app.');
    }
  }

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
              onTap: (){
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
        centerTitle: true,
        backgroundColor: whiteColor,
        title: poppinsText("Contact Us", 20, FontWeight.bold, blackColor),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 36),
            child: Column(
              children: [
                customTextField("Name", greenColor,nameController),
                customTextField("Email", greenColor, emailController),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 15,
            ),
            child: fullWidthButton("SUBMIT", () {
              _launchEmailApp();
            }),
          )
        ],
      ),
    );
  }
}
