import 'package:get/get.dart';
import 'package:check_in/Services/follower_and_following_service.dart';

class FollowerCountingController extends GetxController {
  final FollowerAndFollowingService _service = FollowerAndFollowingService();
  var followersCount = 0.obs;
  var followingCount = 0.obs;
  var profileFollowersCount = 0.obs;
  var profileFollowingCount = 0.obs;

  late String userId;

  @override
  void onInit() {
    super.onInit();
    print("FollowerCountingController initialized.");
  }

  void setUserId(String uid) {
    userId = uid;
    print("User ID set to: $userId");
    _listenToCounts();
  }

  void setUserIdForProfile(String uid) {
    userId = uid;
    print("User ID set to: $userId");
    _listenToCountsForProfile();
  }

  void _listenToCounts() {
    print("Listening to follower count updates...");
    _service.getFollowersStream(userId).listen((count) {
      print("Updated followers count: $count");
      followersCount.value = count;
    }, onError: (error) {
      print("Error listening to followers count: $error");
    });

    print("Listening to following count updates...");
    _service.getFollowingStream(userId).listen((count) {
      print("Updated following count: $count");
      followingCount.value = count;
    }, onError: (error) {
      print("Error listening to following count: $error");
    });
  }

  void _listenToCountsForProfile() {
    print("Listening to profile follower count updates...");
    _service.getFollowersStream(userId).listen((count) {
      print("Updated profile followers count: $count");
      profileFollowersCount.value = count;
    }, onError: (error) {
      print("Error listening to profile followers count: $error");
    });

    print("Listening to profile following count updates...");
    _service.getFollowingStream(userId).listen((count) {
      print("Updated profile following count: $count");
      profileFollowingCount.value = count;
    }, onError: (error) {
      print("Error listening to profile following count: $error");
    });
  }
}
