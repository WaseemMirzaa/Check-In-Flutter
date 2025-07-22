import 'package:cached_network_image/cached_network_image.dart';
import 'package:check_in/Services/user_services.dart';
import 'package:check_in/Services/court_data_service.dart';
import 'package:check_in/Services/review_service.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/court_data_models.dart';
import 'package:check_in/ui/screens/player.dart';
import 'package:check_in/ui/screens/gallery.dart';
import 'package:check_in/ui/screens/reviews.dart';
import 'package:check_in/ui/screens/comments.dart';
import 'package:check_in/ui/widgets/upload_dialog.dart';
import 'package:check_in/ui/widgets/dialog_widgets.dart';
import 'package:check_in/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../core/constant/constant.dart';

class PlayersView extends StatefulWidget {
  final LatLng courtLatLng;
  final String courtName;
  final bool isCheckedIn;
  final String courtId;

  const PlayersView({
    super.key,
    required this.courtLatLng,
    required this.courtName,
    required this.isCheckedIn,
    required this.courtId,
  });

  @override
  State<PlayersView> createState() => _PlayersViewState();
}

class User {
  final String name;
  final String email;
  final String about;
  final String court;
  final String photoUrl;
  bool? isVerified;
  bool? isPremium;

  User({
    required this.name,
    required this.email,
    required this.about,
    required this.court,
    required this.photoUrl,
    this.isVerified,
    this.isPremium,
  });
}

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LatLng court;
  UserService({required this.court});
  Stream<List<User>> get users {
    return _firestore.collection(Collections.USER).snapshots().map((snapshot) {
      return snapshot.docs
          .where((d) =>
              // d.get("uid") != FirebaseAuth.instance.currentUser!.uid &&
              d.get(UserKey.CHECKED_IN) == true &&
              d.get(CourtKey.COURT_LAT) == court.latitude &&
              d.get(CourtKey.COURT_LNG) == court.longitude)
          .map((doc) => User(
                name: doc.data()[UserKey.USER_NAME],
                email: doc.data()[UserKey.EMAIL],
                about: doc.data()[UserKey.ABOUT_ME] ?? "",
                court: doc.data()[UserKey.HOME_COURT] ?? "",
                photoUrl: doc.data()[UserKey.PHOTO_URL] ?? "",
                isVerified: doc.data()[UserKey.IS_VERIFIED] ?? true,
                isPremium: doc.data()[UserKey.IS_PREMIUM] ?? false,
              ))
          .toList();
    });
  }

  Stream<List<User>> get emptyUsers {
    return Stream.fromIterable([<User>[]]);
  }
}

// Reusable Widgets
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget? subtitle;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: TempLanguage.poppins,
                fontSize: 18,
                color: appBlackColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) subtitle!,
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class RatingWidget extends StatelessWidget {
  final double averageRating;
  final String totalRatings;
  final double starSize;
  final double fontSize;

  const RatingWidget({
    super.key,
    required this.averageRating,
    required this.totalRatings,
    this.starSize = 16,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < averageRating.floor() ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: starSize,
          );
        }),
        const SizedBox(width: 5),
        Text(
          totalRatings,
          style: TextStyle(
            fontFamily: TempLanguage.poppins,
            fontSize: fontSize,
            color: appGreenColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class ViewAllLink extends StatelessWidget {
  final VoidCallback? onTap;

  const ViewAllLink({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        "View All",
        style: TextStyle(
          fontFamily: TempLanguage.poppins,
          fontSize: 14,
          color: appGreenColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
        decoration: BoxDecoration(
          color: appGreenColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: TempLanguage.poppins,
            fontSize: 14,
            color: appWhiteColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class GallerySection extends StatelessWidget {
  final bool isPremium;
  final bool isCheckedIn;
  final String courtName;
  final String courtId;

  const GallerySection({
    super.key,
    required this.isPremium,
    required this.isCheckedIn,
    required this.courtName,
    required this.courtId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Gallery",
          trailing: ViewAllLink(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GalleryScreen(
                    courtName: courtName,
                    courtId: courtId,
                    isPremium: isPremium,
                    isCheckedIn: isCheckedIn,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
        StreamBuilder<List<GalleryItem>>(
          stream: CourtDataService(courtId: courtId).galleryItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade100,
                ),
                child: Center(
                  child: Text(
                    "No gallery images yet",
                    style: TextStyle(
                      fontFamily: TempLanguage.poppins,
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }

            final List<GalleryItem> galleryItems = snapshot.data!;
            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: galleryItems.length,
                itemBuilder: (context, index) {
                  GalleryItem item = galleryItems[index];
                  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                  final isOwner = currentUserId == item.uploadedBy;

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GalleryScreen(
                            courtName: courtName,
                            courtId: courtId,
                            isPremium: isPremium,
                            isCheckedIn: isCheckedIn,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade200,
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 3),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                print('Error loading image: $error');
                                return Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey.shade500,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                          if (isOwner)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _showDeleteGalleryConfirmation(
                                    context, item, courtId),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        if (isPremium && isCheckedIn)
          CustomButton(
            text: "Upload Gallery Images",
            onTap: () {
              UploadDialog.showUploadDialog(
                context: context,
                courtId: courtId,
                courtName: courtName,
              );
            },
          ),
      ],
    );
  }

  void _showDeleteGalleryConfirmation(
      BuildContext context, GalleryItem item, String courtId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Image",
            style: TextStyle(
              fontFamily: TempLanguage.poppins,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this image? This action cannot be undone.",
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
                _deleteGalleryItem(context, item, courtId);
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

  void _deleteGalleryItem(
      BuildContext context, GalleryItem item, String courtId) async {
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
                "Deleting image...",
                style: TextStyle(fontFamily: TempLanguage.poppins),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );

      // Delete the image from Firestore
      await FirebaseFirestore.instance
          .collection(Collections.COURT_GALLERY)
          .doc(item.id)
          .delete();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Image deleted successfully!",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: appGreenColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error deleting gallery item: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to delete image. Please try again.",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;
  final String courtId;

  const ReviewCard({
    super.key,
    required this.review,
    required this.courtId,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = currentUserId == review.userId;

    return GestureDetector(
      onTap: () => _showReviewDetailDialog(context),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: appWhiteColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              offset: const Offset(0, 1),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Row(
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
                child: review.userPhotoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: review.userPhotoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
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
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          review.userName,
                          style: TextStyle(
                            fontFamily: TempLanguage.poppins,
                            fontSize: 14,
                            color: appBlackColor,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isOwner)
                        GestureDetector(
                          onTap: () => _showDeleteReviewConfirmation(
                              context, review, courtId),
                          child: Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red.shade600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    review.reviewText,
                    style: TextStyle(
                      fontFamily: TempLanguage.poppins,
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: RatingWidget(
                          averageRating: review.rating.toDouble(),
                          totalRatings: "",
                          starSize: 12,
                          fontSize: 12,
                        ),
                      ),
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
            ),
          ],
        ),
      ), // closing Container (child of GestureDetector)
    ); // closing GestureDetector
  } // closing build method of ReviewCard

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

  void _showReviewDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: appWhiteColor,
          contentPadding: const EdgeInsets.all(20),
          title: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: ClipOval(
                  child: review.userPhotoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: review.userPhotoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.grey.shade500,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.grey.shade500,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey.shade500,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.userName,
                  style: TextStyle(
                    fontFamily: TempLanguage.poppins,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: RatingWidget(
                      averageRating: review.rating.toDouble(),
                      totalRatings: "",
                      starSize: 16,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(review.createdAt),
                    style: TextStyle(
                      fontFamily: TempLanguage.poppins,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                "Review:",
                style: TextStyle(
                  fontFamily: TempLanguage.poppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: appBlackColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                review.reviewText,
                style: TextStyle(
                  fontFamily: TempLanguage.poppins,
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close",
                style: TextStyle(
                  color: appGreenColor,
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

  void _showDeleteReviewConfirmation(
      BuildContext context, Review review, String courtId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: appWhiteColor,
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
                _deleteReview(context, review, courtId);
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

  void _deleteReview(
      BuildContext context, Review review, String courtId) async {
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

      // Delete the review from Firestore
      await FirebaseFirestore.instance
          .collection(Collections.COURT_REVIEWS)
          .doc(review.id)
          .delete();

      // Show success message
      if (context.mounted) {
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
      if (context.mounted) {
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
}

class ReviewsSection extends StatelessWidget {
  final bool isPremium;
  final bool isCheckedIn;
  final String courtName;
  final String courtId;

  const ReviewsSection({
    super.key,
    required this.isPremium,
    required this.isCheckedIn,
    required this.courtName,
    required this.courtId,
  });

  Future<Map<String, dynamic>> _getReviewStats() async {
    return ReviewService.getReviewStats(
      targetId: courtId, // Using courtId as document ID
      reviewType: ReviewType.court,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<Map<String, dynamic>>(
          future: _getReviewStats(),
          builder: (context, statsSnapshot) {
            final stats =
                statsSnapshot.data ?? {'averageRating': 0.0, 'totalReviews': 0};
            return SectionHeader(
              title: "Reviews",
              subtitle: RatingWidget(
                averageRating: stats['averageRating'].toDouble(),
                totalRatings: "${stats['totalReviews']}",
              ),
              trailing: ViewAllLink(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReviewsScreen(
                        courtId: courtId, // Using courtId as document ID
                        courtName: courtName,
                        isPremium: isPremium,
                        isCheckedIn: isCheckedIn,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 15),
        StreamBuilder<List<Review>>(
          stream: CourtDataService(courtId: courtId).reviews,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Container(
                height: 120,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.red.shade50,
                ),
                child: Center(
                  child: Text(
                    "Error loading reviews. Please try again.",
                    style: TextStyle(
                      fontFamily: TempLanguage.poppins,
                      fontSize: 14,
                      color: Colors.red.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                height: 120,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade100,
                ),
                child: Center(
                  child: Text(
                    "No reviews yet.",
                    style: TextStyle(
                      fontFamily: TempLanguage.poppins,
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final reviews =
                snapshot.data!.take(5).toList(); // Show only first 5 reviews
            return SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: reviews.length,
                padding: EdgeInsets.only(bottom: 10),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final review = reviews[index];

                  return ReviewCard(
                    review: review,
                    courtId: courtId,
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        if (isPremium && isCheckedIn)
          CustomButton(
            text: "Rate this court",
            onTap: () {
              ReviewService.showReviewDialog(
                context: context,
                name: courtName,
                location: "Brooklyn", // You can make this dynamic too
                imageUrl: AppAssets.LOGO_NEW, // You can pass actual court image
                targetId: courtId, // Using courtId as document ID
                reviewType: ReviewType.court,
                onReviewSubmitted: () {
                  // The StreamBuilder will automatically update the UI
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Review submitted successfully!",
                        style: TextStyle(fontFamily: TempLanguage.poppins),
                      ),
                      backgroundColor: appGreenColor,
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

class CommentCard extends StatelessWidget {
  final Comment comment;
  final String courtId;

  const CommentCard({
    super.key,
    required this.comment,
    required this.courtId,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = currentUserId == comment.userId;

    return GestureDetector(
      onTap: () => _showCommentDetailDialog(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: appWhiteColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              offset: const Offset(0, 1),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: ClipOval(
                child: comment.userPhotoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: comment.userPhotoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey.shade500,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 20,
                        color: Colors.grey.shade500,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          comment.userName,
                          style: TextStyle(
                            fontFamily: TempLanguage.poppins,
                            fontSize: 14,
                            color: appBlackColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isOwner)
                        GestureDetector(
                          onTap: () => _showDeleteCommentConfirmation(
                              context, comment, courtId),
                          child: Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red.shade600,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    _formatDate(comment.createdAt),
                    style: TextStyle(
                      fontFamily: TempLanguage.poppins,
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    comment.commentText,
                    style: TextStyle(
                      fontFamily: TempLanguage.poppins,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ), // closing Container (child of GestureDetector)
    ); // closing GestureDetector
  } // closing build method of CommentCard

  void _showCommentDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: appWhiteColor,
          contentPadding: const EdgeInsets.all(20),
          title: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: ClipOval(
                  child: comment.userPhotoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: comment.userPhotoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.grey.shade500,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.grey.shade500,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey.shade500,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  comment.userName,
                  style: TextStyle(
                    fontFamily: TempLanguage.poppins,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(comment.createdAt),
                style: TextStyle(
                  fontFamily: TempLanguage.poppins,
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                comment.commentText,
                style: TextStyle(
                  fontFamily: TempLanguage.poppins,
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close",
                style: TextStyle(
                  color: appGreenColor,
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

  void _showDeleteCommentConfirmation(
      BuildContext context, Comment comment, String courtId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: appWhiteColor,
          title: Text(
            "Delete Comment",
            style: TextStyle(
              fontFamily: TempLanguage.poppins,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this comment? This action cannot be undone.",
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
                _deleteComment(context, comment, courtId);
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

  void _deleteComment(
      BuildContext context, Comment comment, String courtId) async {
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
                "Deleting comment...",
                style: TextStyle(fontFamily: TempLanguage.poppins),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );

      // Delete the comment from Firestore
      await FirebaseFirestore.instance
          .collection(Collections.COURT_COMMENTS_COLLECTION)
          .doc(comment.id)
          .delete();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Comment deleted successfully!",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: appGreenColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error deleting comment: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to delete comment. Please try again.",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class CommentsSection extends StatefulWidget {
  final bool isPremium;
  final bool isCheckedIn;
  final String courtName;
  final String courtId;

  const CommentsSection({
    super.key,
    required this.isPremium,
    required this.isCheckedIn,
    required this.courtName,
    required this.courtId,
  });

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  void _showCommentDialog() {
    TextEditingController commentController = TextEditingController();
    bool isFormValid = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            isFormValid = commentController.text.trim().isNotEmpty;

            return AlertDialog(
              title: Text(
                "Write a Comment",
                style: TextStyle(
                  fontFamily: TempLanguage.poppins,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Share your thoughts about ${widget.courtName}",
                    style: TextStyle(
                      fontFamily: TempLanguage.poppins,
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    onChanged: (value) {
                      setDialogState(() {
                        // Trigger rebuild to update button state
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Write your comment...",
                      hintStyle: TextStyle(
                        fontFamily: TempLanguage.poppins,
                        color: Colors.grey.shade500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: appGreenColor),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: TempLanguage.poppins,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isFormValid
                      ? () {
                          if (commentController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please write a comment",
                                  style: TextStyle(
                                      fontFamily: TempLanguage.poppins),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          Navigator.pop(context);
                          _submitComment(commentController.text);
                        }
                      : null,
                  child: Text(
                    "Post",
                    style: TextStyle(
                      color: isFormValid ? appGreenColor : Colors.grey,
                      fontFamily: TempLanguage.poppins,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitComment(String commentText) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please login to post a comment",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userController = Get.find<UserController>();
      final user = userController.userModel.value;

      await FirebaseFirestore.instance
          .collection(Collections.COURT_COMMENTS_COLLECTION)
          .add({
        CommentKey.USER_ID: currentUser.uid,
        CommentKey.USER_NAME: user.userName,
        CommentKey.USER_PHOTO_URL: user.photoUrl,
        CommentKey.COMMENT_TEXT: commentText,
        CommentKey.COURT_ID: widget
            .courtId, // Add courtId field for separate collection architecture
        CommentKey.CREATED_AT: FieldValue.serverTimestamp(),
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Comment posted successfully!",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: appGreenColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error submitting comment: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to post comment. Please try again.",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Comments",
          trailing: ViewAllLink(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CommentsScreen(
                    courtName: widget.courtName,
                    courtId: widget.courtId,
                    isPremium: widget.isPremium,
                    isCheckedIn: widget.isCheckedIn,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
        StreamBuilder<List<Comment>>(
          stream: CourtDataService(courtId: widget.courtId).comments,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade100,
                ),
                child: Center(
                  child: Text(
                    "No comments yet.",
                    style: TextStyle(
                      fontFamily: TempLanguage.poppins,
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final comments = snapshot.data!;
            return Column(
              children: comments.take(3).map((comment) {
                return CommentCard(
                  comment: comment,
                  courtId: widget.courtId,
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        if (widget.isPremium && widget.isCheckedIn)
          CustomButton(
            text: "Write a comment",
            onTap: _showCommentDialog,
          ),
      ],
    );
  }
}

class PlayerCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  final bool canRate;

  const PlayerCard({
    super.key,
    required this.user,
    required this.onTap,
    this.canRate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: appWhiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                offset: const Offset(0, 2),
                blurRadius: 6,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: user.photoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: user.photoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey.shade500,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontFamily: TempLanguage.poppins,
                        fontSize: 18,
                        color: appBlackColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontFamily: TempLanguage.poppins,
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Home Court: ',
                            style: TextStyle(
                              fontFamily: TempLanguage.poppins,
                              fontSize: 12,
                              color: appGreenColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: user.court.isEmpty
                                ? "Not specified"
                                : user.court,
                            style: TextStyle(
                              fontFamily: TempLanguage.poppins,
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (canRate && (user.isPremium ?? false))
                Column(
                  children: [
                    IconButton(
                      onPressed: () => _showPlayerRatingDialog(context, user),
                      icon: Icon(
                        Icons.star_rate,
                        color: appGreenColor,
                        size: 28,
                      ),
                      tooltip: "Rate Player",
                    ),
                    Text(
                      "Rate",
                      style: TextStyle(
                        fontFamily: TempLanguage.poppins,
                        fontSize: 10,
                        color: appGreenColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlayerRatingDialog(BuildContext context, User user) {
    // Get user ID - you'll need to implement this based on your User model
    // For now, using email as identifier, but you should use actual user ID
    final playerId = user.email; // Replace with actual user ID when available

    ReviewService.showReviewDialog(
      context: context,
      name: user.name,
      location: user.court.isNotEmpty ? user.court : "Unknown Court",
      imageUrl: user.photoUrl,
      targetId: playerId,
      reviewType: ReviewType.player,
      onReviewSubmitted: () {
        // Optionally refresh player data or show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Player review submitted successfully!",
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
            backgroundColor: appGreenColor,
          ),
        );
      },
    );
  }
}

class _PlayersViewState extends State<PlayersView> {
  int numberOfPLayers = 0;
  bool isCurrentUserPremium = false;
  late UserController userController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getNumberOfPlayers() async {
    final snapshot = await _firestore.collection(Collections.USER).get();
    final users = snapshot.docs.where((doc) =>
        doc.get(UserKey.CHECKED_IN) == true &&
        doc.get(CourtKey.COURT_LAT) == widget.courtLatLng.latitude &&
        doc.get(CourtKey.COURT_LNG) == widget.courtLatLng.longitude);
    numberOfPLayers = users.length;
    setState(() {});
    return users.length;
  }

  Future<void> getCurrentUserPremiumStatus() async {
    // You'll need to implement this based on your authentication system
    // For example, if you're using Firebase Auth:
    // final currentUser = FirebaseAuth.instance.currentUser;
    // if (currentUser != null) {
    //   final userDoc = await _firestore.collection(Collections.USER).doc(currentUser.uid).get();
    //   isCurrentUserPremium = userDoc.data()?[UserKey.IS_PREMIUM] ?? false;
    //   setState(() {});
    // }

    // For now, setting a default value - replace with actual implementation
    isCurrentUserPremium = userController.userModel.value.isPremium ??
        false; // Replace with actual user premium status check
    setState(() {});
  }

  @override
  void initState() {
    userController = Get.put(UserController(UserServices()));
    getNumberOfPlayers();
    getCurrentUserPremiumStatus();
    super.initState();
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
            )),
        centerTitle: true,
        title: Text(
          widget.courtName,
          // '${TempLanguage.player}s',
          maxLines: 2,

          style: TextStyle(
            fontFamily: TempLanguage.poppins,
            fontSize: 20,
            color: appBlackColor,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          softWrap: false,
        ),
        elevation: 0,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                labelColor: appWhiteColor,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: TextStyle(
                  fontFamily: TempLanguage.poppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: TempLanguage.poppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: appGreenColor,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(2),
                tabs: const [
                  Tab(text: "Active Players"),
                  Tab(text: "Court Info"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Active Players Tab
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "${TempLanguage.numOfPlayers}$numberOfPLayers",
                          style: TextStyle(
                            fontFamily: TempLanguage.poppins,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                          softWrap: false,
                        ),
                      ),
                      const SizedBox(height: 20),
                      StreamBuilder<List<User>>(
                        stream: !widget.isCheckedIn
                            ? UserService(court: widget.courtLatLng).users
                            : UserService(court: widget.courtLatLng).emptyUsers,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final users = snapshot.data!;
                          return Expanded(
                            child: ListView.builder(
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return PlayerCard(
                                  user: user,
                                  canRate: isCurrentUserPremium,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PlayerScreen(user: user),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      )
                    ],
                  ),
                  // Court Info Tab
                  Stack(
                    children: [
                      // Apply blur effect when user is not premium
                      Container(
                        child: !isCurrentUserPremium
                            ? ImageFiltered(
                                imageFilter:
                                    ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GallerySection(
                                        isPremium: isCurrentUserPremium,
                                        isCheckedIn: widget.isCheckedIn,
                                        courtName: widget.courtName,
                                        courtId: widget.courtId,
                                      ),
                                      const SizedBox(height: 30),
                                      ReviewsSection(
                                        isPremium: isCurrentUserPremium,
                                        isCheckedIn: widget.isCheckedIn,
                                        courtName: widget.courtName,
                                        courtId: widget.courtId,
                                      ),
                                      const SizedBox(height: 30),
                                      CommentsSection(
                                        isPremium: isCurrentUserPremium,
                                        isCheckedIn: widget.isCheckedIn,
                                        courtName: widget.courtName,
                                        courtId: widget.courtId,
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GallerySection(
                                      isPremium: isCurrentUserPremium,
                                      isCheckedIn: widget.isCheckedIn,
                                      courtName: widget.courtName,
                                      courtId: widget.courtId,
                                    ),
                                    const SizedBox(height: 30),
                                    ReviewsSection(
                                      isPremium: isCurrentUserPremium,
                                      isCheckedIn: widget.isCheckedIn,
                                      courtName: widget.courtName,
                                      courtId: widget.courtId,
                                    ),
                                    const SizedBox(height: 30),
                                    CommentsSection(
                                      isPremium: isCurrentUserPremium,
                                      isCheckedIn: widget.isCheckedIn,
                                      courtName: widget.courtName,
                                      courtId: widget.courtId,
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                      ),
                      // Show upgrade message when user is not premium
                      if (!isCurrentUserPremium)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black54,
                            child: Center(
                              child: Container(
                                margin: const EdgeInsets.all(20),
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock,
                                      size: 48,
                                      color: appGreenColor,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Premium Feature",
                                      style: TextStyle(
                                        fontFamily: TempLanguage.poppins,
                                        fontSize: 20,
                                        color: appBlackColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Upgrade to Premium to unlock court information, gallery, reviews, and comments",
                                      style: TextStyle(
                                        fontFamily: TempLanguage.poppins,
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    CustomButton(
                                      text: "Upgrade to Premium",
                                      onTap: () {
                                        // Handle premium upgrade navigation
                                        // You can navigate to your premium upgrade screen here
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Coming soon",
                                              style: TextStyle(
                                                  fontFamily:
                                                      TempLanguage.poppins),
                                            ),
                                            backgroundColor: appGreenColor,
                                          ),
                                        );
                                      },
                                      width: double.infinity,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
