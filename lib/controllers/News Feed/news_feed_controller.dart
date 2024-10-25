import 'dart:io';
import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/NewsFeed%20Model/comment_model.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chewie/chewie.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:check_in/Services/push_notification_service.dart';
import 'package:check_in/Services/user_services.dart';

import '../../Services/follower_and_following_service.dart';

class NewsFeedController extends GetxController {
  Rx<NewsFeedModel> newsFeedModel = NewsFeedModel().obs;
  Rx<CommentModel> commentModel = CommentModel().obs;
  NewsFeedService newsFeedService;
  late TextEditingController postController;
  UserController userController = Get.put(UserController(UserServices()));
  late FocusNode postFocusNode;
  late Rx<XFile?> fileImage = Rx<XFile?>(null);
  NewsFeedController(this.newsFeedService);
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  RxString type = ''.obs;
  RxBool videoLoad = false.obs;
  String thumbnailPath = '';
  String originalPath = '';
  RxBool isLoader = false.obs;
  final _newsFeed = <NewsFeedModel>[].obs;
  DocumentSnapshot? lastPostDoc;

  List<NewsFeedModel> get newsFeed => _newsFeed;
  void fetchInitialNewsFeed() {
    newsFeedService.getNewsFeed().listen((newsFeedList) {
      print("The news feed list is: ${newsFeedList.length}");
      if (newsFeedList.isNotEmpty) {
        lastPostDoc = newsFeedList.last['snapshot'] as DocumentSnapshot;
        print("The last document is: ${lastPostDoc!.id}");
      }
      _newsFeed.assignAll(
          newsFeedList.map((e) => e['model'] as NewsFeedModel).toList());
    });
  }

  void fetchMoreNewsFeed() {
    print("The news feed document is: ${lastPostDoc!.id}");

    if (lastPostDoc == null) return;
    print("The news feed document is: ${lastPostDoc!.id}");
    isLoader.value = true;
    newsFeedService.getNewsFeed(startAfter: lastPostDoc).listen((newsFeedList) {
      if (newsFeedList.isNotEmpty) {
        lastPostDoc = newsFeedList.last['snapshot'] as DocumentSnapshot;
        print("The last document is: ${lastPostDoc!.id}");

        // Get the existing IDs from the _newsFeed list
        final existingIds = _newsFeed.map((e) => e.id).toSet();

        // Filter out posts that already exist in _newsFeed
        final newPosts = newsFeedList
            .map((e) => e['model'] as NewsFeedModel)
            .where((post) => !existingIds.contains(post.id))
            .toList();

        // Add only new posts to _newsFeed
        _newsFeed.addAll(newPosts);
      }
      isLoader.value = false;
    });
  }

  void clearNewsFeeds() {
    _newsFeed.clear();
    lastPostDoc = null;
    isLoader.value = false;
  }

  final _userPosts = <NewsFeedModel>[].obs;
  DocumentSnapshot? userLastDoc;
  final userPostLoader = false.obs;

  List<NewsFeedModel> get userPosts => _userPosts;
  bool get isUserPostMore => userPostLoader.value;

  void getUserPosts(String userId) {
    // Clear existing posts when fetching new user posts
    clearUserPosts();
    newsFeedService.getMyPosts(userId).listen((postList) {
      if (postList.isNotEmpty) {
        userLastDoc = postList.last['snapshot'] as DocumentSnapshot;
        print("User do is: ${userLastDoc!.id}");
      }
      _userPosts
          .assignAll(postList.map((e) => e['model'] as NewsFeedModel).toList());
    });
  }

// Update this function in your controller
  void fetchMoreUserPosts(String userId) async {
    print("Fetching more posts for user: $userId");
    // Check if there's a last document and that we're not already loading posts
    if (userLastDoc == null || userPostLoader.value) return;

    // Set loading state to true
    userPostLoader.value = true;

    // Fetch the next batch of posts
    newsFeedService
        .getMyPosts(userId, startAfter: userLastDoc)
        .listen((postList) {
      if (postList.isNotEmpty) {
        userLastDoc = postList.last['snapshot'] as DocumentSnapshot;
        _userPosts
            .addAll(postList.map((e) => e['model'] as NewsFeedModel).toList());
      } else {
        userLastDoc = null; // No more posts to fetch
      }
      userPostLoader.value = false; // Set loading state to false
    });
  }

  //uncomment this one if this issues
  void clearUserPosts() {
    _userPosts.clear();
    userLastDoc = null;
    userPostLoader.value = false;
  }

  final _myPosts = <NewsFeedModel>[].obs;
  DocumentSnapshot? lastDocument;
  final myPostLoader = false.obs;

  List<NewsFeedModel> get myPosts => _myPosts;
  bool get isLoadingMore => myPostLoader.value;

  void getMyPosts() {
    clearMyPosts();
    if (FirebaseAuth.instance.currentUser != null) {
      newsFeedService
          .getMyPosts(FirebaseAuth.instance.currentUser?.uid ?? '')
          .listen((postList) {
        if (postList.isNotEmpty) {
          userLastDoc = postList.last['snapshot'] as DocumentSnapshot;
        }
        _myPosts.assignAll(
            postList.map((e) => e['model'] as NewsFeedModel).toList());
      });
    }
  }

  void fetchMoreMyPosts() async {
    // Check if there's a last document and that we're not already loading posts
    if (userLastDoc == null || myPostLoader.value) return;

    // Set loading state to true
    myPostLoader.value = true;

    // Fetch the next batch of posts
    newsFeedService
        .getMyPosts(FirebaseAuth.instance.currentUser?.uid ?? '', startAfter: userLastDoc)
        .listen((postList) {
      if (postList.isNotEmpty) {
        userLastDoc = postList.last['snapshot'] as DocumentSnapshot;
        _myPosts
            .addAll(postList.map((e) => e['model'] as NewsFeedModel).toList());
      } else {
        userLastDoc = null; // No more posts to fetch
      }
      myPostLoader.value = false; // Set loading state to false
    });
  }

  // void fetchMoreMyPosts() async {
  //   print("Hello  ++++++++++++++++++++++++  ");
  //   if (userLastDoc == null || myPostLoader.value) return;
  //   myPostLoader.value = true;
  //   newsFeedService
  //       .getMyPosts(FirebaseAuth.instance.currentUser?.uid ?? '',
  //           startAfter: userLastDoc)
  //       .listen((postList) {
  //     if (postList.isNotEmpty) {
  //       userLastDoc = postList.last['snapshot'] as DocumentSnapshot;
  //       _myPosts
  //           .addAll(postList.map((e) => e['model'] as NewsFeedModel).toList());
  //     }
  //     myPostLoader.value = false;
  //   });
  // }

  void clearMyPosts() {
    _myPosts.clear();
    userLastDoc = null;
    myPostLoader.value = false;
  }

  RxBool commentLoader = false.obs;

  /// Update the collection
  Future<bool> updateCollection(
      String collectionName, String docId, Map<String, dynamic> list) async {
    return await newsFeedService.updateCollection(collectionName, docId, list);
  }

  /// Create post controller
  Future<bool> createPost(
      NewsFeedModel feedsModel, String compressImage) async {
    print("The post url ${newsFeedModel.value.postUrl}");
    feedsModel.name = userController.userModel.value.userName;
    feedsModel.userImage = userController.userModel.value.photoUrl;
    feedsModel.postUrl = newsFeedModel.value.postUrl;
    feedsModel.userId = userController.userModel.value.uid;
    feedsModel.noOfComment = 0;
    feedsModel.noOfLike = 0;
    feedsModel.noOfShared = 0;
    feedsModel.isOriginal = true;
    feedsModel.timestamp = Timestamp.now();
    feedsModel.isType = type.value;
    print("Created-------${feedsModel.timestamp}");
    return await newsFeedService.createPost(feedsModel, compressImage);
  }

  /// share post
  Future<bool> sharePost(NewsFeedModel feedsModel) async {
    print("The post url ${newsFeedModel.value.postUrl}");
    feedsModel.isOriginal = false;
    feedsModel.noOfShared = 0;
    feedsModel.shareUID = userController.userModel.value.uid;
    feedsModel.shareName = userController.userModel.value.userName;
    feedsModel.shareImage = userController.userModel.value.photoUrl;
    feedsModel.sharePostID = feedsModel.id;
    feedsModel.timestamp = Timestamp.now();
    return await newsFeedService.sharePost(feedsModel);
  }

  /// Share count get
  Future<int?> getNumberOfShares(String postID) async {
    return await newsFeedService.getNumberOfShares(postID);
  }

  /// Like post controller
  Future<String?> likePost(String postId, String userId) async {
    return newsFeedService.toggleLikePost(postId, userId);
  }

  /// fetch all likers on posts controller
  Future<List<UserModel>> fetchLikerUsers(String postId) async {
    return await newsFeedService.fetchLikerUsers(postId);
  }

  /// Add comment on post controller
  Future<bool> addCommentOnPost(
      String postId, CommentModel commentModel) async {
    commentLoader.value = true;
    commentModel.parentId = postId;
    commentModel.postId = postId;
    commentModel.timestamp = Timestamp.now();
    commentModel.likedBy = [];
    commentModel.userImage = userController.userModel.value.photoUrl;
    commentModel.likes = 0;
    bool added = await newsFeedService.addCommentOnPost(postId, commentModel);
    commentLoader.value = false;
    return added;
  }

  RxBool subCommentLoader = false.obs;

  /// Add comment on comment controller
  Future<bool> addCommentOnComment(
      String postId, String commentId, CommentModel commentModel) async {
    subCommentLoader.value = true;
    commentModel.parentId = commentId;
    commentModel.timestamp = Timestamp.now();
    commentModel.postId = postId;
    commentModel.likedBy = [];
    commentModel.userImage = userController.userModel.value.photoUrl;
    commentModel.likes = 0;
    bool added = await newsFeedService.addCommentOnComment(
        postId, commentId, commentModel);
    subCommentLoader.value = false;
    return added;
  }

  /// get post by id
  Future<NewsFeedModel?> getPostById(String docId) async {
    return await newsFeedService.getPostById(docId);
  }

  ///liked by
  Stream<List<String>?> getPostLikedBy(String postId) {
    return newsFeedService.getPostLikedBy(postId);
  }

  Stream<NewsFeedModel?> getPostsByDocID(String postId) {
    return newsFeedService.getPostsByDocID(postId);
  }

  /// get post comments controller
  Stream<List<CommentModel>> getPostComments(String postId) {
    return newsFeedService.getPostComments(postId);
  }

  /// get comments on comments
  Stream<List<CommentModel>> getCommentsOnComment(
      String postId, String commentId) {
    return newsFeedService.getCommentsOnComment(postId, commentId);
  }

  /// get number of comments
  Stream<int> getNumOfComments(String newsFeedId) {
    return newsFeedService.getNumOfComments(newsFeedId);
  }

  Future<bool> reportPost(
      String postId, String reportedBy, String reason) async {
    return newsFeedService.reportPost(postId, reportedBy, reason);
  }

  Future<bool> reportProfile(
      String profileId, String reportedBy, String reason) async {
    return newsFeedService.reportProfile(profileId, reportedBy, reason);
  }

  /// like on comments controller
  Future<bool> toggleLikeComment(
      String postId, String commentId, String userId) async {
    return await newsFeedService.toggleLikeComment(postId, commentId, userId);
  }

  /// like on subComment controller
  Future<bool> toggleLikeSubComment(String postId, String commentId,
      String userId, String subCommentId) async {
    return await newsFeedService.toggleLikeSubComment(
      postId,
      commentId,
      subCommentId,
      userId,
    );
  }

  /// file picker
  Future<String?> filePicker(String fileType) async {
    if (fileType == 'image') {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        fileImage.value = pickedFile;
        await compressImage();
        type.value = 'image';
        String compress = originalPath;
        // final url = await newsFeedService.uploadChatImageToFirebase(compress, userController.userModel.value.uid!, DateTime.now().toString(),'jpg');
        // newsFeedModel.value.postUrl = url;
        return compress;
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
        originalPath = pickedFile.path;
        type.value = 'video';
        // final url = await newsFeedService.uploadChatImageToFirebase(pickedFile.path, userController.userModel.value.uid!, DateTime.now().toString(),'mp4');
        // print("The Video path is: $url");
        // newsFeedModel.value.postUrl = url;
        log("_______\n\n\n\n--------------Video is: ${pickedFile.path}");
        return pickedFile.path;
      } else {
        return null;
      }
    }
  }

  /// fetch all likes on comments
  Future<List<UserModel>> fetchLikesOnComment(
      String postId, String commentId) async {
    return await newsFeedService.fetchAllLikesComment(postId, commentId);
  }

  /// fetch all likes on sub comments
  Future<List<UserModel>> fetchAllLikesOnSubComment(
      String postId, String parentId, String commentId) async {
    return await newsFeedService.fetchAllLikesOnSubComment(
        postId, parentId, commentId);
  }

  /// create deep link
  Future<String> createDynamicLink(String postId) async {
    return await newsFeedService.createDynamicLink(postId);
  }

  /// hide post for me
  Future<bool> hidePost(String docId) async {
    return await newsFeedService.hidePost(docId);
  }

  /// Delete post for all
  Future<void> deletePost(String docId) async {
    return newsFeedService.deleteSubcollection(docId);
  }

  /// Send notification function

  Future<void> sendNotificationMethod(String notificationType, String msg,
      String title, String docId, List memberId,
      {String? image}) async {
    // print(senderName);
    // print(memberId);
    for (var element in memberId) {
      print("The IDS are: $element");
      print("THe currrnt iD is: ${FirebaseAuth.instance.currentUser!.uid}");
      if (element != FirebaseAuth.instance.currentUser!.uid) {
        List<dynamic> deviceToken =
            await newsFeedService.getDeviceToken(element);
        // print(deviceToken.first);
        // print(deviceToken.first.runtimeType);
        sendNotification(
            token: deviceToken,
            notificationType: notificationType,
            title: title,
            msg: msg,
            docId: docId,
            image: image ?? '',
            name: userController.userModel.value.userName ?? '',
            memberIds: memberId,
            isGroup: false,
            uid: element);
      }
    }
  }

  /// image compresser
  Future<void> compressImage() async {
    // final lastIndex = fileImage.value!.path.lastIndexOf(RegExp(r'.'));
    // final splitted = fileImage.value!.path.substring(0, (lastIndex));
    thumbnailPath = "${fileImage.value!.path}_thumbnail";
    originalPath = "${fileImage.value!.path}_original";
    FlutterImageCompress.validator.ignoreCheckExtName = true;
    print('thumbnailpath =$thumbnailPath');
//............. for thumbnail
    await FlutterImageCompress.compressAndGetFile(
      fileImage.value!.path,
      thumbnailPath,
      quality: 20,
      minHeight: 300,
      minWidth: 300,
    );
//............. for original image
    await FlutterImageCompress.compressAndGetFile(
      fileImage.value!.path,
      originalPath,
      quality: 50,
      minHeight: 600,
      minWidth: 600,
    );
  }

  //edit by asjad
  final ScrollController scrollController = ScrollController();
  RxBool isTopContainerVisible = true.obs;
  int selectedOption = 0; // 0 for Community, 1 for Following
  List<String> followingList = [];

  final RxBool isLoading = true.obs; // Add this line

  Future<void> handleRefresh() async {
    await Future.delayed(const Duration(seconds: 3));
    update();
  }

  void setSelectedOption(int option) async {
    selectedOption = option;
    if (selectedOption == 1) {
      loadFollowingList();
    } else {
      // Possibly refresh data or set an empty list
      followingList.clear();
      update(); // Ensure this is triggering a rebuild
    }
    update(); // Ensure this is correctly updating the UI
  }

  // Load the list of users the current user is following
  void loadFollowingList() async {
    if (FirebaseAuth.instance.currentUser != null) {
      isLoading.value = true; // Set loading to true
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      final FollowerAndFollowingService service = FollowerAndFollowingService();
      followingList = await service.getFollowingList(currentUserId);

      isLoading.value = false; // Set loading to true
      update();
    } // Update the controller only after the list is fetched
  }

  Query getNewsFeedQuery() {
    if (selectedOption == 0) {
      return FirebaseFirestore.instance
          .collection(Collections.NEWSFEED)
          .orderBy(NewsFeed.TIME_STAMP, descending: true);
    } else {
      if (followingList.isEmpty) {
        return FirebaseFirestore.instance
            .collection(Collections.NEWSFEED)
            .where('userId', isEqualTo: null);
      } else {
        return FirebaseFirestore.instance
            .collection(Collections.NEWSFEED)
            .where('userId', whereIn: followingList)
            .orderBy(NewsFeed.TIME_STAMP, descending: true);
      }
    }
  }

  @override
  void onInit() {
    super.onInit();

    // When loading the community feed for the first time, show loading
    isLoading.value = true;

    postController = TextEditingController();
    postFocusNode = FocusNode();

    // Initialize required data
    loadFollowingList(); // This is only for following feed, not community
    getMyPosts(); // Load community posts (or add any community-related data fetching here)

    // Set loading to false after data is fetched for the first time
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false; // Turn off loading after fetching data
    });

    // Optionally set an initial value
    Future.microtask(() async => await setValue('first', 'no'));
  }

  bool shouldShowPost(Map<String, Object?> data) {
    final showPost = selectedOption == 0 ||
        (selectedOption == 1 && followingList.contains(data['userId']));

    return showPost;
  }

  Future<List<String>> getReportArray() async {
    return newsFeedService.getReportArray();
  }
}
