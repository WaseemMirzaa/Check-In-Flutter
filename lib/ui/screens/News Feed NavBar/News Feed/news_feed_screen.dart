import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/auth_service.dart';
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
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';
import '../../../widgets/custom_appbar.dart';

class NewsFeedScreen extends StatefulWidget {
  NewsFeedScreen({super.key, this.postId = '', this.isBack = false});
  String postId;
  bool isBack;

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final controller = Get.put(NewsFeedController(NewsFeedService()));

  final ScrollController _scrollController = ScrollController();
  double _topContainerHeight = 0.0; // Variable to control the animation height
  bool _isTopContainerVisible = true; // Variable to track visibility

  @override
  void initState() {
    super.initState();

    Future.microtask(() async => await setValue('first', 'no'));

    _scrollController.addListener(_onScroll); // Add scroll listener
  }

  void _onScroll() {
    double offset = _scrollController.offset;

    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse && _isTopContainerVisible) {

      setState(() {
        _isTopContainerVisible = false;
      });
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward && !_isTopContainerVisible) {
      // Scroll up
      setState(() {
        _isTopContainerVisible = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll); // Remove listener
    _scrollController.dispose();
    controller.clearNewsFeeds();
    super.dispose();
  }

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

        AnimatedContainer(
          height: _isTopContainerVisible ? 17.5.h : 0.0,
          duration: const Duration(milliseconds: 10),
          curve: Curves.easeInOut,
          child: TopContainer(
            ontap: () {
              pushNewScreen(context,
                  screen: CreatePost(), withNavBar: true);
            },
          ),
        ),

          Expanded(
            child: FirestorePagination(
                controller: _scrollController,
                limit: 10,
                viewType: ViewType.list,
                shrinkWrap: true,
                // isLive: true,
                onEmpty: const Center(
                  child: Text('Cart is empty'),
                ),
                bottomLoader: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: 25,
                        height: 25,
                        margin: const EdgeInsets.all(10),
                        child: const CircularProgressIndicator.adaptive(
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  ],
                ),
                query: FirebaseFirestore.instance
                    .collection(Collections.NEWSFEED)
                    .orderBy(NewsFeed.TIME_STAMP, descending: true),
                itemBuilder: (context, documentSnapshot, index) {
                  if (index % 5 == 4) {
                    return NavtiveAdsComp(
                      key: ValueKey('Ad_$index'),
                    );
                  }
                  final itemIndex = index - (index ~/ 5);

                  print("*******************Length is*************** $itemIndex\n");
                  final doc = documentSnapshot;
                  final data = doc.data() as Map<String, Object?>;
                  if (data[NewsFeed.HIDE_USER] is List &&
                      !(data[NewsFeed.HIDE_USER] as List).contains(
                          userController.userModel.value.uid)) {
                    final newsFeedModel = NewsFeedModel.fromJson(data);
                    print("------Model is: ${newsFeedModel.id}");
                    if (data == null) return Container();
                    return newsFeedModel.isOriginal!
                        ? ListTileContainer(
                      key: ValueKey(newsFeedModel.id),
                      data: newsFeedModel,
                    )
                        : SharedPostComp(
                        key: ValueKey(newsFeedModel.shareID),
                        data: newsFeedModel);
                  } else {
                    return const SizedBox.shrink();
                  }
                }
            ),
          ),
        ],
      ),
    );
  }
}
