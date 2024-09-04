import 'package:check_in/Services/follower_and_following_service.dart';
import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/Messages/chat_controller.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/Component/send_message_container.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/Chat/chat_screen.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/other_profile/other_profile_messages.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/list_tile_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/followers_and_following/controller/followers_and_following_controller.dart';
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

import '../../../../auth_service.dart';
import '../../News Feed NavBar/News Feed/Component/report_on_post_comp.dart';
import '../../News Feed NavBar/News Feed/Component/shared_post_comp.dart';

class OtherProfileView extends StatefulWidget {
  final String uid;
  bool toHome;
  final bool isMyProfile; // Parameter with default value

  OtherProfileView(
      {super.key,
      required this.uid,
      this.toHome = false,
      this.isMyProfile = false});

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

  final sendMessageController = Get.put(OtherProfileMessages());

  final controller = Get.put(NewsFeedController(NewsFeedService()));

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();

    controller.clearUserPosts();
  }

  //methods to check for followers and following

  // void _listenToFollowStatus() {
  //   print("Listening to follow status");
  //   _firestoreService.getFollowStatus(widget.uid).listen((status) {
  //     print("Received follow status update: $status");
  //     setState(() {
  //       isFollowing = status;
  //     });
  //   });
  // }

  // Future<void> _toggleFollow() async {
  //   try {
  //     String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  //     if (isFollowing) {
  //       print("Unfollowing user ${widget.uid}");
  //       followerCountController.setUserId(widget.uid);
  //       await _firestoreService.removeFollower(currentUserId, widget.uid);

  //       setState(() {
  //         isFollowing = false;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Unfollowed successfully!')),
  //       );
  //     } else {
  //       print("Following user ${widget.uid}");
  //       followerCountController.setUserId(widget.uid);
  //       await _firestoreService.addFollower(currentUserId, widget.uid);

  //       setState(() {
  //         isFollowing = true;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Followed successfully!')),
  //       );
  //     }
  //   } catch (e) {
  //     print("Error toggling follow: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to toggle follow: $e')),
  //     );
  //   }
  // }

  late FollowerCountingController followerCountController;

  late String currentUid;
  late String senderName;
  late String senderPhotoUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(_onScroll);
    controller.getUserPosts(widget.uid);

    // Initialize the FollowerCountingController and set the userId
    followerCountController = Get.put(FollowerCountingController());

    followerCountController.setUserId(widget.uid);

    // // Set the userId after the controller is initialized
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   followerCountController.setUserId(widget.uid);
    // });

    // Check follow status
    sendMessageController
        .listenToFollowStatus(widget.uid); // Set up real-time listener

    // Fetch current user's profile once and store the data
    fetchCurrentUserProfile();
  }

  Future<UserModel> getCurrentUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Handle the case where no user is signed in
      throw Exception("No user is currently signed in");
    }

    final uid = currentUser.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection(Collections.USER)
        .doc(uid)
        .get();

    final data = snapshot.data();
    if (data != null) {
      return UserModel.fromMap(data);
    } else {
      // Handle the case when user data is not available
      throw Exception("Current user data not available");
    }
  }

  final ChatController chatcontroller =
      Get.find<ChatController>(); //find can be problematic

  Future<void> fetchCurrentUserProfile() async {
    try {
      final currentUser = await getCurrentUserProfile();
      setState(() {
        currentUid = currentUser.uid!;
        senderName = currentUser.userName!;
        senderPhotoUrl = currentUser.photoUrl!;
      });
    } catch (e) {
      // Handle the error, e.g., show a message to the user
      print("Error fetching current user profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        actions: [
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appGreyColor1),
              child: Icon(
                Icons.more_horiz,
                color: greyColor,
              ),
            ),
            onSelected: (String result) async {
              switch (result) {
                case 'Block Profile':
                  final res = await userController.blockProfile(widget.uid, userController.userModel.value.uid!);
                  if (res) {
                    toast('Profile is successfully blocked for you');
                  } else {
                    toast('Something went wrong. Try again later');
                  }
                  break;
                case 'Profile Report':
                  final res = await Get.to(Report(profileId: widget.uid, reportedBy: userController.userModel.value.uid!, isProfile: true,));
                  if (res ?? false) {} else {
                    toast('Something went wrong. Try again later');
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry<String>> items = [
                const PopupMenuItem<String>(
                  value: 'Profile Report',
                  child: ListTile(
                    leading: Icon(Icons.report),
                    title: Text('Profile Report'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Block Profile',
                  child: ListTile(
                    leading: Icon(Icons.block),
                    title: Text('Block Profile'),
                  ),
                ),
              ];

              return items;
            },
          )
        ],
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
                          width: 30.9.w,
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
                            24,
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
                                      otherUserId: widget.uid,
                                      showFollowers: true,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Obx(() => poppinsText(
                                        followerCountController
                                            .followersCount.value
                                            .toString(),
                                        16,
                                        underline: true,
                                        bold,
                                        appBlackColor,
                                      )),
                                  SizedBox(height: 4),
                                  poppinsText(
                                      'Followers', 16, medium, appBlackColor),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              height: 38,
                              child: VerticalDivider(
                                width: 20,
                                thickness: 2,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FollowersAndFollowingScreen(
                                      otherUserId: widget.uid,
                                      showFollowers: false,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Obx(() => poppinsText(
                                        followerCountController
                                            .followingCount.value
                                            .toString(),
                                        16,
                                        underline: true,
                                        bold,
                                        appBlackColor,
                                      )),
                                  SizedBox(height: 4),
                                  poppinsText(
                                      'Following', 16, medium, appBlackColor),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        if (widget.isMyProfile == false)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Obx(() => InkWell(
                                    onTap: () {
                                      sendMessageController
                                          .toggleFollow(widget.uid);
                                    },
                                    child: Container(
                                      height: 35,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: offWhiteColor,
                                        borderRadius: BorderRadius.circular(
                                            12), // Adjust the radius as needed
                                      ),
                                      child: Center(
                                        child: sendMessageController
                                                .isFollowing.value
                                            ? poppinsText('Unfollow', 16,
                                                FontWeight.w400, Colors.black)
                                            : poppinsText('Follow', 16,
                                                FontWeight.w400, Colors.black),
                                      ),
                                    ),
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Obx(() {
                                return Stack(
                                  children: [
                                    InkWell(
                                      onTap: sendMessageController
                                              .isLoading.value
                                          ? null
                                          : () async {
                                              sendMessageController.setLoading(
                                                  true); // Start loading

                                              try {
                                                var value =
                                                    await sendMessageController
                                                        .startNewChat(
                                                  currentUid,
                                                  senderName,
                                                  senderPhotoUrl,
                                                  userItems.uid!,
                                                  userItems.userName!,
                                                  userItems.photoUrl!,
                                                );

                                                if (value['isNewChat'] ==
                                                    true) {
                                                  // Send notification
                                                  await sendMessageController
                                                      .sendNotificationMethod(
                                                    '',
                                                    '$senderName sent a message request',
                                                    senderName,
                                                    value['docId'],
                                                    [currentUid, userItems.uid],
                                                    currentUid,
                                                    image: senderPhotoUrl,
                                                  );
                                                } else {
                                                  // Update delete chat status
                                                  await sendMessageController
                                                      .updateDeleteChatStatus(
                                                    value['docId'],
                                                    currentUid,
                                                  );
                                                  // Uncomment if you want to show a success message
                                                  // successMessage('Chat already exists');
                                                }

                                                log('doc id $value');
                                                chatcontroller.docId.value =
                                                    value['docId'];
                                                chatcontroller.name.value =
                                                    userItems.userName!;
                                                chatcontroller.senderName
                                                    .value = senderName;
                                                chatcontroller.isgroup = false;
                                                chatcontroller.image.value =
                                                    userItems.photoUrl!;
                                                chatcontroller.memberId.value =
                                                    [currentUid, userItems.uid];

                                                // Navigate to ChatScreen
                                                pushNewScreen(
                                                  context,
                                                  screen: ChatScreen(
                                                    image: userItems.photoUrl,
                                                  ),
                                                );
                                              } catch (e) {
                                                // Handle errors if necessary
                                                print("Error: $e");
                                              } finally {
                                                sendMessageController
                                                    .setLoading(
                                                        false); // End loading
                                              }
                                            },
                                      child: Container(
                                        height: 35,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: offWhiteColor,
                                          borderRadius: BorderRadius.circular(
                                              12), // Adjust the radius as needed
                                        ),
                                        child: Center(
                                          child: sendMessageController
                                                  .isLoading.value
                                              ? Container(
                                                  height: 15,
                                                  width: 15,
                                                  child:
                                                      CircularProgressIndicator(
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                ) // Show progress indicator when loading
                                              : poppinsText(
                                                  'Message',
                                                  16,
                                                  FontWeight.w400,
                                                  Colors.black),
                                        ),
                                      ),
                                    ),
                                    if (sendMessageController.isLoading.value)
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                  ],
                                );
                              }),
                            ],
                          ),

                        if (widget.isMyProfile == false)
                          const SizedBox(
                            height: 15,
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
                                      radius: 50.0,
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
                                          fontSize: 14.0,
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
                                      radius: 50.0,
                                      lineWidth: 8.0,
                                      animation: true,
                                      percent: (0 / (totalCount ?? 10))
                                          .clamp(0.0, 1.0),
                                      center: const Text(
                                        "0\nCheck ins",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
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
