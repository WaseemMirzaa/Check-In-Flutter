import 'package:check_in/core/constant/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsFeedModel {
  String? id;
  String? userId;
  String? name;
  String? description;
  String? userImage;
  String? postUrl;
  String? isType;
  List<String>? likedBy;
  int noOfLike;
  int? noOfComment;
  int? noOfShared;
  String? timestamp;
  NewsFeedModel(
      {this.id,
      this.userId,
      this.name,
      this.description,
      this.userImage,
      this.postUrl,
      this.isType,
        this.likedBy,
      this.noOfLike = 0,
      this.noOfComment,
      this.noOfShared,
      this.timestamp
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
        timestamp: json[NewsFeed.TIME_STAMP],
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
    data[NewsFeed.NO_OF_SHARED] = noOfShared ?? 0;
    data[NewsFeed.POST_URL] = postUrl ?? '';
    data[NewsFeed.TIME_STAMP] = timestamp ?? '';
    data[NewsFeed.USER_IMAGE] = userImage ?? '';
    return data;
  }
}
