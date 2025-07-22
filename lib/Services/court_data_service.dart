import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/court_data_models.dart';

// Services for court data using separate collections
class CourtDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String courtId;

  CourtDataService({required this.courtId});

  // Gallery items stream from separate collection
  Stream<List<GalleryItem>> get galleryItems {
    return _firestore
        .collection(Collections.COURT_GALLERY)
        .where(GalleryKey.COURT_ID, isEqualTo: courtId)
        .orderBy(GalleryKey.UPLOADED_AT, descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GalleryItem.fromFirestore(doc))
            .toList());
  }

  // Reviews stream from separate collection
  Stream<List<Review>> get reviews {
    return _firestore
        .collection(Collections.COURT_REVIEWS)
        .where(ReviewKey.COURT_ID, isEqualTo: courtId)
        .orderBy(ReviewKey.CREATED_AT, descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  // Comments stream from separate collection
  Stream<List<Comment>> get comments {
    return _firestore
        .collection(Collections.COURT_COMMENTS_COLLECTION)
        .where(CommentKey.COURT_ID, isEqualTo: courtId)
        .orderBy(CommentKey.CREATED_AT, descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());
  }

  // Get average rating and count from separate collection
  Future<Map<String, dynamic>> getReviewStats() async {
    final snapshot = await _firestore
        .collection(Collections.COURT_REVIEWS)
        .where(ReviewKey.COURT_ID, isEqualTo: courtId)
        .get();

    if (snapshot.docs.isEmpty) {
      return {'averageRating': 0.0, 'totalReviews': 0};
    }

    double totalRating = 0;
    for (var doc in snapshot.docs) {
      totalRating += (doc.data()[ReviewKey.RATING] ?? 0).toDouble();
    }

    return {
      'averageRating': totalRating / snapshot.docs.length,
      'totalReviews': snapshot.docs.length,
    };
  }

  // Add new review to separate collection
  Future<void> addReview(Review review) async {
    await _firestore.collection(Collections.COURT_REVIEWS).add(review.toMap());
  }

  // Add new comment to separate collection
  Future<void> addComment(Comment comment) async {
    await _firestore
        .collection(Collections.COURT_COMMENTS_COLLECTION)
        .add(comment.toMap());
  }

  // Add new gallery item to separate collection
  Future<void> addGalleryItem(GalleryItem galleryItem) async {
    await _firestore
        .collection(Collections.COURT_GALLERY)
        .add(galleryItem.toMap());
  }

  // Delete review
  Future<void> deleteReview(String reviewId) async {
    await _firestore
        .collection(Collections.COURT_REVIEWS)
        .doc(reviewId)
        .delete();
  }

  // Delete comment
  Future<void> deleteComment(String commentId) async {
    await _firestore
        .collection(Collections.COURT_COMMENTS_COLLECTION)
        .doc(commentId)
        .delete();
  }

  // Delete gallery item
  Future<void> deleteGalleryItem(String galleryItemId) async {
    await _firestore
        .collection(Collections.COURT_GALLERY)
        .doc(galleryItemId)
        .delete();
  }
}
