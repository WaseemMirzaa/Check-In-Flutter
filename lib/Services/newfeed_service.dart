import 'dart:io';

import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/NewsFeed%20Model/comment_model.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class NewsFeedService {
  final db = FirebaseFirestore.instance;
  final CollectionReference _newsFeedCollection =
      FirebaseFirestore.instance.collection(Collections.NEWSFEED);

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final userController = Get.put(UserController());

 Stream<List<NewsFeedModel>> getNewsFeed() {
  return _newsFeedCollection
      .orderBy(NewsFeed.TIME_STAMP, descending: true)
      .snapshots()
      .map((querySnapshot) => querySnapshot.docs
          .where((doc) =>
              doc.data() != null &&
              (doc.data() as Map<String, dynamic>?)![NewsFeed.HIDE_USER] is List &&
              !(doc.data() as Map<String, dynamic>)[NewsFeed.HIDE_USER].contains(userController.userModel.value.uid))
          .map<NewsFeedModel>((doc) {
            return NewsFeedModel.fromJson(doc.data() as Map<String, dynamic>);
          })
          .toList());
}

  /// Create news feed post
  Future<bool> createPost(NewsFeedModel newsFeedModel,String compress) async{
    try{
      if(compress.isNotEmpty){
        final url = await uploadChatImageToFirebase(compress, userController.userModel.value.uid!, DateTime.now().toString(),newsFeedModel.isType == 'image' ? 'jpg' : 'mp4');
        newsFeedModel.postUrl = url;
        if(newsFeedModel.postUrl!.isNotEmpty) {
          DocumentReference docReff = FirebaseFirestore.instance.collection(
              Collections.NEWSFEED).doc();
          newsFeedModel.id = docReff.id;
          await docReff.set(newsFeedModel.toJson());
          return true;
        }
        return true;
      }else {
        DocumentReference docReff = FirebaseFirestore.instance.collection(
            Collections.NEWSFEED).doc();
        newsFeedModel.id = docReff.id;
        await docReff.set(newsFeedModel.toJson());
        return true;
      }
    }catch (e){
      print(e.toString());
      return false;
    }
  }

   /// Create news feed post
  Future<bool> sharePost(NewsFeedModel newsFeedModel) async{
    try{
        DocumentReference docReff = FirebaseFirestore.instance.collection(
            Collections.NEWSFEED).doc();
        newsFeedModel.shareID = docReff.id;
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

  /// Fetch all likers on posts
  Future<List<UserModel>> fetchLikerUsers(String postId) async {
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

/// Add comment on post
  Future<bool> addCommentOnPost(String postId, CommentModel commentModel) async{
    try{
      final commentDoc = _newsFeedCollection.doc(postId).collection(Collections.COMMENTS).doc();
      commentModel.commentId = commentDoc.id;
      await commentDoc.set(commentModel.toJson());
      return true;
    }catch (e){
      return false;
    }
  }

/// Add comment on comment
  Future<bool> addCommentOnComment(String postId, String commentId ,CommentModel commentModel) async{
    try{
      final commentDoc = _newsFeedCollection.doc(postId).collection(Collections.COMMENTS).doc(commentId).collection(Collections.COMMENTS).doc();
      commentModel.commentId = commentDoc.id;
      await commentDoc.set(commentModel.toJson());
      return true;
    }catch (e){
      return false;
    }
  }

/// Get comments on posts
  Stream<List<CommentModel>> getPostComments(String postId){
    return FirebaseFirestore.instance
        .collection(Collections.NEWSFEED)
        .doc(postId)
        .collection(Collections.COMMENTS)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs.map((doc) {
        return CommentModel.fromJson(doc.data());
      }).toList();
    });
  }

  /// Get comments on comments
  Stream<List<CommentModel>> getCommentsOnComment(String postId,String commentId){
    return FirebaseFirestore.instance
        .collection(Collections.NEWSFEED)
        .doc(postId)
        .collection(Collections.COMMENTS).doc(commentId)
        .collection(Collections.COMMENTS).orderBy('timestamp', descending: false)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs.map((doc) {
        return CommentModel.fromJson(doc.data());
      }).toList();
    });
  }

/// Like and unlike the comment
  Future<bool> toggleLikeComment(String postId, String commentId ,String userId) async {
    try{
      final docRef = FirebaseFirestore.instance.collection(Collections.NEWSFEED).doc(postId).collection(Collections.COMMENTS).doc(commentId);
      log(docRef.id.toString());

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          log("Post does not exist!");
          return false;
        }
        final post = CommentModel.fromJson(snapshot.data() as Map<String, dynamic>);
        if (post.likedBy!.contains(userId)) {
          post.likedBy!.remove(userId);
          post.likes -= 1;
        } else {
          post.likedBy!.add(userId);
          post.likes += 1;
        }
        transaction.update(docRef, {
          'likes': post.likes,
          NewsFeed.LIKED_BY: post.likedBy,
        });
      });
      return true;
    }catch (e){
      return false;
    }
  }



/// Like and unlike the subcomment
  Future<bool> toggleLikeSubComment(String postId, String commentId, String subCommentId ,String userId) async {
    try{
      final docRef = FirebaseFirestore.instance.collection(Collections.NEWSFEED).doc(postId).collection(Collections.COMMENTS).doc(commentId).collection(Collections.COMMENTS).doc(subCommentId);
      log("The doc is:${docRef.id}");
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          log("Post does not exist!");
          return false;
        }
        final post = CommentModel.fromJson(snapshot.data() as Map<String, dynamic>);
        if (post.likedBy!.contains(userId)) {
          post.likedBy!.remove(userId);
          post.likes -= 1;
        } else {
          post.likedBy!.add(userId);
          post.likes += 1;
        }
        transaction.update(docRef, {
          'likes': post.likes,
          NewsFeed.LIKED_BY: post.likedBy,
        });
      });
      return true;
    }catch (e){
      return false;
    }
  }


/// Fetch all likers on comments
  Future<List<UserModel>> fetchAllLikesComment(String postId,String commentId) async {
    final postDoc = await FirebaseFirestore.instance
        .collection(Collections.NEWSFEED)
        .doc(postId).collection(Collections.COMMENTS).doc(commentId)
        .get();

    final likedBy = List<String>.from(postDoc['likedBy']);

    final usersQuery = await FirebaseFirestore.instance
        .collection(Collections.USER)
        .where(FieldPath.documentId, whereIn: likedBy)
        .get();

    final likers = usersQuery.docs.map((doc) => UserModel.fromMap(doc.data())).toList();

    return likers;
  }

  /// fetch all likers on sub comments
  Future<List<UserModel>> fetchAllLikesOnSubComment(String postId,String parentId,String commentId) async {
    final postDoc = await FirebaseFirestore.instance
        .collection(Collections.NEWSFEED)
        .doc(postId).collection(Collections.COMMENTS).doc(parentId).collection(Collections.COMMENTS).doc(commentId)
        .get();

    final likedBy = List<String>.from(postDoc['likedBy']);

    final usersQuery = await FirebaseFirestore.instance
        .collection(Collections.USER)
        .where(FieldPath.documentId, whereIn: likedBy)
        .get();

    final likers = usersQuery.docs.map((doc) => UserModel.fromMap(doc.data())).toList();

    return likers;
  }

  /// Hide post for me
  Future<bool> hidePost(String docId)async{
    try{
       _newsFeedCollection.doc(docId).update({
      NewsFeed.HIDE_USER: FieldValue.arrayUnion([userController.userModel.value.uid])
    });
      return true;
    }catch (e){
      return false;
    }
   
  }

  /// share through deep linking
  Future<String> createDynamicLink(String postId) async {
    try{
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://developlogix.page.link', // Your Firebase Dynamic Links URL prefix
        link: Uri.parse('https://yourapp.com/post?postId=12'), // Deep link URL
        androidParameters: const AndroidParameters(
          packageName: 'com.developlogix.checkinapp', // Your package name
          minimumVersion: 0,
        ),
        iosParameters: const IOSParameters(
          bundleId: 'com.developlogix.checkin', // Your bundle ID
          minimumVersion: '0',
        ),
      );

      final ShortDynamicLink shortDynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
      return shortDynamicLink.shortUrl.toString();
    }catch (e){
      log("The error is----------\n\n\n\n\n\n\ $e\n\n\n");
      return '';
    }
    }

/// Upload image to firebase for news feed
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
