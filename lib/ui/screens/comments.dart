import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CommentsScreen extends StatefulWidget {
  final String courtName;
  final bool isPremium;

  const CommentsScreen({
    super.key,
    required this.courtName,
    this.isPremium = false,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();

  // Sample comments data - replace with actual data
  List<CommentData> comments = List.generate(
    6,
    (index) => CommentData(
      userName: "Benjamin",
      userImage: AppAssets.LOGO_NEW,
      commentText:
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry.",
      timeAgo: "2 hours ago",
    ),
  );

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
                  "1011 Comments",
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Container(
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
                          image: DecorationImage(
                            image: AssetImage(comment.userImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.userName,
                              style: TextStyle(
                                fontFamily: TempLanguage.poppins,
                                fontSize: 16,
                                color: appBlackColor,
                                fontWeight: FontWeight.w600,
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Write a Comment Button
          if (widget.isPremium)
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
                    "Share your thoughts about this court",
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

  void _submitComment(String commentText) {
    // Add the new comment to the list
    setState(() {
      comments.insert(
        0,
        CommentData(
          userName: "You", // Replace with actual user name
          userImage: AppAssets.LOGO_NEW, // Replace with actual user image
          commentText: commentText,
          timeAgo: "Just now",
        ),
      );
    });

    // Show success message
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

    // Here you would typically send the comment to your backend
    // Example: await commentService.postComment(widget.courtName, commentText);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

class CommentData {
  final String userName;
  final String userImage;
  final String commentText;
  final String timeAgo;

  CommentData({
    required this.userName,
    required this.userImage,
    required this.commentText,
    required this.timeAgo,
  });
}
