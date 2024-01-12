import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart' hide greenColor, blackColor, whiteColor;
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/user_controller.dart';
import '../../core/constant/app_assets.dart';
import '../../core/constant/constant.dart';
import '../../core/constant/temp_language.dart';
import '../../utils/colors.dart';
import '../../utils/gaps.dart';
import '../../utils/styles.dart';
import '../screens/add_home_court.dart';

class AboutSection extends StatefulWidget {
  final UserController userController;
  const AboutSection({Key? key, required this.userController})
      : super(key: key);

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  bool tapped = false;
  String aboutMe = '';
  TextEditingController aboutMeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // aboutMe = (widget.userController.userModel.value.aboutMe.isEmptyOrNull)
    //     ? TempLanguage.tellUsAboutGame
    //     : widget.userController.userModel.value.aboutMe ?? "";

    aboutMe = widget.userController.userModel.value.aboutMe ?? "";

    aboutMeController.text = aboutMe;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        poppinsText(TempLanguage.homeCourt, 14, semiBold, greenColor),
        verticalGap(0.8.h),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  poppinsText(
                      (widget.userController.userModel.value.homeCourt
                              .isEmptyOrNull)
                          ? ""
                          : widget.userController.userModel.value.homeCourt ??
                              "",
                      14,
                      semiBold,
                      blackColor),
                  InkWell(
                    onTap: () {
                      pushNewScreen(context,
                          screen: const AddHomeCourt(), withNavBar: false);
                    },
                    child: SizedBox(
                      height: 2.3.h,
                      width: 4.47.w,
                      child: Image.asset(AppAssets.MAP_PIN),
                    ),
                  )
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
        Column(
          // alignment: Alignment.topCenter,
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 30,
                right: 30,
              ),
              height: 20.h,
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: greyColor.withOpacity(0.2),
                    blurRadius: 1,
                    //   spreadRadius: -12,
                    offset: const Offset(0, -3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 0.5.h,
                    decoration: BoxDecoration(
                        color: greenColor,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5))),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      poppinsText(
                          TempLanguage.aboutMe, 14, semiBold, blackColor),
                      InkWell(
                        onTap: () => setState(() {
                          if(tapped){
                            setState(() {
                              // userController.userModel.value.
                              //..........
                              aboutMe = aboutMeController.text;
                              widget.userController.userModel.value.aboutMe = aboutMe;
                              FirebaseFirestore.instance
                                  .collection(Collections.USER)
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .update({UserKey.ABOUT_ME: aboutMe});
                            });
                          }
                          tapped = !tapped;
                        }),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: SizedBox(
                            height: 1.8.h,
                            // width: 15.w,
                            child: tapped ?
                            poppinsText(TempLanguage.save, 14, semiBold, greenColor)
                                :
                            Image.asset(AppAssets.EDIT_ICON,),
                          ),
                        ),
                      )
                    ],
                  ),
                  TextField(
                    controller: aboutMeController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) {
                      // setState(() {
                      //   // userController.userModel.value.
                      //   //..........
                      //   aboutMe = value;
                      //   widget.userController.userModel.value.aboutMe = value;
                      //   FirebaseFirestore.instance
                      //       .collection(Collections.USER)
                      //       .doc(FirebaseAuth.instance.currentUser!.uid)
                      //       .update({UserKey.ABOUT_ME: aboutMe});
                      // });
                    },
                    maxLines:
                        widget.userController.userModel.value.isVerified ==
                                false
                            ? 3
                            : 5,
                    onChanged: (val) {},
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        enabled: tapped,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        hintText: TempLanguage.tellUsAboutGame,
                        helperStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: regular,
                            color: silverColor)),
                  ),
                  // verticalGap(20),
                  Container(
                    height: 1,
                    color: greyColor,
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
