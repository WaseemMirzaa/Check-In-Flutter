import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/ui/screens/persistent_nav_bar.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';

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
    await Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Home()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: whiteColor,
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
                    style: TextStyle(fontSize: 12, color: blackColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    TempLanguage.villeMarcos,
                    style: TextStyle(
                        fontSize: 16,
                        color: blackColor,
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
