import 'package:check_in/ui/screens/persistent_nav_bar.dart';
import 'package:check_in/ui/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
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
                customTextField("Name", greenColor),
                customTextField("Email", greenColor),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                    height: 143,
                    width: MediaQuery.of(context).size.width,
                    child: Image(
                      image: AssetImage("assets/images/Group 12499.png"),
                      fit: BoxFit.fill,
                    )),
                Positioned(
                    left: 30,
                    right: 30,
                    child: poppinsText(
                        "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore  et dolore magna aliquyam erat, sed diam voluptua. At vero.",
                        14,
                        regular,
                        textColor))
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 15,
            ),
            child: fullWidthButton("SUBMIT", () {
              pushNewScreen(context, screen: Home(), withNavBar: false);
            }),
          )
        ],
      ),
    );
  }
}
