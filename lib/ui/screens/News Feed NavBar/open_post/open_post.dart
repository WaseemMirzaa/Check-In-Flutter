
import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/list_tile_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/shared_post_comp.dart';
import 'package:check_in/ui/screens/persistent_nav_bar.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpenPost extends StatelessWidget {
  OpenPost({super.key, this.postId = '',});
  String postId;

  final controller = Get.put(NewsFeedController(NewsFeedService()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: appBlackColor),
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Home()), (route) => false);
              },
            ),
            centerTitle: true,
            title: poppinsText('News Feed', 14, FontWeight.w500, appBlackColor),
            elevation: 0,),
        body: SingleChildScrollView(
          child: StreamBuilder(
                stream: controller.getPostsByDocID(postId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  } else if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  } else if (snapshot.hasError) {
                    return const SizedBox.shrink();
                  } else {
                    return snapshot.data!.isOriginal! ? GestureDetector(
                      onTap: () {
                        print("The post is:\n\n ${snapshot.data!.id}");
                      },
                      child: ListTileContainer(
                        key: ValueKey(snapshot.data!.id),
                        data: snapshot.data!,
                      ),
                    ) : SharedPostComp(
                        key: ValueKey(snapshot.data!.shareID),
                        data: snapshot.data!);
                  }
                }
                  ),
        ));
  }
}
