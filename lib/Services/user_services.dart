import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class UserServices{
  FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseFirestore firebaseRef = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;


  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await db.collection(Collections.USER).doc(uid).get();

      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromMap(snapshot.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}