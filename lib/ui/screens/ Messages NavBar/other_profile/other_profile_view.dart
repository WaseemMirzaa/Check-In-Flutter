import 'package:check_in/auth_service.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';


class OtherProfileView extends StatefulWidget {
  final String uid;

  const OtherProfileView({super.key, required this.uid});

  @override
  State<OtherProfileView> createState() => _OtherProfileViewState();
}

class _OtherProfileViewState extends State<OtherProfileView> {
  Stream<UserModel> getProfile(String uid) {
    return FirebaseFirestore.instance
        .collection(Collections.USER)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data != null) {
        return UserModel.fromMap(data);
      } else {
        // Handle the case when user data is not available
        // You can throw an error, return a default user, or handle it as per your application's logic
        throw Exception("User data not available");
      }
    });
  }
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
        title: poppinsText(TempLanguage.profile, 20, FontWeight.bold, appBlackColor),
      ),
      body: StreamBuilder<UserModel>(
        stream: getProfile(widget.uid),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
              Center(child: CircularProgressIndicator()),
            ],);
          }else if(snapshot.hasError){
            return Text(snapshot.error.toString());
          }else {
            final userItems = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
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
                                shape: BoxShape.circle,
                                border: userItems.photoUrl == ""
                                    ? Border.all(
                                    width: 2, color: appGreenColor)
                                    : null,
                                image: userItems.photoUrl != ""
                                    ? DecorationImage(
                                    fit: BoxFit.fill,
                                    image:
                                    // AssetImage(
                                    //     "assets/images/Mask Group 1.png")
                                    NetworkImage(
                                      userItems.photoUrl!,
                                    ))
                                    : const DecorationImage(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                      AppAssets.LOGO_NEW,
                                    )),
                              ),
                            ),
                            userItems.isVerified == false
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
                                            AppAssets
                                                .INSTAGRAM_VERIFICATION))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      verticalGap(0.5.h),
                      poppinsText(
                          userItems.userName!, 32, FontWeight.bold,
                          appBlackColor),
                      poppinsText(
                          "@${userItems.email!.substring(0, userItems.email!
                              .indexOf('@'))}",
                          12,
                          FontWeight.normal,
                          appBlackColor),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Container(
                        padding:
                        const EdgeInsets.only(
                            left: 30, right: 30, top: 30),
                        height: 200,
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
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                poppinsText(
                                    TempLanguage.aboutMe, 14, semiBold,
                                    appBlackColor),
                              ],
                            ),
                            TextFormField(
                              maxLines: 4,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  enabled: false,
                                  hintText: userItems.aboutMe! == ""
                                      ? ""
                                      : userItems.aboutMe!,
                                  helperStyle: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: regular,
                                      color: textColor)),
                            ),
                            Spacer(),
                            Container(
                              height: 1,
                              color: greyColor,
                            )
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            );
          }
        }
      ),
    );
  }
}
