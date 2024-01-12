import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/Create%20Post/create_post_screen.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/list_tile_container.dart';
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

class NewsFeedScreen extends GetView<NewsFeedController> {
  const NewsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(
          showicon: false,
          title: poppinsText(
              TempLanguage.newsFeed, 15, FontWeight.bold, blackColor),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              TopContainer(
                ontap: () {
                  pushNewScreen(context,
                      screen: const CreatePost(), withNavBar: true);
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
                      children: [
                        poppinsText(
                            TempLanguage.checkOutHot, 20, bold, blackColor),
                        poppinsText(TempLanguage.contentThatTrendingAndPopular,
                            9, medium, greyColor),
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
                      return Center(child: Text(TempLanguage.noMessageFound));
                    } else {
                      return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var data = snapshot.data![index];
                            return ListTileContainer(
                              data: data,
                            );
                          });
                    }
                  })
            ],
          ),
        ));
  }
}
