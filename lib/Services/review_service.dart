import 'package:check_in/auth_service.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/court_data_models.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/rate_court_dialog.dart';
import 'package:check_in/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum ReviewType { court, player }

class ReviewService {
  static Future<void> showReviewDialog({
    required BuildContext context,
    required String name,
    required String location,
    required String imageUrl,
    required String targetId,
    required ReviewType reviewType,
    required VoidCallback onReviewSubmitted,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RateCourtDialog(
          courtName: name,
          courtLocation: location,
          courtImage: imageUrl,
          onSubmit: (rating, review) {
            _submitReview(
              context: context,
              rating: rating,
              reviewText: review,
              targetId: targetId,
              reviewType: reviewType,
              onSuccess: onReviewSubmitted,
            );
          },
        );
      },
    );
  }

  static Future<void> _submitReview({
    required BuildContext context,
    required int rating,
    required String reviewText,
    required String targetId,
    required ReviewType reviewType,
    required VoidCallback onSuccess,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showErrorMessage(context, "Please login to submit a review.");
        return;
      }

      UserModel user = userController.userModel.value;

      // Determine the collection path based on review type
      CollectionReference reviewsCollection;

      if (reviewType == ReviewType.court) {
        reviewsCollection = FirebaseFirestore.instance
            .collection(Collections.GOLDEN_LOCATIONS)
            .doc(targetId)
            .collection(Collections.REVIEWS);
      } else {
        // For players - you may need to adjust this path based on your Firestore structure
        reviewsCollection = FirebaseFirestore.instance
            .collection(Collections.USER) // Using USER instead of USERS
            .doc(targetId)
            .collection(Collections.REVIEWS);
      }

      await reviewsCollection.add({
        ReviewKey.RATING: rating,
        ReviewKey.REVIEW_TEXT: reviewText,
        ReviewKey.USER_ID: currentUser.uid,
        ReviewKey.USER_NAME: user.userName,
        ReviewKey.USER_PHOTO_URL: user.photoUrl,
        ReviewKey.CREATED_AT: FieldValue.serverTimestamp(),
        'review_type': reviewType.name, // Track what type of review this is
        'target_id': targetId, // Store the ID of what's being reviewed
      });

      // Call the success callback
      onSuccess();

      // Show success message
      if (context.mounted) {
        _showSuccessMessage(context, "Review submitted successfully!");
      }
    } catch (e) {
      debugPrint("Error submitting review: $e");
      if (context.mounted) {
        _showErrorMessage(
            context, "Failed to submit review. Please try again.");
      }
    }
  }

  static Future<Map<String, dynamic>> getReviewStats({
    required String targetId,
    required ReviewType reviewType,
  }) async {
    try {
      CollectionReference reviewsCollection;

      if (reviewType == ReviewType.court) {
        reviewsCollection = FirebaseFirestore.instance
            .collection(Collections.GOLDEN_LOCATIONS)
            .doc(targetId)
            .collection(Collections.REVIEWS);
      } else {
        reviewsCollection = FirebaseFirestore.instance
            .collection(Collections.USER)
            .doc(targetId)
            .collection(Collections.REVIEWS);
      }

      final snapshot = await reviewsCollection.get();

      if (snapshot.docs.isEmpty) {
        return {'averageRating': 0.0, 'totalReviews': 0};
      }

      double totalRating = 0;
      for (var doc in snapshot.docs) {
        totalRating += (doc.data() as Map<String, dynamic>)[ReviewKey.RATING]
                ?.toDouble() ??
            0;
      }

      return {
        'averageRating': totalRating / snapshot.docs.length,
        'totalReviews': snapshot.docs.length,
      };
    } catch (e) {
      debugPrint("Error getting review stats: $e");
      return {'averageRating': 0.0, 'totalReviews': 0};
    }
  }

  static Future<List<Review>> getReviews({
    required String targetId,
    required ReviewType reviewType,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      CollectionReference reviewsCollection;

      if (reviewType == ReviewType.court) {
        reviewsCollection = FirebaseFirestore.instance
            .collection(Collections.GOLDEN_LOCATIONS)
            .doc(targetId)
            .collection(Collections.REVIEWS);
      } else {
        reviewsCollection = FirebaseFirestore.instance
            .collection(Collections.USER)
            .doc(targetId)
            .collection(Collections.REVIEWS);
      }

      Query query = reviewsCollection
          .orderBy(ReviewKey.CREATED_AT, descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint("Error getting reviews: $e");
      return [];
    }
  }

  static void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: TempLanguage.poppins),
        ),
        backgroundColor: appGreenColor,
      ),
    );
  }

  static void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: TempLanguage.poppins),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
