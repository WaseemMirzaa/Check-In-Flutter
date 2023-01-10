import 'package:checkinmod/ui/screens/contact_us.dart';
import 'package:checkinmod/ui/screens/player.dart';
import 'package:checkinmod/ui/screens/privacy_policy.dart';
import 'package:checkinmod/ui/screens/terms_conditions.dart';
import 'package:checkinmod/ui/widgets/common_button.dart';
import 'package:checkinmod/utils/colors.dart';
import 'package:checkinmod/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

import 'Players.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({Key? key}) : super(key: key);

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> with SingleTickerProviderStateMixin {
  int index = 0;

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  changeIndex() {
    if (index == 0) {
      index = 1;
    } else {
      index = 0;
    }
    setState(() {});
    print(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      drawer: Drawer(
        backgroundColor: whiteColor,
        child: Container(
          height: 300,
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
               DrawerHeader(
                decoration: BoxDecoration(
                  color: whiteColor,
                ),
                child:  Image.asset("assets/images/logo.jpeg",),
              ),
              const SizedBox(
                height: 20,
              ),
              ListTile(
                leading: const Icon(
                  Icons.contact_page,
                ),
                title: const Text('Contact Us'),
                onTap: () {
                  pushNewScreen(context,
                      screen: const ContactUs(), withNavBar: false);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.privacy_tip,
                ),
                title: const Text('Privacy Policy'),
                onTap: () {
                  pushNewScreen(context,
                      screen: const PrivacyPolicy(), withNavBar: false);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.privacy_tip,
                ),
                title: const Text('Terms And Conditions'),
                onTap: () {
                  pushNewScreen(context,
                      screen: const TermsAndConditions(), withNavBar: false);
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GestureDetector(
                onTap: () {
                  pushNewScreen(context,
                      screen: const PlayersView(), withNavBar: false);
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
                height: MediaQuery.of(context).size.height * 0.84,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              _scaffoldState.currentState?.openDrawer();
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: greenColor, shape: BoxShape.circle),
                              child: Icon(
                                Icons.menu,
                                color: whiteColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Material(
                          borderRadius:  BorderRadius.circular(10),
                          elevation: 2,
                          shadowColor: Colors.grey,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: TextField(
                              decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.only(left: 20, top: 15),
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
                                      const SizedBox(
                                        width: 20,
                                      )
                                    ],
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                    fullWidthButton(index == 0 ? "CHECK IN" : "CHECK OUT", () {
                      changeIndex();
                      print(index);
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
