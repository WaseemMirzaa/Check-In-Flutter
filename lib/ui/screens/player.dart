import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
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
                  color: transparentColor,
                  child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset(AppAssets.LEFT_ARROW))),
            )
          ],
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: appWhiteColor,
        title: poppinsText(TempLanguage.player, 20, FontWeight.bold, appBlackColor),
      ),
      body: SingleChildScrollView(
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
                        width: 15.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: widget.user.photoUrl == ""
                              ? Border.all(width: 2, color: appGreenColor)
                              : null,
                          image: widget.user.photoUrl != ""
                              ? DecorationImage(
                                  fit: BoxFit.fill,
                                  image:
                                      // AssetImage(
                                      //     "assets/images/Mask Group 1.png")
                                      NetworkImage(
                                    widget.user.photoUrl,
                                  ))
                              : const DecorationImage(
                                  fit: BoxFit.fill,
                                  image: AssetImage(
                                    AppAssets.LOGO_NEW,
                                  )),
                        ),
                      ),
                      widget.user.isVerified == false
                          ? const SizedBox()
                          : Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                height: 5.5.h,
                                width: 12.1.w,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: AssetImage(
                                            AppAssets.INSTAGRAM_VERIFICATION))),
                              ),
                            ),
                    ],
                  ),
                ),
                verticalGap(0.5.h),
                poppinsText(
                    widget.user.name, 32, FontWeight.bold, appBlackColor),
                poppinsText(
                    "@${widget.user.email.substring(0, widget.user.email.indexOf('@'))}",
                    12,
                    FontWeight.normal,
                    appBlackColor),
              ],
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.24,),
            Column(
              children: [
                poppinsText(TempLanguage.homeCourt, 14, semiBold, appGreenColor),
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
                              appBlackColor),
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
                                AppAssets.MAP_PIN),
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
                      decoration: BoxDecoration(
                        color: appWhiteColor,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: greyColor.withOpacity(0.2),
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
                                  TempLanguage.aboutMe, 14, semiBold, appBlackColor),
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
                                    color: textColor)),
                          ),
                          // verticalGap(15),
                          Container(
                            height: 1,
                            color: greyColor,
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: 100,
                      color: appGreenColor,
                      height: 2,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
