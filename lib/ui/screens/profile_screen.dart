import 'dart:io';

import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/add_home_court.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';
import '../../utils/gaps.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class User {
  final String name;
  final String email;
  final String about;
  final String court;
  final String pic;

  User(
      {required this.name,
      required this.email,
      required this.about,
      required this.court,
      required this.pic});
}

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<User>> get users {
    return _firestore.collection('USER').snapshots().map((snapshot) {
      return snapshot.docs
          .where((d) => d.get("uid") == FirebaseAuth.instance.currentUser!.uid)
          .map((doc) => User(
                name: doc.data()['user name'],
                email: doc.data()['email'],
                about: doc.data()['about me'] ?? "",
                court: doc.data()['home court'] ?? "",
                pic: doc.data()['photoUrl'] ?? "",
              ))
          .toList();
    });
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserController userController = Get.put(UserController());

  UserModel userd = UserModel();
  getUser() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("USER")
        .doc(userController.userModel.value.uid)
        .get();
    UserModel currentUser =
        UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
    userd = currentUser;
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
          .child('profile/${DateTime.now().millisecondsSinceEpoch}');
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

  String mail = FirebaseAuth.instance.currentUser?.email as String;
  bool tapped = false;
  String? aboutMe;

  @override
  void initState() {
    // getUser();
    // UserService();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String nmail = mail.substring(0, mail.indexOf('@'));

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
          child: StreamBuilder<List<User>>(
              stream: UserService().users,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data;
                return (users!.isNotEmpty && users != null)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              verticalGap(3.h),
                              Container(
                                width: 35.9.w,
                                //   padding: EdgeInsets.all(10),
                                child: Stack(
                                  //  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    GestureDetector(
                                      onTap: _selectImage,
                                      child: Container(
                                        height: 15.h,
                                        width: 32.9.w,
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            image: (_downloadUrl != null)
                                                ? DecorationImage(
                                                    fit: BoxFit.fill,
                                                    image:
                                                        // AssetImage(
                                                        //     "assets/images/Mask Group 1.png")
                                                        NetworkImage(
                                                            _downloadUrl
                                                                as String))
                                                : DecorationImage(
                                                    fit: BoxFit.fill,
                                                    image:
                                                        // AssetImage(
                                                        //     "assets/images/Mask Group 1.png")
                                                        NetworkImage(
                                                            users[0].pic))),
                                        child: Center(
                                          child: Image.asset(
                                              'assets/images/Icon material-person.png',
                                              scale: 1.5,
                                              color: Colors.grey[850]!.withOpacity(0.5),
                                              ),
                                        ),
                                      ),
                                    ),
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
                                    ),
                                  ],
                                ),
                              ),
                              verticalGap(0.5.h),
                              poppinsText(
                                  // FirebaseAuth.instance.currentUser?.displayName
                                  //     as String,
                                  users[0].name,
                                  32,
                                  FontWeight.bold,
                                  blackColor),
                              poppinsText(
                                  "@${users[0].email.substring(0, users[0].email.indexOf('@'))}",
                                  12,
                                  FontWeight.normal,
                                  blackColor),
                            ],
                          ),
                          Column(
                            children: [
                              poppinsText(
                                  "Home Court", 14, semiBold, greenColor),
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
                                            (users[0].court == "")
                                                ? ""
                                                : users[0].court,
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
                              Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 30, right: 30, top: 30),
                                    height: 200,
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            poppinsText("About me", 14,
                                                semiBold, blackColor),
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
                                          maxLines: 5,
                                          onChanged: (val) {
                                            setState(() {
                                              aboutMe = val;
                                              FirebaseFirestore.instance
                                                  .collection("USER")
                                                  .doc(FirebaseAuth.instance
                                                      .currentUser!.uid)
                                                  .update(
                                                      {"about me": aboutMe});
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
                                              hintText: (users[0].about == "")
                                                  ? "Tell us about your game"
                                                  : users[0].about,
                                              helperStyle: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: regular,
                                                  color:
                                                      const Color(0xff777777))),
                                        ),
                                        verticalGap(15),
                                        Container(
                                          height: 1,
                                          color: greyColor,
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 100,
                                    color: greenColor,
                                    height: 2,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      )
                    : const Center(child: Text("Loading..."));
              }),
        ),
      ),
    );
  }
}
