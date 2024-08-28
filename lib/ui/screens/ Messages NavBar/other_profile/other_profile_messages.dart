import 'package:check_in/Services/follower_and_following_service.dart';
import 'package:check_in/Services/message_service.dart';
import 'package:check_in/Services/push_notification_service.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/followers_and_following/controller/followers_and_following_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:get/get.dart';

class OtherProfileMessages extends GetxController {
  final MessageService chatService = MessageService();

  Future<Map<String, dynamic>> startNewChat(
      String senderUid,
      String senderName,
      String senderPhotoUrl,
      String receiverUID,
      String receiverName,
      String receiverPhotoUrl) async {
    print("startNewChat called with:");
    print("Sender UID: $senderUid");
    print("Sender Name: $senderName");
    print("Sender Photo URL: $senderPhotoUrl");
    print("Receiver UID: $receiverUID");
    print("Receiver Name: $receiverName");
    print("Receiver Photo URL: $receiverPhotoUrl");

    // Matching IDs to check whether chat already exists
    var response = await chatService.areIdsMatching([senderUid, receiverUID]);
    print("Response from areIdsMatching: $response");

    if (response != '') {
      print("Chat already exists with docId: $response");
      // Do not add data and return existing chat info
      return {'isNewChat': false, 'docId': response};
    } else {
      print("No existing chat found, starting a new chat...");
      var res = await chatService.startNewChat([senderUid, receiverUID],
          senderName, receiverName, receiverPhotoUrl, senderPhotoUrl);
      print("New chat started with docId: $res");
      return {'isNewChat': true, 'docId': res};
    }
  }

  Future<void> sendNotificationMethod(
    String notificationType,
    String msg,
    String senderName,
    String docId,
    List<dynamic> memberId,
    String senderUID, {
    String? image,
  }) async {
    print("sendNotificationMethod called with:");
    print("Notification Type: $notificationType");
    print("Message: $msg");
    print("Sender Name: $senderName");
    print("Document ID: $docId");
    print("Member IDs: $memberId");
    print("Sender UID: $senderUID");
    print("Image URL: ${image ?? 'No image provided'}");

    for (var element in memberId) {
      if (element != senderUID) {
        print("Processing notification for user: $element");

        List<dynamic> deviceToken = await chatService.getDeviceToken(element);
        print("Device tokens for user $element: $deviceToken");

        sendNotification(
          token: deviceToken,
          notificationType: notificationType,
          title: senderName,
          msg: msg,
          docId: docId,
          isGroup: false,
          image: image ?? '',
          name: senderName,
          memberIds: memberId,
          uid: element,
        );

        print("Notification sent to user: $element");
      }
    }
  }

  Future<void> updateDeleteChatStatus(String docId, String userId) async {
    print("updateDeleteChatStatus called with:");
    print("Document ID: $docId");
    print("User ID: $userId");

    try {
      final response = await chatService.updateUserDelete(docId, userId);
      print("Successfully Update delete chat status response");
    } catch (e) {
      print("Error updating delete chat status: $e");
    }
  }

  //listen to followers
  var isFollowing = false.obs;

  void listenToFollowStatus(uid) {
    print("Listening to follow status");
    _firestoreService.getFollowStatus(uid).listen((status) {
      print("Received follow status update: $status");

      isFollowing.value = status;
    });
  }

  //for toggle followers

  final followerCountController = Get.put(FollowerCountingController());
  final FollowerAndFollowingService _firestoreService =
      FollowerAndFollowingService();

  Future<void> toggleFollow(String otherUserId) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      if (isFollowing.value) {
        print("Unfollowing user $otherUserId");
        await _firestoreService.removeFollower(currentUserId, otherUserId);

        isFollowing.value = false;
      } else {
        print("Following user $otherUserId");
        await _firestoreService.addFollower(currentUserId, otherUserId);

        isFollowing.value = true;
      }
    } catch (e) {
      print("Error toggling follow: $e");
    }
  }
}
