import 'package:check_in/ui/screens/News%20Feed%20NavBar/Create%20Post/create_post_screen.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Widgets/list_tile_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Widgets/write_something_container.dart';
import 'package:check_in/ui/widgets/custom_container.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import '../../../widgets/custom_appbar.dart';

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(
          showicon: false,
          title: poppinsText('News Feed', 15, FontWeight.bold, blackColor),
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
                            "Check out what's Hot", 20, bold, blackColor),
                        poppinsText("Content that's trending and most popular",
                            9, medium, greyColor),
                      ],
                    ),
                    Image.asset(AppImage.fire)
                  ],
                ),
              )),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return ListTileContainer(
                      index: index,
                    );
                  })
            ],
          ),
        ));
  }
}
