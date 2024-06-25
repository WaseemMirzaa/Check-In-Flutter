import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/All%20Likes/post_all_likes_view.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

class FullScreenImage extends StatelessWidget {
  FullScreenImage({super.key,required this.newsFeedModel, this.postId = ''});
  NewsFeedModel newsFeedModel;
  String formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat formatter = DateFormat('E \' AT \' hh:mm a');
    String formattedDate = formatter.format(dateTime);
    List<String> parts = formattedDate.split(' ');
    if (parts.isNotEmpty) {
      parts[0] = parts[0].toUpperCase();
    }
    return parts.join(' ');
  }
  String postId;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: appBlackColor,
      appBar: CustomAppbar(
        backgroundColor: appBlackColor,
        iconColor: appWhiteColor,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.more_vert),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Image.network(
                newsFeedModel.postUrl!,
              ),
            ),
          ),
          Container(
            color: greyColor.withOpacity(0.4),
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      poppinsText(
                          newsFeedModel.name!, 14, bold, appWhiteColor),
                      verticalGap(8),
                      poppinsText(
                          newsFeedModel.description!,
                          10,
                          medium,
                          appWhiteColor,
                          maxlines: 3),
                      verticalGap(6),
                      poppinsText(formatTimestamp(newsFeedModel.timestamp!), 10, medium, appWhiteColor)
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                        pushNewScreen(context, screen: PostAllLikesView(postId: newsFeedModel.id!,));
                      },
                      child: SvgPicture.asset(
                        AppImage.like1,
                        height: 23,
                      ),
                    ),
                    horizontalGap(5),
                    poppinsText(newsFeedModel.noOfLike.toString(), 12, medium, appWhiteColor),
                    const Spacer(),
                    poppinsText("${newsFeedModel.noOfComment} Comments", 12, medium, appWhiteColor),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
