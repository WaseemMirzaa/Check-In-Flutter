// ignore_for_file: avoid_print
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/my_posts/my_posts.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/news_feed_onboarding/news_feed_onboarding.dart';
import 'package:check_in/ui/screens/check_in.dart';
import 'package:check_in/ui/screens/profile_screen.dart';
import 'package:check_in/ui/screens/start.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/common.dart';
import 'package:check_in/utils/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

import ' Messages NavBar/Messages/messages.dart';
import 'History.dart';
import '../../controllers/nav_bar_controller.dart';
import 'News Feed NavBar/News Feed/news_feed_screen.dart';
import 'dart:developer' as developer;
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
          color: appWhiteColor,
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
                                  16, FontWeight.w500, appBlackColor),
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
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() async{
      FirebaseAuth.instance.currentUser != null && getStringAsync('first') != 'no' ?  Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const NewsFeedOnboarding())) : null;
    });
    initDynamicLinks(context);


}
  final List<Widget> _buildScreens = [
    const CheckIn(),
    MessageScreen(),
    //................ News Feed
    NewsFeedScreen(),
    const HistoryView(),
    ProfileScreen()
    //KeyedSubtree(key: UniqueKey(), child: const ProfileScreen()),
  ];
  /// The deep link
  Future<void> initDynamicLinks(BuildContext context) async {
    await Firebase.initializeApp();
    // Handle initial link when the app is first opened
    final PendingDynamicLinkData? initialLinkData = await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(context, initialLinkData?.link);

    // Set up the listener for any dynamic links clicked while the app is in the background or foreground
    FirebaseDynamicLinks.instance.onLink.listen(
          (PendingDynamicLinkData dynamicLinkData) {
        _handleDeepLink(context, dynamicLinkData?.link);
      },
      onError: (error) async {
        developer.log('Dynamic Link Failed: ${error.toString()}');
      },
    );
  }

  void _handleDeepLink(BuildContext context, Uri? deepLink) {
    if (deepLink != null) {
      var isPost = deepLink.pathSegments.contains('post');
      print("THe collection contains---> $isPost");
      if (isPost) {
        var postId = deepLink.queryParameters['postId=12'];
        if (postId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsFeedScreen(postId: postId,),
            ),
          );
        }
      }
    }
  }


  List<BottomNavigationBarItem> _navBarsItems() {
    return [
      BottomNav(
        label: 'Home',
        boxColor:
            navBarController.controller.index == 0 ? appGreenColor : appWhiteColor,
        icon: "Group 12548",
        iconColor:
            navBarController.controller.index == 0 ? appWhiteColor : appBlackColor,
      ).getBottomNavItem(),
      BottomNav(
        label: 'Chat',
        boxColor:
            navBarController.controller.index == 1 ? appGreenColor : appWhiteColor,
        icon: "Path 28661",
        iconColor:
            navBarController.controller.index == 1 ? appWhiteColor : appBlackColor,
      ).getBottomNavItem(),

      //.......................... News Feed
      BottomNav(
        label: 'NewsFeed',
        boxColor:
            navBarController.controller.index == 2 ? appGreenColor : appWhiteColor,
        icon: "calendar",
        iconColor:
            navBarController.controller.index == 2 ? appWhiteColor : appBlackColor,
      ).getBottomNavItem(),
      BottomNav(
        label: 'History',
        boxColor:
            navBarController.controller.index == 3 ? appGreenColor : appWhiteColor,
        icon: "Icon awesome-history",
        iconColor:
            navBarController.controller.index == 3 ? appWhiteColor : appBlackColor,
      ).getBottomNavItem(),
      BottomNav(
        label: 'Profile',
        boxColor:
            navBarController.controller.index == 4 ? appGreenColor : appWhiteColor,
        icon: "Icon material-person",
        iconColor:
            navBarController.controller.index == 4 ? appWhiteColor : appBlackColor,
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
          body: _buildScreens[navBarController.currentIndex.value],
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
                              FontWeight.w500, appBlackColor),
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
