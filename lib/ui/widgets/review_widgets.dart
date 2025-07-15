import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/Services/review_service.dart';
import 'package:check_in/utils/colors.dart';
import 'package:flutter/material.dart';

class ReviewButton extends StatelessWidget {
  final String targetId;
  final String targetName;
  final String targetLocation;
  final String targetImageUrl;
  final ReviewType reviewType;
  final VoidCallback? onReviewSubmitted;
  final bool isPremium;
  final String buttonText;

  const ReviewButton({
    super.key,
    required this.targetId,
    required this.targetName,
    required this.targetLocation,
    required this.targetImageUrl,
    required this.reviewType,
    this.onReviewSubmitted,
    this.isPremium = true,
    this.buttonText = "Rate",
  });

  @override
  Widget build(BuildContext context) {
    if (!isPremium) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showReviewDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: appGreenColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: TempLanguage.poppins,
                    fontSize: 16,
                    color: appWhiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    ReviewService.showReviewDialog(
      context: context,
      name: targetName,
      location: targetLocation,
      imageUrl: targetImageUrl,
      targetId: targetId,
      reviewType: reviewType,
      onReviewSubmitted: () {
        if (onReviewSubmitted != null) {
          onReviewSubmitted!();
        }
      },
    );
  }
}

// Example usage widget for displaying reviews stats
class ReviewStatsWidget extends StatelessWidget {
  final String targetId;
  final ReviewType reviewType;

  const ReviewStatsWidget({
    super.key,
    required this.targetId,
    required this.reviewType,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ReviewService.getReviewStats(
        targetId: targetId,
        reviewType: reviewType,
      ),
      builder: (context, snapshot) {
        final stats =
            snapshot.data ?? {'averageRating': 0.0, 'totalReviews': 0};
        final averageRating = stats['averageRating'].toDouble();
        final totalReviews = stats['totalReviews'];

        return Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$totalReviews Reviews",
                style: TextStyle(
                  fontFamily: TempLanguage.poppins,
                  fontSize: 18,
                  color: appGreenColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < averageRating.floor()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                  const SizedBox(width: 5),
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontFamily: TempLanguage.poppins,
                      fontSize: 16,
                      color: appBlackColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
