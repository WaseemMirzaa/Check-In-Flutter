import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:flutter/material.dart';

void showReportDialog(BuildContext context, String postId, String reportedBy) {
  TextEditingController reasonController = TextEditingController();
  NewsFeedController newsFeedController = NewsFeedController(NewsFeedService());

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Report Post'),
      content: TextField(
        controller: reasonController,
        decoration: const InputDecoration(hintText: "Reason for reporting"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            String reason = reasonController.text.trim();
            if (reason.isNotEmpty) {
              await newsFeedController.reportPost(postId, reportedBy, reason);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post reported successfully')));
            }
          },
          child: const Text('Report'),
        ),
      ],
    ),
  );
}
