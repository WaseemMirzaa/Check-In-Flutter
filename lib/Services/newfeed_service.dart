import 'dart:io';

import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class NewsFeedService {
  final db = FirebaseFirestore.instance;
  final CollectionReference _newsFeedCollection =
      FirebaseFirestore.instance.collection(Collections.NEWSFEED);

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final userController = Get.put(UserController());

  //............ Get newsfeed post
  Stream<List<NewsFeedModel>> getNewsFeed() {
    return _newsFeedCollection.snapshots()
        .map((querySnapshot) => querySnapshot.docs.map<NewsFeedModel>((doc) {
              return NewsFeedModel.fromJson(doc.data() as Map<String, dynamic>);
            }).toList());
  }

  /// Create news feed post
  Future<bool> createPost(NewsFeedModel newsFeedModel) async{
    try{
      DocumentReference docReff = FirebaseFirestore.instance.collection(Collections.NEWSFEED).doc();
      newsFeedModel.id = docReff.id;
      await docReff.set(newsFeedModel.toJson());
      return true;
    }catch (e){
      print(e.toString());
      return false;
    }
  }

  /// Like and unlike post
  Future<bool> toggleLikePost(String postId, String userId) async {
    try{
      final docRef = FirebaseFirestore.instance.collection(Collections.NEWSFEED).doc(postId);
      log(docRef.id.toString());

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          log("Post does not exist!");
          return false;
        }
        final post = NewsFeedModel.fromJson(snapshot.data() as Map<String, dynamic>);
        if (post.likedBy!.contains(userId)) {
          post.likedBy!.remove(userId);
          post.noOfLike -= 1;
        } else {
          post.likedBy!.add(userId);
          post.noOfLike += 1;
        }
        transaction.update(docRef, {
          NewsFeed.NO_OF_LIKE: post.noOfLike,
          NewsFeed.LIKED_BY: post.likedBy,
        });
      });
      return true;
    }catch (e){
      return false;
    }

  }

  Future<List<UserModel>> fetchLikerUsers(String postId) async {
    // Fetch the likedBy list from the post document
    final postDoc = await FirebaseFirestore.instance
        .collection(Collections.NEWSFEED)
        .doc(postId)
        .get();

    final likedBy = List<String>.from(postDoc['likedBy']);

    // Fetch user documents for each userId in likedBy
    final usersQuery = await FirebaseFirestore.instance
        .collection(Collections.USER)
        .where(FieldPath.documentId, whereIn: likedBy)
        .get();

    final likers = usersQuery.docs.map((doc) => UserModel.fromMap(doc.data())).toList();

    return likers;
  }

  Future<String> uploadChatImageToFirebase( String imagePath, String uId, String time, String extension) async {
    try {
      Reference storageReference;
        storageReference = _storage.ref().child('NewsFeed/$uId/$time.$extension');
      await storageReference.putFile(File(imagePath));
      final downloadUrl = await storageReference.getDownloadURL();
      return  downloadUrl;
    } catch (e) {
      log(e.toString());
      return '';
    }
  }

}
