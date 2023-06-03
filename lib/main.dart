import 'dart:io';

import 'package:check_in/ui/screens/login.dart';
import 'package:check_in/ui/screens/persistent_nav_bar.dart';
import 'package:check_in/ui/screens/start.dart';
import 'package:check_in/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'ui/screens/History.dart';
import 'firebase_options.dart';

String? con;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(Platform.isIOS){
    await Firebase.initializeApp(
      // name: "check_in",// Removing this name causes exception and show white screen on ios
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }else {
    await Firebase.initializeApp();
  }
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // var email = prefs.getString('email');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Widget firstWidget;
    if (FirebaseAuth.instance.currentUser != null) {
      firstWidget = Home();
    } else {
      firstWidget = const StartView();
    }
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Check In',
          theme: ThemeData(scaffoldBackgroundColor: whiteColor),
          home: firstWidget,
        );
      },
    );
  }
}
