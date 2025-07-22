import 'package:cached_network_image/cached_network_image.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/court_data_models.dart';
import 'package:check_in/ui/widgets/dialog_widgets.dart';
import 'package:check_in/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/user_controller.dart';

class CommentsScreen extends StatefulWidget {
  final String courtName;
  final String courtId;
  final bool isPremium;

  final bool isCheckedIn;

  const CommentsScreen({
    super.key,
    required this.courtName,
    required this.courtId,
    required this.isPremium,
    required this.isCheckedIn,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  List<Comment> comments = [];
  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool hasMoreData = true;
  bool isLoadingMore = false;
  int totalComments = 0;
  final int pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialComments();
    _loadCommentsCount();
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
        _loadMoreComments();
      }
    }
  }

  Future<void> _loadInitialComments() async {
    setState(() {
      isLoading = true;
      comments.clear();
      lastDocument = null;
      hasMoreData = true;
    });

    await _loadMoreComments();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadMoreComments() async {
    if (isLoadingMore || !hasMoreData) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      debugPrint("🔵 Loading comments for courtId: ${widget.courtId}");
      Query query = FirebaseFirestore.instance
          .collection(Collections.COURT_COMMENTS_COLLECTION)
          .where(CommentKey.COURT_ID, isEqualTo: widget.courtId)
          .orderBy(CommentKey.CREATED_AT, descending: true)
          .limit(pageSize);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      final snapshot = await query.get();
      debugPrint(
          "🔵 Comments query returned ${snapshot.docs.length} documents");

      if (snapshot.docs.isNotEmpty) {
        final newComments =
            snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();

        debugPrint("🔵 Parsed ${newComments.length} comments successfully");
        setState(() {
          comments.addAll(newComments);
          lastDocument = snapshot.docs.last;
          hasMoreData = snapshot.docs.length == pageSize;
        });
      } else {
        debugPrint("🔵 No comments found");
        setState(() {
          hasMoreData = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading comments: $e");
      if (mounted) {
        AppDialogs.showErrorSnackbar(
          context: context,
          message: "Error loading comments. Please try again.",
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

  Future<void> _loadCommentsCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(Collections.COURT_COMMENTS_COLLECTION)
          .where(CommentKey.COURT_ID, isEqualTo: widget.courtId)
          .count()
          .get();

      if (mounted) {
        setState(() {
          totalComments = snapshot.count ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Error getting comments count: $e");
    }
  }

  Future<void> _refreshComments() async {
    await _loadInitialComments();
    await _loadCommentsCount();
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
          "Comments",
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
          // Header with total comments
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  "$totalComments Comments",
                  style: TextStyle(
                    fontFamily: TempLanguage.poppins,
                    fontSize: 18,
                    color: appGreenColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No comments yet",
                              style: TextStyle(
                                fontFamily: TempLanguage.poppins,
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshComments,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: comments.length +
                              (hasMoreData && isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == comments.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final comment = comments[index];
                            final currentUserId =
                                FirebaseAuth.instance.currentUser?.uid;
                            final isOwner = currentUserId == comment.userId;

                            return GestureDetector(
                              onTap: () => AppDialogs.showCommentDetailDialog(
                                context: context,
                                comment: comment,
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: appWhiteColor,
                                  borderRadius: BorderRadius.circular(12),
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
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.shade200,
                                      ),
                                      child: ClipOval(
                                        child: comment.userPhotoUrl.isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: comment.userPhotoUrl,
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
                                              Flexible(
                                                child: Text(
                                                  comment.userName,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        TempLanguage.poppins,
                                                    fontSize: 16,
                                                    color: appBlackColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (isOwner)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8),
                                                  child: GestureDetector(
                                                    onTap: () => AppDialogs
                                                        .showDeleteConfirmationDialog(
                                                      context: context,
                                                      title: 'Delete Comment',
                                                      content:
                                                          'Are you sure you want to delete this comment?',
                                                      onConfirm: () =>
                                                          _deleteComment(
                                                              comment),
                                                    ),
                                                    child: Icon(
                                                      Icons.delete_outline,
                                                      size: 18,
                                                      color:
                                                          Colors.red.shade600,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Text(
                                            AppDateUtils.formatDate(
                                                comment.createdAt),
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
                              ),
                            );
                          },
                        ),
                      ),
          ),

          // Write a Comment Button
          if (widget.isPremium && widget.isCheckedIn)
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _showCommentDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: appGreenColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          "Write a Comment",
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
      debugPrint("🔵 Submitting comment for courtId: ${widget.courtId}");
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint("🔴 No current user found");
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

      debugPrint("🔵 User data: ${user.userName}");

      await FirebaseFirestore.instance
          .collection(Collections.COURT_COMMENTS_COLLECTION)
          .add({
        CommentKey.USER_ID: currentUser.uid,
        CommentKey.USER_NAME: user.userName,
        CommentKey.USER_PHOTO_URL: user.photoUrl,
        CommentKey.COMMENT_TEXT: commentText,
        CommentKey.CREATED_AT: FieldValue.serverTimestamp(),
        CommentKey.COURT_ID: widget.courtId, // Add courtId field
      });

      debugPrint("🔵 Comment added successfully to collection");

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

        // Refresh comments to show the new comment
        debugPrint("🔵 Refreshing comments list");
        await _refreshComments();
      }
    } catch (e) {
      debugPrint("🔴 Error submitting comment: $e");
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

  void _deleteComment(Comment comment) async {
    try {
      // Show loading indicator
      AppDialogs.showLoadingSnackbar(
        context: context,
        message: "Deleting comment...",
      );

      // Delete the comment from Firestore - using new separate collection
      await FirebaseFirestore.instance
          .collection(Collections.COURT_COMMENTS_COLLECTION)
          .doc(comment.id)
          .delete();

      // Remove from local list
      setState(() {
        comments.removeWhere((c) => c.id == comment.id);
        totalComments = totalComments > 0 ? totalComments - 1 : 0;
      });

      // Show success message
      if (mounted) {
        AppDialogs.showSuccessSnackbar(
          context: context,
          message: "Comment deleted successfully!",
        );
      }
    } catch (e) {
      debugPrint("Error deleting comment: $e");
      if (mounted) {
        AppDialogs.showErrorSnackbar(
          context: context,
          message: "Failed to delete comment. Please try again.",
        );
      }
    }
  }
}
