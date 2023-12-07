import 'dart:io';

import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/add_home_court.dart';
import 'package:check_in/ui/widgets/common_button.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart' as nbutils;
import 'package:percent_indicator/circular_percent_indicator.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/gaps.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

int? totalCount = 10;

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> get users {
    return _firestore.collection('USER').snapshots().map((snapshot) {
      return snapshot.docs
          .where((d) => d.get("uid") == FirebaseAuth.instance.currentUser!.uid)
          .map((doc) => UserModel(
                userName: doc.data()['user name'],
                email: doc.data()['email'],
                aboutMe: doc.data()['about me'] ?? "",
                homeCourt: doc.data()['home court'] ?? "",
                photoUrl: doc.data()['photoUrl'] ?? "",
                isVerified: doc.data()['isVerified'],
                goldenCheckin: doc.data()['goldenCheckin'] ?? 0,
              ))
          .toList();
    });
  }
}

Future<int> getGoldenLocationsCount() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('goldenLocations') // Replace with your collection name
        .get();

    int count = querySnapshot.size;
    return count;
  } catch (e) {
    print("Error getting golden locations count: $e");
    return 0; // Return 0 in case of an error
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserController userController = Get.put(UserController());

  // UserModel userd = UserModel();
  bool isVerified = false;
  getUser() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("USER")
        .doc(userController.userModel.value.uid)
        .get();
    UserModel currentUser =
        UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
    userController.userModel.value = currentUser;
    setState(() {});
  }

  File? _imageFile;
  String? _downloadUrl;

  Future<void> _selectImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      final storage = FirebaseStorage.instance;
      final ref = storage
          .ref()
          // .child('profile/${DateTime.now().millisecondsSinceEpoch}');
          .child('profile/${FirebaseAuth.instance.currentUser?.uid ?? ""}');
      final uploadTask = ref.putFile(_imageFile!);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _downloadUrl = downloadUrl;
      });

      final firestore = FirebaseFirestore.instance;
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await firestore
          .collection('USER')
          .doc(userId)
          .update({'photoUrl': downloadUrl});
    }
  }

  void initializeData() async {
    // Example: Fetching the total count asynchronously
    try {
      totalCount = await getGoldenLocationsCount();
    } catch (e) {
      print("Error fetching data: $e");
      // Handle the error as needed
    }

    // Update the state after the asynchronous work is done
    if (mounted) {
      setState(() {});
    }
  }

  String mail = FirebaseAuth.instance.currentUser?.email as String;
  // String mail = FirebaseAuth.instance.currentUser?.email ?? "";
  bool tapped = false;
  String? aboutMe;

  @override
  void initState() {
    getUser();
    // UserService();
    initializeData();
    // print("Siuuu${totalCount}");
    // TODO: implement initState

    super.initState();
  }

  sendEmail(String name, String email, String homeCourt) async {
    const subject = "Application for Check In Hoops Profile Verification";

    var emailContent = '''
    
    Dear Support Team,
    
    I would like to apply for the profile verification:
    
    - My Name: $name
    - My Email: $email
    - My Home Court: $homeCourt
    - Description: 
    
    
    Best regards,
    $name
    ''';

    final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@checkinhoops.net',
      // Replace with the recipient's email address for reporting
      query: 'subject=$subject&body=$emailContent',
    );

    // if (await canLaunchUrl(_emailLaunchUri)) {
    try {
      await launchUrl(_emailLaunchUri);
    } catch (e) {
      nbutils.toast("Could not launch email.");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // return GetBuilder<UserController>(builder: (userController) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: whiteColor,
        title: poppinsText("Profile", 20, FontWeight.bold, blackColor),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child:
              // if (!snapshot.hasData) {
              //   return const Center(child: CircularProgressIndicator());
              // }
              // final users = snapshot.data;
              !userController.userModel.value.uid.isEmptyOrNull
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            verticalGap(3.h),
                            SizedBox(
                              width: 35.9.w,
                              //   padding: EdgeInsets.all(10),
                              child: Stack(
                                //  clipBehavior: Clip.antiAliasWithSaveLayer,
                                alignment: Alignment.bottomCenter,
                                children: [
                                  GestureDetector(
                                      onTap: _selectImage,
                                      child: (_downloadUrl != null)
                                          ? Container(
                                              height: 20.h,
                                              width: 35.h,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          _downloadUrl
                                                              as String),
                                                      fit: BoxFit.fill)))
                                          : (!userController.userModel.value
                                                  .photoUrl.isEmptyOrNull)
                                              ? Container(
                                                  height: 20.h,
                                                  width: 35.h,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                          image: NetworkImage(
                                                              userController
                                                                      .userModel
                                                                      .value
                                                                      .photoUrl ??
                                                                  ""),
                                                          fit: BoxFit.fill)))
                                              : Container(
                                                  height: 20.h,
                                                  width: 35.h,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          width: 2,
                                                          color: greenColor),
                                                      image: const DecorationImage(
                                                          image: AssetImage(
                                                              'assets/images/logo-new.png'),
                                                          fit: BoxFit.fill)),
                                                )),
                                  if (userController
                                              .userModel.value.isVerified ==
                                          null ||
                                      userController
                                              .userModel.value.isVerified ==
                                          true)
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        height: 5.5.h,
                                        width: 12.1.w,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/instagram-verification-badge.png"))),
                                      ),
                                    )
                                  else
                                    const SizedBox(),
                                ],
                              ),
                            ),
                            verticalGap(0.5.h),
                            poppinsText(
                                // FirebaseAuth.instance.currentUser?.displayName
                                //     as String,
                                userController.userModel.value.userName ?? "",
                                32,
                                FontWeight.bold,
                                blackColor),
                            // poppinsText(
                            //     "@${userController.userModel.value.email.substring(0, userController.userModel.value.email.indexOf('@'))}",
                            //     12,
                            //     FontWeight.normal,
                            //     blackColor),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 216, 227, 242),
                                      width: 8.0,
                                    ),
                                  ),
                                  child: Obx(() => CircularPercentIndicator(
                                        radius: 55.0,
                                        lineWidth: 8.0,
                                        animation: true,
                                        percent: ((userController.userModel
                                                    .value.goldenCheckin ??
                                                0) /
                                            (totalCount ?? 10)),
                                        center: Text(
                                          "${userController.userModel.value.goldenCheckin}\nCheck ins",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        circularStrokeCap:
                                            CircularStrokeCap.round,
                                        progressColor:
                                            Color.fromARGB(255, 255, 206, 26),
                                      )),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    poppinsText("Golden\nCourt", 22,
                                        FontWeight.bold, blackColor),
                                    poppinsText(
                                        "${userController.userModel.value.goldenCheckin} Check ins",
                                        12,
                                        FontWeight.normal,
                                        blackColor),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Column(
                          children: [
                            poppinsText("Home Court", 14, semiBold, greenColor),
                            verticalGap(0.8.h),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      poppinsText(
                                          (userController.userModel.value
                                                  .homeCourt.isEmptyOrNull)
                                              ? ""
                                              : userController.userModel.value
                                                      .homeCourt ??
                                                  "",
                                          14,
                                          semiBold,
                                          blackColor),
                                      InkWell(
                                        onTap: () {
                                          pushNewScreen(context,
                                              screen: const AddHomeCourt(),
                                              withNavBar: false);
                                        },
                                        child: SizedBox(
                                          height: 2.3.h,
                                          width: 4.47.w,
                                          child: Image.asset(
                                              "assets/images/Icon feather-map-pin.png"),
                                        ),
                                      )
                                    ],
                                  ),
                                  verticalGap(1.3.h),
                                  Container(
                                    height: 1,
                                    color: greyColor,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 3.5.h,
                            ),
                            Column(
                              // alignment: Alignment.topCenter,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                    left: 30,
                                    right: 30,
                                  ),
                                  height: 20.h,
                                  decoration: BoxDecoration(
                                    color: whiteColor,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        blurRadius: 1,
                                        //   spreadRadius: -12,
                                        offset: const Offset(0,
                                            -3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 0.5.h,
                                        decoration: BoxDecoration(
                                            color: greenColor,
                                            borderRadius:
                                                const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(5),
                                                    bottomRight:
                                                        Radius.circular(5))),
                                      ),
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          poppinsText("About me", 14, semiBold,
                                              blackColor),
                                          InkWell(
                                            onTap: () => setState(() {
                                              tapped = !tapped;
                                            }),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8),
                                              child: SizedBox(
                                                height: 1.8.h,
                                                width: 4.w,
                                                child: Image.asset(
                                                    "assets/images/Icon feather-edit-2.png"),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      TextField(
                                        maxLines: userController.userModel.value
                                                    .isVerified ==
                                                false
                                            ? 3
                                            : 5,
                                        onChanged: (val) {
                                          setState(() {
                                            aboutMe = val;
                                            FirebaseFirestore.instance
                                                .collection("USER")
                                                .doc(FirebaseAuth
                                                    .instance.currentUser!.uid)
                                                .update({"about me": aboutMe});
                                          });
                                        },
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            enabled: tapped,
                                            enabledBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            focusedErrorBorder:
                                                InputBorder.none,
                                            hintText: (userController
                                                    .userModel
                                                    .value
                                                    .aboutMe
                                                    .isEmptyOrNull)
                                                ? "Tell us about your game"
                                                : userController.userModel.value
                                                        .aboutMe ??
                                                    "",
                                            helperStyle: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: regular,
                                                color:
                                                    const Color(0xff777777))),
                                      ),
                                      verticalGap(20),
                                      Container(
                                        height: 1,
                                        color: greyColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
          // : const Center(child: Text("Loading...")),
        ),
      ),
    );
    // });
  }
}
