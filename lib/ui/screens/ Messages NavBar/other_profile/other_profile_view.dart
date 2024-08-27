import 'package:check_in/Services/follower_and_following_service.dart';
import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/list_tile_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/followers_and_following/followers_and_following.dart';
import 'package:check_in/ui/screens/add_home_court.dart';
import 'package:check_in/ui/screens/persistent_nav_bar.dart';
import 'package:check_in/ui/screens/profile_screen.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

import '../../News Feed NavBar/News Feed/Component/shared_post_comp.dart';

class OtherProfileView extends StatefulWidget {
  final String uid;
  bool toHome;

  OtherProfileView({super.key, required this.uid, this.toHome = false});

  @override
  State<OtherProfileView> createState() => _OtherProfileViewState();
}

class _OtherProfileViewState extends State<OtherProfileView> {
  Stream<UserModel> getProfile(String uid) {
    return FirebaseFirestore.instance
        .collection(Collections.USER)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data != null) {
        return UserModel.fromMap(data);
      } else {
        // Handle the case when user data is not available
        // You can throw an error, return a default user, or handle it as per your application's logic
        throw Exception("User data not available");
      }
    });
  }

  final ScrollController _scrollController = ScrollController();

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      controller.fetchMoreUserPosts(widget.uid);
    }
  }

  final controller = Get.put(NewsFeedController(NewsFeedService()));

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    controller.clearUserPosts();
  }

  //methods to check for followers and following

  bool isFollowing = false;
  final FollowerAndFollowingService _firestoreService =
      FollowerAndFollowingService();
  int _followersCount = 0;
  int _followingCount = 0;

  void _listenToFollowStatus() {
    print("Listening to follow status");
    _firestoreService.getFollowStatus(widget.uid).listen((status) {
      print("Received follow status update: $status");
      setState(() {
        isFollowing = status;
      });
    });
  }

  Future<void> _toggleFollow() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      if (isFollowing) {
        print("Unfollowing user ${widget.uid}");
        await _firestoreService.removeFollower(currentUserId, widget.uid);
        setState(() {
          isFollowing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unfollowed successfully!')),
        );
      } else {
        print("Following user ${widget.uid}");
        await _firestoreService.addFollower(currentUserId, widget.uid);
        setState(() {
          isFollowing = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Followed successfully!')),
        );
      }
    } catch (e) {
      print("Error toggling follow: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle follow: $e')),
      );
    }
  }

 

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(_onScroll);
    controller.getUserPosts(widget.uid);

    // Check follow status
    _listenToFollowStatus(); // Set up real-time listener
 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //changes by asjad for adding followers and followings
        actions: [
          IconButton(
            onPressed: () {
              print("Toggling follow status");
              _toggleFollow();
            },
            icon: Icon(
              isFollowing ? Icons.remove : Icons.add,
            ),
          ),
        ],

        leading: InkWell(
          onTap: () {
            if (widget.toHome) {
              print("Home+++++++++++++++++++++++++++++");
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Home()));
            } else {
              Navigator.pop(context);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 25,
              ),
              SizedBox(
                height: 2.1.h,
                width: 2.9.w,
                child: Material(
                    color: appTransparentColor,
                    child: Image.asset(AppAssets.LEFT_ARROW)),
              )
            ],
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: appWhiteColor,
        title: poppinsText(
            TempLanguage.profile, 20, FontWeight.bold, appBlackColor),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: StreamBuilder<UserModel>(
            stream: getProfile(widget.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 80.h,
                  width: 100.w,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: CircularProgressIndicator()),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                final userItems = snapshot.data!;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: 32.9.w,
                          //   padding: EdgeInsets.all(10),
                          child: Stack(
                            //  clipBehavior: Clip.antiAliasWithSaveLayer,
                            alignment: Alignment.bottomCenter,
                            children: [
                              (snapshot.data!.photoUrl!.isEmptyOrNull)
                                  ? Container(
                                      height: 20.h,
                                      width: 35.h,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 2, color: appGreenColor),
                                          image: const DecorationImage(
                                              image: AssetImage(
                                                  AppAssets.LOGO_NEW),
                                              fit: BoxFit.fill)),
                                    )
                                  : Container(
                                      height: 20.h,
                                      width: 35.h,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  snapshot.data!.photoUrl ??
                                                      ""),
                                              fit: BoxFit.fill))),
                              if (snapshot.data!.isVerified == null ||
                                  snapshot.data!.isVerified == true)
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    height: 5.5.h,
                                    width: 12.1.w,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: AssetImage(AppAssets
                                                .INSTAGRAM_VERIFICATION))),
                                  ),
                                )
                              else
                                const SizedBox(),
                            ],
                          ),
                        ),
                        poppinsText(
                            // FirebaseAuth.instance.currentUser?.displayName
                            //     as String,
                            snapshot.data!.userName ?? "",
                            32,
                            FontWeight.bold,
                            appBlackColor),
                        // poppinsText(
                        //     "@${userController.userModel.value.email.substring(0, userController.userModel.value.email.indexOf('@'))}",
                        //     12,
                        //     FontWeight.normal,
                        //     blackColor),

                        // poppinsText(
                        //   // FirebaseAuth.instance.currentUser?.displayName
                        //   //     as String,
                        //     snapshot.data!.email ?? "",
                        //     12,
                        //     FontWeight.normal,
                        //     appBlackColor),
                        // poppinsText(
                        //     "@${userController.userModel.value.email.substring(0, userController.userModel.value.email.indexOf('@'))}",
                        //     12,
                        //     FontWeight.normal,
                        //     blackColor),
                        const SizedBox(
                          height: 10,
                        ),

                        //added by asjad

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FollowersAndFollowingScreen(
                                            showFollowers: true),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  poppinsText("$_followersCount", 12,
                                      FontWeight.bold, appBlackColor),
                                  SizedBox(height: 4),
                                  poppinsText('Followers', 12,
                                      FontWeight.normal, appBlackColor),
                                ],
                              ),
                            ),
                            const SizedBox(width: 25),
                            VerticalDivider(
                              width: 20, // Adjust width as needed
                              thickness: 10, // Adjust thickness as needed
                              color: Colors.black, // Adjust color as needed
                            ),
                            const SizedBox(width: 25),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FollowersAndFollowingScreen(
                                            showFollowers: false),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  poppinsText("$_followingCount", 12,
                                      FontWeight.bold, appBlackColor),
                                  SizedBox(height: 4),
                                  poppinsText('Following', 12,
                                      FontWeight.normal, appBlackColor),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: offWhiteColor,
                                  width: 8.0,
                                ),
                              ),
                              child: FutureBuilder<List<UserModel>?>(
                                future: getUniqueCourtOtherNameMaps(
                                    snapshot.data!.uid!),
                                builder: (context, courtsSnapshot) {
                                  if (courtsSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox(
                                        height: 110,
                                        width: 110,
                                        child: Center(
                                            child:
                                                CircularProgressIndicator()));
                                  } else if (courtsSnapshot.hasData &&
                                      courtsSnapshot.data != null) {
                                    return CircularPercentIndicator(
                                      radius: 55.0,
                                      lineWidth: 8.0,
                                      animation: true,
                                      percent:
                                          ((courtsSnapshot.data?.length ?? 0) /
                                                  (totalCount ?? 10))
                                              .clamp(0.0, 1.0),
                                      center: Text(
                                        "${courtsSnapshot.data?.length ?? 0}\nCheck ins",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      circularStrokeCap:
                                          CircularStrokeCap.round,
                                      progressColor: darkYellowColor,
                                    );
                                  } else if (courtsSnapshot.hasError) {
                                    return Center(
                                      child: Text(TempLanguage.wentWrong),
                                    );
                                  } else {
                                    return CircularPercentIndicator(
                                      radius: 55.0,
                                      lineWidth: 8.0,
                                      animation: true,
                                      percent: (0 / (totalCount ?? 10))
                                          .clamp(0.0, 1.0),
                                      center: const Text(
                                        "0\nCheck ins",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      circularStrokeCap:
                                          CircularStrokeCap.round,
                                      progressColor: darkYellowColor,
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                poppinsText("Golden", 22, FontWeight.bold,
                                    appBlackColor),
                                poppinsText("Courts", 22, FontWeight.bold,
                                    appBlackColor),
                                FutureBuilder<List<UserModel>?>(
                                  future: getUniqueCourtOtherNameMaps(
                                      snapshot.data!.uid!),
                                  builder: (context, goldenSnapshot) {
                                    if (goldenSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      // return const Center(child: CircularProgressIndicator());
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (goldenSnapshot.hasData &&
                                        goldenSnapshot.data != null) {
                                      return poppinsText(
                                          "${goldenSnapshot.data?.length ?? 0} Check ins",
                                          12,
                                          FontWeight.normal,
                                          appBlackColor);
                                    } else if (goldenSnapshot.hasError) {
                                      return Center(
                                        child: Text(TempLanguage.wentWrong),
                                      );
                                    } else {
                                      return poppinsText("0 Check ins", 12,
                                          FontWeight.normal, appBlackColor);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                              width: 100.w,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 12),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: appGreyColor1),
                              child: Text(
                                snapshot.data!.aboutMe.toString(),
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: regular,
                                    color: silverColor),
                              )),
                          Positioned(
                              top: -10,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 3),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: appGreenColor),
                                  child: poppinsText('About Me', 12,
                                      FontWeight.w400, appWhiteColor),
                                ),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            width: 100.w,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: appGreyColor1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                poppinsText(
                                    snapshot.data!.homeCourt.isEmptyOrNull
                                        ? ''
                                        : snapshot.data!.homeCourt ?? '',
                                    14,
                                    FontWeight.w500,
                                    silverColor),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: InkWell(
                                      onTap: () {
                                        pushNewScreen(context,
                                            screen: const AddHomeCourt(),
                                            withNavBar: false);
                                      },
                                      child: SizedBox(
                                        height: 2.3.h,
                                        width: 4.47.w,
                                        child: Image.asset(AppAssets.MAP_PIN),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                              top: -10,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 3),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: appGreenColor),
                                  child: poppinsText('Home Court', 12,
                                      FontWeight.w400, appWhiteColor),
                                ),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                              color: appGreyColor1,
                              borderRadius: BorderRadius.circular(30)),
                          child: Center(
                              child:
                                  Text("${snapshot.data!.userName}'s Posts")),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Obx(() {
                      if (controller.userPosts.isEmpty) {
                        return Center(child: Text(TempLanguage.noPostFound));
                      } else {
                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: controller.userPosts.length +
                              (controller.isUserPostMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == controller.userPosts.length) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            print("Length ${controller.userPosts.length}");

                            var data = controller.userPosts[index];
                            return data.isOriginal!
                                ? ListTileContainer(
                                    isOtherProfile: true,
                                    key: ValueKey(data.id),
                                    data: data,
                                  )
                                : SharedPostComp(
                                    isOtherProfile: true,
                                    key: ValueKey(data.id),
                                    data: data,
                                  );
                          },
                        );
                      }
                    }),
                    controller.userPostLoader.value
                        ? const Center(
                            key: ValueKey('Loader'),
                            child: CircularProgressIndicator(),
                          )
                        : const SizedBox(
                            key: ValueKey('Empty'),
                          ),
                    SizedBox(
                      height: 2.h,
                    )
                  ],
                );
              }
            }),
      ),
    );
  }
}
