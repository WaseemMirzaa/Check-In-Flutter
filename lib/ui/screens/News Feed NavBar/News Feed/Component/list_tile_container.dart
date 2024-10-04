import 'package:cached_network_image/cached_network_image.dart';
import 'package:check_in/Services/user_services.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/Messages%20NavBar/other_profile/other_profile_view.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/share_screen/share_screen.dart';
import 'package:check_in/ui/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/All%20Comments/all_comments.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/All%20Likes/post_all_likes_view.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/Full%20Screen%20Image/full_screen_image.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/comment_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/video_player_widget.dart';
import 'package:check_in/ui/widgets/text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:check_in/ui/widgets/custom_container.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/constant/app_assets.dart';
import 'report_on_post_comp.dart';

class ListTileContainer extends StatefulWidget {
  NewsFeedModel? data;
  bool isMyProfile;
  bool isOtherProfile;
  UserModel? userData;
  ListTileContainer(
      {super.key,
      this.data,
      this.userData,
      this.isMyProfile = false,
      this.isOtherProfile = false});

  @override
  State<ListTileContainer> createState() => _ListTileContainerState();
}

class _ListTileContainerState extends State<ListTileContainer> {
  NewsFeedController newsFeedController =
      Get.put(NewsFeedController(NewsFeedService()));

  final addCommentController = TextEditingController();

  UserController userController = Get.put(UserController(UserServices()));

  final userServices = UserServices();

  bool? playing;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  RxBool isVisible = false.obs;

  @override
  Widget build(BuildContext context) {
    newsFeedController.commentModel.value.userId =
        userController.userModel.value.uid ??
            FirebaseAuth.instance.currentUser!.uid;
    return widget.userData == null
        ? const SizedBox()
        : LoaderOverlay(
            child: CustomContainer1(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
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
                                          userController.userModel.value.uid ==
                                              widget.data!.userId
                                      ? null
                                      : () {
                                          if (userController
                                                  .userModel.value.uid ==
                                              widget.data!.userId) {
                                            pushNewScreen(context,
                                                screen: ProfileScreen(
                                                  isNavBar: false,
                                                ));
                                          } else if (widget.isOtherProfile &&
                                              widget.data!.userId!.isNotEmpty) {
                                          } else {
                                            widget.isOtherProfile
                                                ? Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            OtherProfileView(
                                                                uid: widget
                                                                    .data!
                                                                    .userId!)))
                                                : pushNewScreen(context,
                                                    screen: OtherProfileView(
                                                        uid: widget
                                                            .data!.userId!));
                                          }
                                        },
                                  child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: widget.userData!.photoUrl
                                                      .isEmptyOrNull
                                                  ? NetworkImage(
                                                      AppImage.userImagePath)
                                                  : NetworkImage(widget
                                                          .userData!.photoUrl ??
                                                      ''),
                                              fit: BoxFit.cover)))),
                              if (widget.userData!.isVerified == null ||
                                  widget.userData!.isVerified == true)
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
                                          image: DecorationImage(
                                              image: AssetImage(AppAssets
                                                  .INSTAGRAM_VERIFICATION))),
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
                                          widget.data!.userId
                                  ? null
                                  : () {
                                      if (userController.userModel.value.uid ==
                                          widget.data!.userId) {
                                        pushNewScreen(context,
                                            screen: ProfileScreen(
                                              isNavBar: false,
                                            ));
                                      } else if (widget.isOtherProfile &&
                                          widget.data!.userId!.isNotEmpty) {
                                      } else {
                                        widget.isOtherProfile
                                            ? Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        OtherProfileView(
                                                            uid: widget.data!
                                                                .userId!)))
                                            : pushNewScreen(context,
                                                screen: OtherProfileView(
                                                    uid: widget.data!.userId!));
                                      }
                                    },
                              child: poppinsText(
                                  widget.userData!.userName ?? 'No Name',
                                  14,
                                  bold,
                                  appDarkBlue,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          horizontalGap(5),
                          PopupMenuButton<String>(
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: appGreyColor1),
                              child: Icon(
                                Icons.more_horiz,
                                color: greyColor,
                              ),
                            ),
                            onSelected: (String result) async {
                              switch (result) {
                                case 'Hide Content':
                                  newsFeedController.hidePost(widget.data!.id!);
                                  break;
                                case 'Block Profile':
                                  // newsFeedController.hidePost(
                                  //     widget.data!.id!);
                                  if (widget.data != null &&
                                      !widget.data!.shareUID.isEmptyOrNull) {
                                    final res =
                                        await userController.blockProfile(
                                            widget.data!.shareUID!,
                                            userController
                                                .userModel.value.uid!);
                                    newsFeedController
                                        .hidePost(widget.data!.id!);
                                  } else {
                                    final res =
                                        await userController.blockProfile(
                                            widget.data!.userId!,
                                            userController
                                                .userModel.value.uid!);
                                    newsFeedController
                                        .hidePost(widget.data!.id!);
                                  }
                                  break;
                                case 'Delete':
                                  newsFeedController
                                      .deletePost(widget.data!.id!);
                                  break;
                                case 'Share':
                                  String link = await newsFeedController
                                      .createDynamicLink(widget.data!.id!);
                                  if (link.isNotEmpty) {
                                    Share.share('Check out this post: $link');
                                  }
                                  break;
                                case 'Report Content':
                                  final res = await Get.to(Report(
                                    postId: widget.data!.id!,
                                    reportedBy:
                                        userController.userModel.value.uid!,
                                    isProfile: false,
                                  ));
                                  if (res ?? false) {
                                    showHidePostDialog(context);
                                  }
                                  break;
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              List<PopupMenuEntry<String>> items = [
                                PopupMenuItem<String>(
                                  value: widget.data!.userId ==
                                          userController.userModel.value.uid
                                      ? 'Delete'
                                      : 'Hide Content',
                                  child: ListTile(
                                    leading: Icon(widget.data!.userId ==
                                            userController.userModel.value.uid
                                        ? Icons.delete
                                        : Icons.visibility_off),
                                    title: Text(widget.data!.userId ==
                                            userController.userModel.value.uid
                                        ? 'Delete'
                                        : 'Hide Content'),
                                  ),
                                ),
                                if (widget.data!.userId !=
                                    userController.userModel.value.uid)
                                  const PopupMenuItem<String>(
                                    value: 'Block Profile',
                                    child: ListTile(
                                      leading: Icon(Icons.block),
                                      title: Text('Block Profile'),
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
                              if (widget.data!.userId !=
                                  userController.userModel.value.uid) {
                                items.add(
                                  const PopupMenuItem<String>(
                                    value: 'Report Content',
                                    child: ListTile(
                                      leading: Icon(Icons.report),
                                      title: Text('Report Content'),
                                    ),
                                  ),
                                );
                              }
                              return items;
                            },
                          )
                        ],
                      ),
                    ),
                    verticalGap(8),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ReadMoreText(
                          widget.data!.description ?? "",
                          trimMode: TrimMode.Line,
                          trimLines: 6,
                          colorClickableText: Colors.blue,
                          trimCollapsedText: ' Show more',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: medium,
                              color: appDarkBlue.withOpacity(0.8)),
                          trimExpandedText: ' Show less',
                        )
                        // poppinsText(data!.description ?? "", 12, medium,
                        //     appDarkBlue.withOpacity(0.8),
                        //     maxlines: 10),
                        ),
                    verticalGap(8),
                    widget.data!.isType == 'image' &&
                            widget.data!.postUrl!.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              pushNewScreen(context,
                                  screen: FullScreenImage(
                                    newsFeedModel: widget.data!,
                                  ));
                            },
                            child: SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                // child: Image.network(
                                //   widget.data!.postUrl ?? '',
                                //   fit: BoxFit.cover,
                                // ),
                                child: CachedNetworkImage(
                                  imageUrl: widget.data!.postUrl ?? '',
                                  progressIndicatorBuilder: (context, url,
                                          downloadProgress) =>
                                      Center(
                                          child: CircularProgressIndicator(
                                              value:
                                                  downloadProgress.progress)),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                          )
                        : widget.data!.isType == 'video'
                            ? playing ?? false
                                ? VideoPlayerWidget(
                                    videoUrl: widget.data!.postUrl!)
                                : GestureDetector(
                                    onTap: () {
                                      //initializePlayer(widget.data!.postUrl!);
                                      setState(() {
                                        //_playingIndex = widget.index;
                                        playing = true;
                                      });
                                    },
                                    child: SizedBox(
                                      height: 200,
                                      width: double.infinity,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: widget.data!.thumbnail ==
                                                    null
                                                ? Container(
                                                    color: Colors.black,
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl:
                                                        widget.data!.thumbnail!,
                                                    progressIndicatorBuilder: (context,
                                                            url,
                                                            downloadProgress) =>
                                                        Center(
                                                            child: CircularProgressIndicator(
                                                                value: downloadProgress
                                                                    .progress)),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons.error),
                                                  ),
                                            //     : Image.network(
                                            //   widget.data!.thumbnail!,
                                            //   fit: BoxFit.cover,
                                            // ),
                                          ),
                                          Center(
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                            : const SizedBox(),
                    verticalGap(10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          poppinsText("${widget.data!.noOfComment} ", 11,
                              medium, appDarkBlue),
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
                        child: StreamBuilder(
                            stream: newsFeedController
                                .getPostsByDocID(widget.data!.id ?? ''),
                            builder: (context, postSnap) {
                              if (postSnap.connectionState ==
                                  ConnectionState.waiting) {
                                return rowComp();
                              } else if (postSnap.hasError) {
                                return rowComp();
                              } else if (!postSnap.hasData) {
                                return rowComp();
                              } else {
                                return Row(
                                  children: [
                                    GestureDetector(
                                        onTap: () async {
                                          print(
                                              "The post id is: ${widget.data!.id} and the user id is ${FirebaseAuth.instance.currentUser!.uid}");
                                          final result =
                                              await newsFeedController.likePost(
                                                  postSnap.data!.id!,
                                                  FirebaseAuth.instance
                                                          .currentUser?.uid ??
                                                      '');
                                          print(
                                              "The Toggle is--------> $result");
                                          if (result == 'liked') {
                                            await newsFeedController
                                                .sendNotificationMethod(
                                                    'newsFeed',
                                                    "${userController.userModel.value.userName} liked your post",
                                                    'New reaction',
                                                    widget.data?.id ?? '', [
                                              FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              widget.data!.userId
                                            ]);
                                          }
                                        },
                                        child: postSnap.data!.likedBy!.contains(
                                                FirebaseAuth
                                                    .instance.currentUser?.uid)
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: appGreenColor,
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: const Color(
                                                                  0x65719029)
                                                              .withOpacity(0.2),
                                                          blurRadius: 15,
                                                          offset: const Offset(
                                                              0, 3))
                                                    ]),
                                                child: SvgPicture.asset(
                                                  AppImage.like,
                                                  color: appWhiteColor,
                                                  height: 18,
                                                ),
                                              )
                                            : Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: appWhiteColor,
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: const Color(
                                                                  0x65719029)
                                                              .withOpacity(0.2),
                                                          blurRadius: 15,
                                                          offset: const Offset(
                                                              0, 3))
                                                    ]),
                                                child: SvgPicture.asset(
                                                  AppImage.like,
                                                  height: 20,
                                                ),
                                              )),
                                    horizontalGap(3.w),
                                    GestureDetector(
                                      onTap: () {
                                        isVisible.value = !isVisible.value;
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: appWhiteColor,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: const Color(0x65719029)
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
                                            color: appWhiteColor,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: const Color(0x65719029)
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
                                                  postId: widget.data!.id!,
                                                  isFromProfile:
                                                      widget.isOtherProfile ||
                                                          widget.isMyProfile,
                                                ));
                                          },
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: postSnap.data!.noOfLike <= 1
                                                ? poppinsText(
                                                    'Liked by ${postSnap.data!.noOfLike} Person',
                                                    11,
                                                    medium,
                                                    greyColor,
                                                    maxlines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis)
                                                : poppinsText(
                                                    'Liked by ${postSnap.data!.noOfLike} People',
                                                    11,
                                                    medium,
                                                    greyColor,
                                                    maxlines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                          )),
                                    ),
                                    horizontalGap(2.w),
                                    GestureDetector(
                                      onTap: () {
                                        pushNewScreen(context,
                                            screen: PostAllLikesView(
                                              postId: widget.data!.id!,
                                            ));
                                      },
                                      child: SvgPicture.asset(
                                        AppImage.like,
                                        height: 16,
                                      ),
                                    ),
                                  ],
                                );
                              }
                            })),
                    // verticalGap(8),
                    // const Divider(),
                    verticalGap(7),
                    Obx(() => isVisible.value
                        ? Column(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      color: greyColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(25)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: CustomTextfield1(
                                    controller: addCommentController,
                                    onChanged: (value) {
                                      newsFeedController
                                          .commentModel.value.content = value;
                                    },
                                    onEditingCompleted: () async {
                                      primaryFocus?.unfocus();
                                    },
                                    suffixIcon: newsFeedController
                                            .commentLoader.value
                                        ? SizedBox(
                                            height: 1.5.h,
                                            width: 1.5.h,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(
                                                  strokeWidth: 2.sp,
                                                ),
                                              ],
                                            ))
                                        : GestureDetector(
                                            onTap: () async {
                                              if (addCommentController
                                                  .text.isEmptyOrNull) {
                                                toast('The field is empty');
                                              } else {
                                                addCommentController.clear();
                                                final comment =
                                                    await newsFeedController
                                                        .addCommentOnPost(
                                                            widget.data!.id!,
                                                            newsFeedController
                                                                .commentModel
                                                                .value);
                                                if (comment) {
                                                  await newsFeedController
                                                      .updateCollection(
                                                          Collections.NEWSFEED,
                                                          widget.data!.id!, {
                                                    NewsFeed.NO_OF_COMMENT:
                                                        widget.data!
                                                                .noOfComment! +
                                                            1,
                                                  });
                                                  await newsFeedController
                                                      .sendNotificationMethod(
                                                          'newsFeed',
                                                          '${userController.userModel.value.userName} commented on your post',
                                                          'New comment',
                                                          widget.data?.id ?? '',
                                                          [
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                        widget.data!.userId
                                                      ]);
                                                }
                                                (comment)
                                                    ? addCommentController
                                                        .clear()
                                                    : null;
                                                print(
                                                    "The comment has added $comment");
                                              }
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                  stream: newsFeedController
                                      .getPostComments(widget.data!.id!),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Text(snapshot.error.toString()),
                                      );
                                    } else if (!snapshot.hasData) {
                                      return const Center(
                                        child: SizedBox.shrink(),
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: snapshot.data!.length > 5
                                                ? 5
                                                : snapshot.data!.length,
                                            padding: const EdgeInsets.all(8),
                                            scrollDirection: Axis.vertical,
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(
                                              height: 20,
                                            ),
                                            itemBuilder: (context, index) =>
                                                CommentContainer(
                                              commentModel:
                                                  snapshot.data![index],
                                              isFromProfile:
                                                  widget.isMyProfile ||
                                                      widget.isOtherProfile,
                                            ),
                                          ),
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
                                                        screen:
                                                            AllCommentsScreen(
                                                          docId: snapshot
                                                                  .data
                                                                  ?.first
                                                                  .postId ??
                                                              '',
                                                          newsFeedModel:
                                                              widget.data!,
                                                        ));
                                                  },
                                                  child: poppinsText(
                                                      'Show more',
                                                      15,
                                                      bold,
                                                      appGreenColor))
                                        ],
                                      );
                                    }
                                  }),
                            ],
                          )
                        : const SizedBox())
                  ],
                ),
              ),
            ),
          );
  }

  Widget rowComp() => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: appWhiteColor,
                boxShadow: [
                  BoxShadow(
                      color: const Color(0x65719029).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 3))
                ]),
            child: SvgPicture.asset(
              AppImage.like,
              height: 20,
            ),
          ),
          horizontalGap(3.w),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: appWhiteColor,
                boxShadow: [
                  BoxShadow(
                      color: const Color(0x65719029).withOpacity(0.2),
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
                color: appWhiteColor,
                boxShadow: [
                  BoxShadow(
                      color: const Color(0x65719029).withOpacity(0.2),
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
                child: poppinsText('Liked by  Person', 11, medium, greyColor,
                    maxlines: 1, overflow: TextOverflow.ellipsis)),
          ),
          horizontalGap(2.w),
          SvgPicture.asset(
            AppImage.like,
            height: 16,
          ),
        ],
      );

  void showHidePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hide Post'),
        content: const Text('Are you want to hide this post?'),
        actions: [
          TextButton(
            onPressed: () {
              //newsFeedController.hidePost(widget.data!.id!);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              newsFeedController.hidePost(widget.data!.id!);
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
