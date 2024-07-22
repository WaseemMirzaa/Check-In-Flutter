import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/auth_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/NewsFeed%20Model/comment_model.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/comment_container.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/ui/widgets/text_field.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:nb_utils/nb_utils.dart';

class AllCommentsScreen extends StatelessWidget {
  AllCommentsScreen({super.key,required this.docId, required this.newsFeedModel, this.isShare = false});
  String docId;
  NewsFeedModel newsFeedModel;
  bool isShare;
  final newsFeedController = Get.put(NewsFeedController(NewsFeedService()));
  final addCommentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: Row(
          children: [
            SvgPicture.asset(
              AppImage.comment,
              height: 20,
            ),
            const Spacer(),
            poppinsText('Comments', 15, bold, appBlackColor),
            const Spacer(
              flex: 3,
            )
          ],
        ),
      ),
      body: StreamBuilder(
        stream: newsFeedController.getPostComments(docId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator(),);
      } else if (snapshot.hasError) {
        return Center(child: Text(snapshot.error.toString()),);
      } else if (!snapshot.hasData) {
        return const Center(child: Text('No data found'),);
      }
      else {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 7.0, horizontal: 10),
                      child: CommentContainer(
                          commentModel: snapshot.data![index]),
                    );
                  }),
            ),
            Container(
              decoration: BoxDecoration(
                color: appWhiteColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: greyColor.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(1, 1))
                ],
              ),
              child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: greyColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25)),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomTextfield1(
                    hintText: 'Write a comment',
                    onChanged: (value){
                      newsFeedController.commentModel.value.content = value;
                    },
                    onEditingCompleted: () async{
                      if(!addCommentController.text.isEmptyOrNull){

                        final comment = await newsFeedController.addCommentOnPost(isShare ? newsFeedModel.shareID! : newsFeedModel.id!,
                            newsFeedController.commentModel.value);
                        if(comment){
                          await newsFeedController.updateCollection(Collections.NEWSFEED,isShare ? newsFeedModel.shareID! : newsFeedModel.id!,
                              {
                                NewsFeed.NO_OF_COMMENT : newsFeedModel.noOfComment! + 1,
                              });
                        }
                        (comment) ? addCommentController.clear() : null;
                        print("The comment has added $comment");
                      }else{
                        primaryFocus?.unfocus();
                      }

                    },
                    controller: addCommentController,
                    suffixIcon: GestureDetector(
                      onTap: () async{
                        if(addCommentController.text.isEmptyOrNull){
                          toast('The field is empty');
                        }else {
                          final comment = await newsFeedController.addCommentOnPost(isShare ? newsFeedModel.shareID! : newsFeedModel.id!,newsFeedController.commentModel.value);
                          if(comment){
                            await newsFeedController.updateCollection(Collections.NEWSFEED,isShare ? newsFeedModel.shareID! : newsFeedModel.id!,
                                {
                                  NewsFeed.NO_OF_COMMENT : newsFeedModel.noOfComment! + 1,
                                });
                          }
                          (comment) ? addCommentController.clear() : null;
                          print("The comment has added $comment");
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: SvgPicture.asset(
                          AppImage.messageappbaricon,
                          color: appGreenColor,
                        ),
                      ),
                    ),
                  )),
            ),
          ],
        );
      }
    }
      ),

    );
  }
}
