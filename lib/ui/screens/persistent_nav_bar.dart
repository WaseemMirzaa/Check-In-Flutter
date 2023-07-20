// ignore_for_file: avoid_print

import 'package:check_in/ui/screens/check_in.dart';
import 'package:check_in/ui/screens/profile_screen.dart';
import 'package:check_in/ui/screens/start.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

import 'History.dart';
import '../../controllers/nav_bar_controller.dart';

class BottomNav {
  String icon;
  Color iconColor;
  Color boxColor;

  BottomNav({
    required this.icon,
    required this.iconColor,
    required this.boxColor,
  });

  getBottomNavItem() {
    return PersistentBottomNavBarItem(
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
    );
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
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(40))),
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
                              title: poppinsText("Please log in to use more features", 16,
                                  FontWeight.w500, Colors.black),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Get.off(() => StartView(isBack: true));
                                  },
                                  child: const Text('Login'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
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

class _HomeState extends State<Home> {
  final NavBarController navBarController = Get.put(NavBarController());

  List<Widget> _buildScreens() {
    return [
      const CheckIn(),
      const HistoryView(),
      const ProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      BottomNav(
        boxColor:
            navBarController.controller.index == 0 ? greenColor : whiteColor,
        icon: "Group 12548",
        iconColor:
            navBarController.controller.index == 0 ? whiteColor : blackColor,
      ).getBottomNavItem(),
      BottomNav(
        boxColor:
            navBarController.controller.index == 1 ? greenColor : whiteColor,
        icon: "Icon awesome-history",
        iconColor:
            navBarController.controller.index == 1 ? whiteColor : blackColor,
      ).getBottomNavItem(),
      BottomNav(
        boxColor:
            navBarController.controller.index == 2 ? greenColor : whiteColor,
        icon: "Icon material-person",
        iconColor:
            navBarController.controller.index == 2 ? whiteColor : blackColor,
      ).getBottomNavItem(),
    ];
  }

  Future<bool> showExitPopup(BuildContext? context) async {
    return await showDialog(
          context: context!,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you want to exit an App?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                //return false when click on "NO"
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                //return true when click on "Yes"
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false; //if showDialouge had returned null, then return false
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: PersistentTabView.custom(
        context,
        controller: navBarController.controller,
        itemCount: _navBarsItems().length,
        // This is required in case of custom style! Pass the number of items for the nav bar.
        screens: _buildScreens(),
        navBarHeight: 60,
        onWillPop: (context) {
          return showExitPopup(context);
        },
        hideNavigationBarWhenKeyboardShows: true,
        backgroundColor: Colors.white,
        popAllScreensOnTapOfSelectedTab: true,
        confineInSafeArea: true,
        handleAndroidBackButtonPress: true,
        customWidget: (navBarEssentials) => Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
          ),
          child: CustomNavBarWidget(
            // Your custom widget goes here
            items: _navBarsItems(),
            selectedIndex: navBarController.currentIndex.value,
            onItemSelected: (index) {
              setState(() {
                navBarController.currentIndex.value = index;
                navBarController.controller.index =
                    index; // NOTE: THIS IS CRITICAL!! Don't miss it!
              });
              print(navBarController.currentIndex.value);
              print(navBarController.controller.index);
            },
          ),
        ),
      ),
    );
  }
}
