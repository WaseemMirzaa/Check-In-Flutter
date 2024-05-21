import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FullScreenImage extends StatelessWidget {
  FullScreenImage({super.key,required this.newsFeedModel});
  NewsFeedModel newsFeedModel;
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
                      poppinsText(newsFeedModel.timestamp!, 10, medium, appWhiteColor)
                    ],
                  ),
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      AppImage.multiplelike,
                      height: 23,
                    ),
                    horizontalGap(5),
                    poppinsText(newsFeedModel.noOfLike.toString(), 12, medium, appWhiteColor),
                    const Spacer(),
                    poppinsText(newsFeedModel.noOfComment.toString(), 12, medium, appWhiteColor)
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
