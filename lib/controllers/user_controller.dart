import 'package:check_in/model/user_modal.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  Rx<UserModel> userModel = UserModel().obs;
  void updateGoldenCheckin(int newGoldenCheckin) {
    userModel.update((val) {
      val?.goldenCheckin = newGoldenCheckin;
    });
  }
}
