import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/court_data_models.dart';
import 'package:check_in/Services/review_service.dart';
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

                        return Container(
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
                                          ? Image.network(
                                              review.userPhotoUrl,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 25,
                                                  color: Colors.grey.shade500,
                                                );
                                              },
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
                                                onTap: () =>
                                                    _showDeleteReviewConfirmation(
                                                        review),
                                                child: Icon(
                                                  Icons.delete_outline,
                                                  size: 18,
                                                  color: Colors.red.shade600,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
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
                                    _formatDate(review.createdAt),
                                    style: TextStyle(
                                      fontFamily: TempLanguage.poppins,
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return "${date.day}/${date.month}/${date.year}";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago";
    } else {
      return "Just now";
    }
  }

  void _showDeleteReviewConfirmation(Review review) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Review",
            style: TextStyle(
              fontFamily: TempLanguage.poppins,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this review? This action cannot be undone.",
            style: TextStyle(
              fontFamily: TempLanguage.poppins,
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontFamily: TempLanguage.poppins,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteReview(review);
              },
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: TempLanguage.poppins,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteReview(Review review) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "Deleting review...",
                style: TextStyle(fontFamily: TempLanguage.poppins),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Review deleted successfully!",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: appGreenColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error deleting review: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to delete review. Please try again.",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: Colors.red,
          ),
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
