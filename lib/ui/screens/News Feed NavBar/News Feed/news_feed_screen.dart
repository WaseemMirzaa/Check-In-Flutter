import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/Services/user_services.dart';
import 'package:check_in/auth_service.dart' hide newsFeedController;
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/Create%20Post/create_post_screen.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/list_tile_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/shared_post_comp.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/top_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/test_aid_comp/test_aid_comp.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sizer/sizer.dart';
import '../../../../utils/custom/custom_firebase_pagination.dart';
import '../../../widgets/custom_appbar.dart';
import '../../terms_conditions.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key, this.postId = '', this.isBack = false});
  final String postId;
  final bool isBack;

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

//added a mixin "automatickeepaliveclientmixin"
class _NewsFeedScreenState extends State<NewsFeedScreen>
    with AutomaticKeepAliveClientMixin {
  final NewsFeedController controller =
      Get.put(NewsFeedController(NewsFeedService()));

  Future<void> _handleRefresh() async {
    Future.delayed(const Duration(seconds: 3));
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  final userServices = UserServices();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      if (FirebaseAuth.instance.currentUser != null &&
          userController.userModel.value.isTermsVerified == null) {
        Get.to(const TermsAndConditions(
          showButtons: true,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //added in build
    return Scaffold(
      appBar: CustomAppbar(
        showicon: widget.isBack,
        title: poppinsText(
          TempLanguage.newsFeed,
          15,
          FontWeight.bold,
          appBlackColor,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
             Obx(() {
              // Check if loading state is active
              if (controller.isLoading.value) {
                return _buildSecondTopContainer(true);
              }

              // Check if the following list is empty when selectedOption is 1
              if (controller.selectedOption == 1 &&
                  controller.followingList.isEmpty) {
                return _buildSecondTopContainer(false);
              }

              return
               FutureBuilder<List<UserModel>?>(
                future: userServices.getUsersList(), // Fetch the list of users
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loader while the future is being fetched
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // Handle error state
                    return Center(child: Text('Error fetching user data'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Handle empty data state
                    return _buildEmptyState();
                  } else {
                    // When data is successfully fetched, return the RefreshIndicator wrapped pagination feed
                    return RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: CustomFirestorePagination(
                        key: UniqueKey(),
                        limit: 20, // Reduces initial pagination
                        viewType: ViewType.list,
                        isLive: true,
                        initialLoader: _buildTopContainer(),
                        bottomLoader: Container(),
                        physics: const AlwaysScrollableScrollPhysics(),
                        onEmpty: _buildEmptyState(),
                        query: controller.getNewsFeedQuery(),                        
                        itemBuilder: (context, documentSnapshot, index) {
                          final data =
                              documentSnapshot.data() as Map<String, Object?>;

                          if (index == 0) {
                            return _buildTopContainer();
                          }

                          if (index % 10 == 9) {
                            return NavtiveAdsComp(key: ValueKey('Ad_$index'));
                          }

                          if (data.isNotEmpty &&
                              controller.shouldShowPost(data)) {
                            if (data[NewsFeed.HIDE_USER] is List) {
                              final hideUserList =
                                  data[NewsFeed.HIDE_USER] as List;

                              if (!hideUserList.contains(
                                  userController.userModel.value.uid)) {
                                final newsFeedModel =
                                    NewsFeedModel.fromJson(data);

                                UserModel? matchingUserShared, matchingUser;
                                try {
                                  matchingUser = snapshot.data!.firstWhere(
                                      (user) =>
                                          user.uid == newsFeedModel.userId);
                                } catch (_) {}
                                if (newsFeedModel.shareUID != null) {
                                  try {
                                    matchingUserShared = snapshot.data!
                                        .firstWhere((user) =>
                                            user.uid == newsFeedModel.shareUID);
                                  } catch (_) {}
                                }

                                // Check if the user profile is blocked
                                if (userController.blockProfiles
                                        .contains(newsFeedModel.userId) ||
                                    userController.blockProfiles
                                        .contains(newsFeedModel.shareUID)) {
                                  return const SizedBox.shrink();
                                }

                                if (matchingUser == null) {
                                  return const SizedBox
                                      .shrink(); // Fallback for unhandled cases
                                }

                                // Build the appropriate post based on the original or shared post
                                return newsFeedModel.isOriginal!
                                    ? ListTileContainer(
                                        key: ValueKey(newsFeedModel.id),
                                        data: newsFeedModel,
                                        userData: matchingUser,
                                      )
                                    : SharedPostComp(
                                        postUserData: matchingUser,
                                        shareUserData: matchingUserShared,
                                        key: ValueKey(newsFeedModel.shareID),
                                        data: newsFeedModel,
                                      );
                              }
                            }
                          }

                          return const SizedBox
                              .shrink(); // Fallback for unhandled cases
                        },
                      ),
                    );
                  }
                },
              );

              // If not loading and following list is not empty, show the content
              return RefreshIndicator(
                onRefresh: _handleRefresh,
                child: CustomFirestorePagination(
                  key: UniqueKey(),
                  limit: 20, //reduces initail pagination
                  viewType: ViewType.list,
                  isLive: true,
                  initialLoader: _buildTopContainer(),
                  bottomLoader: Container(),
                  physics: const AlwaysScrollableScrollPhysics(),
                  onEmpty: _buildEmptyState(),
                  query: controller.getNewsFeedQuery(),
                  itemBuilder: (context, documentSnapshot, index) {
                    final data =
                        documentSnapshot.data() as Map<String, Object?>;

                    if (index == 0) {
                      return _buildTopContainer();
                    }

                    if (index % 5 == 4) {
                      return Container();
                    }

                    if (controller.shouldShowPost(data)) {
                      if (data[NewsFeed.HIDE_USER] is List) {
                        final hideUserList = data[NewsFeed.HIDE_USER] as List;

                        if (!hideUserList
                            .contains(userController.userModel.value.uid)) {
                          final newsFeedModel = NewsFeedModel.fromJson(data);

                          // Here we create a Future to get user data
                          return FutureBuilder<UserModel?>(
                            future: userServices.getUserData(newsFeedModel
                                .userId!), // Get user data asynchronously
                            builder: (context, snapshot) {
                              // Check the status of the future
                              if (snapshot.hasData) {
                                UserModel? userData = snapshot.data;

                                // Proceed to check if the profile is blocked
                                if (userController.blockProfiles
                                        .contains(newsFeedModel.userId) ||
                                    userController.blockProfiles
                                        .contains(newsFeedModel.shareUID)) {
                                  return const SizedBox.shrink();
                                } else {
                                  return newsFeedModel.isOriginal!
                                      ? ListTileContainer(
                                          key: ValueKey(newsFeedModel.id),
                                          data: newsFeedModel,
                                          userData: userData,
                                        )
                                      : SharedPostComp(
                                          key: ValueKey(newsFeedModel.shareID),
                                          data: newsFeedModel,
                                        );
                                }
                              }
                              return const SizedBox.shrink(); // Fallback
                            },
                          );
                        }
                      }
                    }
                    return const SizedBox.shrink(); // Fallback
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContentofContainer() {
    return AnimatedContainer(
      height: 17.5.h,
      duration: const Duration(milliseconds: 10),
      curve: Curves.easeInOut,
      child: TopContainer(
        onWriteSomethingTap: () async {
          final result = await Get.to(CreatePost());
          if (result ?? false) {
            setState(() {});
          }
        },
        onPhotoTap: (String? val) async {
          if (!val.isEmptyOrNull) {
            final result = await Get.to(CreatePost());
            if (result ?? false) {
              setState(() {});
            }
          }
        },
        onVideoTap: (String? val) async {
          if (!val.isEmptyOrNull) {
            final result = await Get.to(CreatePost());
            if (result ?? false) {
              setState(() {});
            }
          }
        },
      ),
    );
  }

  // Builds the top container
  Widget _buildTopContainer() {
    return Column(
      children: [
        _buildContentofContainer(),
        _buildOptionsContainer(),
      ],
    );
  }

  // Builds the second top container
  Widget _buildSecondTopContainer(bool isload) {
    return Stack(
      children: [
        // Original content
        Column(
          children: [
            _buildContentofContainer(),
            _buildOptionsContainer(),
          ],
        ),

        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              isload
                  ? CircularProgressIndicator()
                  : poppinsText('No Posts Found', 16, medium, appBlackColor),
            ],
          ),
        )
        // // Centering the "No Posts Found" text
        // Positioned(
        //   top: screenSize.height * 0.5 -
        //       20, // Adjust the value to center it vertically
        //   left: screenSize.width * 0.6 -
        //       100, // Adjust the value to center it horizontally
        //   child: Center(
        //       child: isload
        //           ? const Center(child: CircularProgressIndicator(),)
        //           : poppinsText('No Posts Found', 16, medium, appBlackColor)),
        // )
      ],
    );
  }

  // Builds the options container
  Widget _buildOptionsContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          height: 30,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            // Add drop shadow here
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Shadow color
                spreadRadius: 1, // Spread radius
                blurRadius: 5, // Blur radius
                offset: Offset(0, 3), // Shadow position
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOptionButton('Community', 0),
              _buildOptionButton('Following', 1),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the option button
  Widget _buildOptionButton(String title, int option) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            controller.setSelectedOption(option);
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: controller.selectedOption == option
                ? appPrimaryColor
                : Colors.transparent,
            borderRadius: option == 0
                ? const BorderRadius.horizontal(left: Radius.circular(10))
                : const BorderRadius.horizontal(right: Radius.circular(10)),
          ),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: controller.selectedOption == option
                  ? Colors.white
                  : greyColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

// Builds the empty state widget
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopContainer(),
        Expanded(
          child: Center(
            child: Text(
              'No posts available',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: greyColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
