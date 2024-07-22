import 'package:check_in/Services/user_services.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  UserServices userServices;
  UserController(this.userServices);

  Rx<UserModel> userModel = UserModel().obs;

  void updateGoldenCheckin(int newGoldenCheckin) {
    userModel.update((val) {
      val?.goldenCheckin = newGoldenCheckin;
    });
  }

  Future<void> getUserData() async {
    UserModel? userData = await userServices.getUserData(FirebaseAuth.instance.currentUser?.uid ?? '');
    if (userData != null) {
      userModel.value = userData;
      print("User is: ${userModel.value.userName}");
    } else {
      print("User data is null");
    }
    // Optionally, you can return the user data if needed
    // return userData;
  }
}
