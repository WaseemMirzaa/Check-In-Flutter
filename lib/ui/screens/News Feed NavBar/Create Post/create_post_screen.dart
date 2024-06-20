import 'dart:io';
import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/News%20Feed/create_post_controller.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/ui/screens/persistent_nav_bar.dart';
import 'package:check_in/ui/widgets/custom_appbar.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/loader.dart';
import 'package:check_in/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sizer/sizer.dart';
import 'package:chewie/chewie.dart';

class CreatePost extends StatelessWidget {
  CreatePost({super.key,this.isOnboard = false});
  bool isOnboard;
  UserController userController = Get.put(UserController());
  NewsFeedController newsFeedController = Get.put(NewsFeedController(NewsFeedService()));
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: SizedBox(
          height: 4.5.h,
          child: FloatingActionButton.extended(
            onPressed: () async{
              if(newsFeedController.newsFeedModel.value.description.isEmptyOrNull){
                toast('Post description is empty');
              }else {
                print(newsFeedController.newsFeedModel.value.description.toString());
                await newsFeedController.createPost(newsFeedController.newsFeedModel.value,newsFeedController.originalPath ).then((value) {
                  newsFeedController.newsFeedModel.value.postUrl = null;
                  newsFeedController.originalPath = '';
                  isOnboard ? Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Home()), (route) => false) : Navigator.pop(context);
                } );
              }
            },

            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            backgroundColor: appGreenColor,
            extendedIconLabelSpacing: 5,
            label: Row(
              children: [
                poppinsText('Send', 12, FontWeight.normal, appWhiteColor),
                horizontalGap(20),
                SvgPicture.asset(
                  AppImage.messageappbaricon,
                  color: appWhiteColor,
                  height: 20,
                ),
              ],
            ),
            isExtended: true,
          ),
        ),
      ),
      appBar: CustomAppbar(
        title: poppinsText('Create Post', 15, FontWeight.bold, appBlackColor,),
        isOnbard: isOnboard,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  verticalGap(10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomRight,
                          children: [
                            (userController.userModel.value.photoUrl != null)
                                ? Container(
                                height: 7.8.h,
                                width: 7.8.h,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage(userController.userModel.value.photoUrl as String), fit: BoxFit.fill)))
                                : (!userController.userModel.value.photoUrl.isEmptyOrNull)
                                ? Container(
                                height: 7.8.h,
                                width: 7.8.h,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            userController.userModel.value.photoUrl ?? ""),
                                        fit: BoxFit.fill)))
                                : Container(
                              height: 7.8.h,
                              width: 7.8.h,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(width: 2, color: appGreenColor),
                                  image: const DecorationImage(
                                      image: AssetImage(AppAssets.LOGO_NEW), fit: BoxFit.fill)),
                            ),
                            if (userController.userModel.value.isVerified == null ||
                                userController.userModel.value.isVerified == true)
                              Positioned(
                                right: -6,
                                bottom: -2,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    height: 3.4.h,
                                    width: 3.4.h,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(image: AssetImage(AppAssets.INSTAGRAM_VERIFICATION))),
                                  ),
                                ),
                              )
                            else
                              const SizedBox(),
                          ],
                        ),
                        horizontalGap(20),
                        Expanded(child: poppinsText(userController.userModel.value.userName!, 18, bold, appBlackColor,maxlines: 1))
                      ],
                    ),
                  ),
                  verticalGap(12),
                  TextField(
                    maxLines: 6,
                    autofocus: true,
                    onChanged: (value)async{
                      newsFeedController.newsFeedModel.value.description = value;
                       print("The desData is: ${newsFeedController.newsFeedModel.value.description  ?? '0'}");
                    },
                    decoration: const InputDecoration(
                        hintText: "What's on your mind?",
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        border: InputBorder.none),
                  ),
                  SizedBox(
                      height: 40.h,
                      child: Obx(() => newsFeedController.type.value == 'video'
                          ? newsFeedController.videoLoad.value
                          ? loaderView()
                          : Chewie(
                        controller: newsFeedController.chewieController!,
                      )
                          : newsFeedController.type.value == 'image'
                          ? Image.file(
                          File(newsFeedController.fileImage.value!.path))
                          : const SizedBox()))
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
            decoration: BoxDecoration(
                color: appWhiteColor,
                border: Border(top: BorderSide(color: greyColor.withOpacity(0.3)))),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppImage.camera,
                  height: 16,
                ),
                horizontalGap(5),
                GestureDetector(
                    onTap: () async {
                      newsFeedController.filePicker('image');
                    },
                    child: poppinsText('Photo', 14, medium, greyColor)),
                horizontalGap(10.w),
                SvgPicture.asset(
                  AppImage.video,
                  height: 12,
                ),
                horizontalGap(5),
                GestureDetector(
                    onTap: () async {
                      newsFeedController.filePicker('video');
                    },
                    child: poppinsText('Video', 14, medium, greyColor))
              ],
            ),
          )
        ],
      ),
    );
  }
}