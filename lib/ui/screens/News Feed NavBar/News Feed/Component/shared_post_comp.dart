import 'dart:io';
import 'package:check_in/Services/user_services.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/%20Messages%20NavBar/other_profile/other_profile_view.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/share_screen/share_screen.dart';
import 'package:check_in/ui/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/auth_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/All%20Comments/all_comments.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/All%20Likes/post_all_likes_view.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/Full%20Screen%20Image/full_screen_image.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/comment_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/custom_paint.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/video_player_widget.dart';
import 'package:check_in/ui/widgets/text_field.dart';
import 'package:check_in/utils/loader.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:check_in/ui/widgets/custom_container.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import 'report_on_post_comp.dart';


class SharedPostComp extends StatefulWidget {
  NewsFeedModel? data;
  bool isMyProfile;
  bool isOtherProfile;
  SharedPostComp({super.key, this.data, this.isMyProfile = false, this.isOtherProfile = false});

  @override
  State<SharedPostComp> createState() => _SharedPostCompState();
}

class _SharedPostCompState extends State<SharedPostComp> {
  NewsFeedController newsFeedController = Get.put(NewsFeedController(NewsFeedService()));

  final addCommentController = TextEditingController();

  UserController userController = Get.put(UserController(UserServices()));

  final userServices = UserServices();

  UserModel? shareUserData;
  UserModel? postUserData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() async{
      shareUserData = await userServices.getUserData(widget.data!.shareUID!);
      postUserData = await userServices.getUserData(widget.data!.userId!);
      setState(() {

      });
    });
  }
  RxBool isVisible = false.obs;
  @override
  Widget build(BuildContext context) {
    newsFeedController.commentModel.value.userId = userController.userModel.value.uid ?? FirebaseAuth.instance.currentUser!.uid;
    return shareUserData == null || postUserData == null ? const SizedBox() : CustomContainer1(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomRight,
                          children: [
                            GestureDetector(
                              onTap: widget.isMyProfile &&
                                  userController.userModel.value.uid == widget.data!.shareUID ? null : () {
                                if (userController.userModel.value.uid == widget.data!.shareUID) {
                                  widget.isOtherProfile
                                      ? Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) => ProfileScreen(isNavBar: false, isOther: true,)))
                                      : pushNewScreen(context, screen: ProfileScreen(isNavBar: false,));
                                } else if (widget.isOtherProfile &&
                                    widget.data!.userId!.isNotEmpty) {

                                } else {
                                  widget.isOtherProfile
                                      ? Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) => OtherProfileView(uid: widget.data!.shareUID!)))
                                      : pushNewScreen(context, screen: OtherProfileView(uid: widget.data!.shareUID!));
                                }
                              },
                              child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: shareUserData!.photoUrl
                                              .isEmptyOrNull ? NetworkImage(
                                              AppImage.userImagePath) :
                                          NetworkImage(
                                              shareUserData!.photoUrl ?? ''),
                                          fit: BoxFit.cover))),),

                            if (shareUserData!.isVerified == null ||
                                shareUserData!.isVerified == true)
                              Positioned(
                                right: -6,
                                bottom: -2,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    height: 2.4.h,
                                    width: 2.4.h,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(image: AssetImage(AppAssets.INSTAGRAM_VERIFICATION))),
                                  ),
                                ),
                              )
                          ],
                        ),

                        horizontalGap(10),
                        Expanded(
                          child: GestureDetector(
                            onTap: widget.isMyProfile &&
                                userController.userModel.value.uid ==
                                    widget.data!.shareUID ? null : () {
                              if (userController.userModel.value.uid ==
                                  widget.data!.shareUID) {
                                widget.isOtherProfile
                                    ? Navigator.pushReplacement(context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfileScreen(
                                          isNavBar: false, isOther: true,)))
                                    : pushNewScreen(context,
                                    screen: ProfileScreen(isNavBar: false,));
                              } else if (widget.isOtherProfile &&
                                  widget.data!.userId!.isNotEmpty) {

                              } else {
                                widget.isOtherProfile
                                    ? Navigator.pushReplacement(context,
                                    MaterialPageRoute(
                                        builder: (context) => OtherProfileView(
                                            uid: widget.data!.shareUID!)))
                                    : pushNewScreen(context,
                                    screen: OtherProfileView(
                                        uid: widget.data!.shareUID!));
                              }
                            },
                            child: richText(
                                shareUserData!.userName ?? '', 'shared a post'),
                          ),
                        ),
                        horizontalGap(5),
                        PopupMenuButton<String>(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: appGreyColor1
                            ),
                            child: Icon(
                              Icons.more_horiz,
                              color: greyColor,
                            ),
                          ),
                          onSelected: (String result) async {
                            switch (result) {
                              case 'Hide':
                                newsFeedController.hidePost(
                                    widget.data!.shareID!);
                                break;
                              case 'Delete':
                                newsFeedController.deletePost(
                                    widget.data!.shareID!);
                                break;
                              case 'Share':
                                String link = await newsFeedController
                                    .createDynamicLink(widget.data!.shareID!);
                                if (kDebugMode) {
                                  print("The link is: $link");
                                }
                                if (link.isNotEmpty) {
                                  Share.share('Check out this post: $link');
                                }
                                break;
                              case 'Report':
                                showReportDialog(
                                    context,
                                    widget.data!.shareID!,
                                    userController.userModel.value.uid!
                                );
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            List<PopupMenuEntry<String>> items = [
                              PopupMenuItem<String>(
                                value: widget.data!.shareUID ==
                                    userController.userModel.value.uid
                                    ? 'Delete'
                                    : 'Hide',
                                child: ListTile(
                                  leading: Icon(widget.data!.shareUID ==
                                      userController.userModel.value.uid ? Icons
                                      .delete : Icons.visibility_off),
                                  title: Text(widget.data!.shareUID ==
                                      userController.userModel.value.uid
                                      ? 'Delete'
                                      : 'Hide'),
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'Share',
                                child: ListTile(
                                  leading: Icon(Icons.share),
                                  title: Text('Share'),
                                ),
                              ),
                            ];

                            if (widget.data!.shareUID !=
                                userController.userModel.value.uid) {
                              items.add(
                                const PopupMenuItem<String>(
                                  value: 'Report',
                                  child: ListTile(
                                    leading: Icon(Icons.report),
                                    title: Text('Report'),
                                  ),
                                ),
                              );
                            }

                            return items;
                          },
                        )
                      ]),
                ),

                verticalGap(8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: poppinsText(widget.data!.shareText ?? "", 12, medium,
                      appDarkBlue.withOpacity(0.8),
                      maxlines: 3),
                ),
                Padding(padding: const EdgeInsets.only(left: 20), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.bottomRight,
                            children: [
                              GestureDetector(
                                  onTap: widget.isMyProfile &&
                                      userController.userModel.value.uid ==
                                          widget.data!.userId ? null : () {
                                    if (userController.userModel.value.uid ==
                                        widget.data!.userId) {
                                      widget.isOtherProfile
                                          ? Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) =>
                                              ProfileScreen(
                                                isNavBar: false, isOther: true,)))
                                          : pushNewScreen(context,
                                          screen: ProfileScreen(isNavBar: false,));
                                    } else if (widget.isOtherProfile &&
                                        widget.data!.shareUID!.isNotEmpty) {} else {
                                      widget.isOtherProfile
                                          ? Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) =>
                                              OtherProfileView(
                                                  uid: widget.data!.userId!)))
                                          : pushNewScreen(context,
                                          screen: OtherProfileView(
                                              uid: widget.data!.userId!));
                                    }
                                  },
                                  child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: postUserData!.photoUrl
                                                  .isEmptyOrNull
                                                  ? NetworkImage(
                                                  AppImage.userImagePath)
                                                  : NetworkImage(
                                                  postUserData!.photoUrl!),
                                              fit: BoxFit.cover)))
                              ),
                              if (postUserData!.isVerified == null ||
                                  postUserData!.isVerified == true)
                                Positioned(
                                  right: -6,
                                  bottom: -2,
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      height: 2.4.h,
                                      width: 2.4.h,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(image: AssetImage(AppAssets.INSTAGRAM_VERIFICATION))),
                                    ),
                                  ),
                                )
                            ],
                          ),

                          horizontalGap(10),
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.isMyProfile &&
                                  userController.userModel.value.uid ==
                                      widget.data!.userId ? null : () {
                                if (userController.userModel.value.uid ==
                                    widget.data!.userId) {
                                  widget.isOtherProfile
                                      ? Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) =>
                                          ProfileScreen(
                                            isNavBar: false, isOther: true,)))
                                      : pushNewScreen(context,
                                      screen: ProfileScreen(isNavBar: false,));
                                } else if (widget.isOtherProfile &&
                                    widget.data!.shareUID!.isNotEmpty) {

                                } else {
                                  widget.isOtherProfile
                                      ? Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) =>
                                          OtherProfileView(
                                              uid: widget.data!.userId!)))
                                      : pushNewScreen(context,
                                      screen: OtherProfileView(
                                          uid: widget.data!.userId!));
                                }
                              },
                              child: poppinsText(
                                  postUserData!.userName ?? '', 14, bold,
                                  appDarkBlue,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          horizontalGap(5),

                        ],
                      ),
                    ),
                    verticalGap(8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: poppinsText(
                          widget.data!.description ?? "", 12, medium,
                          appDarkBlue.withOpacity(0.8),
                          maxlines: 3),
                    ),
                    verticalGap(8),
                    widget.data!.isType == 'image' && widget.data!.postUrl!
                        .isNotEmpty
                        ? GestureDetector(
                      onTap: () {
                        pushNewScreen(context, screen: FullScreenImage(
                          newsFeedModel: widget.data!,));
                      },
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.data!.postUrl ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                        : widget.data!.isType == 'video'
                        ? newsFeedController.videoLoad.value
                        ? loaderView()
                        : VideoPlayerWidget(videoUrl: widget.data!.postUrl!,)
                        : const SizedBox(),
                    verticalGap(10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          poppinsText("${widget.data!.noOfComment}", 11, medium,
                              appDarkBlue),
                          poppinsText(' comments . ', 11, medium, appDarkBlue),
                          poppinsText("${widget.data!.noOfShared} ", 11, medium,
                              appDarkBlue),
                          poppinsText('shares', 11, medium, appDarkBlue),
                        ],
                      ),
                    ),
                    verticalGap(15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: StreamBuilder(stream: newsFeedController.getPostsByDocID(widget.data!.shareID??''),
                          builder: (context, postSnap)
                          {if (postSnap.connectionState == ConnectionState.waiting)
                          {return rowComp();} else if (postSnap.hasError)
                          {return rowComp();}
                          else if (!postSnap.hasData) {return rowComp();}
                          else {return Row(
                            children: [
                              GestureDetector(
                                  onTap: () async {
                                    print("The post id is: ${widget.data!.shareID} and the user id is ${FirebaseAuth.instance.currentUser!.uid}");
                                    final result = await newsFeedController.likePost(postSnap.data!.shareID!, FirebaseAuth.instance.currentUser?.uid ?? '');
                                    print("The Toggle is--------> $result");
                                    if (result == 'liked') {
                                      await newsFeedController.sendNotificationMethod(
                                          'newsFeed', "${userController.userModel.value.userName} liked your post", 'New reaction',
                                          widget.data?.id ?? '', [FirebaseAuth.instance.currentUser!.uid, widget.data!.shareUID]
                            );
                          }
                                  },
                                  child: postSnap.data!.likedBy!.contains(
                                      FirebaseAuth.instance.currentUser
                                          ?.uid)
                                      ? Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: appGreenColor,
                                        boxShadow: [
                                          BoxShadow(color: const Color(
                                              0x65719029).withOpacity(
                                              0.2),
                                              blurRadius: 15,
                                              offset: const Offset(
                                                  0, 3))
                                        ]),
                                    child: SvgPicture.asset(
                                      AppImage.like,
                                      color: appWhiteColor,
                                      height: 18,
                                    ),)
                                      : Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: appWhiteColor,
                                        boxShadow: [
                                          BoxShadow(color: const Color(
                                              0x65719029).withOpacity(
                                              0.2),
                                              blurRadius: 15,
                                              offset: const Offset(
                                                  0, 3))
                                        ]),
                                    child: SvgPicture.asset(
                                      AppImage.like, height: 20,),)),
                              horizontalGap(3.w),
                              GestureDetector(
                                onTap: () {
                                  isVisible.value = !isVisible.value;
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: appWhiteColor, boxShadow: [
                                    BoxShadow(color: const Color(0x65719029)
                                        .withOpacity(0.2),
                                        blurRadius: 15,
                                        offset: const Offset(0, 3))
                                  ]),
                                  child: SvgPicture.asset(
                                    AppImage.comment,
                                    height: 20,
                                  ),
                                ),
                              ),
                              horizontalGap(3.w),
                              GestureDetector(
                                onTap: () async {
                                  pushNewScreen(context,
                                      screen: SharePostScreen(
                                          data: widget.data!));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: appWhiteColor, boxShadow: [
                                    BoxShadow(color: const Color(0x65719029)
                                        .withOpacity(0.2),
                                        blurRadius: 15,
                                        offset: const Offset(0, 3))
                                  ]),
                                  child: SvgPicture.asset(
                                    AppImage.share,
                                    height: 20,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                    onTap: () {
                                      pushNewScreen(context,
                                          screen: PostAllLikesView(
                                            postId: widget.data!.shareID!,

                                          ));
                                    },
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: postSnap.data!.noOfLike <= 1
                                          ? poppinsText(
                                          'Liked by ${postSnap.data!
                                              .noOfLike} Person', 11, medium,
                                          greyColor, maxlines: 1,
                                          overflow: TextOverflow.ellipsis)
                                          : poppinsText('Liked by ${postSnap.data!
                                          .noOfLike} People',
                                          11, medium, greyColor, maxlines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    )),
                              ),
                              horizontalGap(2.w),
                              GestureDetector(
                                onTap: () {
                                  pushNewScreen(context,
                                      screen: PostAllLikesView(
                                        postId: widget.data!.shareID!,));
                                },
                                child: SvgPicture.asset(
                                  AppImage.like,
                                  height: 16,
                                ),
                              ),
                            ],
                          );
                          }})
                    ),
                    // verticalGap(8),
                    // const Divider(),
                    verticalGap(7),
                    Obx(() =>
                    isVisible.value ? Column(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                color: greyColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(25)
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: CustomTextfield1(
                              controller: addCommentController,
                              onChanged: (value) {
                                newsFeedController.commentModel.value.content =
                                    value;
                              },
                              onEditingCompleted: () async {
                                if (addCommentController.text.isNotEmpty) {
                                  final comment = await newsFeedController
                                      .addCommentOnPost(widget.data!.shareID!,
                                      newsFeedController.commentModel.value);
                                  if (comment) {
                                    await newsFeedController.updateCollection(
                                        Collections.NEWSFEED,
                                        widget.data!.shareID!,
                                        {
                                          NewsFeed.NO_OF_COMMENT: widget.data!
                                              .noOfComment! + 1,
                                        });
                                    await newsFeedController.sendNotificationMethod('newsFeed', '${userController.userModel.value.userName} commented on your post', 'New comment', widget.data?.shareID ?? '', [
                                      FirebaseAuth.instance.currentUser!.uid,
                                      widget.data!.shareUID
                                    ]);
                                  }
                                  (comment)
                                      ? addCommentController.clear()
                                      : null;
                                  print("The comment has added $comment");
                                }else{
                                  primaryFocus!.unfocus();
                                }
                              },
                              suffixIcon: GestureDetector(
                                onTap: () async {
                                  if (addCommentController.text.isEmptyOrNull) {
                                    toast('The field is empty');
                                  } else {
                                    final comment = await newsFeedController
                                        .addCommentOnPost(widget.data!.shareID!,
                                        newsFeedController.commentModel.value);
                                    if (comment) {
                                      await newsFeedController.updateCollection(
                                          Collections.NEWSFEED,
                                          widget.data!.shareID!,
                                          {
                                            NewsFeed.NO_OF_COMMENT: widget.data!
                                                .noOfComment! + 1,
                                          });
                                      await newsFeedController.sendNotificationMethod('newsFeed', '${userController.userModel.value.userName} commented on your post', 'New comment', widget.data?.shareID ?? '', [
                                        FirebaseAuth.instance.currentUser!.uid,
                                        widget.data!.shareUID
                                      ]);
                                    }
                                    (comment)
                                        ? addCommentController.clear()
                                        : null;
                                    print("The comment has added $comment");
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  child: SvgPicture.asset(
                                    AppImage.messageappbaricon,
                                    color: appGreenColor,
                                  ),
                                ),
                              ),
                              hintText: 'Write a comment',
                            )),
                        StreamBuilder(
                            stream: newsFeedController.getPostComments(
                                widget.data!.shareID!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),);
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text(snapshot.error.toString()),);
                              } else if (!snapshot.hasData) {
                                return const Center(
                                  child: Text('No data found'),);
                              } else {
                                return Column(
                                  children: [
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: snapshot.data!.length > 5
                                          ? 5
                                          : snapshot.data!.length,
                                      padding: const EdgeInsets.all(8),
                                      scrollDirection: Axis.vertical,
                                      separatorBuilder: (context, index) =>
                                      const SizedBox(height: 20,),
                                      itemBuilder: (context,
                                          index) =>
                                          CommentContainer(
                                            commentModel: snapshot
                                                .data![index],),),
                                    verticalGap(10),
                                    Divider(
                                      color: greyColor,
                                      indent: 20.w,
                                      endIndent: 20.w,
                                    ),
                                    verticalGap(10),
                                    snapshot.data!.isEmpty
                                        ? const SizedBox()
                                        : GestureDetector(
                                        onTap: () {
                                          pushNewScreen(context,
                                              screen: AllCommentsScreen(
                                                docId: snapshot.data!.first
                                                    .postId!,
                                                newsFeedModel: widget.data!,
                                                isShare: true,));
                                        },
                                        child: poppinsText(
                                            'Show more', 15, bold,
                                            appGreenColor))
                                  ],
                                );
                              }
                            }
                        ),
                      ],
                    ) : const SizedBox())
                  ],),)
              ],
            ),
          ),
        );

  }
}

Widget rowComp()=>Row(
  children: [
    Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: appWhiteColor,
          boxShadow: [
            BoxShadow(color: const Color(
                0x65719029).withOpacity(
                0.2),
                blurRadius: 15,
                offset: const Offset(
                    0, 3))
          ]),
      child: SvgPicture.asset(
        AppImage.like, height: 20,),),
    horizontalGap(3.w),
    Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: appWhiteColor, boxShadow: [
        BoxShadow(color: const Color(0x65719029)
            .withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 3))
      ]),
      child: SvgPicture.asset(
        AppImage.comment,
        height: 20,
      ),
    ),
    horizontalGap(3.w),
    Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: appWhiteColor, boxShadow: [
        BoxShadow(color: const Color(0x65719029)
            .withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 3))
      ]),
      child: SvgPicture.asset(
        AppImage.share,
        height: 20,
      ),
    ),
    Expanded(
      child: Align(
          alignment: Alignment.centerRight,
          child: poppinsText(
              'Liked by  Person', 11, medium,
              greyColor, maxlines: 1,
              overflow: TextOverflow.ellipsis)),
    ),
    horizontalGap(2.w),
    SvgPicture.asset(
      AppImage.like,
      height: 16,
    ),
  ],
);

class ChewieDemo extends StatefulWidget {
   ChewieDemo({
    super.key,
    required this.link
  });

  String link;
  @override
  State<StatefulWidget> createState() {
    return _ChewieDemoState();
  }
}
class _ChewieDemoState extends State<ChewieDemo> {
  TargetPlatform? _platform;
  late VideoPlayerController _videoPlayerController1;
  late VideoPlayerController _videoPlayerController2;
  ChewieController? _chewieController;
  int? bufferDelay;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _videoPlayerController2.dispose();
    _chewieController?.dispose();
    super.dispose();
  }


  Future<void> initializePlayer() async {
    _videoPlayerController1 =
        VideoPlayerController.networkUrl(Uri.parse(widget.link));
    _videoPlayerController2 =
        VideoPlayerController.networkUrl(Uri.parse(widget.link));
    await Future.wait([
      _videoPlayerController1.initialize(),
      _videoPlayerController2.initialize()
    ]);
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    // final subtitles = [
    //     Subtitle(
    //       index: 0,
    //       start: Duration.zero,
    //       end: const Duration(seconds: 10),
    //       text: 'Hello from subtitles',
    //     ),
    //     Subtitle(
    //       index: 0,
    //       start: const Duration(seconds: 10),
    //       end: const Duration(seconds: 20),
    //       text: 'Whats up? :)',
    //     ),
    //   ];

    final subtitles = [
      Subtitle(
        index: 0,
        start: Duration.zero,
        end: const Duration(seconds: 10),
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Hello',
              style: TextStyle(color: Colors.red, fontSize: 22),
            ),
            TextSpan(
              text: ' from ',
              style: TextStyle(color: Colors.green, fontSize: 20),
            ),
            TextSpan(
              text: 'subtitles',
              style: TextStyle(color: Colors.blue, fontSize: 18),
            )
          ],
        ),
      ),
      Subtitle(
        index: 0,
        start: const Duration(seconds: 10),
        end: const Duration(seconds: 20),
        text: 'Whats up? :)',
        // text: const TextSpan(
        //   text: 'Whats up? :)',
        //   style: TextStyle(color: Colors.amber, fontSize: 22, fontStyle: FontStyle.italic),
        // ),
      ),
    ];

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
      progressIndicatorDelay:
      bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,

      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: toggleVideo,
            iconData: Icons.live_tv_sharp,
            title: 'Toggle Video Src',
          ),
        ];
      },
      subtitle: Subtitles(subtitles),
      subtitleBuilder: (context, dynamic subtitle) => Container(
        padding: const EdgeInsets.all(10.0),
        child: subtitle is InlineSpan
            ? RichText(
          text: subtitle,
        )
            : Text(
          subtitle.toString(),
          style: const TextStyle(color: Colors.black),
        ),
      ),

      hideControlsTimer: const Duration(seconds: 1),

      // Try playing around with some of these other options:

      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // placeholder: Container(
      //   color: Colors.grey,
      // ),
      // autoInitialize: true,
    );
  }

  int currPlayIndex = 0;

  Future<void> toggleVideo() async {
    await _videoPlayerController1.pause();
    currPlayIndex += 1;
    if (currPlayIndex >= widget.link.length) {
      currPlayIndex = 0;
    }
    await initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: _chewieController != null &&
                    _chewieController!
                        .videoPlayerController.value.isInitialized
                    ? Chewie(
                  controller: _chewieController!,
                )
                    : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Loading'),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _chewieController?.enterFullScreen();
              },
              child: const Text('Fullscreen'),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _videoPlayerController1.pause();
                        _videoPlayerController1.seekTo(Duration.zero);
                        _createChewieController();
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("Landscape Video"),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _videoPlayerController2.pause();
                        _videoPlayerController2.seekTo(Duration.zero);
                        _chewieController = _chewieController!.copyWith(
                          videoPlayerController: _videoPlayerController2,
                          autoPlay: true,
                          looping: true,
                          /* subtitle: Subtitles([
                            Subtitle(
                              index: 0,
                              start: Duration.zero,
                              end: const Duration(seconds: 10),
                              text: 'Hello from subtitles',
                            ),
                            Subtitle(
                              index: 0,
                              start: const Duration(seconds: 10),
                              end: const Duration(seconds: 20),
                              text: 'Whats up? :)',
                            ),
                          ]),
                          subtitleBuilder: (context, subtitle) => Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              subtitle,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ), */
                        );
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("Portrait Video"),
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _platform = TargetPlatform.android;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("Android controls"),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _platform = TargetPlatform.iOS;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("iOS controls"),
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _platform = TargetPlatform.windows;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("Desktop controls"),
                    ),
                  ),
                ),
              ],
            ),
            if (Platform.isAndroid)
              ListTile(
                title: const Text("Delay"),
                subtitle: DelaySlider(
                  delay:
                  _chewieController?.progressIndicatorDelay?.inMilliseconds,
                  onSave: (delay) async {
                    if (delay != null) {
                      bufferDelay = delay == 0 ? null : delay;
                      await initializePlayer();
                    }
                  },
                ),
              )
          ],
        ),
    );
  }
}

class DelaySlider extends StatefulWidget {
  const DelaySlider({super.key, required this.delay, required this.onSave});

  final int? delay;
  final void Function(int?) onSave;
  @override
  State<DelaySlider> createState() => _DelaySliderState();
}

class _DelaySliderState extends State<DelaySlider> {
  int? delay;
  bool saved = false;

  @override
  void initState() {
    super.initState();
    delay = widget.delay;
  }

  @override
  Widget build(BuildContext context) {
    const int max = 1000;
    return ListTile(
      title: Text(
        "Progress indicator delay ${delay != null ? "${delay.toString()} MS" : ""}",
      ),
      subtitle: Slider(
        value: delay != null ? (delay! / max) : 0,
        onChanged: (value) async {
          delay = (value * max).toInt();
          setState(() {
            saved = false;
          });
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.save),
        onPressed: saved
            ? null
            : () {
          widget.onSave(delay);
          setState(() {
            saved = true;
          });
        },
      ),
    );
  }
}