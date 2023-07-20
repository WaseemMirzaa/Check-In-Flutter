import 'package:check_in/ui/screens/persistent_nav_bar.dart';
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
    firstWidget = const Home();
    // if (FirebaseAuth.instance.currentUser != null) {
    //   firstWidget = const Home();
    // } else {
    //   firstWidget = const StartView();
    // }
    await Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => firstWidget));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                "assets/images/basketball-bro.png",
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
                      "assets/images/logo-new.png",
                      scale: 1,
                    ),
                  ),
                  const SizedBox(height: 0),
                  const Text(
                    'Powered by',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ville Marcos LLC',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
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
