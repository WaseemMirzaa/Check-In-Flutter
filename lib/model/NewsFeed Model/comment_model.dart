class CommentModel {
  String commentId;
  String content;
  String userId;
  String parentId;
  int likes;
  List<String> likedBy;
  DateTime timestamp;

  CommentModel({
    required this.commentId,
    required this.content,
    required this.userId,
    required this.parentId,
    required this.likes,
    required this.likedBy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'content': content,
      'userId': userId,
      'parentId': parentId,
      'likes': likes,
      'likedBy': likedBy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static CommentModel fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['commentId'],
      content: json['content'],
      userId: json['userId'],
      parentId: json['parentId'],
      likes: json['likes'],
      likedBy: List<String>.from(json['likedBy']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}