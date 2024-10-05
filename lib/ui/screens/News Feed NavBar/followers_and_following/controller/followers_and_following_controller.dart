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
  }

  void setUserId(String uid) {
    userId = uid;

    _listenToCounts();
  }

  void setUserIdForProfile(String uid) {
    userId = uid;

    _listenToCountsForProfile();
  }

  void _listenToCounts() {
    _service.getFollowersStream(userId).listen((count) {
      followersCount.value = count;
    }, onError: (error) {});

    _service.getFollowingStream(userId).listen((count) {
      followingCount.value = count;
    }, onError: (error) {});
  }

  void _listenToCountsForProfile() {
    _service.getFollowersStream(userId).listen((count) {
      profileFollowersCount.value = count;
    }, onError: (error) {});

    _service.getFollowingStream(userId).listen((count) {
      profileFollowingCount.value = count;
    }, onError: (error) {});
  }
}
