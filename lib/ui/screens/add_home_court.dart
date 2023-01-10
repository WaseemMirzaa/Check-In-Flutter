import 'package:checkinmod/ui/screens/persistent_nav_bar.dart';
import 'package:checkinmod/ui/widgets/common_button.dart';
import 'package:checkinmod/utils/colors.dart';
import 'package:checkinmod/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

import '../../utils/gaps.dart';

class AddHomeCourt extends StatefulWidget {
  const AddHomeCourt({Key? key}) : super(key: key);

  @override
  State<AddHomeCourt> createState() => _AddHomeCourtState();
}

class _AddHomeCourtState extends State<AddHomeCourt>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GestureDetector(
                onTap: () {
                  pushNewScreen(context, screen: Home(), withNavBar: false);
                },
                child: Image.asset("assets/images/Group 12584.png",
                    fit: BoxFit.fitHeight),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                pushNewScreen(context,
                                screen: Home(), withNavBar: false);
                              },
                              child: SizedBox(
                                height: 2.1.h,
                                width: 2.9.w,
                                child: Image.asset("assets/images/Path 6.png"),
                              ),
                            ),
                            poppinsText("Add Home Court", 20, bold, blackColor),
                            SizedBox(
                              width: 10,
                            )
                          ],
                        ),
                        verticalGap(30),
                        Material(
                          borderRadius:  BorderRadius.circular(10),
                          elevation: 2,
                          shadowColor: Colors.grey,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: TextField(
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.only(left: 20, top: 15),
                                  filled: true,
                                  border: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  fillColor: Colors.white,
                                  hintText: "Find Courts Near You",
                                  hintStyle: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: medium,
                                      color: greyColor),
                                  suffixIcon: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 17,
                                        width: 17,
                                        child: Image.asset(
                                          "assets/images/Icon ionic-ios-search.png",
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      )
                                    ],
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                    fullWidthButton("SELECT", () {
                      pushNewScreen(context, screen: Home(), withNavBar: false);
                    })
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
