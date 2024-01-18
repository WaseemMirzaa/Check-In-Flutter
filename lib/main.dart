import 'dart:io';

import 'package:check_in/Services/push_notification_service.dart';
import 'package:check_in/binding.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/model/notification_model.dart';
import 'package:check_in/ui/screens/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sizer/sizer.dart';

import 'firebase_options.dart';

List<Map<String, dynamic>> courtlist = [];

String? con;

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await initialize();
  FlutterLocalNotificationsPlugin notification =
      FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel androidNotificationChannel =
      const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );
  print("notification received in BACKGROUND");

  if (message.data.isNotEmpty) {
    String notificationType = message.data['notificationType'];
    NotificationModel.type = notificationType;
    NotificationModel.transactionId = message.data['transactionId'];
    NotificationModel.peer = message.data['peer'];

    int notificationBadge = getIntAsync(SharedPreferenceKey.NOTIFICATION_BADGE);
    await setValue(SharedPreferenceKey.NOTIFICATION_BADGE, notificationBadge++);
    FlutterAppBadger.updateBadgeCount(notificationBadge++);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS) {
    await Firebase.initializeApp(
      // name: "check_in",// Removing this name causes exception and show white screen on ios
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }
  final PushNotificationServices pushNotificationService =
      PushNotificationServices();
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
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
            scaffoldBackgroundColor: whiteColor,
          ),
          initialBinding: MyBinding(),
          home: const Splash(),
        );
      },
    );
  }
}
