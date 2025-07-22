import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/court_data_models.dart';
import 'package:check_in/utils/colors.dart';
import 'package:flutter/material.dart';

/// Utility class for date formatting
class AppDateUtils {
  /// Formats a DateTime into a human-readable string
  /// Returns "Just now", "X minutes ago", "X hours ago", "X days ago", or "DD/MM/YYYY"
  static String formatDate(DateTime date) {
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
}

/// Reusable dialogs for the app
class AppDialogs {
  /// Shows a review detail dialog
  static void showReviewDetailDialog({
    required BuildContext context,
    required Review review,
  }) {
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
                  child: review.userPhotoUrl.isNotEmpty &&
                          review.userPhotoUrl.startsWith('http')
                      ? Image.network(
                          review.userPhotoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.grey.shade500,
                            );
                          },
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
                  review.userName.isNotEmpty ? review.userName : 'Anonymous',
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
                  ...List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    AppDateUtils.formatDate(review.createdAt),
                    style: TextStyle(
                      fontFamily: TempLanguage.poppins,
                      fontSize: 12,
                      color: Colors.grey.shade500,
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

  /// Shows a comment detail dialog
  static void showCommentDetailDialog({
    required BuildContext context,
    required Comment comment,
  }) {
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
                  child: comment.userPhotoUrl.isNotEmpty &&
                          comment.userPhotoUrl.startsWith('http')
                      ? Image.network(
                          comment.userPhotoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.grey.shade500,
                            );
                          },
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
                  comment.userName.isNotEmpty ? comment.userName : 'Anonymous',
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
                AppDateUtils.formatDate(comment.createdAt),
                style: TextStyle(
                  fontFamily: TempLanguage.poppins,
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Comment:",
                style: TextStyle(
                  fontFamily: TempLanguage.poppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: appBlackColor,
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

  /// Shows a delete confirmation dialog
  static void showDeleteConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
    String confirmText = "Delete",
    String cancelText = "Cancel",
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: appWhiteColor,
          title: Text(
            title,
            style: TextStyle(
              fontFamily: TempLanguage.poppins,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            content,
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
                cancelText,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontFamily: TempLanguage.poppins,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: Text(
                confirmText,
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

  /// Shows a loading snackbar
  static void showLoadingSnackbar({
    required BuildContext context,
    required String message,
  }) {
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
              message,
              style: TextStyle(fontFamily: TempLanguage.poppins),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Shows a success snackbar
  static void showSuccessSnackbar({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: TempLanguage.poppins),
        ),
        backgroundColor: appGreenColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Shows an error snackbar
  static void showErrorSnackbar({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: TempLanguage.poppins),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
