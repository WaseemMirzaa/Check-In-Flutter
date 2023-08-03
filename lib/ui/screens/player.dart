import 'package:check_in/ui/screens/Players.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../utils/gaps.dart';

class PlayerScreen extends StatefulWidget {
  final User user;

  const PlayerScreen({super.key, required this.user});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool isEditableStatus = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 25,
            ),
            SizedBox(
              height: 2.1.h,
              width: 2.9.w,
              child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset("assets/images/Path 6.png"))),
            )
          ],
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: whiteColor,
        title: poppinsText("Player", 20, FontWeight.bold, blackColor),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  verticalGap(3.h),
                  SizedBox(
                    width: 35.9.w,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          height: 15.h,
                          width: 32.9.w,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              image:
                                 DecorationImage(
                                  fit: BoxFit.fill,
                                  image:
                                  // AssetImage(
                                  //     "assets/images/Mask Group 1.png")
                                  NetworkImage(
                                      widget.user.photoUrl != "" ? widget.user.photoUrl :'https://firebasestorage.googleapis.com/v0/b/check-in-7ecd7.appspot.com/o/placeholders%2Fplayer.png?alt=media&token=3f50ba31-00ec-483f-ac03-a13d5e0a260c',
                                     ))
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            height: 5.5.h,
                            width: 12.1.w,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/instagram-verification-badge.png"))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalGap(0.5.h),
                  poppinsText(
                      widget.user.name, 32, FontWeight.bold, blackColor),
                  poppinsText(
                      "@${widget.user.email.substring(0, widget.user.email.indexOf('@'))}",
                      12,
                      FontWeight.normal,
                      blackColor),
                ],
              ),
              Column(
                children: [
                  poppinsText("Home Court", 14, semiBold, greenColor),
                  verticalGap(0.8.h),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            poppinsText(
                                widget.user.court == ""
                                    ? ""
                                    : widget.user.court,
                                14,
                                semiBold,
                                blackColor),
                            // InkWell(
                            //   onTap: () {
                            //     pushNewScreen(context,
                            //         screen: const AddHomeCourt(isMyProfile: false,),
                            //         withNavBar: false);
                            //   },
                            //   child:
                            SizedBox(
                              height: 2.3.h,
                              width: 4.47.w,
                              child: Image.asset(
                                  "assets/images/Icon feather-map-pin.png"),
                            ),
                            // )
                          ],
                        ),
                        verticalGap(1.3.h),
                        Container(
                          height: 1,
                          color: greyColor,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 3.5.h,
                  ),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.only(left: 30, right: 30, top: 30),
                        height: 200,
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 1,
                              //   spreadRadius: -12,
                              offset: const Offset(
                                  0, -3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                poppinsText(
                                    "About me", 14, semiBold, blackColor),
                              ],
                            ),
                            TextFormField(
                              maxLines: 5,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  enabled: false,
                                  hintText: widget.user.about == ""
                                      ? ""
                                      : widget.user.about,
                                  helperStyle: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: regular,
                                      color: const Color(0xff777777))),
                            ),
                            verticalGap(15),
                            Container(
                              height: 1,
                              color: greyColor,
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: 100,
                        color: greenColor,
                        height: 2,
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
