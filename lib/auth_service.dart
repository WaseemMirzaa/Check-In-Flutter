import 'package:check_in/Services/dio_config.dart';
import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/Services/payment_service.dart';
import 'package:check_in/Services/push_notification_service.dart';
import 'package:check_in/Services/user_services.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/persistent_nav_bar.dart';
import 'package:check_in/ui/screens/start.dart';
import 'package:check_in/utils/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

UserController userController = Get.put(UserController(UserServices()));
final auth = FirebaseAuth.instance;
final snap = FirebaseFirestore.instance;
NewsFeedController newsFeedController = Get.put(NewsFeedController(NewsFeedService()));

Future<bool> signUp(
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
        .then((value) async {
      List<String> nameSearchParams = setSearchParam(userName);
      String token = await FCMManager.getFCMToken();
      String customerId = await PaymentService.createStripeCustomer(email: email);
      snap.collection(Collections.USER).doc(auth.currentUser!.uid).set({
        UserKey.USER_NAME: auth.currentUser!.displayName,
        UserKey.EMAIL: auth.currentUser!.email,
        UserKey.UID: auth.currentUser!.uid,
        UserKey.CHECKED_IN: false,
        UserKey.IS_VERIFIED: false,
        UserKey.CUSTOMER_ID: customerId,
        UserKey.PARAMS: FieldValue.arrayUnion(nameSearchParams),
        UserKey.IS_TERMS_VERIFIED: true,
        //TODO: Change it to arrayUnion
        // UserKey.DEVICE_TOKEN:
        // FieldValue.arrayUnion([token])
        UserKey.DEVICE_TOKEN: [token]
      }).then((value) => pushNewScreen(context, screen: const Home(), withNavBar: false));
    });
  } on FirebaseAuthException catch (e) {
    print('error message ${e.message}');
    Get.snackbar('Error', e.message ?? '', snackPosition: SnackPosition.TOP);
    print('Failed with error code: ${e.code}');
    print(e.message);
    return false;
  }
  return true;
}

Future<void> login(email, password, context) async {
  try {
    await auth.signInWithEmailAndPassword(email: email, password: password).then((value) async {
      // print(FCMManager.fcmToken!);
      final token = await FCMManager.getFCMToken();
      List<String> tokens = [];
      tokens.add(token);
      print(token);
      print('========> toeken');
      if (token.isNotEmpty) {
        snap.collection(Collections.USER).doc(value.user!.uid).update(
          {
            UserKey.DEVICE_TOKEN: FieldValue.arrayUnion(tokens)
          },
        );
      }
      // Temporary --Save userid in global userid for chat
      // GlobalVariable.userid = value.user!.uid;
      await toModal(context);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', 'useremail@gmail.com');
      userController.userModel.value.uid.isEmptyOrNull ? null : pushNewScreen(context, screen: const Home());
    });
  } on FirebaseAuthException catch (e) {
    print('error message ${e.message}');
    // Get.snackbar('Error', e.message ?? '', snackPosition: SnackPosition.BOTTOM);
    Get.snackbar('Error', "Invalid username or password", snackPosition: SnackPosition.TOP);
    print('Failed with error code: ${e.code}');
    print(e.message);
  }
}

Future<void> logout(context) async {
  // userController.userModel.value = UserModel();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('email');
  final token = await FCMManager.getFCMToken();
  newsFeedController.clearNewsFeeds();
  newsFeedController.clearMyPosts();
  newsFeedController.clearUserPosts();
  //Checkout
  print('-----------token-----------$token');
  snap.collection(Collections.USER).doc(auth.currentUser!.uid).update({
    UserKey.CHECKED_IN: false,
    UserKey.DEVICE_TOKEN: FieldValue.arrayRemove([token]),
    CourtKey.COURT_LAT: FieldValue.delete(),
    CourtKey.COURT_LNG: FieldValue.delete(),
    // UserKey.DEVICE_TOKEN: []
  });

  auth.signOut().then(
        (value) =>
            // pushNewScreen(context, screen: const StartView(), withNavBar: false)
            Get.offAll(StartView(
          isBack: false,
        )),
        // Navigator.of(context, rootNavigator: !false).pushReplacement(
        //     getPageRoute(PageTransitionAnimation.cupertino,
        //         enterPage: StartView())),
      );
}

Future<void> delAcc(context) async {
  TextEditingController pass = TextEditingController();
  return showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Confirmation'),
      content: const Text(
          'Are you sure you want to delete your account?\nThese changes are irreversible.'),
      actions: <Widget>[
        OutlinedButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        OutlinedButton(
          child: const Text('Proceed'),
          onPressed: () {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                      title: const Text('Enter Password'),
                      content: TextFormField(
                        controller: pass,
                        obscureText: true,
                      ),
                      actions: [
                        OutlinedButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        OutlinedButton(
                          child: const Text('Delete Account'),
                          onPressed: () async {
                            User? user = FirebaseAuth.instance.currentUser;

                            // Prompt the user to reauthenticate
                            AuthCredential credential = EmailAuthProvider.credential(
                              email: user!.email ?? "",
                              password: pass.text,
                            );

                            try {
                              await user.reauthenticateWithCredential(credential);

                              snap.collection(Collections.USER).doc(auth.currentUser!.uid).delete();

                              await user.delete().then((value) {
                                Get.offAll(StartView(isBack: false));

                                // Navigator.of(context, rootNavigator: !false)
                                //     .pushReplacement(getPageRoute(
                                //         PageTransitionAnimation.cupertino,
                                //         enterPage: StartView()));
                              });
                              print('Account deleted successfully.');
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'wrong-password') {
                                print('Invalid password. Please try again.');
                                toast('Invalid password. Please try again.');
                              } else {
                                print('Error deleting account: ${e.message}');
                              }
                            } catch (e) {
                              print('Error deleting account: $e');
                            }
                          },
                        ),
                      ],
                    ));

            // snap
            //     .collection(Collections.USER)
            //     .doc(auth.currentUser!.uid)
            //     .delete()
            //     .then((value) => auth.currentUser!.delete().then((value) {
            //           // pushNewScreen(
            //           //   context,
            //           //   screen: const StartView(),
            //           //   withNavBar: false,
            //           // );
            //           Navigator.of(context, rootNavigator: !false)
            //               .pushReplacement(getPageRoute(
            //                   PageTransitionAnimation.cupertino,
            //                   enterPage: StartView()));
            //         }));
          },
        ),
      ],
    ),
  );
}

toModal(BuildContext context) async {
  DocumentSnapshot snap =
      await FirebaseFirestore.instance.collection(Collections.USER).doc(auth.currentUser?.uid ?? "").get();
  UserModel userModel = UserModel.fromMap(snap.data() as Map<String, dynamic>);
  userController.userModel.value =userModel;
  print("user model:.. ${userController.userModel.value.uid}");
}

Future<void> resetPassword({required String emailText}) async {
  final email = emailText.trim();

  try {
    // Attempt to send the password reset email
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

    // Display a success message and navigate back
    Fluttertoast.showToast(msg: "Password reset link sent via Email").then((value) {
      Get.back(); // Navigate back to the previous screen
    });
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      // Handle the case where the email is not registered
      Fluttertoast.showToast(msg: "Email not registered").then((value) {
        // You can take appropriate action, such as displaying an error message to the user
      });
    } else {
      // Handle other Firebase Authentication exceptions
      print('Error: ${e.message}');
      Fluttertoast.showToast(msg: 'An error occurred: ${e.message}');
    }
  } catch (e) {
    // Handle other exceptions
    print('Error: $e');
    Fluttertoast.showToast(msg: 'An error occurred: $e');
  }
}
