import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:check_in/core/constant/constant.dart';

// Review model for court reviews
class Review {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final int rating;
  final String reviewText;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      userId: data[ReviewKey.USER_ID] ?? '',
      userName: data[ReviewKey.USER_NAME] ?? '',
      userPhotoUrl: data[ReviewKey.USER_PHOTO_URL] ?? '',
      rating: data[ReviewKey.RATING] ?? 0,
      reviewText: data[ReviewKey.REVIEW_TEXT] ?? '',
      createdAt: (data[ReviewKey.CREATED_AT] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }
}

// Gallery item model for court gallery
class GalleryItem {
  final String id;
  final String imageUrl;
  final String uploadedBy;
  final String uploadedByName;
  final String uploadedByPhoto;
  final DateTime uploadedAt;
  final String description;

  GalleryItem({
    required this.id,
    required this.imageUrl,
    required this.uploadedBy,
    required this.uploadedByName,
    required this.uploadedByPhoto,
    required this.uploadedAt,
    required this.description,
  });

  factory GalleryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GalleryItem(
      id: doc.id,
      imageUrl: data[GalleryKey.IMAGE_URL] ?? '',
      uploadedBy: data[GalleryKey.UPLOADED_BY] ?? '',
      uploadedByName: data[GalleryKey.UPLOADED_BY_NAME] ?? '',
      uploadedByPhoto: data[GalleryKey.UPLOADED_BY_PHOTO] ?? '',
      uploadedAt: (data[GalleryKey.UPLOADED_AT] as Timestamp?)?.toDate() ??
          DateTime.now(),
      description: data[GalleryKey.DESCRIPTION] ?? '',
    );
  }
}

// Comment model for court comments
class Comment {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String commentText;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.commentText,
    required this.createdAt,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      userId: data[CommentKey.USER_ID] ?? '',
      userName: data[CommentKey.USER_NAME] ?? '',
      userPhotoUrl: data[CommentKey.USER_PHOTO_URL] ?? '',
      commentText: data[CommentKey.COMMENT_TEXT] ?? '',
      createdAt: (data[CommentKey.CREATED_AT] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }
}
