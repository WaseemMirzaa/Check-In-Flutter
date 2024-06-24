import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/Create%20Post/create_post_screen.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/list_tile_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/shared_post_comp.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/top_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/test_aid_comp/test_aid_comp.dart';
import 'package:check_in/ui/widgets/custom_container.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/loader.dart';
import 'package:check_in/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/cupertino.dart';
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


  // /// The deep link
  // Future<void> initDynamicLinks(BuildContext context) async {
  //   await Firebase.initializeApp();
  //   // Handle initial link when the app is first opened
  //   final PendingDynamicLinkData? initialLinkData = await FirebaseDynamicLinks.instance.getInitialLink();
  //   _handleDeepLink(context, initialLinkData?.link);
  //
  //   // Set up the listener for any dynamic links clicked while the app is in the background or foreground
  //   FirebaseDynamicLinks.instance.onLink.listen(
  //         (PendingDynamicLinkData dynamicLinkData) {
  //       _handleDeepLink(context, dynamicLinkData?.link);
  //     },
  //     onError: (error) async {
  //       developer.log('Dynamic Link Failed: ${error.toString()}');
  //     },
  //   );
  // }
  //
  // void _handleDeepLink(BuildContext context, Uri? deepLink) {
  //   if (deepLink != null) {
  //     var isPost = deepLink.pathSegments.contains('newsFeed');
  //     print("THe collection contains ::::; $isPost");
  //     if (isPost) {
  //       var postId = deepLink.queryParameters['feedId'];
  //       if (postId != null) {
  //         // Navigate to your post detail page
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => ProfileScreen(),
  //           ),
  //         );
  //       }
  //     }
  //   }
  // }
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() async=> await setValue('first', 'no'));
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
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(
          showicon: false,
          title: poppinsText(
              TempLanguage.newsFeed, 15, FontWeight.bold, appBlackColor),
        ),
        body: Column(
          children: [
            TopContainer(
              ontap: () {
                pushNewScreen(context,
                    screen: CreatePost(), withNavBar: true);
              },
            ),
            // CustomContainer1(
            //     child: Padding(
            //   padding:
            //       const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           poppinsText(
            //               TempLanguage.checkOutHot, 20, bold, appBlackColor),
            //           Padding(
            //             padding: const EdgeInsets.only(left: 10),
            //             child: poppinsText(TempLanguage.contentThatTrendingAndPopular,
            //                 9, medium, greyColor),
            //           ),
            //         ],
            //       ),
            //       Image.asset(AppImage.fire)
            //     ],
            //   ),
            // )),

              Obx(() {
                if (controller.newsFeed.isEmpty) {
        return Center(child: Text(TempLanguage.noPostFound));
                } else {
        return Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: controller.newsFeed.length + (controller.newsFeed.length ~/ 4),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (index % 5 == 4) {
                return const NativeTestAds(key: ValueKey('aid'));
              }
              final itemIndex = index - (index ~/ 5);
              log("\n\nThe Length of the posts are: ${controller.newsFeed.length}\n\n\n");

              var data = controller.newsFeed[itemIndex];
              return data.isOriginal! ? ListTileContainer(
                key: ValueKey(data.id),
                data: data,
              ) : SharedPostComp(
                  key: ValueKey(data.id),
                  data: data);
            },
          ),
        );
                }
              }),

            // FirestorePagination(
            //   shrinkWrap: true,
            //   limit: 1,
            //   viewType: ViewType.list,
            //   bottomLoader: const Center(
            //     child: CircularProgressIndicator(
            //       strokeWidth: 3,
            //       color: Colors.blue,
            //     ),
            //   ),
            //   query: FirebaseFirestore.instance
            //       .collection(Collections.NEWSFEED).orderBy(NewsFeed.TIME_STAMP, descending: true),
            //   itemBuilder: (context, documentSnapshot, index) {
            //     final data = documentSnapshot.data() as Map<String, dynamic>?;
            //     final post = NewsFeedModel.fromJson(data!);
            //     print("News feed length is: ${post.id} \n\n${DateTime.now()} \n\n");
            //     if (post == null) return const CircularProgressIndicator();
            //     if (index % 5 == 4) {
            //       return const NativeTestAds(key: ValueKey('aid'),);
            //     }
            //     final itemIndex = index - (index ~/ 5);
            //     // var data = snapshot.data![itemIndex];
            //     return post.isOriginal! ? ListTileContainer(
            //       key: ValueKey(post.id),
            //       data: post,
            //     ) : SharedPostComp(
            //         key: ValueKey(post.id),
            //         data:post);
            //   },
            // ),

          ],
        ));
  }
}
