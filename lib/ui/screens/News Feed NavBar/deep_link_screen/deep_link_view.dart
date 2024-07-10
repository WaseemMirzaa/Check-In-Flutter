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
class DeepLinkView extends StatelessWidget {
  final TextEditingController commentController = TextEditingController();
  String jobPost;
  DeepLinkView({super.key, required this.jobPost});
  NewsFeedController feedController = NewsFeedController(NewsFeedService());

  @override
  Widget build(BuildContext context) {
    print("The job id is: $jobPost");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
      ),
      body:  FutureBuilder(
          future: feedController.getPostById(jobPost),
          builder: (context, snapshot) {
            print("The Data  is +++++++++++++++++++: ${snapshot.data}");
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (!snapshot.hasData) {
              return const SizedBox();
            } else if (snapshot.hasError) {
              print("Error fetching post data: ${snapshot.error}");
              return const Center(child: Text('Error fetching post data'));
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SharePostComp(data: snapshot.data),
                ],
              );
            }
          }
      ),
    );
  }
}
