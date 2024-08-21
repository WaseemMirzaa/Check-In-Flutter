import 'dart:convert';
import 'package:check_in/Services/message_service.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/news_feed_screen.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/open_post/open_post.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../controllers/Messages/chat_controller.dart';
import '../model/notification_model.dart';
import 'package:http/http.dart' as http;

import '../ui/screens/ Messages NavBar/Chat/chat_screen.dart';

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

      // print('Step 2');
      // handle received push notification messages
      // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      //   print('Received message: ${message.notification?.title}');
      //   print('Received message: ${message.notification?.body}');
      //   if (message.notification?.body != null) {
      //     notificationsPlugin.show(
      //         1,
      //         message.notification?.title,
      //         message.notification?.body,
      //         NotificationDetails(
      //             android: AndroidNotificationDetails(
      //               channel.id,
      //               channel.name,
      //               importance: Importance.high,
      //               color: Colors.blue,
      //               playSound: true,
      //               icon: '@mipmap/ic_launcher',
      //             ),
      //             iOS: IOSNotificationDetails(
      //               presentSound: true,
      //               presentAlert: true,
      //               presentBadge: true,
      //             )));
      //
      //     int notificationBadge = getIntAsync(SharePreferencesKey.NOTIFICATION_BADGE);
      //     await setValue(SharePreferencesKey.NOTIFICATION_BADGE, notificationBadge++);
      //     FlutterAppBadger.updateBadgeCount(notificationBadge++);
      //
      //   }
      // });

      // print('Step 3');
      // FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      //   log("data background is ${message.data}");
      //   // int notificationBadge = 0;
      //   if (message.data.isNotEmpty) {
      //     //RemoteNotification? notification = message.notification;
      //     String notificationType = message.data['notificationType'];
      //     NotificationModel.type = notificationType;
      //     NotificationModel.docId = message.data['docId'];
      //     NotificationModel.name = message.data['name'];
      //     NotificationModel.image = message.data['image'];
      //     NotificationModel.isGroup = bool.parse(message.data['isGroup']);
      //     NotificationModel.memberIds = json.decode(message.data['memberIds']);
      //   }
      //   notificationsPlugin.show(
      //       1,
      //       message.notification?.title,
      //       message.notification?.body,
      //       NotificationDetails(
      //           android: AndroidNotificationDetails(
      //             channel.id,
      //             channel.name,
      //             importance: Importance.high,
      //             color: Colors.blue,
      //             playSound: true,
      //             icon: '@mipmap/ic_launcher',
      //             channelShowBadge: true,
      //           ),
      //           iOS: const DarwinNotificationDetails(
      //             presentSound: true,
      //             presentAlert: true,
      //             presentBadge: true,
      //             // badgeNumber: notificationBadge
      //           )));
      // });

      print('🟢🟢🟢🟢🟢 adding listener');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('🟢🟢🟢🟢🟢 onMessageListened');

        // int notificationBadge = 0;
        if (message.data.isNotEmpty) {
          //RemoteNotification? notification = message.notification;
          String notificationType = message.data['notificationType'];
          NotificationModel.type = notificationType;
          NotificationModel.docId = message.data['docId'];
          NotificationModel.name = message.data['name'];
          NotificationModel.image = message.data['image'];
          NotificationModel.isGroup = bool.parse(message.data['isGroup']);
          NotificationModel.memberIds = json.decode(message.data['memberIds']);

          // print("notification type");
          // print(NotificationModel.type);
          // notificationBadge = getIntAsync(
          //     SharedPreferenceKey.NOTIFICATION_BADGE,
          //     defaultValue: 0);
          // await setValue(
          //     SharedPreferenceKey.NOTIFICATION_BADGE, notificationBadge++);
          // FlutterAppBadger.updateBadgeCount(notificationBadge++);
        }
        if (chatcontroller.docId.value != NotificationModel.docId) {
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
        //....

        // }
        // }
      });

      // FirebaseMessaging.onBackgroundMessage((message) => null)

      // handle notification messages when the app is in the background or terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        print('🟢🟢🟢🟢🟢 onMessageOpenedApp');

        //.............................
        chatcontroller.docId.value = NotificationModel.docId;
        chatcontroller.name.value = NotificationModel.name;
        chatcontroller.isgroup = NotificationModel.isGroup;
        chatcontroller.image.value = NotificationModel.image;
        chatcontroller.memberId.value = NotificationModel.memberIds;
        //.............................

        NotificationModel.type == 'newsFeed' ? Get.to(()=>OpenPost(postId: NotificationModel.docId,))  : Get.to(() => ChatScreen());

        // print('Opened message: ${message.notification?.title}');
        // handle the opened message here, for example by navigating to a specific screen
        String notificationType = message.data['notificationType'];
        NotificationModel.type = notificationType;
        // print("notification types");
        // print(NotificationModel.type);
        // if (notificationType == PushNotificationType.msg) {
        //   print('Step 4');
        //   String transac = message.data['transactionId'];
        //   UserModel userModel =
        //       await userService.userByUid(message.data['peer']);
        //   print("peer id");
        //   print(userModel.uid);
        //   navBarController.controller.index = 1;
        //   navBarController.currentIndex.value = 1;
        //   NotificationModel.transactionId = message.data['transactionId'];
        //   NotificationModel.peer = message.data['peer'];
        //   Get.to(() => ChatPage(
        //       arguments:
        //           ChatPageArguments(peer: userModel, transactionId: transac)));
        // } else {
        //   print('Step 5');
        //   navBarController.controller.index = 3;
        //   navBarController.currentIndex.value = 3;
        //   Get.to(() => Home());
        // }
        // print("2");
        // print(NotificationModel.type);
      });
      //

      // print('Step 6');
      await notificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (payload) async {
        print('🟢🟢🟢🟢🟢 onDidReceiveNotificationResponse');

        // print("notification type is");
        // print(NotificationModel.transactionId);
        //.............................
        chatcontroller.docId.value = NotificationModel.docId;
        chatcontroller.name.value = NotificationModel.name;
        chatcontroller.isgroup = NotificationModel.isGroup;
        chatcontroller.image.value = NotificationModel.image;
        chatcontroller.memberId.value = NotificationModel.memberIds;
        //.............................

        NotificationModel.type == 'newsFeed' ? Get.to(()=>OpenPost(postId: NotificationModel.docId,)) : Get.to(() => ChatScreen());

        // if (NotificationModel.type == PushNotificationType.msg) {
        //   print('Step 7');
        //   String transac = NotificationModel.transactionId;
        //   UserModel userModel =
        //       await userService.userByUid(NotificationModel.peer);
        //   navBarController.controller.index = 1;
        //   navBarController.currentIndex.value = 1;
        //   Get.to(() => ChatPage(
        //       arguments:
        //           ChatPageArguments(peer: userModel, transactionId: transac)));
        // } else {
        //   print('Step 8');
        //   navBarController.controller.index = 3;
        //   navBarController.currentIndex.value = 3;
        //   Get.to(() => Home());
        // }
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
