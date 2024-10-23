import 'dart:io';
import 'package:check_in/Services/user_services.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/NewsFeed%20Model/comment_model.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:rxdart/rxdart.dart' as RES;
import 'package:video_compress_v2/video_compress_v2.dart';

import '../model/NewsFeed Model/report_posts_model.dart';

class NewsFeedService {
  final db = FirebaseFirestore.instance;
  final CollectionReference _newsFeedCollection =
      FirebaseFirestore.instance.collection(Collections.NEWSFEED);
  final FirebaseFirestore firebaseRef = FirebaseFirestore.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final userController = Get.put(UserController(UserServices()));

  Future<bool> updateCollection(
      String collectionName, String docId, Map<String, dynamic> list) async {
    try {
      await db.collection(collectionName).doc(docId).update(list);
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> getNewsFeed(
      {DocumentSnapshot? startAfter}) {
    Query query = _newsFeedCollection
        .orderBy(NewsFeed.TIME_STAMP, descending: true)
        .limit(10);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots().map((querySnapshot) => querySnapshot.docs
            .where((doc) =>
                doc.data() != null &&
                (doc.data() as Map<String, dynamic>)[NewsFeed.HIDE_USER]
                    is List &&
                !(doc.data() as Map<String, dynamic>)[NewsFeed.HIDE_USER]
                    .contains(userController.userModel.value.uid))
            .map((doc) {
          return {
            'model': NewsFeedModel.fromJson(doc.data() as Map<String, dynamic>),
            'snapshot': doc
          };
        }).toList());
  }

  Stream<List<Map<String, dynamic>>> getMyPosts(String id,
      {DocumentSnapshot? startAfter}) {
    Query userPostsQuery = _newsFeedCollection
        .where(NewsFeed.USER_ID, isEqualTo: id)
        .where(NewsFeed.IS_ORIGINAL, isEqualTo: true)
        .orderBy(NewsFeed.TIME_STAMP, descending: true)
        .limit(10);

    if (startAfter != null) {
      userPostsQuery = userPostsQuery.startAfterDocument(startAfter);
    }

    Query sharedPostsQuery = _newsFeedCollection
        .where(NewsFeed.SHARE_UID, isEqualTo: id)
        .where(NewsFeed.IS_ORIGINAL, isEqualTo: false)
        .orderBy(NewsFeed.TIME_STAMP, descending: true)
        .limit(10);

    if (startAfter != null) {
      sharedPostsQuery = sharedPostsQuery.startAfterDocument(startAfter);
    }

    return RES.Rx.combineLatest2(
      userPostsQuery.snapshots(),
      sharedPostsQuery.snapshots(),
      (QuerySnapshot userPostsSnapshot, QuerySnapshot sharedPostsSnapshot) {
        print("User posts count: ${userPostsSnapshot.docs.length}");
        print("Shared posts count: ${sharedPostsSnapshot.docs.length}");

        final combinedDocs = [
          ...userPostsSnapshot.docs,
          ...sharedPostsSnapshot.docs
        ];

        // Log combined documents count
        print(
            "Combined documents count before deduplication: ${combinedDocs.length}");

        // Remove duplicates
        final uniqueDocs =
            {for (var doc in combinedDocs) doc.id: doc}.values.toList();

        // Log unique documents count
        print(
            "Unique documents count after deduplication: ${uniqueDocs.length}");

        // Sort by timestamp
        uniqueDocs.sort((a, b) {
          final timestampA = (a.data()
              as Map<String, dynamic>)[NewsFeed.TIME_STAMP] as Timestamp;
          final timestampB = (b.data()
              as Map<String, dynamic>)[NewsFeed.TIME_STAMP] as Timestamp;
          return timestampB.compareTo(timestampA);
        });

        // Map to NewsFeedModel
        return uniqueDocs
            .map<Map<String, dynamic>>((doc) => {
                  'model': NewsFeedModel.fromJson(
                      doc.data() as Map<String, dynamic>),
                  'snapshot': doc
                })
            .toList();
      },
    );
  }

  /// Get post by spacific ID
  Stream<NewsFeedModel?> getPostsByDocID(String postId) {
    return FirebaseFirestore.instance
        .collection(Collections.NEWSFEED)
        .doc(postId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null; // Return null if the document doesn't exist
      }

      final data = snapshot.data();
      final postModel =
          NewsFeedModel.fromJson(data!); // Create the model from JSON data

      return postModel;
    });
  }

  /// Create news feed post
  Future<bool> createPost(NewsFeedModel newsFeedModel, String compress) async {
    try {
      if (compress.isNotEmpty) {
        String? thumbnail;
        if (newsFeedModel.isType != 'image') {
          final uint8list = await VideoCompressV2.getByteThumbnail(compress,
              quality: 50, // default(100)
              position: -1 // default(-1)
              );
          thumbnail = await uploadUint8ListToFirebaseStorage(
              uint8list!, Timestamp.now().toString());
        }

        final url = await uploadChatImageToFirebase(
            compress,
            userController.userModel.value.uid!,
            DateTime.now().toString(),
            newsFeedModel.isType == 'image' ? 'jpg' : 'mp4');
        newsFeedModel.postUrl = url;
        newsFeedModel.thumbnail = thumbnail;
        if (newsFeedModel.postUrl!.isNotEmpty) {
          DocumentReference docReff =
              FirebaseFirestore.instance.collection(Collections.NEWSFEED).doc();
          newsFeedModel.id = docReff.id;

          await docReff.set(newsFeedModel.toJson());
          return true;
        }
        return true;
      } else {
        DocumentReference docReff =
            FirebaseFirestore.instance.collection(Collections.NEWSFEED).doc();
        newsFeedModel.id = docReff.id;
        await docReff.set(newsFeedModel.toJson());
        return true;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<String?> uploadUint8ListToFirebaseStorage(
      Uint8List imageData, String fileName) async {
    try {
      // Get a reference to the location where we'll store our file
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('thumbnail/$fileName');

      // Upload raw data
      final UploadTask uploadTask = storageRef.putData(
        imageData,
        SettableMetadata(
            contentType: 'image/jpeg'), // Adjust this if you're not using JPEG
      );

      // Wait until the file is uploaded then fetch the download URL
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  /// Create news share feed post
  Future<bool> sharePost(NewsFeedModel newsFeedModel) async {
    try {
      DocumentReference docReff =
          FirebaseFirestore.instance.collection(Collections.NEWSFEED).doc();
      newsFeedModel.shareID = docReff.id;
      await docReff.set(newsFeedModel.toJson());
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  /// get share count
  Future<int?> getNumberOfShares(String postID) async {
    try {
      // Reference to the specific document in the newsFeed collection
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(Collections.NEWSFEED)
          .doc(postID)
          .get();

      // Check if the document exists and has the field
      if (documentSnapshot.exists && documentSnapshot.data() != null) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        return data[NewsFeed.NO_OF_SHARED] as int?;
      } else {
        print('Document does not exist or has no data.');
        return null;
      }
    } catch (e) {
      print('Error fetching document: $e');
      return null;
    }
  }

  /// LIKE AND UNLIKE POSTS
  Future<String?> toggleLikePost(String postId, String userId) async {
    try {
      print("Like Function called -------------------------");
      final docRef = FirebaseFirestore.instance
          .collection(Collections.NEWSFEED)
          .doc(postId);
      log(docRef.id.toString());

      String result =
          await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          log("Post does not exist!");
          return 'error';
        }
        final post =
            NewsFeedModel.fromJson(snapshot.data() as Map<String, dynamic>);
        if (post.likedBy!.contains(userId)) {
          print("Already Liked removing... -------------------------");
          post.likedBy!.remove(userId);
          post.noOfLike > 0 ? post.noOfLike -= 1 : post.noOfLike = 0;
          transaction.update(docRef, {
            NewsFeed.NO_OF_LIKE: post.noOfLike,
            NewsFeed.LIKED_BY: post.likedBy,
          });
          return 'unliked';
        } else {
          print("Not Liked Adding... -------------------------");
          post.likedBy!.add(userId);
          post.noOfLike += 1;
          transaction.update(docRef, {
            NewsFeed.NO_OF_LIKE: post.noOfLike,
            NewsFeed.LIKED_BY: post.likedBy,
          });
          print("Liked");
          return 'liked';
        }
      });

      print("Like Function Finished -------------------------");
      return result;
    } catch (e) {
      return 'error';
    }
  }

  /// GET LIKED BY USERS IDS
  Stream<List<String>?> getPostLikedBy(String postId) {
    return FirebaseFirestore.instance
        .collection(Collections.NEWSFEED)
        .doc(postId)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (!snapshot.exists) {
        return null; // Return null if the document doesn't exist
      }
      final data = snapshot.data();
      final likedBy = data?[NewsFeed.LIKED_BY] as List<dynamic>? ?? [];
      return likedBy
          .cast<String>()
          .toList(); // Cast likedBy to List<String> and return
    });
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

    final likers =
        usersQuery.docs.map((doc) => UserModel.fromMap(doc.data())).toList();

    return likers;
  }

  /// Add comment on post
  Future<bool> addCommentOnPost(
      String postId, CommentModel commentModel) async {
    try {
      final commentDoc = _newsFeedCollection
          .doc(postId)
          .collection(Collections.COMMENTS)
          .doc();
      commentModel.commentId = commentDoc.id;
      await commentDoc.set(commentModel.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Add comment on comment
  Future<bool> addCommentOnComment(
      String postId, String commentId, CommentModel commentModel) async {
    try {
      final commentDoc = _newsFeedCollection
          .doc(postId)
          .collection(Collections.COMMENTS)
          .doc(commentId)
          .collection(Collections.COMMENTS)
          .doc();
      commentModel.commentId = commentDoc.id;
      await commentDoc.set(commentModel.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get comments on posts
  Stream<List<CommentModel>> getPostComments(String postId) {
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
  Stream<List<CommentModel>> getCommentsOnComment(
      String postId, String commentId) {
    return FirebaseFirestore.instance
        .collection(Collections.NEWSFEED)
        .doc(postId)
        .collection(Collections.COMMENTS)
        .doc(commentId)
        .collection(Collections.COMMENTS)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs.map((doc) {
        return CommentModel.fromJson(doc.data());
      }).toList();
    });
  }

  /// Like and unlike the comment
  Future<bool> toggleLikeComment(
      String postId, String commentId, String userId) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(Collections.NEWSFEED)
          .doc(postId)
          .collection(Collections.COMMENTS)
          .doc(commentId);
      log(docRef.id.toString());

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          log("Post does not exist!");
          return false;
        }
        final post =
            CommentModel.fromJson(snapshot.data() as Map<String, dynamic>);
        if (post.likedBy!.contains(userId)) {
          post.likedBy!.remove(userId);
          post.likes > 0 ? post.likes -= 1 : post.likes = 0;
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
    } catch (e) {
      return false;
    }
  }

  /// get the total number of comments on post
  Stream<int> getNumOfComments(String newsFeedId) {
    CollectionReference commentsRef = FirebaseFirestore.instance
        .collection(Collections.NEWSFEED)
        .doc(newsFeedId)
        .collection(Collections.COMMENTS);
    return commentsRef.snapshots().map((snapshot) => snapshot.size);
  }

  /// Like and unlike the subcomment
  Future<bool> toggleLikeSubComment(String postId, String commentId,
      String subCommentId, String userId) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(Collections.NEWSFEED)
          .doc(postId)
          .collection(Collections.COMMENTS)
          .doc(commentId)
          .collection(Collections.COMMENTS)
          .doc(subCommentId);
      log("The doc is:${docRef.id}");
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          log("Post does not exist!");
          return false;
        }
        final post =
            CommentModel.fromJson(snapshot.data() as Map<String, dynamic>);
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
    } catch (e) {
      return false;
    }
  }

  /// Fetch all likers on comments
  Future<List<UserModel>> fetchAllLikesComment(
      String postId, String commentId) async {
    final postDoc = await FirebaseFirestore.instance
        .collection(Collections.NEWSFEED)
        .doc(postId)
        .collection(Collections.COMMENTS)
        .doc(commentId)
        .get();

    final likedBy = List<String>.from(postDoc['likedBy']);

    final usersQuery = await FirebaseFirestore.instance
        .collection(Collections.USER)
        .where(FieldPath.documentId, whereIn: likedBy)
        .get();

    final likers =
        usersQuery.docs.map((doc) => UserModel.fromMap(doc.data())).toList();

    return likers;
  }

  /// fetch all likers on sub comments
  Future<List<UserModel>> fetchAllLikesOnSubComment(
      String postId, String parentId, String commentId) async {
    final postDoc = await FirebaseFirestore.instance
        .collection(Collections.NEWSFEED)
        .doc(postId)
        .collection(Collections.COMMENTS)
        .doc(parentId)
        .collection(Collections.COMMENTS)
        .doc(commentId)
        .get();

    final likedBy = List<String>.from(postDoc['likedBy']);

    final usersQuery = await FirebaseFirestore.instance
        .collection(Collections.USER)
        .where(FieldPath.documentId, whereIn: likedBy)
        .get();

    final likers =
        usersQuery.docs.map((doc) => UserModel.fromMap(doc.data())).toList();

    return likers;
  }

  /// Hide post for me
  Future<bool> hidePost(String docId) async {
    try {
      _newsFeedCollection.doc(docId).update({
        NewsFeed.HIDE_USER:
            FieldValue.arrayUnion([userController.userModel.value.uid])
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> reportPost(
      String postId, String reportedBy, String reason) async {
    try {
      String reportId =
          firebaseRef.collection(Collections.REPORTPOSTS).doc().id;
      ReportModel report = ReportModel(
        reportId: reportId,
        postId: postId,
        reportedBy: reportedBy,
        reason: reason,
        timestamp: Timestamp.now(),
      );
      await firebaseRef
          .collection(Collections.REPORTPOSTS)
          .doc(reportId)
          .set(report.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> reportProfile(
      String profileId, String reportedBy, String reason) async {
    try {
      String reportId =
          firebaseRef.collection(Collections.REPORTPROFILES).doc().id;
      ReportModel report = ReportModel(
        reportId: reportId,
        profileId: profileId,
        reportedBy: reportedBy,
        reason: reason,
        timestamp: Timestamp.now(),
      );
      await firebaseRef
          .collection(Collections.REPORTPROFILES)
          .doc(reportId)
          .set(report.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete post permanently
  Future<void> deleteSubcollection(String postId) async {
    DocumentReference parentDocRef = _newsFeedCollection.doc(postId);
    await deleteSubCollectionNewsFeed(parentDocRef);
    await deleteNewsFeed(postId);
  }

  Future<void> deleteNewsFeed(String postId) async {
    DocumentReference parentDocRef = _newsFeedCollection.doc(postId);
    await parentDocRef.delete();
  }

  Future<void> deleteSubCollectionNewsFeed(DocumentReference docRef) async {
    final comntCollection = await docRef.collection(Collections.COMMENTS).get();

    for (var subCollection in comntCollection.docs) {
      await deleteSubCollectionNewsFeed(subCollection.reference);
      await subCollection.reference.delete();
    }
  }

  /// news feed single post for deep linking
  Future<NewsFeedModel?> getPostById(String docId) async {
    try {
      DocumentSnapshot doc = await _newsFeedCollection.doc(docId).get();
      if (doc.exists) {
        return NewsFeedModel.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error getting document: $e');
      return null;
    }
  }

  // /// share through deep linking
  // Future<String> createDynamicLink(String postId) async {
  //   try{
  //     final DynamicLinkParameters parameters = DynamicLinkParameters(
  //       uriPrefix: 'https://developlogix.page.link', // Your Firebase Dynamic Links URL prefix
  //       link: Uri.parse('https://yourapp.com/post?postId=12'), // Deep link URL
  //       androidParameters: const AndroidParameters(
  //         packageName: 'com.developlogix.checkinapp', // Your package name
  //         minimumVersion: 0,
  //       ),
  //       iosParameters: const IOSParameters(
  //         bundleId: 'com.developlogix.checkin', // Your bundle ID
  //         minimumVersion: '0',
  //       ),
  //     );
  //
  //     final ShortDynamicLink shortDynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
  //     return shortDynamicLink.shortUrl.toString();
  //   }catch (e){
  //     log("The error is----------\n\n\n\n\n\n\ $e\n\n\n");
  //     return '';
  //   }
  //   }
  Future<String> createDynamicLink(String postId) async {
    try {
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix:
            'https://developlogix.page.link', // Your Firebase Dynamic Links URL prefix
        link: Uri.parse(
            'https://yourapp.com/post?postId=$postId'), // Deep link URL
        androidParameters: const AndroidParameters(
          packageName: 'com.developlogix.checkinapp', // Your package name
          minimumVersion: 0,
        ),
        iosParameters: const IOSParameters(
          bundleId: 'com.developlogix.checkinapp', // Your bundle ID
          minimumVersion: '0',
        ),
      );

      final ShortDynamicLink shortDynamicLink =
          await FirebaseDynamicLinks.instance.buildShortLink(parameters);
      return shortDynamicLink.shortUrl.toString();
    } catch (e) {
      log("The error is----------\n\n\n\n\n\n\ $e\n\n\n");
      return '';
    }
  }

  /// Upload image to firebase for news feed
  Future<String> uploadChatImageToFirebase(
      String imagePath, String uId, String time, String extension) async {
    try {
      Reference storageReference;
      storageReference = _storage.ref().child('NewsFeed/$uId/$time.$extension');
      await storageReference.putFile(File(imagePath));
      final downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      log(e.toString());
      return '';
    }
  }

  Future<List<dynamic>> getDeviceToken(String id) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('USER').doc(id);

    DocumentSnapshot userSnapshot = await userRef.get();
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>;
    // print(userData[UserKey.DEVICE_TOKEN]);
    //
    // print(userData[UserKey.DEVICE_TOKEN].runtimeType);
    // print(userData[UserKey.DEVICE_TOKEN]);

    List<dynamic>? deviceTokens = userData[UserKey.DEVICE_TOKEN];
    return deviceTokens ?? [];
  }

  /// Tried
//   Future<List<NewsFeedModel>> fetchNewsFeed({required DocumentSnapshot? lastDoc, required int pageSize}) async {
//     List<NewsFeedModel> posts = [];
//     try {
//       Query query = _newsFeedCollection.orderBy(NewsFeed.TIME_STAMP, descending: true).limit(pageSize);
//       if (lastDoc != null) {
//         query = query.startAfterDocument(lastDoc);
//       }
//
//       QuerySnapshot snapshot = await query.get();
//
//       for (var doc in snapshot.docs) {
//         posts.add(NewsFeedModel.fromJson(doc.data() as Map<String, dynamic>, doc: doc)); // Pass the doc reference
//       }
//     } catch (e) {
//       print('Error fetching news feed: $e');
//     }
//     return posts;
//   }

  Future<List<String>> getReportArray() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('reportPosts')) {
        return prefs.getStringList('reportPosts')!;
      } else {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('configuration')
            .doc('report')
            .get();
        if (documentSnapshot.exists) {
          List<String> reportArray =
              List<String>.from(documentSnapshot['report']);
          await prefs.setStringList('reportPosts', reportArray);
          return reportArray;
        } else {
          return [];
        }
      }
    } catch (e) {
      return [];
    }
  }
}
