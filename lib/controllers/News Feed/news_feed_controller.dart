import 'dart:io';

import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class NewsFeedController extends GetxController {

  Rx<NewsFeedModel> newsFeedModel = NewsFeedModel().obs;

  NewsFeedService newsFeedService;

  late TextEditingController postController;

  UserController userController = Get.put(UserController());

  late FocusNode postFocusNode;

  late Rx<XFile?> fileImage = Rx<XFile?>(null);

  NewsFeedController(this.newsFeedService);

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  RxString type = ''.obs;
  RxBool videoLoad = false.obs;

  @override
  void onInit() {
    super.onInit();
    postController = TextEditingController();
    postFocusNode = FocusNode();
  }

  Stream<List<NewsFeedModel>> getNewsFeed() {
    return newsFeedService.getNewsFeed();
  }
  Future<bool> createPost(NewsFeedModel feedsModel) async{
    print("The post url ${newsFeedModel.value.postUrl}");
    feedsModel.name = userController.userModel.value.userName;
    feedsModel.userImage = userController.userModel.value.photoUrl;
    feedsModel.postUrl = newsFeedModel.value.postUrl;
    feedsModel.userId = userController.userModel.value.uid;
    feedsModel.noOfComment = 0;
    feedsModel.noOfLike = 0;
    feedsModel.noOfShared = 0;
    feedsModel.timestamp = Timestamp.now().millisecondsSinceEpoch.toString();
    feedsModel.isType = type.value;
    print("Created-------${feedsModel.timestamp}");

    return await newsFeedService.createPost(feedsModel);
  }

  Future<bool> likePost(String postId, String userId)async{
    return newsFeedService.toggleLikePost(postId, userId);
  }

  Future<List<UserModel>> fetchLikerUsers(String postId) async {
    return await newsFeedService.fetchLikerUsers(postId);
  }





  Future<String?> filePicker(String fileType) async {
    if (fileType == 'image') {
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        fileImage.value = pickedFile;
        type.value = 'image';
        final url = await newsFeedService.uploadChatImageToFirebase(pickedFile.path, userController.userModel.value.uid!, DateTime.now().toString(),'jpg');
        newsFeedModel.value.postUrl =  url;
        return url;
      } else {
        return null;
      }
    } else {
      final pickedFile =
      await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        videoLoad.value = true;
        /// video player initialize
        videoPlayerController =
        VideoPlayerController.file(File(pickedFile.path))
          ..initialize().then(
                (_) => videoLoad.value = false,
          );
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          allowMuting: false,
          allowFullScreen: false,
          showOptions: false,
        );
        type.value = 'video';
        final url = await newsFeedService.uploadChatImageToFirebase(pickedFile.path, userController.userModel.value.uid!, DateTime.now().toString(),'mp4');
        print("The Video path is: $url");
        newsFeedModel.value.postUrl = url;
        return url;
      } else {
        return null;
      }
    }
  }
}
