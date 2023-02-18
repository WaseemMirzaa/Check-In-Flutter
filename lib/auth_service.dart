import 'package:checkinmod/controllers/user_controller.dart';
import 'package:checkinmod/modal/user_modal.dart';
import 'package:checkinmod/ui/screens/persistent_nav_bar.dart';
import 'package:checkinmod/ui/screens/start.dart';
import 'package:checkinmod/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';

UserController userController = Get.put(UserController());
final auth = FirebaseAuth.instance;
final snap = FirebaseFirestore.instance;

Future<void> signUp(
  email,
  password,
  userName,
  BuildContext context,
) async {
  try {
    await auth
        .createUserWithEmailAndPassword(email: email, password: password)
        // .then((value) async =>
        //     await addUserData(email: email, fullName: userName))
        .then((value) => auth.currentUser?.updateDisplayName(userName))
        .then((value) => snap.collection("USER").doc(auth.currentUser!.uid).set(
              {
                "user name": auth.currentUser!.displayName,
                "email": auth.currentUser!.email,
                "uid": auth.currentUser!.uid,
                "checkedIn": false,
              },
            )
                // .then((value) async => await toModal(context))
                .then((value) =>
                    pushNewScreen(context, screen: Home(), withNavBar: false)));
  } on FirebaseAuthException catch (e) {
    print('error message ${e.message}');
    Get.snackbar('Error', e.message ?? '', snackPosition: SnackPosition.BOTTOM);
    print('Failed with error code: ${e.code}');
    print(e.message);
  }
}

Future<void> login(email, password, context) async {
  try {
    await auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      // await toModal(context);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', 'useremail@gmail.com');
      pushNewScreen(context, screen: Home());
    });
  } on FirebaseAuthException catch (e) {
    print('error message ${e.message}');
    Get.snackbar('Error', e.message ?? '', snackPosition: SnackPosition.BOTTOM);
    print('Failed with error code: ${e.code}');
    print(e.message);
  }
  ;
}

Future<void> logout(context) async {
  // userController.userModel.value = UserModel();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('email');
  auth.signOut().then(
        (value) =>
            // pushNewScreen(context, screen: const StartView(), withNavBar: false)
            Navigator.of(context, rootNavigator: !false).pushReplacement(
                getPageRoute(PageTransitionAnimation.cupertino,
                    enterPage: StartView())),
      );
}

Future<void> delAcc(context) async {
  snap
      .collection("USER")
      .doc(auth.currentUser!.uid)
      .delete()
      .then((value) => auth.currentUser!.delete().then((value) {
            // pushNewScreen(
            //   context,
            //   screen: const StartView(),
            //   withNavBar: false,
            // );
            Navigator.of(context, rootNavigator: !false).pushReplacement(
                getPageRoute(PageTransitionAnimation.cupertino,
                    enterPage: StartView()));
          }));
}

toModal(BuildContext context) async {
  DocumentSnapshot snap = await FirebaseFirestore.instance
      .collection("USER")
      .doc(auth.currentUser?.uid ?? "")
      .get();
  UserModel userModel = UserModel.fromMap(snap.data() as Map<String, dynamic>);
}
