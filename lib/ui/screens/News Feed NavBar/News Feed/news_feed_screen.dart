import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/Create%20Post/create_post_screen.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/list_tile_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/shared_post_comp.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/top_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/test_aid_comp/test_aid_comp.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';
import '../../../widgets/custom_appbar.dart';

class NewsFeedScreen extends StatefulWidget {
  NewsFeedScreen({super.key, this.postId = ''});
  String postId;

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final controller = Get.put(NewsFeedController(NewsFeedService()));

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() async => await setValue('first', 'no'));
    controller.fetchInitialNewsFeed();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      print("The else if condition called");
      controller.fetchMoreNewsFeed();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    controller.clearNewsFeeds();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(
          showicon: false,
          title:  poppinsText(
                TempLanguage.newsFeed, 15, FontWeight.bold, appBlackColor),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Obx(() {
            return Column(
              children: [
                TopContainer(
                  ontap: () {
                    pushNewScreen(context,
                        screen: CreatePost(), withNavBar: true);
                  },
                ),
                Obx(() {
                  if (controller.newsFeed.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(TempLanguage.noPostFound),
                      ],
                    );
                  } else {

                    return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.newsFeed.length +
                            (controller.newsFeed.length ~/ 4),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          if (index % 5 == 4) {
                            return const NavtiveAdsComp(key: ValueKey('Aid'));
                          }
                          final itemIndex = index - (index ~/ 5);
                          log("\n\nThe Length of the posts are: ${controller
                              .newsFeed
                              .length}\n\n\n");
                          var data = controller.newsFeed[itemIndex];
                          return data.isOriginal! ? ListTileContainer(
                            key: ValueKey(data.id),
                            data: data,
                          ) : SharedPostComp(
                              key: ValueKey(data.shareUID),
                              data: data);
                        }
                    );
                  }
                }),
                controller.isLoader.value ? const Center(
                  key: ValueKey('LOADER'),
                  child: Padding(
                  padding: EdgeInsets.all(2.0),
                  child: CircularProgressIndicator(),
                ),) : const SizedBox(key: ValueKey('empty'),),
                SizedBox(
                  key: const ValueKey('For space'),
                  height: 2.h,)
              ],
            );
          }
          ),
        ));
  }
}
