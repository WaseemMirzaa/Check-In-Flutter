import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserServices{
  FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseFirestore firebaseRef = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;


  Future<UserModel?> getUserData(String uid) async {
    try {
      if (uid.isEmpty || uid == null) {
        return null;
      }
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await db.collection(Collections.USER).doc(uid).get();

      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromMap(snapshot.data()!);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<UserModel>?> getUsersList() async {

    List<UserModel> usersList = [];
    try {

      QuerySnapshot<Map<String, dynamic>> snapshot =
      await db.collection(Collections.USER).get();

      if (snapshot.docs.isNotEmpty) {

        for (var snap in snapshot.docs) {

          usersList.add(UserModel.fromMap(snap.data()));

        }

        return usersList;

      }
    } catch (e) {
      return null;
    }

    return null;

  }

  /// Hide profile for me
  Future<bool> blockProfile(String profileId, String userId) async {
    try{
      await db.collection(Collections.USER).doc(userId).update({
        UserKey.BLOCK_PROFILES: FieldValue.arrayUnion([profileId])
      });
      return true;
    }catch (e){
      return false;
    }

  }
}