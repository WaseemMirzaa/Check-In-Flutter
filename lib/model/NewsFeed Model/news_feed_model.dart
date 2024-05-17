import 'package:check_in/core/constant/constant.dart';

class NewsFeedModel {
  String? id;
  String? userId;
  String? name;
  String? description;
  String? userImage;
  String? postUrl;
  String? isType;
  int? noOfLike;
  int? noOfComment;
  int? noOfShared;
  NewsFeedModel(
      {this.id,
      this.userId,
      this.name,
      this.description,
      this.userImage,
      this.postUrl,
      this.isType,
      this.noOfLike,
      this.noOfComment,
      this.noOfShared});

  factory NewsFeedModel.fromJson(Map<String, dynamic> json) {
    return NewsFeedModel(
        id: json[NewsFeed.FEED_ID],
        userId: json[NewsFeed.USER_ID],
        name: json[NewsFeed.NAME],
        description: json[NewsFeed.DESCRIPTION],
        userImage: json[NewsFeed.USER_IMAGE],
        postUrl: json[NewsFeed.POST_URL],
        isType: json[NewsFeed.IS_TYPE],
        noOfLike: json[NewsFeed.NO_OF_LIKE],
        noOfComment: json[NewsFeed.NO_OF_COMMENT],
        noOfShared: json[NewsFeed.NO_OF_SHARED]);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[NewsFeed.FEED_ID] = id ?? '';
    data[NewsFeed.USER_ID] = userId ?? '';
    data[NewsFeed.NAME] = name ?? '';
    data[NewsFeed.DESCRIPTION] = description ?? '';
    data[NewsFeed.IS_TYPE] = isType ?? '';
    data[NewsFeed.NO_OF_COMMENT] = noOfComment ?? 0;
    data[NewsFeed.NO_OF_LIKE] = noOfLike ?? 0;
    data[NewsFeed.NO_OF_SHARED] = noOfShared ?? 0;
    data[NewsFeed.POST_URL] = postUrl ?? '';
    data[NewsFeed.USER_IMAGE] = userImage ?? '';
    return data;
  }
}
