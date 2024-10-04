import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/Players.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsFeedModel {
  String? id;
  String? userId;
  String? name;
  String? description;
  String? userImage;
  String? postUrl;
  String? thumbnail;
  String? isType;
  List<String>? likedBy;
  int noOfLike;
  int? noOfComment;
  int? noOfShared;
  bool? isOriginal;
  Timestamp? timestamp;
  List<String>? hideUsers;
  UserModel? user;

  String? shareName;
  String? shareImage;
  String? shareID;
  String? shareUID;
  String? sharePostID;
  String? shareText;

  NewsFeedModel(
      {this.id,
      this.userId,
      this.name,
      this.description,
      this.userImage,
      this.postUrl,
      this.isType,
        this.thumbnail,
        this.likedBy,
      this.noOfLike = 0,
      this.noOfComment,
      this.noOfShared,
      this.isOriginal,
      this.timestamp,
      this.hideUsers,
      this.shareName,
      this.shareImage,
      this.shareUID,
      this.shareID,
      this.sharePostID,
      this.shareText,
        this.user,
      });



  factory NewsFeedModel.fromJson(Map<String, dynamic> json) {
    return NewsFeedModel(
        id: json[NewsFeed.FEED_ID],
        userId: json[NewsFeed.USER_ID],
        name: json[NewsFeed.NAME],
        description: json[NewsFeed.DESCRIPTION],
        userImage: json[NewsFeed.USER_IMAGE],
        postUrl: json[NewsFeed.POST_URL],
        isType: json[NewsFeed.IS_TYPE],
        likedBy: (json[NewsFeed.LIKED_BY] as List<dynamic>?)?.cast<String>() ?? [],
        noOfLike: json[NewsFeed.NO_OF_LIKE],
        noOfComment: json[NewsFeed.NO_OF_COMMENT],
        noOfShared: json[NewsFeed.NO_OF_SHARED],
        hideUsers: (json[NewsFeed.HIDE_USER] as List<dynamic>?)?.cast<String>() ?? [],
        timestamp: json[NewsFeed.TIME_STAMP],
        isOriginal: json[NewsFeed.IS_ORIGINAL] ?? true,
        shareName: json[NewsFeed.SHARE_NAME],
        shareImage: json[NewsFeed.SHARE_IMAGE],
        shareUID: json[NewsFeed.SHARE_UID],
        shareID: json[NewsFeed.SHARE_ID],
        shareText: json[NewsFeed.SHARE_TEXT],
        sharePostID: json[NewsFeed.SHARE_POSTID],
      thumbnail: json[NewsFeed.THUMBNAIL]
    );
  }

  factory NewsFeedModel.fromJsonWithUsersList(Map<String, dynamic> json, List<UserModel> users) {




    return NewsFeedModel(
        id: json[NewsFeed.FEED_ID],
        userId: json[NewsFeed.USER_ID],
        name: json[NewsFeed.NAME],
        description: json[NewsFeed.DESCRIPTION],
        userImage: json[NewsFeed.USER_IMAGE],
        postUrl: json[NewsFeed.POST_URL],
        isType: json[NewsFeed.IS_TYPE],
        likedBy: (json[NewsFeed.LIKED_BY] as List<dynamic>?)?.cast<String>() ?? [],
        noOfLike: json[NewsFeed.NO_OF_LIKE],
        noOfComment: json[NewsFeed.NO_OF_COMMENT],
        noOfShared: json[NewsFeed.NO_OF_SHARED],
        hideUsers: (json[NewsFeed.HIDE_USER] as List<dynamic>?)?.cast<String>() ?? [],
        timestamp: json[NewsFeed.TIME_STAMP],
        isOriginal: json[NewsFeed.IS_ORIGINAL] ?? true,
        shareName: json[NewsFeed.SHARE_NAME],
        shareImage: json[NewsFeed.SHARE_IMAGE],
        shareUID: json[NewsFeed.SHARE_UID],
        shareID: json[NewsFeed.SHARE_ID],
        shareText: json[NewsFeed.SHARE_TEXT],
        sharePostID: json[NewsFeed.SHARE_POSTID],
        thumbnail: json[NewsFeed.THUMBNAIL],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[NewsFeed.FEED_ID] = id ?? '';
    data[NewsFeed.USER_ID] = userId ?? '';
    data[NewsFeed.NAME] = name ?? '';
    data[NewsFeed.DESCRIPTION] = description ?? '';
    data[NewsFeed.IS_TYPE] = isType ?? '';
    data[NewsFeed.LIKED_BY] = likedBy ?? [];
    data[NewsFeed.NO_OF_COMMENT] = noOfComment ?? 0;
    data[NewsFeed.NO_OF_LIKE] = noOfLike ?? 0;
    data[NewsFeed.IS_ORIGINAL] = isOriginal ?? true;
    data[NewsFeed.NO_OF_SHARED] = noOfShared ?? 0;
    data[NewsFeed.POST_URL] = postUrl ?? '';
    data[NewsFeed.TIME_STAMP] = timestamp ?? Timestamp.now();
    data[NewsFeed.USER_IMAGE] = userImage ?? '';
    data[NewsFeed.HIDE_USER] = hideUsers ?? [];
    data[NewsFeed.SHARE_ID] = shareID ?? '';
    data[NewsFeed.SHARE_UID] = shareUID ?? '';
    data[NewsFeed.SHARE_POSTID] = sharePostID ?? '';
    data[NewsFeed.SHARE_NAME] = shareName ?? '';
    data[NewsFeed.SHARE_IMAGE] = shareImage ?? '';
    data[NewsFeed.SHARE_TEXT] = shareText ?? '';
    data[NewsFeed.THUMBNAIL] = thumbnail ?? '';
    return data;
  }
}
