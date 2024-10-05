import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowerAndFollowingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addFollower(String currentUserUid, String targetUserId) async {
    // Document for the current user in the "following" collection
    DocumentReference followingRef =
    _db.collection('following').doc(currentUserUid).collection('following').doc(targetUserId);

    // Document for the target user in the "followers" collection
    DocumentReference followersRef =
    _db.collection('followers').doc(targetUserId).collection('followers').doc(currentUserUid);

    // Add the target user to the current user's "following" list
    await followingRef.set({
      'id': targetUserId
    });

    // Add the current user to the target user's "followers" list
    await followersRef.set({
      'id': currentUserUid
    });
  }

  Future<void> removeFollower(String currentUserUid, String targetUserId) async {
    // Document for the current user in the "following" collection
    DocumentReference followingRef =
    _db.collection('following').doc(currentUserUid).collection('following').doc(targetUserId);

    // Document for the target user in the "followers" collection
    DocumentReference followersRef =
    _db.collection('followers').doc(targetUserId).collection('followers').doc(currentUserUid);

    // Remove the target user from the current user's "following" list
    await followingRef.delete();

    // Remove the current user from the target user's "followers" list
    await followersRef.delete();
  }

  Stream<bool> getFollowStatus(String profileUid) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return _db
        .collection('following')
        .doc(currentUserId)
        .collection('following')
        .doc(profileUid)
        .snapshots()
        .map((snapshot) {
       return snapshot.exists;
    });
  }

  Stream<int> getFollowersStream(String userId) {
    return _db
        .collection('followers')
        .doc(userId)
        .collection('followers')  // Added subcollection
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.size; // Get the count of followers
    });
  }

  Stream<int> getFollowingStream(String userId) {
    return _db
        .collection('following')
        .doc(userId)
        .collection('following')  // Added subcollection
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.size; // Get the count of following
    });
  }

  Future<List<String>> getFollowingList(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('following')
          .doc(userId)
          .collection('following')  // Added subcollection
          .get();

      // Extracting user IDs from the documents
      List<String> followingList = querySnapshot.docs.map((doc) {
        return doc.id;
      }).toList();

      return followingList;
    } catch (e) {
      return [];
    }
  }
}
