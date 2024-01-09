import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/notification_modal.dart';

class NotificationService{
  final CollectionReference notificationsCollection =
      FirebaseFirestore.instance.collection('notifications');

  Future<List<NotificationModel>> getNotifications() async {
    try {
      QuerySnapshot querySnapshot = await notificationsCollection
          .orderBy('time', descending: false)
          .get();

      List<NotificationModel> notifications = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return NotificationModel(
          body: data['body'] ?? '',
          image: data['image'] ?? '',
          isRead: data['isRead'] ?? false,
          time: (data['time'] as Timestamp).toDate(),
          title: data['title'] ?? '',
          type: data['type'] ?? '',
        );
      }).toList();

      return notifications;
    } catch (e) {
      // Handle errors
      print('Error fetching notifications: $e');
      return [];
    }
  }

}