import 'dart:math';

import 'package:check_in/auth_service.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future addUserData({
  required String fullName,
  required String email,
  BuildContext? context,
}) async {
  try {
    // showLoadingIndicator(context!);
    if (auth.currentUser != null) {
      UserModel userModel = UserModel(
        email: email,
        uid: auth.currentUser!.uid,
        userName: fullName,
      );
      FirebaseFirestore.instance
          .collection("USER")
          .doc(auth.currentUser!.uid)
          .set(userModel.toMap());
    } else {
      Navigator.pop(context!);
    }
  } on FirebaseAuthException catch (e) {
    Navigator.of(context!).pop();
    if (e.message != null) print(e.message!);
  }
}

void getUsersOnLocation(LatLng courtLocation) async{

  final double latitude = 37.7749;
  final double longitude = -122.4194;
  final double earthRadius = 6371; // Earth's radius in kilometers
  final double radiusInKm = 10; // Example distance in kilometers

  final double radius = _kilometersToDegrees(radiusInKm);

  final pi = 3.14159;

  final double lowerLat = latitude - (radius / earthRadius) * (180 / pi);
  final double lowerLng = longitude - (radius / earthRadius) * (180 / pi) / cos(latitude * pi / 180);
  final double upperLat = latitude + (radius / earthRadius) * (180 / pi);
  final double upperLng = longitude + (radius / earthRadius) * (180 / pi) / cos(latitude * pi / 180);

  final collectionReference = FirebaseFirestore.instance.collection('users');

  final QuerySnapshot querySnapshot = await collectionReference
      .where('latitude', isGreaterThan: lowerLat)
      .where('latitude', isLessThan: upperLat)
      .where('longitude', isGreaterThan: lowerLng)
      .where('longitude', isLessThan: upperLng)
      .get();

  final List<DocumentSnapshot> documentList = querySnapshot.docs;

  for (DocumentSnapshot document in documentList) {
    final user = document.data();
    // Process the user data
    print(user);
  }
}



double _degreesToKilometers(double degrees) {
  double earthRadiusInKilometers = 6371;
  return degrees * (earthRadiusInKilometers * pi / 180);
}

double _kilometersToDegrees(double kilometers) {
  double earthRadiusInKilometers = 6371;
  return kilometers / (earthRadiusInKilometers * pi / 180);
}
