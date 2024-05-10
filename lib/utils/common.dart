

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

 Future<bool> showExitPopup(BuildContext? context) async {
    return await showDialog(
          context: context!,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you want to exit an App?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                //return false when click on "NO"
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                //return true when click on "Yes"
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false; //if showDialouge had returned null, then return false
  }

List<String> setSearchParam(String caseNumber) {
  List<String> caseSearchList = [];
  for (int i = 0; i < caseNumber.length; i++) {
    for (int j = i + 1; j <= caseNumber.length; j++) {
      caseSearchList.add(caseNumber.substring(i, j));
    }
  }
  return caseSearchList;
}

Widget progressDialog() {
  return Container(
    padding: const EdgeInsets.all(16),
    color: Colors.white.withOpacity(0.8),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _getLoadingIndicator(),
      ],
    ),
  );
}

void showLoadingIndicator(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            backgroundColor: Colors.white,
            content: progressDialog(),
          ));
    },
  );
}

Widget _getLoadingIndicator() {
  return const Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: SizedBox(
      width: 32,
      height: 32,
      child: CircularProgressIndicator(strokeWidth: 3),
    ),
  );
}

Timestamp convertDateToTimeStamp(String date) {
  DateTime dateTime = DateTime.parse(date);
  Timestamp firebaseTimestamp = Timestamp.fromDate(dateTime);
  return firebaseTimestamp;
}