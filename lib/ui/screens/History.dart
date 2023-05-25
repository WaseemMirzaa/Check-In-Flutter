import 'package:checkinmod/utils/gaps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  var courtsList = [
    'pexels-king-siberia-2277981',
    'pexels-ricardo-esquivel-1607855',
    'pexels-daniel-absi-680074',
    'pexels-tom-jackson-2891884',
    'pexels-tom-jackson-2891884',
    'pexels-king-siberia-2277981',
    'pexels-ricardo-esquivel-1607855',
    'pexels-daniel-absi-680074',
    'pexels-tom-jackson-2891884',
    'pexels-tom-jackson-2891884',
    'pexels-king-siberia-2277981',
    'pexels-ricardo-esquivel-1607855',
    'pexels-daniel-absi-680074',
    'pexels-tom-jackson-2891884',
    'pexels-tom-jackson-2891884',
    'pexels-king-siberia-2277981',
    'pexels-ricardo-esquivel-1607855',
    'pexels-daniel-absi-680074',
    'pexels-tom-jackson-2891884',
    'pexels-tom-jackson-2891884',
  ];

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
        .collection("USER")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    final checkedCourtsData = documentSnapshot.data()?["checkedCourts"];

    if (checkedCourtsData != null && checkedCourtsData is List<dynamic>) {
      dataArray = List.from(checkedCourtsData);
    } else {
      dataArray = [];
    }

    print(dataArray);
    print(dataArray.length);

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
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'History',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            color: const Color(0xff000000),
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.right,
          softWrap: false,
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ListView.builder(
            itemCount: dataArray.length,
            itemBuilder: (context, int index) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 1.1.h),
                    child: Container(
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: const Color(0xffffffff),
                        borderRadius: BorderRadius.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x29000000),
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
                                "assets/images/${courtsList[index]}.png",
                                scale: 3,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Text.rich(TextSpan(
                              text: '${dataArray[index]["courtName"]}\n',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 1.6.h,
                                color: const Color(0xff000000),
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 1.1.h,
                                    color: const Color(0xff007a33),
                                    height: 1.7,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Court Location :',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' ${dataArray[index]["courtName"]}\n',
                                      style: TextStyle(
                                        color: const Color(0xff9f9f9f),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Check in :',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' ${dataArray[index]["checkInTime"]} ',
                                      style: TextStyle(
                                        color: const Color(0xff9f9f9f),
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
                      color: Color(0xff9f9f9f),
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }
}
