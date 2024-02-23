import 'dart:convert';
import 'dart:io';

import 'package:check_in/Services/push_notification_service.dart';
import 'package:check_in/binding.dart';
import 'package:check_in/model/notification_model.dart';
import 'package:check_in/ui/screens/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sizer/sizer.dart';

import 'firebase_options.dart';

List<Map<String, dynamic>> courtlist = [];
late final FirebaseMessaging _messaging;

String? con;
final init = Firebase.initializeApp(
  options: Platform.isIOS ? DefaultFirebaseOptions.currentPlatform : null,
);
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔴🔴🔴🔴🔴firebaseMessagingBackgroundHandler');
  await init;
  // await Firebase.initializeApp();
  await initialize();
  FlutterLocalNotificationsPlugin notification = FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel androidNotificationChannel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  print("notification received in BACKGROUND");
  print(message.data);

  if (message.data.isNotEmpty) {
    print('message is not empty');
    String notificationType = message.data['notificationType'];
    NotificationModel.type = notificationType;
    NotificationModel.docId = message.data['docId'];
    NotificationModel.name = message.data['name'];
    NotificationModel.image = message.data['image'];
    NotificationModel.isGroup = bool.parse(message.data['isGroup']);
    NotificationModel.memberIds = json.decode(message.data['memberIds']);

    // int notificationBadge = getIntAsync(SharedPreferenceKey.NOTIFICATION_BADGE);
    // await setValue(SharedPreferenceKey.NOTIFICATION_BADGE, notificationBadge++);
    // FlutterAppBadger.updateBadgeCount(notificationBadge++);
  }
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await init;

  // if (Platform.isIOS) {
  //   await Firebase.initializeApp(
  //     // name: "check_in",// Removing this name causes exception and show white screen on ios
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  // } else {
  //   await Firebase.initializeApp();
  // }
  await Firebase.initializeApp();
  _messaging = FirebaseMessaging.instance;
  if(Platform.isIOS){
    await _messaging.requestPermission();
  }
  final PushNotificationServices pushNotificationService = PushNotificationServices();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  pushNotificationService.init();
  FCMManager.getFCMToken();

  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // var email = prefs.getString('email');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Widget firstWidget;
    // if (FirebaseAuth.instance.currentUser != null) {
    //   firstWidget = Home();
    // } else {
    //   firstWidget = const StartView();
    // }
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Check In',
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: whiteColor,
          ),
          initialBinding: MyBinding(),
          home: const Splash(),
        );
      },
    );
  }
}
