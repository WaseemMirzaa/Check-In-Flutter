import 'package:checkinmod/auth_service.dart';
import 'package:checkinmod/modal/user_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
