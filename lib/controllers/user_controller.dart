import 'package:check_in/Services/user_services.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  UserServices userServices;
  UserController(this.userServices);

  Rx<UserModel> userModel = UserModel().obs;
  RxList blockProfiles = [].obs;

  void updateGoldenCheckin(int newGoldenCheckin) {
    userModel.update((val) {
      val?.goldenCheckin = newGoldenCheckin;
    });
  }

  Future<void> getUserData() async {
    if (FirebaseAuth.instance.currentUser != null) {
      UserModel? userData = await userServices.getUserData(
          FirebaseAuth.instance.currentUser?.uid ?? '');
      if (userData != null) {
        userModel.value = userData;
        blockProfiles.addAll(userData.blockProfiles ?? []);
      }
    }
  }

  /// block profile
  Future<bool> blockProfile(String profileId, String userId) async {
    final res = await userServices.blockProfile(profileId, userId);
    if (res) {
      blockProfiles.add(profileId);
      return true;
    } else {
      return false;
    }
  }


}
