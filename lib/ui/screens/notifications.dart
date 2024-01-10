import 'package:check_in/Services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../core/constant/app_assets.dart';
import '../../core/constant/temp_language.dart';
import '../../model/notification_modal.dart';
import '../../utils/DateTimeUtils.dart';
import '../../utils/colors.dart';
import '../../utils/gaps.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationService notificationService = NotificationService();

  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
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
          title: Padding(
            padding: EdgeInsets.only(right: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/bell.png',
                  scale: 3,
                  color: blackColor,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: TempLanguage.poppins,
                    fontSize: 20,
                    color: blackColor,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.right,
                  softWrap: false,
                ),
              ],
            ),
          ),
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: FutureBuilder<List<dynamic>>(
            future: notificationService.getNotifications(auth.currentUser!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // return const Center(child: CircularProgressIndicator());
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data!.isNotEmpty) {
                List notifications = snapshot.data ?? [];
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, int index) {
                        // final imageIndex = index % courtsList.length;
                        NotificationModel notification = notifications[index];

                        String imagePath = '';
                        if (notification.type == 'chat') {
                          imagePath = 'assets/images/chat_image.png';
                        } else if (notification.type == 'groupChat') {
                          imagePath = 'assets/images/group_chat_image.png';
                        } else if (notification.type == 'experience') {
                          imagePath = 'assets/images/experience_type.png';
                        }
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
                                        ),
                                        child: Image.asset(
                                          imagePath,
                                          scale: 3,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text.rich(TextSpan(
                                              text: '${notification.title}\n',
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
                                                    fontFamily:
                                                        TempLanguage.poppins,
                                                    fontSize: 12,
                                                    color: greenColor,
                                                    height: 1.7,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          '${notification.body}',
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
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          notification.isRead
                                              ? Container(
                                                  height: 15,
                                                  width: 15,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            999),
                                                  ),
                                                )
                                              : Container(
                                                  height: 15,
                                                  width: 15,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              999),
                                                      color: greenColor),
                                                ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            '${DateFormat.jm().format(notification.time)}',
                                            style: TextStyle(
                                              color: silverColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding + 15),
                              child: Container(
                                height: 1,
                                color: silverColor,
                              ),
                            )
                          ],
                        );
                      }),
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
