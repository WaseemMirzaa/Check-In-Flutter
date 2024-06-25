import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/model/NewsFeed%20Model/comment_model.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/All%20Comments/all_comments.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/comment_all_lIkes_view.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/sub_comment_comp.dart';
import 'package:check_in/ui/widgets/text_field.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

class CommentContainer extends StatelessWidget {
  CommentContainer({super.key, required this.commentModel,});
  CommentModel commentModel;
  final newsFeedController = Get.put(NewsFeedController(NewsFeedService()));
  final userController = Get.put(UserController());

  final replyComment = TextEditingController();
  String formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat formatter = DateFormat('hh:mm a');
    String formattedDate = formatter.format(dateTime);
    List<String> parts = formattedDate.split(' ');
    if (parts.isNotEmpty) {
      parts[0] = parts[0].toUpperCase();
    }
    return parts.join(' ');
  }
  Rx<bool> isLiked = false.obs;

  @override
  Widget build(BuildContext context) {
    Rx isReply = false.obs;
    isLiked.value = commentModel.likedBy!.contains(userController.userModel.value.uid);
    return SizedBox(
      width: 100.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              commentModel.userImage!.isNotEmpty ?  CircleAvatar(
                backgroundImage: NetworkImage(
                    commentModel.userImage!),
                radius: 17,
              ) : Container(
                height: 4.5.h,
                width: 4.5.h,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 2, color: appGreenColor),
                    image: const DecorationImage(
                        image: AssetImage(AppAssets.LOGO_NEW), fit: BoxFit.fill)),
              ),
              horizontalGap(10),
              Expanded(
                child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.65,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: appDarkBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: poppinsText(commentModel.content!, 12,
                        medium, appBlackColor,
                        overflow: TextOverflow.ellipsis,
                        maxlines: 5)),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(left: 10.w, top: 5),
            width: 52.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                poppinsText(formatTimestamp(commentModel.timestamp!), 12, regular, greyColor),
                Obx(() => GestureDetector(
                          onTap: ()async{
                            await newsFeedController.toggleLikeComment(commentModel.parentId! ,commentModel.commentId!, userController.userModel.value.uid!,).then((value) {
                            });
                            isLiked = commentModel.likedBy!.contains(userController.userModel.value.uid).obs;
                            print("The liked obx is: $isLiked");
                          },
                          child: commentModel.likedBy!.contains(userController.userModel.value.uid) || isLiked.value ? poppinsText('Liked', 12, bold, appGreenColor) : poppinsText('Like', 12, regular, greyColor)),
                    ),

                GestureDetector(
                    onTap: (){
                      isReply.value =! isReply.value;
                    },
                    child: poppinsText('Reply', 12, regular, greyColor)),
                Row(
                  children: [
                    poppinsText(commentModel.likes.toString(), 12, regular, greyColor),
                    horizontalGap(5),
                    GestureDetector(
                      onTap: (){
                        pushNewScreen(context, screen: CommentAllLikesView(postId: commentModel.parentId!,commentId: commentModel.commentId!));
                      },
                      child: SvgPicture.asset(
                        AppImage.like1,
                        height: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Obx(() => Visibility(
              visible: isReply.value,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 2.h,),
                    StreamBuilder(
                        stream: newsFeedController.getCommentsOnComment(commentModel.parentId!, commentModel.commentId!),
                        builder: (context, snapshot) {
                          if(snapshot.connectionState == ConnectionState.waiting){
                            return const Center(child: CircularProgressIndicator(),);
                          }else if(snapshot.hasError){
                            return Center(child: Text(snapshot.error.toString()),);
                          }else if(!snapshot.hasData){
                            return const Center(child: Text('No data found'),);
                          }else{
                            return Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data!.length,
                                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                                  scrollDirection: Axis.vertical,

                                  itemBuilder: (context,
                                      index) => SubCommentComp(commentModel: snapshot.data![index],)),
                                Divider(
                                  color: appGreyColor1,
                                  indent: 15.w,
                                  endIndent: 15.w,
                                ),

                              ],
                            );

                          }
                        }
                    ),
                    verticalGap(10),
                    Center(
                      child: Container(
                        height: 5.h,
                          width: MediaQuery.sizeOf(context).width * 0.6,
                          decoration: BoxDecoration(
                              color: greyColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25)),
                          child: TextFormField(
                            onEditingComplete: () async{
                              if(replyComment.text.isEmptyOrNull){
                                toast('The field is empty');
                              }else {
                                final comment = await newsFeedController
                                    .addCommentOnComment(commentModel.postId!,commentModel.commentId!,
                                    newsFeedController.commentModel.value);
                                (comment) ? replyComment.clear() : null;
                                print("The comment has added $comment");
                              }
                            },

                            style: const TextStyle(fontSize: 12),
                            controller: replyComment,
                            onChanged:(value){
                              newsFeedController.commentModel.value.content = value;
                              },
                            decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                  onTap: () async{
                                    if(replyComment.text.isEmptyOrNull){
                                      toast('The field is empty');

                                    }else {
                                      final comment = await newsFeedController
                                          .addCommentOnComment(commentModel.parentId!,commentModel.commentId!,
                                          newsFeedController.commentModel.value);
                                      (comment) ? replyComment.clear() : null;
                                      print("The comment has added $comment");
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      AppImage.messageappbaricon,
                                      color: appGreenColor,
                                    ),
                                  ),
                                ),
                                hintText: 'Write a comment',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 6),
                                hintStyle: TextStyle(
                                    fontSize: 12, fontWeight: medium, fontFamily: 'Poppins'),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none),
                          ),
                        
                    ),
                    )

              ]
                    ))),
        ],
      ),
    );
  }
}
