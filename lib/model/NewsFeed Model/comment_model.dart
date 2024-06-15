import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String? commentId;
  String? content;
  String? userId;
  String? userImage;
  String? parentId;
  String? postId;
  int likes;
  List<String>? likedBy;
  Timestamp? timestamp;

  CommentModel({
    this.commentId,
    this.content,
    this.userId,
    this.postId,
    this.userImage,
    this.parentId,
    this.likes = 0,
    this.likedBy,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId ?? '',
      'content': content ?? '',
      'postId': postId ?? '',
      'userId': userId ?? '',
      'userImage': userImage ?? '',
      'parentId': parentId ?? '',
      'likes': likes ?? 0,
      'likedBy': likedBy ?? [],
      'timestamp': timestamp ?? Timestamp.now(),
    };
  }

  static CommentModel fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['commentId'] ?? '',
      content: json['content'] ?? '',
      userId: json['userId'] ?? '',
      postId: json['postId'] ?? '',
      userImage: json['userImage'] ?? '',
      parentId: json['parentId'] ?? '',
      likes: json['likes']??0,
      likedBy: List<String>.from(json['likedBy']) ?? [],
      timestamp: json['timestamp'] ?? Timestamp.now(),
    );
  }
}
