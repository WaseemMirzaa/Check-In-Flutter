import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sizer/sizer.dart';

import '../../core/constant/constant.dart';
import '../../utils/DateTimeUtils.dart';
import '../../utils/colors.dart';
import '../../utils/common.dart';
import '../../utils/styles.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {

  List<String> courts = [
    "Boston ",
    "Philadelphia",
    "Chicago",
    "Manhattan",
    "Los Angeles"
  ];

  List<dynamic> dataArray = [];

  Future<List<dynamic>> fetchData() async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection(Collections.USER)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    final checkedCourtsData = documentSnapshot.data()?[CourtKey.CHECKED_COURTS];

    if (checkedCourtsData != null && checkedCourtsData is List<dynamic>) {
      dataArray = List.from(checkedCourtsData).reversed.toList();
    } else {
      dataArray = [];
    }

    // print(dataArray);
    // print(dataArray.length);

    setState(
        () {}); // Assuming this method is inside a StatefulWidget, call setState to update the state

    return dataArray;
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    fetchData();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        centerTitle: true,
        title: Text(
          TempLanguage.history,
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
      backgroundColor: Colors.white,
      body: dataArray.isEmpty
          ? Center(child: Text(TempLanguage.noDataFound),)
          : Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ListView.builder(
            itemCount: dataArray.length,
            itemBuilder: (context, int index) {
              final imageIndex = index % courtsList.length;
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 1.1.h),
                    child: Container(
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: blackTranslucentColor,
                            offset: Offset(0, 1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              height: 10.2.h,
                              width: 22.3.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Image.asset(
                                "assets/images/${courtsList[imageIndex]}.png",
                                scale: 3,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Text.rich(TextSpan(
                              text: '${dataArray[index]["courtName"]}\n',
                              style: TextStyle(
                                fontFamily: TempLanguage.poppins,
                                fontSize: 1.6.h,
                                color: blackColor,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(
                                  style: TextStyle(
                                    fontFamily: TempLanguage.poppins,
                                    fontSize: 1.1.h,
                                    color: greenColor,
                                    height: 1.7,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: TempLanguage.courtLocation,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' ${dataArray[index]["courtName"]}\n',
                                      style: TextStyle(
                                        color: silverColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: TempLanguage.checkInHistory,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' ${DateTimeUtils.time24to12(dataArray[index]["checkInTime"])} ',
                                      style: TextStyle(
                                        color: silverColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ]))
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
      ),
    );
  }
}
