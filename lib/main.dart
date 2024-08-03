import 'dart:convert';
import 'dart:io';

import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/Services/push_notification_service.dart';
import 'package:check_in/binding.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/model/notification_model.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/test_aid_comp/test_aid_comp.dart';
import 'package:check_in/ui/screens/splash.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'ui/screens/News Feed NavBar/news_feed_onboarding/news_feed_onboarding.dart';

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

final newsFeedController = Get.put(NewsFeedController(NewsFeedService()));


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await init;
  await initialize();

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
  if (Platform.isIOS) {
    await _messaging.requestPermission();
  }
  final PushNotificationServices pushNotificationService = PushNotificationServices();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  pushNotificationService.init();
  FCMManager.getFCMToken();

  //Stripe.publishableKey = 'pk_test_51P9IBQRwQJgokiPYdbWlcZnEpVC6ZDb0B7ZMVPFSJzi0LzPWCSG1kzwnrSscPCH1ZZBzWKoLeapYlZX5QLHBBNKR00HKEkqjkJ';
  Stripe.publishableKey = 'pk_live_51P9IBQRwQJgokiPYvyLG23TCbtFARynKi5dFHmmxmx69GkHZxQm15cmLz8EkHaCAhIpzK9ma2Prr0yQbyF1l6ZpW006am35MWF';
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();
  await FirebaseAppCheck.instance.activate();

  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // var email = prefs.getString('email');

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
       newsFeedController.getMyPosts(); // Fetch posts for the logged-in user
      // newsFeedController.fetchInitialNewsFeed(); // Fetch posts for the logged-in user
    } else {
      newsFeedController.clearMyPosts(); // Clear posts when no user is logged in
      newsFeedController.clearNewsFeeds(); // Clear posts when no user is logged in
    }
  });
  runApp(
      // DevicePreview(
      // enabled: !kReleaseMode,
      // builder: (context) =>
      const MyApp()
      // )
      );
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
        return GestureDetector(
          onTap: (){
            try {
              FocusManager.instance.primaryFocus?.unfocus();
            } catch (e, stacktrace) {
              print('Error in onTap: $e');
              print('Stacktrace: $stacktrace');
              FirebaseCrashlytics.instance.recordError(e, stacktrace);
            }
          },
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Check In',
            builder: DevicePreview.appBuilder,
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: whiteColor,
            ),
            initialBinding: MyBinding(),
            home: const Splash(),
          ),
        );
      },
    );
  }
}
