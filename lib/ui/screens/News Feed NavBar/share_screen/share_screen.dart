import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/list_tile_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/share_post_comp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class SharePostScreen extends StatelessWidget {
  final NewsFeedModel data;
  final TextEditingController commentController = TextEditingController();

  SharePostScreen({required this.data});
  NewsFeedController feedController = NewsFeedController(NewsFeedService());


  @override
  Widget build(BuildContext context) {
    feedController.newsFeedModel.value = data;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              final share = await feedController.sharePost(feedController.newsFeedModel.value);
              share ?
              Get.back() : null; // Go back to the previous screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Padding(padding: const EdgeInsets.all(16),child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             const Text('Add your thoughts'),
             SizedBox(height: 1.h,),
            TextField(
              controller: commentController,
              maxLines: 3,
              onChanged: (value){
                feedController.newsFeedModel.value.shareText = value;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write something...',
              ),
            ),
           ],),),
            SharePostComp(data: data),
          ],
        ),
      ),
    );
  }

}
