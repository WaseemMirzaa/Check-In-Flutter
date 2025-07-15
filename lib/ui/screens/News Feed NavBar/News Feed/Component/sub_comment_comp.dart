import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/model/NewsFeed%20Model/comment_model.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/Messages%20NavBar/other_profile/other_profile_view.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/subcomment_all_likes.dart';
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
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:sizer/sizer.dart';
import 'package:check_in/Services/user_services.dart';

class SubCommentComp extends StatefulWidget {
  SubCommentComp({super.key, required this.commentModel});
  CommentModel commentModel;

  @override
  State<SubCommentComp> createState() => _SubCommentCompState();
}

class _SubCommentCompState extends State<SubCommentComp> {
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

  final userServices = UserServices();
  UserModel? userModel;
  getUserData() async {
    userModel =
        await userServices.getUserData(widget.commentModel.userId ?? "");
    mounted ? setState(() {}) : null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() async => await getUserData());
    // getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          // borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
          border: Border(
              left: BorderSide(width: 2, color: appGreyColor1),
              right: BorderSide(width: 2, color: appGreyColor1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userModel?.photoUrl != null && userModel?.photoUrl != ''
                ? GestureDetector(
                    onTap: () {
                      if (widget.commentModel.userId ==
                          FirebaseAuth.instance.currentUser!.uid) {
                        pushScreen(context,
                            screen: ProfileScreen(
                              isNavBar: false,
                            ));
                      } else {
                        pushScreen(context,
                            screen: OtherProfileView(
                                uid: widget.commentModel.userId!));
                      }
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(userModel?.photoUrl ?? ''),
                      radius: 17,
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      if (widget.commentModel.userId ==
                          FirebaseAuth.instance.currentUser!.uid) {
                        pushScreen(context,
                            screen: ProfileScreen(
                              isNavBar: false,
                            ));
                      } else {
                        pushScreen(context,
                            screen: OtherProfileView(
                                uid: widget.commentModel.userId!));
                      }
                    },
                    child: Container(
                        height: 4.h,
                        width: 4.h,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 2, color: appGreenColor),
                            image: const DecorationImage(
                                image: AssetImage(AppAssets.LOGO_NEW),
                                fit: BoxFit.fill))),
                  ),
            horizontalGap(10),
            Builder(builder: (context) {
              bool containsEmojis = hasEmojis(
                  widget.commentModel.content!); // Function to check emojis

              return Container(
                width: MediaQuery.sizeOf(context).width * 0.4,
                padding: containsEmojis
                    ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
                    : const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: appDarkBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: poppinsText(
                  widget.commentModel.content!,
                  containsEmojis ? 25 : 14, // Use dynamic font size
                  medium,
                  appBlackColor,
                  overflow: TextOverflow.ellipsis,
                  maxlines: 5,
                ),
              );
            })
          ],
        ),
        Container(
          margin: EdgeInsets.only(left: 10.w, top: 5),
          width: 52.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              poppinsText(formatTimestamp(widget.commentModel.timestamp!), 10,
                  regular, greyColor),
              GestureDetector(
                  onTap: () async {
                    // print("The parent Job post id is: ${commentModel.postId!}\n The previous comment id  ${commentModel.parentId!} \n The user id ${ userController.userModel.value.uid!} \n The Current doc id ${commentModel.commentId!}");
                    await newsFeedController.toggleLikeSubComment(
                      widget.commentModel.postId!,
                      widget.commentModel.parentId!,
                      userController.userModel.value.uid!,
                      widget.commentModel.commentId!,
                    );
                  },
                  child: widget.commentModel.likedBy!
                          .contains(userController.userModel.value.uid)
                      ? poppinsText('Liked', 10, bold, appGreenColor)
                      : poppinsText('Like', 10, regular, greyColor)),
              Row(
                children: [
                  poppinsText(widget.commentModel.likes.toString(), 10, regular,
                      greyColor),
                  horizontalGap(5),
                  GestureDetector(
                    onTap: () {
                      pushScreen(context,
                          screen: SubCommentAllLikesView(
                            postId: widget.commentModel.postId!,
                            parentId: widget.commentModel.parentId!,
                            commentId: widget.commentModel.commentId!,
                          ));
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
      ]),
    );
  }

  bool hasEmojis(String text) {
    RegExp regex = RegExp(
      r"(\p{Emoji_Presentation}|\p{Emoji}\uFE0F)",
      unicode: true,
      caseSensitive: false,
    );
    return regex.hasMatch(text);
  }
}
