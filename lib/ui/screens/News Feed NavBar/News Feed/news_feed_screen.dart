import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/auth_service.dart' hide newsFeedController;
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/Create%20Post/create_post_screen.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/list_tile_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/shared_post_comp.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/top_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/test_aid_comp/test_aid_comp.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sizer/sizer.dart';
import '../../../../utils/custom/custom_firebase_pagination.dart';
import '../../../widgets/custom_appbar.dart';

class NewsFeedScreen extends StatefulWidget {
  NewsFeedScreen({super.key, this.postId = '', this.isBack = false});
  final String postId;
  final bool isBack;

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final NewsFeedController controller =
      Get.put(NewsFeedController(NewsFeedService()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        showicon: widget.isBack,
        title: poppinsText(
            TempLanguage.newsFeed, 15, FontWeight.bold, appBlackColor),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.handleRefresh,
              child: CustomFirestorePagination(
                key: UniqueKey(),
                limit: 20,
                viewType: ViewType.list,
                isLive: true,
                physics: const AlwaysScrollableScrollPhysics(),
                onEmpty: _buildEmptyState(),
                query: controller.getNewsFeedQuery(), // Use dynamic query here
                itemBuilder: (context, documentSnapshot, index) {
                  final data = documentSnapshot.data() as Map<String, Object?>;

                  // Debugging log to check the data
                  print('Document data: $data');

                  if (index == 0) {
                    return _buildTopContainer();
                  }

                  if (index % 5 == 4) {
                    return NavtiveAdsComp(key: ValueKey('Ad_$index'));
                  }

                  if (controller.shouldShowPost(data)) {
                    print("Post should be shown: ${data[NewsFeed.HIDE_USER]}");

                    if (data[NewsFeed.HIDE_USER] is List) {
                      final hideUserList = data[NewsFeed.HIDE_USER] as List;
                      print("Hide user list: $hideUserList");

                      if (!(hideUserList
                          .contains(userController.userModel.value.uid))) {
                        final newsFeedModel = NewsFeedModel.fromJson(data);
                        print("Displaying post: $newsFeedModel");
                        print(
                            "Post ID: ${newsFeedModel.id}, Share ID: ${newsFeedModel.shareID}, Is Original: ${newsFeedModel.isOriginal}");

                        return newsFeedModel.isOriginal!
                            ? ListTileContainer(
                                key: ValueKey(newsFeedModel.id),
                                data: newsFeedModel,
                              )
                            : SharedPostComp(
                                key: ValueKey(newsFeedModel.shareID),
                                data: newsFeedModel,
                              );
                      } else {
                        print("User is hidden for this post.");
                      }
                    } else {
                      print("HIDE_USER is not a List.");
                    }
                  } else {
                    print("Post filtered out by shouldShowPost.");
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  // Builds the top container
  Widget _buildTopContainer() {
    return Column(
      children: [
        AnimatedContainer(
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
        ),
        _buildOptionsContainer(),
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
          height: 50,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
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
        const Center(child: Text('No data found')),
      ],
    );
  }
}
