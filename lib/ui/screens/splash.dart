import 'package:check_in/ui/screens/persistent_nav_bar.dart';
import 'package:check_in/ui/screens/start.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() async {
    Widget firstWidget;
    if (FirebaseAuth.instance.currentUser != null) {
      firstWidget = Home();
    } else {
      firstWidget = const StartView();
    }
    await Future.delayed(Duration(seconds: 1), () {});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => firstWidget));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Image.asset(
          "assets/images/Green minimalist speed check logo (1).png",
          scale: 3,
        ),
      ),
    );
  }
}
