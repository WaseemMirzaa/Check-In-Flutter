import 'package:checkinmod/ui/screens/player.dart';
import 'package:checkinmod/utils/gaps.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

class PlayersView extends StatefulWidget {
  const PlayersView({super.key});

  @override
  State<PlayersView> createState() => _PlayersViewState();
}

class _PlayersViewState extends State<PlayersView> {
  var list = [
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            padding: EdgeInsets.only(left: 10),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: SizedBox(
              height: 2.1.h,
              width: 2.9.w,
              child: Image.asset(
                'assets/images/Path 6.png',
              ),
            )),
        centerTitle: true,
        title: const Text(
          'Players',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            color: Color(0xff000000),
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.right,
          softWrap: false,
        ),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'Players at this court',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    color: Color(0xff007a33),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                  softWrap: false,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GestureDetector(
                              onTap: () {
                                pushNewScreen(context,
                                    screen: const PlayerScreen(),
                                    withNavBar: false);
                              },
                              child: Container(
                                height: 115,
                                decoration: BoxDecoration(
                                  color: const Color(0xffffffff),
                                  borderRadius: BorderRadius.circular(6.0),
                                  boxShadow: [
                                    const BoxShadow(
                                      color: Color(0x29000000),
                                      offset: Offset(0, 1),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Container(
                                        height: 85,
                                        width: 85,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.asset(
                                          'assets/images/player.png',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    const Text.rich(TextSpan(
                                        text: 'Benjamin\n',
                                        style: TextStyle(
                                          height: 1.5,
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                          color: Color(0xff000000),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '@Alexhales\n',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 9,
                                              color: Color(0xff9f9f9f),
                                            ),
                                          ),
                                          TextSpan(
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 10,
                                              color: Color(0xff007a33),
                                              height: 1.7,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Home Court :',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' Morse Kelley Park ',
                                                style: TextStyle(
                                                  color: Color(0xff9f9f9f),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ]))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Container(
                              height: 1,
                              color: const Color(0xff9f9f9f),
                            ),
                          )
                        ],
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
