// ignore_for_file: avoid_print
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/ui/screens/check_in.dart';
import 'package:check_in/ui/screens/profile_screen.dart';
import 'package:check_in/ui/screens/start.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/common.dart';
import 'package:check_in/utils/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'History.dart';
import '../../controllers/nav_bar_controller.dart';

class BottomNav {
  String icon;
  Color iconColor;
  Color boxColor;
  String label;

  BottomNav(
      {required this.icon,
      required this.iconColor,
      required this.boxColor,
      required this.label});

  getBottomNavItem() {
    return BottomNavigationBarItem(
        icon: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(shape: BoxShape.circle, color: boxColor),
          child: Center(
            child: SizedBox(
              height: 19,
              width: 19,
              child: SvgPicture.asset(
                "assets/images/$icon.svg",
                color: iconColor,
              ),
            ),
          ),
        ),
        label: label);
  }
}

class CustomNavBarWidget extends StatelessWidget {
  final int selectedIndex;
  final List<PersistentBottomNavBarItem>
      items; // NOTE: You CAN declare your own model here instead of `PersistentBottomNavBarItem`.
  final ValueChanged<int> onItemSelected;

  const CustomNavBarWidget({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onItemSelected,
  });

  Widget _buildItem(PersistentBottomNavBarItem item, bool isSelected) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(40))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: IconTheme(
              data: IconThemeData(
                  size: 26.0,
                  color: isSelected
                      ? (item.activeColorSecondary ?? item.activeColorPrimary)
                      : item.inactiveColorPrimary ?? item.activeColorPrimary),
              child: item.icon,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(40))),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            int index = items.indexOf(item);
            return Flexible(
              child: GestureDetector(
                onTap: () {
                  if (FirebaseAuth.instance.currentUser == null) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: poppinsText(TempLanguage.logInForFeatures,
                                  16, FontWeight.w500, blackColor),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Get.off(() => StartView(isBack: true));
                                  },
                                  child: Text(TempLanguage.logIn),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(TempLanguage.cancel),
                                ),
                              ],
                            ));
                  } else {
                    onItemSelected(index);
                  }
                },
                child: _buildItem(item, selectedIndex == index),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  final NavBarController navBarController = Get.put(NavBarController());

  final List<Widget> _buildScreens = [
    const CheckIn(),
    const HistoryView(),
    const ProfileScreen()
    //KeyedSubtree(key: UniqueKey(), child: const ProfileScreen()),
  ];

  List<BottomNavigationBarItem> _navBarsItems() {
    return [
      BottomNav(
        label: 'Home',
        boxColor:
            navBarController.controller.index == 0 ? greenColor : whiteColor,
        icon: "Group 12548",
        iconColor:
            navBarController.controller.index == 0 ? whiteColor : blackColor,
      ).getBottomNavItem(),
      BottomNav(
        label: 'History',
        boxColor:
            navBarController.controller.index == 1 ? greenColor : whiteColor,
        icon: "Icon awesome-history",
        iconColor:
            navBarController.controller.index == 1 ? whiteColor : blackColor,
      ).getBottomNavItem(),
      BottomNav(
        label: 'Profile',
        boxColor:
            navBarController.controller.index == 2 ? greenColor : whiteColor,
        icon: "Icon material-person",
        iconColor:
            navBarController.controller.index == 2 ? whiteColor : blackColor,
      ).getBottomNavItem(),
    ];
  }

  Future<bool> _onWillPop() async {
    if (navBarController.currentIndex.value == 0) {
      // Only show exit confirmation dialog on the first screen (CheckIn)
      final bool shouldExit = await showExitPopup(context);
      return shouldExit;
    } else {
      // Allow navigating back on other screens
      return true;
    }
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Obx(() {
        return Scaffold(
          body: Obx(() => IndexedStack(
              index: navBarController.currentIndex.value,
              children: _buildScreens)),
          bottomNavigationBar: BottomNavigationBar(
            items: _navBarsItems(),
            currentIndex: navBarController.currentIndex.value,
            //selectedItemColor: Colors.amber[800],
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: (index) {
              if (FirebaseAuth.instance.currentUser == null) {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: poppinsText(TempLanguage.logInForFeatures, 16,
                              FontWeight.w500, blackColor),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.off(() => StartView(isBack: true));
                              },
                              child: Text(TempLanguage.logIn),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(TempLanguage.cancel),
                            ),
                          ],
                        ));
              } else {
                navBarController.currentIndex.value = index;
                navBarController.controller.index = index;
              }
            },
          ),
        );
      }),
    );

    // return WillPopScope(
    //     onWillPop: _onWillPop,
    //     child: PersistentTabView.custom(
    //         context,
    //         controller: navBarController.controller,
    //         itemCount: _navBarsItems().length,
    //         // This is required in case of custom style! Pass the number of items for the nav bar.
    //         screens: _buildScreens(),
    //         navBarHeight: 60,
    //         onWillPop: (context) {
    //           return showExitPopup(context);
    //         },
    //         resizeToAvoidBottomInset: true,
    //         hideNavigationBarWhenKeyboardShows: true,
    //         backgroundColor: whiteColor,
    //         popAllScreensOnTapOfSelectedTab: true,
    //         stateManagement: false,
    //         confineInSafeArea: true,
    //         handleAndroidBackButtonPress: true,
    //         customWidget: (navBarEssentials) => Container(
    //           decoration: const BoxDecoration(
    //             borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
    //           ),
    //           child: Obx(() => CustomNavBarWidget(
    //             items: _navBarsItems(),
    //             selectedIndex: navBarController.currentIndex.value,
    //             onItemSelected: (index) {
    //               navBarController.currentIndex.value = index;
    //               navBarController.controller.index = index;
    //               log('${navBarController.controller.index}');
    //             },
    //           ),)
    //         ),
    //       ),
    //     );
  }
}
