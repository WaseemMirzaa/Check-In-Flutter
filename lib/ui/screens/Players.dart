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
import 'package:check_in/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  final String courtName;
  final String courtId;

  const GallerySection({
    super.key,
    this.isPremium = false,
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
                    isPremium: isPremium,
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

            final galleryItems = snapshot.data!;
            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: galleryItems.length,
                itemBuilder: (context, index) {
                  final item = galleryItems[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GalleryScreen(
                            courtName: courtName,
                            isPremium: isPremium,
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
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
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        if (isPremium)
          CustomButton(
            text: "Upload Gallery Images",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GalleryScreen(
                    courtName: courtName,
                    isPremium: isPremium,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String userName;
  final String reviewText;
  final int rating;
  final String userImage;

  const ReviewCard({
    super.key,
    required this.userName,
    required this.reviewText,
    required this.rating,
    required this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: appWhiteColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: ClipOval(
              child: userImage.isNotEmpty && userImage.startsWith('http')
                  ? Image.network(
                      userImage,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 25,
                          color: Colors.grey.shade500,
                        );
                      },
                    )
                  : userImage.isNotEmpty
                      ? Image.asset(
                          userImage,
                          fit: BoxFit.cover,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontFamily: TempLanguage.poppins,
                    fontSize: 14,
                    color: appBlackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  reviewText,
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
                RatingWidget(
                  averageRating: rating.toDouble(),
                  totalRatings: "",
                  starSize: 12,
                  fontSize: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewsSection extends StatefulWidget {
  final bool isPremium;
  final String courtName;
  final String courtId;

  const ReviewsSection({
    super.key,
    required this.isPremium,
    required this.courtName,
    required this.courtId,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  late Future<Map<String, dynamic>> reviewStats;
  late Future<List<Review>> reviews;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    reviewStats = _getReviewStats();
    reviews = _getReviews();
  }

  Future<Map<String, dynamic>> _getReviewStats() async {
    return ReviewService.getReviewStats(
      targetId: widget.courtId, // Using courtId as document ID
      reviewType: ReviewType.court,
    );
  }

  Future<List<Review>> _getReviews() async {
    return ReviewService.getReviews(
      targetId: widget.courtId, // Using courtId as document ID
      reviewType: ReviewType.court,
      limit: 5, // Show only first 5 reviews in this preview
    );
  }

  void _refreshReviewStats() {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<Map<String, dynamic>>(
          future: reviewStats,
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
                        courtId: widget.courtId, // Using courtId as document ID
                        courtName: widget.courtName,
                        isPremium: widget.isPremium,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 15),
        FutureBuilder<List<Review>>(
          future: reviews,
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
                    "No reviews yet. Be the first to review this court!",
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

            final reviews = snapshot.data!;
            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];

                  return ReviewCard(
                    userName: review.userName,
                    reviewText: review.reviewText,
                    rating: review.rating,
                    userImage: review.userPhotoUrl,
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        if (widget.isPremium)
          CustomButton(
            text: "Rate this court",
            onTap: () {
              ReviewService.showReviewDialog(
                context: context,
                name: widget.courtName,
                location: "Brooklyn", // You can make this dynamic too
                imageUrl: AppAssets.LOGO_NEW, // You can pass actual court image
                targetId: widget.courtId, // Using courtId as document ID
                reviewType: ReviewType.court,
                onReviewSubmitted: _refreshReviewStats,
              );
            },
          ),
      ],
    );
  }
}

class CommentCard extends StatelessWidget {
  final String userName;
  final String commentText;
  final String userImage;

  const CommentCard({
    super.key,
    required this.userName,
    required this.commentText,
    required this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: appWhiteColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
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
              child: userImage.isNotEmpty && userImage.startsWith('http')
                  ? Image.network(
                      userImage,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey.shade500,
                        );
                      },
                    )
                  : userImage.isNotEmpty
                      ? Image.asset(
                          userImage,
                          fit: BoxFit.cover,
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
                Text(
                  userName,
                  style: TextStyle(
                    fontFamily: TempLanguage.poppins,
                    fontSize: 14,
                    color: appBlackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  commentText,
                  style: TextStyle(
                    fontFamily: TempLanguage.poppins,
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentsSection extends StatelessWidget {
  final bool isPremium;
  final String courtName;
  final String courtId;

  const CommentsSection({
    super.key,
    this.isPremium = false,
    required this.courtName,
    required this.courtId,
  });

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
                    courtName: courtName,
                    isPremium: isPremium,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
        StreamBuilder<List<Comment>>(
          stream: CourtDataService(courtId: courtId).comments,
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
                    "No comments yet. Be the first to comment!",
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
                  userName: comment.userName,
                  commentText: comment.commentText,
                  userImage: comment.userPhotoUrl,
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        if (isPremium)
          CustomButton(
            text: "Write a comment",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CommentsScreen(
                    courtName: courtName,
                    isPremium: isPremium,
                  ),
                ),
              );
            },
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
                  child: user.photoUrl != ""
                      ? Image.network(
                          user.photoUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey.shade500,
                              ),
                            );
                          },
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
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GallerySection(
                          isPremium: isCurrentUserPremium,
                          courtName: widget.courtName,
                          courtId: widget.courtId,
                        ),
                        const SizedBox(height: 30),
                        ReviewsSection(
                          isPremium: isCurrentUserPremium,
                          courtName: widget.courtName,
                          courtId: widget.courtId,
                        ),
                        const SizedBox(height: 30),
                        CommentsSection(
                          isPremium: isCurrentUserPremium,
                          courtName: widget.courtName,
                          courtId: widget.courtId,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
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
