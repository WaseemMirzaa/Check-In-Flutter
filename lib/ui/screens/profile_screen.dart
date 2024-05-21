import 'dart:developer';
import 'dart:io';

import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/unique_courts_screen.dart';
import 'package:check_in/ui/widgets/about_section.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart' as nbutils;
import 'package:percent_indicator/circular_percent_indicator.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth_service.dart';
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
    return _firestore.collection(Collections.USER).snapshots().map((snapshot) {
      return snapshot.docs
          .where((d) => d.get(UserKey.UID) == FirebaseAuth.instance.currentUser!.uid)
          .map((doc) => UserModel(
                userName: doc.data()[UserKey.USER_NAME],
                email: doc.data()[UserKey.EMAIL],
                aboutMe: doc.data()[UserKey.ABOUT_ME] ?? "",
                homeCourt: doc.data()[UserKey.HOME_COURT] ?? "",
                photoUrl: doc.data()[UserKey.PHOTO_URL] ?? "",
                isVerified: doc.data()[UserKey.IS_VERIFIED],
                goldenCheckin: doc.data()[UserKey.GOLDEN_CHECK_IN] ?? 0,
              ))
          .toList();
    });
  }
}

Future<List<UserModel>?> getUniqueCourtNameMaps() async {
  CollectionReference<Map<String, dynamic>> collectionReference =
      FirebaseFirestore.instance.collection(Collections.USER);
  DocumentSnapshot<Map<String, dynamic>> document =
      await collectionReference.doc(userController.userModel.value.uid).get();

  Set<int> uniqueCourtIds = <int>{};
  List<UserModel> resultMaps = [];

  try {
    List<Map<String, dynamic>> mapsArray = List<Map<String, dynamic>>.from(document.data()?[CourtKey.CHECKED_COURTS]);
    for (var map in mapsArray) {
      int courtId = map[CourtKey.ID] ?? 0;
      bool isGold = map[CourtKey.IS_GOLDEN] ?? false;
      if (isGold && courtId > 0 && !uniqueCourtIds.contains(courtId)) {
        resultMaps.add(UserModel.fromMap(map));
        uniqueCourtIds.add(courtId);
      }
    }
    return resultMaps;
  } catch (e) {
    return null;
  }
}

Future<int> getGoldenLocationsCount() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Collections.GOLDEN_LOCATIONS) // Replace with your collection name
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
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection(Collections.USER).doc(userController.userModel.value.uid).get();
    // log("all snapshot data.......${snapshot.data()}");
    UserModel currentUser = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
    userController.userModel.value = currentUser;
    if (mounted) setState(() {});
  }

  File? _imageFile;
  String? _downloadUrl;

  Future<void> _selectImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      final storage = FirebaseStorage.instance;
      final ref = storage.ref()
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
      await firestore.collection(Collections.USER).doc(userId).update({UserKey.PHOTO_URL: downloadUrl});
      CollectionReference messagesRef = FirebaseFirestore.instance.collection(Collections.MESSAGES);

      QuerySnapshot messagesQuery = await messagesRef.where(MessageField.SENDER_ID, isEqualTo: userController.userModel.value.uid).get();

      // Iterate through the documents and update senderImage field
      messagesQuery.docs.forEach((doc) async {
        // Update the senderImage field with the new image URL
        await messagesRef.doc(doc.id).update({
          MessageField.SENDER_IMG: downloadUrl,
        });
      });
      await firestore.collection(Collections.MESSAGES).where(MessageField.SENDER_ID, isEqualTo: userController.userModel.value.uid);
    }
  }

  void initializeData() async {
    // Example: Fetching the total count asynchronously
    try {
      totalCount = await getGoldenLocationsCount();
      // final courts = await getUniqueCourtNameMaps();
      // totalCount = courts.length;
    } catch (e) {
      print("Error fetching data: $e");
      // Handle the error as needed
    }

    // Update the state after the asynchronous work is done
    if (mounted) {
      setState(() {});
    }
  }

  //String mail = FirebaseAuth.instance.currentUser?.email ?? '';
  // String mail = FirebaseAuth.instance.currentUser?.email ?? "";

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

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@checkinhoops.net',
      // Replace with the recipient's email address for reporting
      query: 'subject=$subject&body=$emailContent',
    );

    // if (await canLaunchUrl(_emailLaunchUri)) {
    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      nbutils.toast(TempLanguage.notLaunchEmailToast);
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // return GetBuilder<UserController>(builder: (userController) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: appWhiteColor,
        title: poppinsText(TempLanguage.profile, 20, FontWeight.bold, appBlackColor),
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
                  ? SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              verticalGap(3.h),
                              SizedBox(
                                width: 35.9.w,
                                //   padding: EdgeInsets.all(10),
                                child: GestureDetector(
                                  onTap: _selectImage,
                                  child: Stack(
                                    //  clipBehavior: Clip.antiAliasWithSaveLayer,
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      (_downloadUrl != null)
                                          ? Container(
                                              height: 20.h,
                                              width: 35.h,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: NetworkImage(_downloadUrl as String), fit: BoxFit.fill)))
                                          : (!userController.userModel.value.photoUrl.isEmptyOrNull)
                                              ? Container(
                                                  height: 20.h,
                                                  width: 35.h,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                          image: NetworkImage(
                                                              userController.userModel.value.photoUrl ?? ""),
                                                          fit: BoxFit.fill)))
                                              : Container(
                                                  height: 20.h,
                                                  width: 35.h,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(width: 2, color: appGreenColor),
                                                      image: const DecorationImage(
                                                          image: AssetImage(AppAssets.LOGO_NEW), fit: BoxFit.fill)),
                                                ),
                                      if (userController.userModel.value.isVerified == null ||
                                          userController.userModel.value.isVerified == true)
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            height: 5.5.h,
                                            width: 12.1.w,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(image: AssetImage(AppAssets.INSTAGRAM_VERIFICATION))),
                                          ),
                                        )
                                      else
                                        const SizedBox(),
                                    ],
                                  ),
                                ),
                              ),
                              verticalGap(0.5.h),
                              poppinsText(
                                  // FirebaseAuth.instance.currentUser?.displayName
                                  //     as String,
                                  userController.userModel.value.userName ?? "",
                                  32,
                                  FontWeight.bold,
                                  appBlackColor),
                              // poppinsText(
                              //     "@${userController.userModel.value.email.substring(0, userController.userModel.value.email.indexOf('@'))}",
                              //     12,
                              //     FontWeight.normal,
                              //     blackColor),
                              const SizedBox(
                                height: 10,
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: offWhiteColor,
                                        width: 8.0,
                                      ),
                                    ),
                                    child: FutureBuilder<List<UserModel>?>(
                                      future: getUniqueCourtNameMaps(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const SizedBox(
                                              height: 110,
                                              width: 110,
                                              child: Center(child: CircularProgressIndicator()));
                                        } else if (snapshot.hasData && snapshot.data != null) {
                                          return InkWell(
                                            onTap: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(builder: (context) => const UniqueCourtsScreen()));
                                            },
                                            child: CircularPercentIndicator(
                                              radius: 55.0,
                                              lineWidth: 8.0,
                                              animation: true,
                                              percent:
                                              ((snapshot.data?.length ?? 0) / (totalCount ?? 10)).clamp(0.0, 1.0),
                                              center: Text(
                                                "${snapshot.data?.length ?? 0}\nCheck ins",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0,
                                                ),
                                              ),
                                              circularStrokeCap: CircularStrokeCap.round,
                                              progressColor: darkYellowColor,
                                            ),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Center(
                                            child: Text(TempLanguage.wentWrong),
                                          );
                                        } else {
                                          return InkWell(
                                            onTap: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(builder: (context) => const UniqueCourtsScreen()));
                                            },
                                            child: CircularPercentIndicator(
                                              radius: 55.0,
                                              lineWidth: 8.0,
                                              animation: true,
                                              percent: (0 / (totalCount ?? 10)).clamp(0.0, 1.0),
                                              center: const Text(
                                                "0\nCheck ins",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0,
                                                ),
                                              ),
                                              circularStrokeCap: CircularStrokeCap.round,
                                              progressColor: darkYellowColor,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context, MaterialPageRoute(builder: (context) => const UniqueCourtsScreen()));
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        poppinsText("Golden", 22, FontWeight.bold, appBlackColor),
                                        poppinsText("Courts", 22, FontWeight.bold, appBlackColor),
                                        FutureBuilder<List<UserModel>?>(
                                          future: getUniqueCourtNameMaps(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              // return const Center(child: CircularProgressIndicator());
                                              return const Center(child: CircularProgressIndicator());
                                            } else if (snapshot.hasData && snapshot.data != null) {
                                              return poppinsText("${snapshot.data?.length ?? 0} Check ins", 12,
                                                  FontWeight.normal, appBlackColor);
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                child: Text(TempLanguage.wentWrong),
                                              );
                                            } else {
                                              return poppinsText("0 Check ins", 12, FontWeight.normal, appBlackColor);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          AboutSection(userController: userController),
                        ],
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
          // : const Center(child: Text("Loading...")),
        ),
      ),
    );
    // });
  }
}
