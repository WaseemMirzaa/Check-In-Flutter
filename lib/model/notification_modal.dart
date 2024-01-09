class NotificationModel {
  final String body;
  final String image;
  final bool isRead;
  final DateTime time;
  final String title;
  final String type;

  NotificationModel({
    required this.body,
    required this.image,
    required this.isRead,
    required this.time,
    required this.title,
    required this.type,
  });
}
