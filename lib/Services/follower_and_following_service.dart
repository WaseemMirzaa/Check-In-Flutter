import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowerAndFollowingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addFollower(String currentUserUid, String targetUserId) async {
    try {
      // Document for the current user in the "following" collection
      DocumentReference followingRef =
          _db.collection('following').doc(currentUserUid);

      // Document for the target user in the "followers" collection
      DocumentReference followersRef =
          _db.collection('followers').doc(targetUserId);

      // Add the target user to the current user's "following" list
      await followingRef.set({
        'following': FieldValue.arrayUnion([targetUserId])
      }, SetOptions(merge: true));

      // Add the current user to the target user's "followers" list
      await followersRef.set({
        'followers': FieldValue.arrayUnion([currentUserUid])
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error adding follower: $e");
      throw e;
    }
  }

  Future<void> removeFollower(
      String currentUserUid, String targetUserId) async {
    try {
      // Document for the current user in the "following" collection
      DocumentReference followingRef =
          _db.collection('following').doc(currentUserUid);

      // Document for the target user in the "followers" collection
      DocumentReference followersRef =
          _db.collection('followers').doc(targetUserId);

      // Remove the target user from the current user's "following" list
      await followingRef.update({
        'following': FieldValue.arrayRemove([targetUserId])
      });

      // Remove the current user from the target user's "followers" list
      await followersRef.update({
        'followers': FieldValue.arrayRemove([currentUserUid])
      });
    } catch (e) {
      print("Error removing follower: $e");
      throw e;
    }
  }

  Stream<bool> getFollowStatus(String profileUid) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return _db
        .collection('following')
        .doc(currentUserId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> following = data['following'] ?? [];
        return following.contains(profileUid);
      } else {
        return false;
      }
    });
  }

  Stream<int> getFollowersStream(String userId) {
    return _db.collection('followers').doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> followers = data['followers'] ?? [];
        return followers.length;
      } else {
        return 0;
      }
    });
  }

  Stream<int> getFollowingStream(String userId) {
    return _db.collection('following').doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> following = data['following'] ?? [];
        return following.length;
      } else {
        return 0;
      }
    });
  }
}
