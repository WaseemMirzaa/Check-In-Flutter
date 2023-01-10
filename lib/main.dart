import 'package:checkinmod/ui/screens/login.dart';
import 'package:checkinmod/ui/screens/start.dart';
import 'package:checkinmod/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:sizer/sizer.dart';

import 'ui/screens/History.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Check In',
          theme: ThemeData(scaffoldBackgroundColor: whiteColor),
          home: StartView(),
        );
      },
    );
  }
}
