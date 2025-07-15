import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/court_data_models.dart';

// Services for court subcollections
class CourtDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String courtId;

  CourtDataService({required this.courtId});

  // Gallery subcollection stream
  Stream<List<GalleryItem>> get galleryItems {
    return _firestore
        .collection(Collections.GOLDEN_LOCATIONS)
        .doc(courtId)
        .collection(Collections.GALLERY)
        .orderBy(GalleryKey.UPLOADED_AT, descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GalleryItem.fromFirestore(doc))
            .toList());
  }

  // Reviews subcollection stream
  Stream<List<Review>> get reviews {
    return _firestore
        .collection(Collections.GOLDEN_LOCATIONS)
        .doc(courtId)
        .collection(Collections.REVIEWS)
        .orderBy(ReviewKey.CREATED_AT, descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  // Comments subcollection stream
  Stream<List<Comment>> get comments {
    return _firestore
        .collection(Collections.GOLDEN_LOCATIONS)
        .doc(courtId)
        .collection(Collections.COURT_COMMENTS)
        .orderBy(CommentKey.CREATED_AT, descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());
  }

  // Get average rating and count
  Future<Map<String, dynamic>> getReviewStats() async {
    final snapshot = await _firestore
        .collection(Collections.GOLDEN_LOCATIONS)
        .doc(courtId)
        .collection(Collections.REVIEWS)
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
}
