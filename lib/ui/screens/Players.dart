// ignore_for_file: must_be_immutable

import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/ui/screens/player.dart';
import 'package:check_in/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../core/constant/constant.dart';

class PlayersView extends StatefulWidget {
  final LatLng courtLatLng;
  String courtName;
  bool isCheckedIn = false;
  PlayersView(
      {super.key,
      required this.courtLatLng,
      required this.courtName,
      required this.isCheckedIn});

  @override
  State<PlayersView> createState() => _PlayersViewState();
}

class User {
  final String name;
  final String email;
  final String about;
  final String court;
  final String photoUrl;
  bool? isVerified;

  User(
      {required this.name,
      required this.email,
      required this.about,
      required this.court,
      required this.photoUrl,
      this.isVerified});
}

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LatLng court;
  UserService({required this.court});
  Stream<List<User>> get users {
    return _firestore.collection(Collections.USER).snapshots().map((snapshot) {
      return snapshot.docs
          .where((d) =>
              // d.get("uid") != FirebaseAuth.instance.currentUser!.uid &&
              d.get(UserKey.CHECKED_IN) == true &&
              d.get(CourtKey.COURT_LAT) == court.latitude &&
              d.get(CourtKey.COURT_LNG) == court.longitude)
          .map((doc) => User(
                name: doc.data()[UserKey.USER_NAME],
                email: doc.data()[UserKey.EMAIL],
                about: doc.data()[UserKey.ABOUT_ME] ?? "",
                court: doc.data()[UserKey.HOME_COURT] ?? "",
                photoUrl: doc.data()[UserKey.PHOTO_URL] ?? "",
                isVerified: doc.data()[UserKey.IS_VERIFIED] ?? true,
              ))
          .toList();
    });
  }

  Stream<List<User>> get emptyUsers {
    return Stream.fromIterable([<User>[]]);
  }
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

  int numberOfPLayers = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getNumberOfPlayers() async {
    final snapshot = await _firestore.collection(Collections.USER).get();
    final users = snapshot.docs.where((doc) =>
        doc.get(UserKey.CHECKED_IN) == true &&
        doc.get(CourtKey.COURT_LAT) == widget.courtLatLng.latitude &&
        doc.get(CourtKey.COURT_LNG) == widget.courtLatLng.longitude);
    numberOfPLayers = users.length;
    setState(() {});
    return users.length;
  }

  @override
  void initState() {
    getNumberOfPlayers();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhiteColor,
      appBar: AppBar(
        backgroundColor: appWhiteColor,
        leading: IconButton(
            padding: const EdgeInsets.only(left: 10),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: SizedBox(
              height: 2.1.h,
              width: 2.9.w,
              child: Image.asset(
                AppAssets.LEFT_ARROW,
              ),
            )),
        centerTitle: true,
        title: Text(
          '${TempLanguage.player}s',
          style: TextStyle(
            fontFamily: TempLanguage.poppins,
            fontSize: 20,
            color: appBlackColor,
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
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  widget.courtName ?? "",
                  style: TextStyle(
                    fontFamily: TempLanguage.poppins,
                    fontSize: 15,
                    color: appGreenColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                  softWrap: false,
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "${TempLanguage.numOfPlayers}$numberOfPLayers",
                  style: TextStyle(
                    fontFamily: TempLanguage.poppins,
                    fontSize: 15,
                    // color: Color(0xff007a33),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                  softWrap: false,
                ),
              ),
              // const Padding(
              //   padding: EdgeInsets.only(top: 20),
              //   child: Text(
              //     'Players at this court',
              //     style: TextStyle(
              //       fontFamily: 'Poppins',
              //       fontSize: 15,
              //       color: Color(0xff007a33),
              //       fontWeight: FontWeight.w500,
              //     ),
              //     textAlign: TextAlign.right,
              //     softWrap: false,
              //   ),
              // ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder<List<User>>(
                stream: widget.isCheckedIn
                    ? UserService(court: widget.courtLatLng).users
                    : UserService(court: widget.courtLatLng).emptyUsers,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final users = snapshot.data;
                  return Expanded(
                    child: ListView.builder(
                        itemCount: users!.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: GestureDetector(
                                  onTap: () {
                                    // pushNewScreen(context,
                                    //     screen: const PlayerScreen(),
                                    //     withNavBar: false);
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PlayerScreen(user: user)));
                                  },
                                  child: Container(
                                    height: 115,
                                    decoration: BoxDecoration(
                                      color: appWhiteColor,
                                      borderRadius: BorderRadius.circular(6.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: blackTranslucentColor,
                                          offset: const Offset(0, 1),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: SizedBox(
                                            width: 26.w,
                                            child: Stack(
                                              alignment: Alignment.bottomRight,
                                              clipBehavior: Clip.none,
                                              children: [
                                                Container(
                                                  height: 13.5.h,
                                                  width: 13.5.h,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: user.photoUrl == ""
                                                        ? Border.all(width: 2, color: appGreenColor)
                                                        : null,
                                                  ),
                                                  child: ClipOval(
                                                    child: user.photoUrl != ""
                                                        ? Image.network(
                                                            user.photoUrl,
                                                            fit: BoxFit.fill,
                                                            loadingBuilder:
                                                                (context, child,
                                                                    loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null) {
                                                                return child;
                                                              }
                                                              return const Center(
                                                                child:
                                                                    CircularProgressIndicator(), // You can replace this with any loading indicator you prefer.
                                                              );
                                                            },
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Image
                                                                  .asset(
                                                                AppAssets.LOGO_NEW, // The local placeholder image
                                                                fit:
                                                                    BoxFit.fill,
                                                              );
                                                            },
                                                          )
                                                        : Image.asset(
                                                            AppAssets.LOGO_NEW,
                                                            fit: BoxFit.fill,
                                                          ),
                                                  ),
                                                ),
                                                users[index].isVerified == false
                                                    ? const SizedBox()
                                                    : Align(
                                                        alignment: Alignment.bottomRight,
                                                        child: Container(
                                                          height: 5.h,
                                                          width: 10.w,
                                                          decoration: const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              image: DecorationImage(
                                                                  image: AssetImage(
                                                                      AppAssets.INSTAGRAM_VERIFICATION))),
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Text.rich(
                                          TextSpan(
                                              text: "${user.name}\n",
                                              style: TextStyle(
                                                height: 1.5,
                                                fontFamily:
                                                    TempLanguage.poppins,
                                                fontSize: 13,
                                                color: appBlackColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      "@${user.email.substring(0, user.email.indexOf('@'))}\n",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        TempLanguage.poppins,
                                                    fontSize: 9,
                                                    color: silverColor,
                                                  ),
                                                ),
                                                TextSpan(
                                                  style: TextStyle(
                                                    fontFamily:
                                                        TempLanguage.poppins,
                                                    fontSize: 10,
                                                    color: appGreenColor,
                                                    height: 1.7,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: '${TempLanguage.homeCourt} :',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: user.court == ""
                                                          ? ' ----'
                                                          : user.court,
                                                      style: TextStyle(
                                                        color:
                                                            silverColor,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Container(
                                  height: 1,
                                  color: silverColor,
                                ),
                              ),
                            ],
                          );
                        }),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
