import 'dart:async';
import 'dart:math';

import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/auth_service.dart' hide newsFeedController;
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/main.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/Create%20Post/create_post_screen.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/list_tile_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/shared_post_comp.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/top_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/test_aid_comp/test_aid_comp.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';
import '../../../../utils/custom/custom_firebase_pagination.dart';
import '../../../widgets/custom_appbar.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

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
  RxBool _isTopContainerVisible = true.obs; // Variable to track visibility


  @override
  void initState() {
    super.initState();

    Future.microtask(() async => await setValue('first', 'no'));

    _scrollController.addListener(_onScroll); // Add scroll listener
  }

  void _onScroll() {
    double offset = _scrollController.offset;

    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse && _isTopContainerVisible.value && offset > 10) {

      //setState(() {
        _isTopContainerVisible.value = false;
      //});
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward && !_isTopContainerVisible.value && offset <= 50) {
      // Scroll up
      //setState(() {
        _isTopContainerVisible.value = true;
      //});
    }

  }

  @override
  void dispose() {
   //_scrollController.removeListener(_onScroll); // Remove listener
   //_scrollController.dispose();
    //controller.clearNewsFeeds();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    //Future.delayed(Duration(seconds: 3));
       setState(() {});
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
            Obx((){
              return AnimatedContainer(
                height: _isTopContainerVisible.value ? 17.5.h : 0.0,
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
            }),
            Expanded(
              child: CustomFirestorePagination(
                key: UniqueKey(),
                controller: _scrollController,
                limit: 20,
                viewType: ViewType.list,
                isLive: true,
                shrinkWrap: true,
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
                  // Add a custom container as the first item


                  if (index % 5 == 4) {
                    return NavtiveAdsComp(
                      key: ValueKey('Ad_$index'),
                    );
                  }
                  final itemIndex = index - (index ~/ 5);

                  final doc = documentSnapshot;
                  final data = doc.data() as Map<String, Object?>;

                  if (data[NewsFeed.HIDE_USER] is List &&
                      !(data[NewsFeed.HIDE_USER] as List)
                          .contains(userController.userModel.value.uid)) {
                    final newsFeedModel = NewsFeedModel.fromJson(data);
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
                },
              ),
            )
          ],
        )
    );
  }

}
