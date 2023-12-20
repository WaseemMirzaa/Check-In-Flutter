import 'package:check_in/ui/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../auth_service.dart';
import '../../model/user_modal.dart';
import '../../utils/DateTimeUtils.dart';
import '../../utils/common.dart';
import '../../utils/gaps.dart';

Future<List<Map<String, dynamic>>> getUniqueCourtNameMaps() async {
  CollectionReference<Map<String, dynamic>> collectionReference = FirebaseFirestore.instance.collection('USER');
  DocumentSnapshot<Map<String, dynamic>> document = await collectionReference.doc(userController.userModel.value.uid).get();

  Set<int> uniqueCourtIds = <int>{};
  List<Map<String, dynamic>> resultMaps = [];

  List<Map<String, dynamic>> mapsArray = List<Map<String, dynamic>>.from(document.data()?['checkedCourts']);

  for (var map in mapsArray) {
    int courtId = map['id'] ?? 0;
    bool isGold = map['isGolden'] ?? false;
    if (isGold && courtId > 0 && !uniqueCourtIds.contains(courtId)) {
      resultMaps.add(map);
      uniqueCourtIds.add(courtId);
    }
  }

  return resultMaps;
}

class UniqueCourtsScreen extends StatelessWidget {
  const UniqueCourtsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black,),
        ),
        title: const Text(
          'Golden Courts',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            color: Color(0xff000000),
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.right,
          softWrap: false,
        ),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getUniqueCourtNameMaps(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            return ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, int index) {
                  final imageIndex = index % courtsList.length;
                  final court = snapshot.data![index];
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
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x29000000),
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
                                  text: '${court["courtName"]}\n',
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
                                        const TextSpan(
                                          text: 'Court Location :',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                          ' ${court["courtName"]}\n',
                                          style: const TextStyle(
                                            color: Color(0xff9f9f9f),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        // const TextSpan(
                                        //   text: 'Check in :',
                                        //   style: TextStyle(
                                        //     fontWeight: FontWeight.w600,
                                        //   ),
                                        // ),
                                        // TextSpan(
                                        //   text:
                                        //   ' ${DateTimeUtils.time24to12(court["checkInTime"])} ',
                                        //   style: const TextStyle(
                                        //     color: Color(0xff9f9f9f),
                                        //     fontWeight: FontWeight.w500,
                                        //   ),
                                        // ),
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
                          color: const Color(0xff9f9f9f),
                        ),
                      )
                    ],
                  );
                });
          } else {
            return const Center(child: Text('Something went wrong'),);
          }
        },
      ),
    );
  }
}
