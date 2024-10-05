import 'dart:convert';
import 'package:check_in/Services/message_service.dart';
import 'package:check_in/ui/screens/Messages%20NavBar/Chat/chat_screen.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/open_post/open_post.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../controllers/Messages/chat_controller.dart';
import '../model/notification_model.dart';
import 'package:http/http.dart' as http;


final ChatController chatcontroller = Get.find<ChatController>();

class FCMManager {
  static String? fcmToken;

  static Future<String> getFCMToken() async {
    await FirebaseMessaging.instance.requestPermission();
    return await FirebaseMessaging.instance.getToken() ?? '';
  }
}

FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

late AndroidNotificationChannel channel;

const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('appicon');
DarwinInitializationSettings iosInitializationSettings = const DarwinInitializationSettings();

final InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
  iOS: iosInitializationSettings,
);

class PushNotificationServices {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    print('🟢🟢🟢🟢🟢 init');

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    print('🟢🟢🟢🟢🟢 plugin resolved');
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🟢🟢🟢🟢🟢 setForegroundNotificationPresentationOptions');

    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    print('🟢🟢🟢🟢🟢 AndroidNotificationChannel');

    // request permission to receive push notifications
    NotificationSettings settings = await _fcm.requestPermission();
    print('🟢🟢🟢🟢🟢 NotificationSettings');

    // print('Step 1');
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('🟢🟢🟢🟢🟢 authorized');
      print('🟢🟢🟢🟢🟢 adding listener');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('🟢🟢🟢🟢🟢 onMessageListened');

        NotificationModel notificationModel = NotificationModel();
        // int notificationBadge = 0;
        if (message.data.isNotEmpty) {
          //RemoteNotification? notification = message.notification;
          String notificationType = message.data['notificationType'];
          notificationModel.type = notificationType;
          notificationModel.docId = message.data['docId'];
          notificationModel.name = message.data['name'];
          notificationModel.image = message.data['image'];
          notificationModel.isGroup = bool.parse(message.data['isGroup']);
          notificationModel.memberIds = json.decode(message.data['memberIds']);

        }
        if (chatcontroller.docId.value != notificationModel.docId) {
          notificationsPlugin.show(
              1,
              message.notification?.title,
              message.notification?.body,
              NotificationDetails(
                  android: AndroidNotificationDetails(
                    channel.id,
                    channel.name,
                    importance: Importance.high,
                    color: Colors.blue,
                    playSound: true,
                    icon: 'appicon',
                    channelShowBadge: true,
                  ),
                  iOS: const DarwinNotificationDetails(
                    presentSound: true,
                    presentAlert: true,
                    presentBadge: true,
                    // badgeNumber: notificationBadge
                  )));
        }
      });

      // handle notification messages when the app is in the background or terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        print('🟢🟢🟢🟢🟢 onMessageOpenedApp');

        chatcontroller.docId.value = message.data['docId'];
        chatcontroller.name.value = message.data['name'];
        chatcontroller.isgroup = bool.parse(message.data['isGroup']);
        chatcontroller.image.value = message.data['image'];
        List<dynamic> memberIdsList = jsonDecode(message.data['memberIds']);
        chatcontroller.memberId.value = memberIdsList;

        message.data['notificationType'] == 'newsFeed'
            ? Get.to(() => OpenPost(postId: message.data['docId'],))
            : Get.to(() => ChatScreen());

        String notificationType = message.data['notificationType'];
        NotificationModel notificationModel = NotificationModel();
        notificationModel.type = notificationType;
      });

      await notificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (payload) async {
        print('🟢🟢🟢🟢🟢 onDidReceiveNotificationResponse');
        NotificationModel notificationModel = NotificationModel();
        chatcontroller.docId.value = notificationModel.docId;
        chatcontroller.name.value = notificationModel.name;
        chatcontroller.isgroup = notificationModel.isGroup;
        chatcontroller.image.value = notificationModel.image;
        chatcontroller.memberId.value = notificationModel.memberIds;

        notificationModel.type == 'newsFeed'
            ? Get.to(() => OpenPost(postId: notificationModel.docId,))
            : Get.to(() => ChatScreen());

      });
    }
  }
}

Future<void> sendNotification(
    {required List<dynamic> token,
    required String notificationType,
    required String title,
    required String msg,
    required String docId,
    required bool isGroup,
    required String name,
    required String image,
    required List memberIds,
    required String uid}) async {
  var completeUrl = 'https://us-central1-check-in-7ecd7.cloudfunctions.net/sendNotification';
  final headers = {'Content-Type': 'application/json'};
  // Loop through each token and send individual notifications
  for (final userToken in token) {
    final body = jsonEncode({
      'token': userToken, // Use each token in the loop
      'title': title,
      'body': msg,
      'notificationType': notificationType,
      'docId': docId,
      'name': name,
      'isGroup': isGroup,
      'image': image,
      'memberIds': memberIds,
    });

    try {
      final response = await http.post(Uri.parse(completeUrl), headers: headers, body: body);
      if (response.statusCode == 200) {
        print('🟡🟡🟡Notification sent');
      } else {
        print('🔴🔴🔴Error sending notification: ${response.statusCode}');
        MessageService.removeDeviceToken(uid, userToken);
      }
    } catch (e) {
      print('🔴🔴🔴Error sending notification: $e');
    }
  }
}
