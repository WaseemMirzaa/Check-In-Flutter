import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/notification_modal.dart';

class NotificationService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('USER');

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await usersCollection.doc(userId).get();

      if (!userSnapshot.exists) {
        print('User not found');
        return [];
      }

      List<NotificationModel> notifications = [];

      QuerySnapshot notificationsQuery = await usersCollection
          .doc(userId)
          .collection('notifications')
          .orderBy('time', descending: false)
          .get();

      notifications = notificationsQuery.docs.map((doc) {
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
