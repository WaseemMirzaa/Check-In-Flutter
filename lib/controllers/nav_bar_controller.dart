import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class NavBarController extends GetxController {
  RxInt currentIndex = 0.obs;
  PersistentTabController controller = PersistentTabController(
    initialIndex: 0,
  );
  updateCurrentIndex(int index) {
    controller.jumpToTab(index);
    currentIndex.value = index;
    update();
  }
}
