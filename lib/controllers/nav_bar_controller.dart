import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

class NavBarController extends GetxController {
  RxInt currentIndex = 1.obs;
  PersistentTabController controller = PersistentTabController(
    initialIndex: 1,
  );
  updateCurrentIndex(int index) {
    controller = PersistentTabController(
      initialIndex: index,
    );
    update();
  }
}
