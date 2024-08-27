import 'package:check_in/Services/follower_and_following_service.dart';
import 'package:get/get.dart';

import 'package:firebase_auth/firebase_auth.dart';

class FollowerCountingController extends GetxController {
  final FollowerAndFollowingService _service = FollowerAndFollowingService();
  var followersCount = 0.obs;
  var followingCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToCounts();
  }

  void _listenToCounts() {
    String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid != null) {
      _service.getFollowersStream(currentUserUid).listen((count) {
        followersCount.value = count;
      });

      _service.getFollowingStream(currentUserUid).listen((count) {
        followingCount.value = count;
      });
    }
  }
}
