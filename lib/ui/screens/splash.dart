import 'dart:convert';

import 'package:check_in/Services/user_services.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/ui/screens/Messages%20NavBar/Chat/chat_screen.dart';
import 'package:check_in/ui/screens/onboarding.dart';
import 'package:check_in/ui/screens/persistent_nav_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/Messages/chat_controller.dart';
import '../../model/notification_model.dart';
import '../../utils/colors.dart';

import 'News Feed NavBar/open_post/open_post.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  UserController userController = Get.put(UserController(UserServices()));
  final ChatController chatcontroller = Get.find<ChatController>();

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(seconds: 6),(){
    //   Navigator.push(context, MaterialPageRoute(builder: (context)=>MyHomePage()));
    // });

    _navigatetohome();
  }

  _navigatetohome() async {
    await userController.getUserData();

    // Check if onboarding has been completed
    final prefs = await SharedPreferences.getInstance();
    final bool onboardingCompleted =
        prefs.getBool('onboarding_completed') ?? false;

    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    } else {
      await Future.delayed(const Duration(milliseconds: 1500), () {
        if (onboardingCompleted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const Home()));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const OnboardingScreen()));
        }
      });
    }
  }

  void _handleMessage(RemoteMessage message) {
    /// Navigate to detail
    chatcontroller.docId.value = message.data['docId'];
    chatcontroller.name.value = message.data['name'];
    chatcontroller.isgroup = bool.parse(message.data['isGroup']);
    chatcontroller.image.value = message.data['image'];
    List<dynamic> memberIdsList = jsonDecode(message.data['memberIds']);
    chatcontroller.memberId.value = memberIdsList;

    message.data['notificationType'] == 'newsFeed'
        ? Get.to(() => OpenPost(
              postId: message.data['docId'],
            ))
        : Get.to(() => ChatScreen());

    String notificationType = message.data['notificationType'];
    NotificationModel notificationModel = NotificationModel();
    notificationModel.type = notificationType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appWhiteColor,
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                AppAssets.BASKETBALL_BRO,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            height: MediaQuery.of(context).size.height / 2,
            child: FractionallySizedBox(
              alignment: Alignment.topCenter,
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox.fromSize(size: const Size.fromHeight(20)),
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      AppAssets.LOGO_NEW,
                      scale: 1,
                    ),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    TempLanguage.poweredBy,
                    style: TextStyle(fontSize: 12, color: appBlackColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    TempLanguage.villeMarcos,
                    style: TextStyle(
                        fontSize: 16,
                        color: appBlackColor,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
