import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/list_tile_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/share_post_comp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    feedController.newsFeedModel.value.likedBy = [];
    feedController.newsFeedModel.value.noOfLike = 0;
    feedController.newsFeedModel.value.noOfComment = 0;
    feedController.newsFeedModel.value.noOfShared = 0;
    feedController.newsFeedModel.value.timestamp = Timestamp.now();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              if(data.shareID!.isNotEmpty){
                print("True");
                await feedController.updateCollection(
                    Collections.NEWSFEED, data.shareID!,
                    {
                      NewsFeed.NO_OF_SHARED: data!.noOfShared! + 1,
                    });
              }
              final share = await feedController.sharePost(feedController.newsFeedModel.value);
              print("Share : $share");
              print("Number of shares are : ${data!.noOfShared}");
              if(share){
                print("The share id is:${data.shareID!}");
                  await feedController.updateCollection(
                      Collections.NEWSFEED, data.id!,
                      {
                        NewsFeed.NO_OF_SHARED: data!.noOfShared! + 1,
                      });
              }
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
