import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class NewsFeedController extends GetxController {
  NewsFeedService newsFeedService;
  late TextEditingController postController;
  UserController userController = Get.put(UserController());
  late FocusNode postFocusNode;
  late Rx<XFile?> fileImage = Rx<XFile?>(null);
  NewsFeedController(this.newsFeedService);

  @override
  void onInit() {
    super.onInit();
    postController = TextEditingController();
    postFocusNode = FocusNode();
  }

  Stream<List<NewsFeedModel>> getNewsFeed() {
    return newsFeedService.getNewsFeed();
  }

  Future<bool> createPost(NewsFeedModel newsFeedModel) async{
    newsFeedModel.name = userController.userModel.value.userName;
    newsFeedModel.userImage =
        userController.userModel.value.photoUrl;
    newsFeedModel.userId = userController.userModel.value.uid;
    newsFeedModel.noOfComment = 0;
    newsFeedModel.noOfLike = 0;
    newsFeedModel.noOfShared = 0;
    print(newsFeedModel.toString());
    return await newsFeedService.createPost(newsFeedModel);
  }
}
