import 'package:check_in/auth_service.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class FollowingScreen extends StatefulWidget {
  final List<dynamic> userIds;
  const FollowingScreen({super.key, required this.userIds});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  @override
  Widget build(BuildContext context) {
    Future<List<UserModel>?> fetchUserData() async {
      try {
        List<UserModel> followingList = [];

        for (String userId in widget.userIds) {
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection(Collections.USER)
              .doc(userId)
              .get();

          if (userSnapshot.exists) {
            UserModel currentUser =
                UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);
            followingList.add(currentUser);
          }
        }

        return followingList;
      } catch (e) {
        print('Error fetching user data: $e');
        return null;
      }
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: whiteColor,
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: SizedBox(
              height: 2.1.h,
              width: 2.9.w,
              child: Image.asset(
                AppAssets.LEFT_ARROW,
                scale: 4,
              ),
            ),
          ),
          title: Text(
            'Following',
            style: TextStyle(
              fontFamily: TempLanguage.poppins,
              fontSize: 20,
              color: blackColor,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
            softWrap: false,
          ),
          elevation: 0,
        ),
        backgroundColor: whiteColor,
        body: FutureBuilder<List<UserModel>?>(
            future: fetchUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data!.isNotEmpty) {
                List<UserModel> following = snapshot.data!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: horizontalPadding),
                      child: Text(
                        '${following.length} Following',
                        style: TextStyle(
                          fontFamily: TempLanguage.poppins,
                          fontSize: 18,
                          color: greenColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: ListView.builder(
                          itemCount: following.length,
                          shrinkWrap: true,
                          itemBuilder: (context, int index) {
                            UserModel followingData = following[index];

                            return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: horizontalPadding,
                                      vertical: 1.1.h),
                                  child: Container(
                                    height: 11.h,
                                    decoration: BoxDecoration(
                                      color: whiteColor,
                                      borderRadius: BorderRadius.circular(6.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: blackTranslucentColor,
                                          offset: const Offset(0, 1),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        userController
                                                                .userModel
                                                                .value
                                                                .photoUrl ??
                                                            ""),
                                                    fit: BoxFit.fill)),
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Text.rich(TextSpan(
                                                  text:
                                                      '${followingData.userName}\n',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        TempLanguage.poppins,
                                                    fontSize: 15,
                                                    color: blackColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      style: TextStyle(
                                                        fontFamily: TempLanguage
                                                            .poppins,
                                                        fontSize: 12,
                                                        color: greenColor,
                                                        height: 1.7,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              '${followingData.homeCourt}',
                                                          style: TextStyle(
                                                            color: greyColor,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ])),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(TempLanguage.wentWrong),
                );
              } else {
                return Center(
                  child: Text(TempLanguage.noDataFound),
                );
              }
            }));
  }
}
