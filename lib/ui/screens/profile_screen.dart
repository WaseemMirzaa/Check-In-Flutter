import 'dart:developer';
import 'dart:io';

import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/controllers/user_controller.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/list_tile_container.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/shared_post_comp.dart';
import 'package:check_in/ui/screens/add_home_court.dart';
import 'package:check_in/ui/screens/unique_courts_screen.dart';
import 'package:check_in/ui/widgets/about_section.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/common.dart';
import 'package:check_in/utils/loader.dart';
import 'package:check_in/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart' as nbutils;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth_service.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key,this.isNavBar = true}) : super(key: key);
  bool isNavBar;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

int? totalCount = 10;

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; bool tapped = false;


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

  bool isUploading = false;

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
      isUploading = true;

      _imageFile = await compressImage(pickedFile);

      setState(() {
        // _imageFile = File(pickedFile.path);

      });

      final storage = FirebaseStorage.instance;
      final ref = storage.ref()
          // .child('profile/${DateTime.now().millisecondsSinceEpoch}');
          .child('profile/${FirebaseAuth.instance.currentUser?.uid ?? ""}');
      final uploadTask = ref.putFile(_imageFile!);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      isUploading = false;

      setState(() {
        _downloadUrl = downloadUrl;
      });

      final firestore = FirebaseFirestore.instance;
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await firestore.collection(Collections.USER).doc(userId).update({UserKey.PHOTO_URL: downloadUrl});
      CollectionReference messagesRef = FirebaseFirestore.instance.collection(Collections.MESSAGES);

      QuerySnapshot messagesQuery =
          await messagesRef.where(MessageField.SENDER_ID, isEqualTo: userController.userModel.value.uid).get();

      // Iterate through the documents and update senderImage field
      messagesQuery.docs.forEach((doc) async {
        // Update the senderImage field with the new image URL
        await messagesRef.doc(doc.id).update({
          MessageField.SENDER_IMG: downloadUrl,
        });
      });
      await firestore
          .collection(Collections.MESSAGES)
          .where(MessageField.SENDER_ID, isEqualTo: userController.userModel.value.uid);


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
    _scrollController.addListener(_onScroll);
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
  final controller = Get.put(NewsFeedController(NewsFeedService()));

  String aboutMe = '';
  TextEditingController aboutMeController = TextEditingController();
  bool tapped = false;

  final ScrollController _scrollController = ScrollController();


  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      controller.fetchMoreMyPosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        leading: widget.isNavBar ? const SizedBox() : IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back_ios)),
        title: poppinsText(TempLanguage.profile, 20, FontWeight.bold, appBlackColor),
      ),
      body: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: !userController.userModel.value.uid.isEmptyOrNull
                  ? SingleChildScrollView(
            controller: _scrollController,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                width: 32.9.w,
                                //   padding: EdgeInsets.all(10),
                                child: GestureDetector(
                                  onTap: _selectImage,
                                  child: Stack(
                                    //  clipBehavior: Clip.antiAliasWithSaveLayer,
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      isUploading
                                          ? Container(
                                        height: 20.h,
                                        width: 35.h,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white, // White background
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                          : (_downloadUrl != null)
                                              ? Container(
                                                  height: 20.h,
                                                  width: 35.h,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                          image: NetworkImage(_downloadUrl as String),
                                                          fit: BoxFit.fill)))
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
                                                image: DecorationImage(
                                                    image: AssetImage(AppAssets.INSTAGRAM_VERIFICATION))),
                                          ),
                                        )
                                      else
                                        const SizedBox(),
                                    ],
                                  ),
                                ),
                              ),
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

                              poppinsText(
                                // FirebaseAuth.instance.currentUser?.displayName
                                //     as String,
                                  userController.userModel.value.email ?? "",
                                  12,
                                  FontWeight.normal,
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
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.topCenter,
                              children: [
                                Container(
                                  width: 100.w,
                                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: appGreyColor1),
                                  child: TextField(
                                    controller: aboutMeController,
                                    textInputAction: TextInputAction.done,

                                    onSubmitted: (value) {
                                      // setState(() {
                                      //   // userController.userModel.value.
                                      //   //..........
                                      //   aboutMe = value;
                                      //   widget.userController.userModel.value.aboutMe = value;
                                      //   FirebaseFirestore.instance
                                      //       .collection(Collections.USER)
                                      //       .doc(FirebaseAuth.instance.currentUser!.uid)
                                      //       .update({UserKey.ABOUT_ME: aboutMe});
                                      // });
                                    },
                                    maxLines: userController.userModel.value.aboutMe.isEmptyOrNull ? 1 : 3,
                                    onChanged: (val) {},
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        enabled: tapped,
                                        enabledBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        hintText: TempLanguage.tellUsAboutGame,
                                        helperStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: regular, color: silverColor)),
                                  ),
                                ),

                                //   child: poppinsText(userController.userModel.value.aboutMe.isEmptyOrNull
                                // ? TempLanguage.tellUsAboutGame
                                // : userController.userModel.value.aboutMe ?? TempLanguage.tellUsAboutGame, 12, FontWeight.normal, appBlackColor),),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: InkWell(
                                      onTap: () => setState(() {
                                        if (tapped) {
                                          setState(() {
                                            // userController.userModel.value.
                                            //..........
                                            aboutMe = aboutMeController.text;
                                            userController.userModel.value.aboutMe = aboutMe;
                                            FirebaseFirestore.instance.collection(Collections.USER)
                                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                                .update({UserKey.ABOUT_ME: aboutMe});
                                          });
                                        }
                                        tapped = !tapped;
                                      }),
                                      child: Padding(
                                          padding: const EdgeInsets.all( 8),
                                          child: tapped
                                              ? poppinsText(TempLanguage.save, 14, semiBold, appGreenColor)
                                              : const ImageIcon(
                                            AssetImage(
                                              AppAssets.EDIT_ICON,
                                            ),
                                            size: 20,
                                          )),
                                    ),
                                  ),
                                ),
                                Positioned(
                                    top: -10,

                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 3),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30),
                                            color: appGreenColor),
                                        child: poppinsText('About', 12, FontWeight.w400, appWhiteColor),),
                                    ))
                              ],
                            ),
                          ),

                          const SizedBox(height: 25,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.topCenter,
                              children: [
                                Container(
                                  width: 100.w,
                                  padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: appGreyColor1),child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          poppinsText(userController.userModel.value.homeCourt.isEmptyOrNull
                                                                              ? ''
                                                                              : userController.userModel.value.homeCourt ?? '', 14,FontWeight.w500, silverColor),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: InkWell(
                                                onTap: () {
                                                  pushNewScreen(context, screen:  const AddHomeCourt(), withNavBar: false);
                                                },
                                                child: SizedBox(
                                                  height: 2.3.h,
                                                  width: 4.47.w,
                                                  child: Image.asset(AppAssets.MAP_PIN),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),),

                                Positioned(
                                    top: -10,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 3),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: appGreenColor),
                                        child: poppinsText('Home Court', 12, FontWeight.w400, appWhiteColor),),
                                    ))
                              ],
                            ),
                          ),
                          const SizedBox(height: 10,),
                          Center(child: Container(
                            width: 80,
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4,),decoration: BoxDecoration(color: appGreyColor1,borderRadius: BorderRadius.circular(30)),child: Center(child: poppinsText('My Posts', 12, FontWeight.normal, appBlackColor )),),),
                          const SizedBox(height: 10,),
                          Obx(() {
                            if (controller.myPosts.isEmpty) {
                              return Center(child: Text(TempLanguage.noPostFound));
                            } else {
                              return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: controller.myPosts.length + (controller.isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == controller.myPosts.length) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  var data = controller.myPosts[index];
                                  return data.isOriginal!
                                      ? ListTileContainer(
                                    key: ValueKey(data.id),
                                    data: data,
                                  )
                      : SharedPostComp(
                    key: ValueKey(data.id),
                    data: data,
                  );
                },
              );
            }
          }),

                          controller.myPostLoader.value ? const Center(
                            key: ValueKey('Loader'),
                            child: CircularProgressIndicator(),) : const SizedBox(key: ValueKey('Empty'),),

                          SizedBox(height: 2.h,)

                        ],
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
          // : const Center(child: Text("Loading...")),
        ),
    );
    // });
  }
}
