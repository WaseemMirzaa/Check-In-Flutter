import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:check_in/Services/follower_and_following_service.dart';

class FollowerCountingController extends GetxController {
  final FollowerAndFollowingService _service = FollowerAndFollowingService();
  var followersCount = 0.obs;
  var followingCount = 0.obs;

  var profilefollowersCount = 0.obs;
  var profilefollowingCount = 0.obs;

  late String userId; // Use late initialization

  void setUserId(String uid) {
    userId = uid;
    print("User ID set to: $userId"); // Log userId
    _listenToCounts();
    
  }

  void setUserIdforProfile(String uid) {
    userId = uid;
    print("User ID set to: $userId"); // Log userId
    _listenToCountsforProfile();
    
  }


  @override
  void onInit() {
    super.onInit();
    print("FollowerCountingController initialized.");
    // Optionally, you can initialize here if userId is already set
  }

  void _listenToCounts() {
    print("Listening to follower count updates...");
    _service.getFollowersStream(userId).listen((count) {
      print("Updated followers count: $count"); // Log updated followers count
      followersCount.value = count;
    }, onError: (error) {
      print("Error listening to followers count: $error"); // Log error
    });

    print("Listening to following count updates...");
    _service.getFollowingStream(userId).listen((count) {
      print("Updated following count: $count"); // Log updated following count
      followingCount.value = count;
    }, onError: (error) {
      print("Error listening to following count: $error"); // Log error
    });
  }

  //for profile followers and followings
  void _listenToCountsforProfile() {
    print("Listening to follower count updates...");
    _service.getFollowersStream(userId).listen((count) {
      print("Updated followers count: $count"); // Log updated followers count
      profilefollowersCount.value = count;
    }, onError: (error) {
      print("Error listening to followers count: $error"); // Log error
    });

    print("Listening to following count updates...");
    _service.getFollowingStream(userId).listen((count) {
      print("Updated following count: $count"); // Log updated following count
      profilefollowingCount.value = count;
    }, onError: (error) {
      print("Error listening to following count: $error"); // Log error
    });
  }
}
