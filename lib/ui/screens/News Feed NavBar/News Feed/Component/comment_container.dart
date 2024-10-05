import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/model/NewsFeed%20Model/comment_model.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/Messages%20NavBar/other_profile/other_profile_view.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/comment_all_lIkes_view.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/sub_comment_comp.dart';
import 'package:check_in/ui/screens/profile_screen.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

import 'package:check_in/ui/screens/Messages%20NavBar/other_profile/other_profile_view.dart';
import 'package:check_in/Services/user_services.dart';

class CommentContainer extends StatefulWidget {
  CommentContainer(
      {super.key, required this.commentModel, this.isFromProfile = false});
  CommentModel commentModel;
  bool isFromProfile;

  @override
  State<CommentContainer> createState() => _CommentContainerState();
}

class _CommentContainerState extends State<CommentContainer> {
  final newsFeedController = Get.put(NewsFeedController(NewsFeedService()));

  final userController = Get.put(UserController(UserServices()));

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

  //UserModel? userModel;

  final userServices = UserServices();

  // getUserData() async {
  //   userModel = await userServices.getUserData(widget.commentModel.userId ??"");
  //   print("THE USER MODEL IS: ${userModel!.userName}");
  //   mounted ? setState(() {
  //
  //   }) : null;
  // }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Future.microtask(() async=> await getUserData());
    // getUserData();
  }

  @override
  Widget build(BuildContext context) {
    Rx isReply = false.obs;
    isLiked.value = widget.commentModel.likedBy!
        .contains(userController.userModel.value.uid);
    return SizedBox(
      width: 100.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.commentModel.userImage != null &&
                      widget.commentModel.userImage != ''
                  ? GestureDetector(
                      onTap: () {
                        if (widget.commentModel.userId ==
                            FirebaseAuth.instance.currentUser!.uid) {
                          if (widget.isFromProfile) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (index) => ProfileScreen(
                                          isNavBar: false,
                                        )));
                          } else {
                            pushNewScreen(context,
                                screen: ProfileScreen(
                                  isNavBar: false,
                                ));
                          }
                        } else {
                          if (widget.isFromProfile) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (index) => OtherProfileView(
                                        uid: widget.commentModel.userId!)));
                          } else {
                            pushNewScreen(context,
                                screen: OtherProfileView(
                                    uid: widget.commentModel.userId!));
                          }
                        }
                      },
                      child: CircleAvatar(
                        backgroundImage:
                            NetworkImage(widget.commentModel.userImage ?? ''),
                        radius: 17,
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        if (widget.commentModel.userId ==
                            FirebaseAuth.instance.currentUser!.uid) {
                          if (widget.isFromProfile) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (index) => ProfileScreen(
                                          isNavBar: false,
                                        )));
                          } else {
                            pushNewScreen(context,
                                screen: ProfileScreen(
                                  isNavBar: false,
                                ));
                          }
                        } else {
                          if (widget.isFromProfile) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (index) => OtherProfileView(
                                        uid: widget.commentModel.userId!)));
                          } else {
                            pushNewScreen(context,
                                screen: OtherProfileView(
                                    uid: widget.commentModel.userId!));
                          }
                        }
                      },
                      child: Container(
                        height: 4.5.h,
                        width: 4.5.h,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 2, color: appGreenColor),
                            image: const DecorationImage(
                                image: AssetImage(AppAssets.LOGO_NEW),
                                fit: BoxFit.fill)),
                      ),
                    ),
              horizontalGap(10),
              Expanded(child: Builder(builder: (context) {
                //bool containsEmojis = hasEmojis(widget.commentModel.content!); // Function to check emojis

                return Container(
                  width: MediaQuery.sizeOf(context).width * 0.65,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: appDarkBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: poppinsText(
                    widget.commentModel.content!, 14, // Use dynamic font size
                    medium,
                    appBlackColor,
                    overflow: TextOverflow.ellipsis,
                    maxlines: 5,
                  ),
                );
              }))
            ],
          ),
          Container(
            margin: EdgeInsets.only(left: 10.w, top: 5),
            width: 52.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                poppinsText(formatTimestamp(widget.commentModel.timestamp!), 12,
                    regular, greyColor),
                Obx(
                  () => GestureDetector(
                      onTap: () async {
                        await newsFeedController
                            .toggleLikeComment(
                              widget.commentModel.parentId!,
                              widget.commentModel.commentId!,
                              userController.userModel.value.uid!,
                            )
                            .then((value) {});
                        isLiked = widget.commentModel.likedBy!
                            .contains(userController.userModel.value.uid)
                            .obs;
                        print("The liked obx is: $isLiked");
                      },
                      child: widget.commentModel.likedBy!.contains(
                                  userController.userModel.value.uid) ||
                              isLiked.value
                          ? poppinsText('Liked', 12, bold, appGreenColor)
                          : poppinsText('Like', 12, regular, greyColor)),
                ),
                GestureDetector(
                    onTap: () {
                      isReply.value = !isReply.value;
                    },
                    child: poppinsText('Reply', 12, regular, greyColor)),
                Row(
                  children: [
                    poppinsText(widget.commentModel.likes.toString(), 12,
                        regular, greyColor),
                    horizontalGap(5),
                    GestureDetector(
                      onTap: () {
                        pushNewScreen(context,
                            screen: CommentAllLikesView(
                                postId: widget.commentModel.parentId!,
                                commentId: widget.commentModel.commentId!));
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
                    SizedBox(
                      height: 2.h,
                    ),
                    StreamBuilder(
                        stream: newsFeedController.getCommentsOnComment(
                            widget.commentModel.parentId!,
                            widget.commentModel.commentId!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(snapshot.error.toString()),
                            );
                          } else if (!snapshot.hasData) {
                            return const Center(
                              child: Text('No data found'),
                            );
                          } else {
                            return Column(
                              children: [
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.length,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (context, index) =>
                                        SubCommentComp(
                                          commentModel: snapshot.data![index],
                                        )),
                                Divider(
                                  color: appGreyColor1,
                                  indent: 15.w,
                                  endIndent: 15.w,
                                ),
                              ],
                            );
                          }
                        }),
                    verticalGap(10),
                    Center(
                      child: Container(
                        height: 5.h,
                        width: MediaQuery.sizeOf(context).width * 0.6,
                        decoration: BoxDecoration(
                            color: greyColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25)),
                        child: TextFormField(
                          onEditingComplete: () async {
                            if (replyComment.text.isNotEmpty) {
                              replyComment.clear();
                              final comment =
                                  await newsFeedController.addCommentOnComment(
                                      widget.commentModel.postId!,
                                      widget.commentModel.commentId!,
                                      newsFeedController.commentModel.value);
                              (comment) ? replyComment.clear() : null;
                              print("The comment has added $comment");
                            } else {
                              primaryFocus!.unfocus();
                            }
                          },
                          style: const TextStyle(fontSize: 12),
                          controller: replyComment,
                          onChanged: (value) {
                            newsFeedController.commentModel.value.content =
                                value;
                          },
                          decoration: InputDecoration(
                              suffixIcon: newsFeedController
                                      .subCommentLoader.value
                                  ? const Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: CircularProgressIndicator(),
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        if (replyComment.text.isEmptyOrNull) {
                                          toast('The field is empty');
                                        } else {
                                          final comment =
                                              await newsFeedController
                                                  .addCommentOnComment(
                                                      widget.commentModel
                                                          .parentId!,
                                                      widget.commentModel
                                                          .commentId!,
                                                      newsFeedController
                                                          .commentModel.value);
                                          (comment)
                                              ? replyComment.clear()
                                              : null;
                                          print(
                                              "The comment has added $comment");
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
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              hintStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: medium,
                                  fontFamily: 'Poppins'),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none),
                        ),
                      ),
                    )
                  ]))),
        ],
      ),
    );
  }

  // bool hasEmojis(String text) {
  //   RegExp regex = RegExp(
  //     r"(\p{Emoji_Presentation}|\p{Emoji}\uFE0F)",
  //     unicode: true,
  //     caseSensitive: false,
  //   );
  //   return regex.hasMatch(text);
  // }
}
