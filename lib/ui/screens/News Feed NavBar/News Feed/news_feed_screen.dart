import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/Create%20Post/create_post_screen.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/list_tile_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/shared_post_comp.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/top_container.dart';
import 'package:check_in/ui/widgets/custom_container.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/loader.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initDynamicLinks(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(
          showicon: false,
          title: poppinsText(
              TempLanguage.newsFeed, 15, FontWeight.bold, appBlackColor),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              TopContainer(
                ontap: () {
                  pushNewScreen(context,
                      screen: CreatePost(), withNavBar: true);
                },
              ),
              CustomContainer1(
                  child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        poppinsText(
                            TempLanguage.checkOutHot, 20, bold, appBlackColor),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: poppinsText(TempLanguage.contentThatTrendingAndPopular,
                              9, medium, greyColor),
                        ),
                      ],
                    ),
                    Image.asset(AppImage.fire)
                  ],
                ),
              )),
              StreamBuilder<List<NewsFeedModel>>(
                  stream: controller.getNewsFeed(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return loaderView();
                    } else if (!snapshot.hasData) {
                      return Center(child: Text(TempLanguage.noPostFound));
                    }else if (snapshot.data!.isEmpty) {
                      return Center(child: Text(TempLanguage.noPostFound));
                    } else if(snapshot.hasError){
                      return Center(child: Text(snapshot.error.toString()),);
                    } else {
                      return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var data = snapshot.data![index];
                            return data.isOriginal! ? ListTileContainer(
                              data: data,
                            ) : SharedPostComp(data:data);
                          });
                    }
                  })
            ],
          ),
        ));
  }
}
