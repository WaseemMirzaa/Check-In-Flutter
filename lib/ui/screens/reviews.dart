import 'package:cached_network_image/cached_network_image.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/court_data_models.dart';
import 'package:check_in/Services/review_service.dart';
import 'package:check_in/ui/widgets/dialog_widgets.dart';
import 'package:check_in/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ReviewsScreen extends StatefulWidget {
  final String courtName;
  final bool isPremium;
  final String courtId;
  final bool isCheckedIn;

  const ReviewsScreen({
    super.key,
    required this.courtName,
    required this.courtId,
    required this.isPremium,
    required this.isCheckedIn,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<Review> reviews = [];
  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool hasMoreData = true;
  bool isLoadingMore = false;
  final int pageSize = 10;
  late Future<Map<String, dynamic>> reviewStats;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    reviewStats = _getReviewStats();
    _loadInitialReviews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && hasMoreData) {
        _loadMoreReviews();
      }
    }
  }

  Future<void> _loadInitialReviews() async {
    setState(() {
      isLoading = true;
      reviews.clear();
      lastDocument = null;
      hasMoreData = true;
    });

    await _loadMoreReviews();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadMoreReviews() async {
    if (isLoadingMore || !hasMoreData) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection(Collections.COURT_REVIEWS)
          .where(ReviewKey.COURT_ID, isEqualTo: widget.courtId)
          .orderBy(ReviewKey.CREATED_AT, descending: true)
          .limit(pageSize);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        final newReviews =
            snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();

        setState(() {
          reviews.addAll(newReviews);
          lastDocument = snapshot.docs.last;
          hasMoreData = snapshot.docs.length == pageSize;
        });
      } else {
        setState(() {
          hasMoreData = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading reviews: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error loading reviews. Please try again.",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingMore = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _getReviewStats() async {
    return ReviewService.getReviewStats(
      targetId: widget.courtId,
      reviewType: ReviewType.court,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhiteColor,
      appBar: AppBar(
        backgroundColor: appWhiteColor,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 10),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SizedBox(
            height: 2.1.h,
            width: 2.9.w,
            child: Image.asset(
              AppAssets.LEFT_ARROW,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          "Reviews",
          style: TextStyle(
            fontFamily: TempLanguage.poppins,
            fontSize: 20,
            color: appBlackColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with total reviews and rating
          FutureBuilder<Map<String, dynamic>>(
            future: reviewStats,
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
          ),

          // Reviews List
          Expanded(
            child: reviews.isEmpty && !isLoading
                ? Center(
                    child: Text(
                      "No reviews yet.",
                      style: TextStyle(
                        fontFamily: TempLanguage.poppins,
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadInitialReviews,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: reviews.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == reviews.length) {
                          // Load more indicator
                          if (isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return const SizedBox.shrink();
                        }

                        final review = reviews[index];
                        final currentUserId =
                            FirebaseAuth.instance.currentUser?.uid;
                        final isOwner = currentUserId == review.userId;

                        return GestureDetector(
                          onTap: () => AppDialogs.showReviewDetailDialog(
                            context: context,
                            review: review,
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: appWhiteColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  offset: const Offset(0, 2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.shade200,
                                      ),
                                      child: ClipOval(
                                        child: review.userPhotoUrl.isNotEmpty &&
                                                review.userPhotoUrl
                                                    .startsWith('http')
                                            ? CachedNetworkImage(
                                                imageUrl: review.userPhotoUrl,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(
                                                  Icons.person,
                                                  size: 25,
                                                  color: Colors.grey.shade500,
                                                ),
                                              )
                                            : Icon(
                                                Icons.person,
                                                size: 25,
                                                color: Colors.grey.shade500,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  review.userName.isNotEmpty
                                                      ? review.userName
                                                      : 'Anonymous',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        TempLanguage.poppins,
                                                    fontSize: 16,
                                                    color: appBlackColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              if (isOwner)
                                                GestureDetector(
                                                  onTap: () => AppDialogs
                                                      .showDeleteConfirmationDialog(
                                                    context: context,
                                                    title: "Delete Review",
                                                    content:
                                                        "Are you sure you want to delete this review? This action cannot be undone.",
                                                    onConfirm: () =>
                                                        _deleteReview(review),
                                                  ),
                                                  child: Icon(
                                                    Icons.delete_outline,
                                                    size: 18,
                                                    color: Colors.red.shade600,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              ...List.generate(5, (starIndex) {
                                                return Icon(
                                                  starIndex < review.rating
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 16,
                                                );
                                              }),
                                              const SizedBox(width: 8),
                                              Text(
                                                AppDateUtils.formatDate(
                                                    review.createdAt),
                                                style: TextStyle(
                                                  fontFamily:
                                                      TempLanguage.poppins,
                                                  fontSize: 12,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            review.reviewText,
                                            style: TextStyle(
                                              fontFamily: TempLanguage.poppins,
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                              height: 1.4,
                                            ),
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ), // closing Column
                          ), // closing Container
                        ); // closing GestureDetector
                      },
                    ),
                  ),
          ),

          // Rate This Court Button
          if (widget.isPremium && widget.isCheckedIn)
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _showRatingDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: appGreenColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          "Rate This Court",
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
            ),
        ],
      ),
    );
  }

  void _deleteReview(Review review) async {
    try {
      // Show loading indicator
      AppDialogs.showLoadingSnackbar(
        context: context,
        message: "Deleting review...",
      );

      // Delete the review from Firestore - using new separate collection
      await FirebaseFirestore.instance
          .collection(Collections.COURT_REVIEWS)
          .doc(review.id)
          .delete();

      // Remove from local list and refresh stats
      setState(() {
        reviews.removeWhere((r) => r.id == review.id);
        reviewStats = _getReviewStats();
      });

      // Show success message
      if (mounted) {
        AppDialogs.showSuccessSnackbar(
          context: context,
          message: "Review deleted successfully!",
        );
      }
    } catch (e) {
      debugPrint("Error deleting review: $e");
      if (mounted) {
        AppDialogs.showErrorSnackbar(
          context: context,
          message: "Failed to delete review. Please try again.",
        );
      }
    }
  }

  void _showRatingDialog() {
    ReviewService.showReviewDialog(
      context: context,
      name: widget.courtName,
      location: "Brooklyn", // You might want to make this dynamic too
      imageUrl: AppAssets.LOGO_NEW,
      targetId: widget.courtId,
      reviewType: ReviewType.court,
      onReviewSubmitted: () {
        // Refresh the reviews list and stats
        setState(() {
          reviewStats = _getReviewStats();
        });
        _loadInitialReviews();
      },
    );
  }
}
