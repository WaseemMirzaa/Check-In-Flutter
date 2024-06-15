import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class SubCommentAllLikesView extends StatelessWidget {
  SubCommentAllLikesView({super.key, required this.postId,required this.parentId, required this.commentId,});
  String postId;
  String parentId;
  String commentId;
  final newsFeedController = Get.put(NewsFeedController(NewsFeedService()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: Row(
          children: [
            SvgPicture.asset(
              AppImage.like1,
              height: 20,
            ),
            const Spacer(),
            poppinsText('Likes', 15, bold, blackColor),
            const Spacer(
              flex: 3,
            )
          ],
        ),
      ),
      body: FutureBuilder(
          future: newsFeedController.fetchAllLikesOnSubComment(postId,parentId,commentId),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator());
            }else if(!snapshot.hasData){
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: Text('There are no reacts on the post')),
              );
            }else {
              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 6),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 60,
                                    child: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 26,
                                          backgroundImage: NetworkImage(
                                              snapshot.data![index].photoUrl!),
                                        ),
                                        Positioned(
                                          bottom: 1,
                                          right: 1,
                                          child: CircleAvatar(
                                            backgroundColor: whiteColor,
                                            radius: 14,
                                            child: CircleAvatar(
                                              radius: 12,
                                              backgroundColor: greenColor,
                                              child: SvgPicture.asset(
                                                AppImage.like,
                                                color: white,
                                                height: 10,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  horizontalGap(12),
                                  poppinsText(
                                      snapshot.data![index].userName!, 15, medium, blackColor)
                                ],
                              ),
                            );
                          }),
                    ),
                  ),
                ],
              );
            }
          }
      ),
    );
  }
}
