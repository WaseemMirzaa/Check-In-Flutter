import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:check_in/Services/payment_service.dart';
import 'package:check_in/auth_service.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/constant.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/firebase-models/user_firebase_model.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/contact_us.dart';
import 'package:check_in/ui/screens/persistent_nav_bar.dart';
import 'package:check_in/ui/screens/privacy_policy.dart';
import 'package:check_in/ui/screens/start.dart';
import 'package:nb_utils/nb_utils.dart' as nbutils;
import 'package:check_in/ui/screens/terms_conditions.dart';
import 'package:check_in/ui/widgets/common_button.dart';
import 'package:check_in/utils/CourtsParser.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/custom/custom_type_ahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants.dart';
import '../../controllers/user_controller.dart';
import '../../main.dart';
import '../../utils/common.dart';
import 'Players.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:developer'as developer;
class CheckIn extends StatefulWidget {
  const CheckIn({Key? key}) : super(key: key);

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> with SingleTickerProviderStateMixin {
  int? index = 0;
  bool withinRadius = false;
  double ZOOM_LEVEL_INITIAL = 12;
  RxInt heatMapRadius = 45.obs;
  int _previousZoomLevel = 12;
  double heatmapZoomFactor = 2.5;
  int searchRadius = 30 * 1000;
  StreamSubscription<Position>? _positionStreamSubscription;

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  final auth = FirebaseAuth.instance;
  final snap = FirebaseFirestore.instance;

  DocumentReference docRef =
      FirebaseFirestore.instance.collection(Collections.USER).doc(FirebaseAuth.instance.currentUser?.uid);

  LatLng? loc;

  var courtN;
  bool? isCheckedIn = false;
  String checkedInCourtName = '';
  Map<String, dynamic> courtInfo = {};

  TextEditingController typeAheadController = TextEditingController();

  final _places = GoogleMapsPlaces(apiKey: Constants.API_KEY);
  String _selectedPlace = '';

  Position? currentLocation;
  final Completer<GoogleMapController> _googleMapController = Completer();
  GoogleMapController? _mapController;

  Set<Marker> markers = Set<Marker>.identity();

  List<WeightedLatLng> heatmapPoints = <WeightedLatLng>[
    const WeightedLatLng(LatLng(37.782, -122.447), weight: 0),
    // const WeightedLatLng(LatLng(37.782, -122.445), weight: 0.5),
    // const WeightedLatLng(LatLng(37.782, -122.443)),
    // const WeightedLatLng(LatLng(37.782, -122.441)),
    // const WeightedLatLng(LatLng(37.782, -122.439)),
    // const WeightedLatLng(LatLng(37.782, -122.437)),
    // const WeightedLatLng(LatLng(37.782, -122.435)),
    // const WeightedLatLng(LatLng(37.785, -122.447)),
    // const WeightedLatLng(LatLng(37.785, -122.445)),
    // const WeightedLatLng(LatLng(37.785, -122.443)),
    // const WeightedLatLng(LatLng(37.785, -122.441)),
    // const WeightedLatLng(LatLng(37.785, -122.439)),
    // const WeightedLatLng(LatLng(37.785, -122.437)),
    // const WeightedLatLng(LatLng(37.785, -122.435))
  ];

  Future indexValue() async {
    if (FirebaseAuth.instance.currentUser != null) {
      final document =
          FirebaseFirestore.instance.collection(Collections.USER).doc(FirebaseAuth.instance.currentUser!.uid);
      document.get().then((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          dynamic data = snapshot.data();
          isCheckedIn = data[UserKey.CHECKED_IN];
          // print("${pata['checkedIn']}Siuuu");
          // print(isCheckedIn);
          if (isCheckedIn == false) {
            index = 0;
          } else if (isCheckedIn == true) {
            checkedInCourtName = data[UserKey.CHECKED_IN_COURT_NAME] ?? "";
            index = 1;
          }
          mounted ? setState(() {}) : null;
          // print("${index} is index");
        } else {
          print('Document does not exist!');
        }
      });
    }
  }

  changeIndex() {
    if (index == 0) {
      index = 1;
    } else {
      index = 0;
    }
    if (mounted) setState(() {});
    // print(index);
  }

  Future<Position?> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      // courtNames();
      // print(currentLocation?.longitude);
      if (mounted) {
        setState(() {
          currentLocation = position;
          courtNames();
        });
      }
    } catch (e) {
      log('Enable location');
      nbutils.toast('Enable your location');
    }

    return Future.value(currentLocation);
  }

  Future courtNames() async {
    // Golden Location
    try {
      if (courtlist.isEmpty) {
        await snap.collection(Collections.GOLDEN_LOCATIONS).get().then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            courtlist.add(doc.data());
            double latitude = doc.data()[CourtKey.LAT];
            double longitude = doc.data()[CourtKey.LNG];
            String name = doc.data()[CourtKey.NAME];

            LatLng location = LatLng(latitude, longitude);
            Marker marker = Marker(
              markerId: MarkerId(doc.id),
              position: location,
              infoWindow: InfoWindow(title: name, snippet: CourtKey.GOLDEN),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
              onTap: () {
                pushNewScreen(context,
                    screen: PlayersView(
                      courtLatLng: location,
                      courtName: name,
                      isCheckedIn: checkedInCourtName == name,
                    ),
                    withNavBar: false);
              },
            );
            markers.add(marker);
            addHeatedMarkers(marker);
          }
          if (mounted) setState(() {});
        });
      } else {
        for (var doc in courtlist) {
          double latitude = doc[CourtKey.LAT];
          double longitude = doc[CourtKey.LNG];
          String name = doc[CourtKey.NAME];

          LatLng location = LatLng(latitude, longitude);
          Marker marker = Marker(
            markerId: MarkerId(doc[CourtKey.ID].toString()),
            position: location,
            infoWindow: InfoWindow(title: name, snippet: CourtKey.GOLDEN),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
            onTap: () {
              pushNewScreen(context,
                  screen: PlayersView(
                    courtLatLng: location,
                    courtName: name,
                    isCheckedIn: checkedInCourtName == name,
                  ),
                  withNavBar: false);
            },
          );
          markers.add(marker);
          addHeatedMarkers(marker);
        }
        if (mounted) setState(() {});
      }
    } catch (e) {
      print(e);
    }

    // ADDING PLACCES API COURTS LOCATION MARKER
    // final placesResponse = await _places.searchNearbyWithRadius(
    //   Location(
    //     lat: currentLocation!.latitude,
    //     lng: currentLocation!.longitude,
    //   ),
    //   searchRadius,
    //   // 30000,
    //   type: 'court',
    //   name: 'ball court',
    // );

    final courts = await CourtsParser().getCourtsFromCSVFileAndFirestore();

    // final placesResponse = await getBasketballCourts();

    // placesResponse?.results.forEach((place) {
    for (var place in courts) {
      LatLng location = LatLng(
        place.latitude,
        place.longitude,
      );

      BitmapDescriptor icon;
      // if (isGolden) {
      //   icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      // } else{
      icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      // }
      Marker marker = Marker(
        markerId: MarkerId(place.placeId),
        position: location,
        infoWindow: InfoWindow(
          title: place.title,
          snippet: place.address,
        ),
        // icon: icon,
        onTap: () {
          pushNewScreen(
            context,
            screen: PlayersView(
              courtLatLng: location,
              courtName: place.title,
              isCheckedIn: checkedInCourtName == place.title,
            ),
            withNavBar: false,
          );
        },
      );
      markers.add(marker);
      addHeatedMarkers(marker);
    }

    if (mounted) {
      setState(() {
        // markers = markers;
        addLocationChangeListener();
      });
    }
  }

  Future<PlacesSearchResponse?> getBasketballCourts() async {
    final apiKey = Constants.API_KEY;
    final url =
        Uri.parse('https://maps.googleapis.com/maps/api/place/textsearch/json?query=basketball+courts&key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return PlacesSearchResponse.fromJson(json.decode(response.body));
    } else {
      return null;
      // throw Exception('Failed to load basketball courts');
    }
  }

  void addHeatedMarkers(Marker marker) async {
    // int intensityLevel_1 = 0;
    // int intensityLevel_2 = 10;
    // int intensityLevel_3 = 30;
    // int intensityLevel_4 = 100;

    // int playersGathering = Random().nextInt(100);
    // int playersGathering = 100;
    int playersGathering = await getUsersCountOnLocation(marker.position);

    // debugPrint("Court Name:" +
    //     (marker.infoWindow.title ?? "") +
    //     " | Users Count: " +
    //     playersGathering.toString());

    double intensity = playersGathering * 0.1;

    WeightedLatLng point = WeightedLatLng(marker.position, weight: intensity);

    if (mounted) setState(() => heatmapPoints.add(point));
  }

  void setHeatMapSize(int zoomLevel) {
    heatmapZoomFactor = heatmapZoomFactor + (zoomLevel - _previousZoomLevel);
    heatMapRadius.value = (zoomLevel * (heatmapZoomFactor)).toInt();
    if (heatMapRadius.value < 50) {
      heatMapRadius.value = 50;
    }

    print("Zoom Level = $zoomLevel");
    print("heatMapRadius.value = ${heatMapRadius.value}");
    if (mounted) setState(() {});
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

  Future<int> getUsersCountOnLocation(LatLng court) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(Collections.USER)
        .where(UserKey.CHECKED_IN, isEqualTo: true)
        .where(CourtKey.COURT_LAT, isEqualTo: court.latitude)
        .where(CourtKey.COURT_LNG, isEqualTo: court.longitude)
        .get();

    return snapshot.size;
  }

  Future<Position> setCurrentLocationOnMap() async {
    GoogleMapController googleMapController = await _googleMapController.future;

    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: 16,
          target: LatLng(currentLocation!.latitude, currentLocation!.longitude),
        ),
      ),
    );
    if (mounted) setState(() {});

    return Future.value(currentLocation);
  }

  void addLocationChangeListener() {
    // Configure the location callback
    var locationOptions = const LocationOptions(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10, // Minimum distance (in meters) for location change updates
    );

    // Listen for location changes
    _positionStreamSubscription = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.best,
      distanceFilter: 10, // Minimum distance (in meters) for location change updates
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          currentLocation = position;
          checkIfWithinRadiusAndSetUserCourtInfo();
        });
      }
    });
  }

  bool _checkIfWithinRadius(Position userPos, LatLng court) {
    double distanceInMeters =
        Geolocator.distanceBetween(userPos.latitude, userPos.longitude, court.latitude, court.longitude);
    if (distanceInMeters <= 100) {
      // print("user in radius");
      return true;
    } else {
      // print("user not in radius");
      return false;
    }
  }

  Future<bool> checkIfWithinRadiusAndSetUserCourtInfo() async {
    withinRadius = false;
    for (Marker marker in markers) {
      withinRadius = _checkIfWithinRadius(currentLocation!, marker.position);

      if (withinRadius) {
        loc = marker.position;
        courtN = marker.infoWindow.title;
        int id;
        try {
          id = int.parse(marker.markerId.value);
        } catch (e) {
          id = 0;
        }
        courtInfo.addAll({
          CourtKey.COURT_LAT: loc!.latitude,
          CourtKey.COURT_LNG: loc!.longitude,
          CourtKey.COURT_NAME: courtN,
          CourtKey.ID: id,
        });
        print(marker.infoWindow.snippet);
        if (marker.infoWindow.snippet == CourtKey.GOLDEN) {
          // Add additional info for golden location
          courtInfo.addAll({
            CourtKey.IS_GOLDEN: true,
            // Add any other specific information for golden locations
          });
        } else {
          // If not a golden location, you can still add some other information
          courtInfo.addAll({
            CourtKey.IS_GOLDEN: false,
            // Add any other specific information for non-golden locations
          });
        }
        break;
      }
    }

    return Future.value(withinRadius);

    // final placesResponse = await _places.searchNearbyWithRadius(
    //   Location(
    //     lat: currentLocation!.latitude,
    //     lng: currentLocation!.longitude,
    //   ),
    //   200,
    //   type: 'court',
    //   name: 'ball court',
    // );
    //
    // withinRadius = false;
    //
    //
    // placesResponse.results.forEach((place) {
    //   LatLng location = LatLng(
    //     place.geometry!.location.lat,
    //     place.geometry!.location.lng,
    //   );
    //
    //   // Check if the marker is within the radius
    //    withinRadius = _checkIfWithinRadius(currentLocation!, location);
    //
    //   if (withinRadius) {
    //     loc = location;
    //     courtN = place.name;
    //     courtInfo.addAll({
    //       "courtLat": loc!.latitude,
    //       "courtLng": loc!.longitude,
    //       "courtName": courtN,
    //     });
    //   }
    //
    //   print(withinRadius);
    //
    //
    // });
    // return Future.value(withinRadius);
  }

  Future<bool> isCourtAlreadyStored(double currentCourtLat, double currentCourtLng) async {
    DocumentSnapshot userDoc = await snap.collection(Collections.USER).doc(auth.currentUser!.uid).get();
    List<dynamic> checkedCourts = (userDoc.data() as Map<String, dynamic>?)?[CourtKey.CHECKED_COURTS] ?? [];
    // Check if the coordinates are already present in the array
    if (checkedCourts
        .any((court) => court[CourtKey.COURT_LAT] == currentCourtLat && court[CourtKey.COURT_LNG] == currentCourtLng)) {
      return false;
    } else {
      return true;
    }
  }

  void _buttonPress() async {
    changeIndex();

    //CheckIn Pressed
    if (index == 1) {
      if (mounted) {
        setState(() {
          courtInfo['checkInTime'] = DateFormat('HH:mm:ss').format(DateTime.now());
          courtInfo[CheckedCourts.checkInTimeStamp] = Timestamp.now();

          checkedInCourtName = courtInfo['courtName'];
        });
      }
      print(courtInfo['isGolden']);
      bool val = await isCourtAlreadyStored(loc!.latitude, loc!.longitude);
      snap.collection(Collections.USER).doc(auth.currentUser!.uid).update({
        CourtKey.CHECKED_COURTS: FieldValue.arrayUnion([courtInfo]),
        UserKey.CHECKED_IN: true,
        UserKey.CHECKED_IN_COURT_NAME: courtInfo[CourtKey.COURT_NAME],
        CourtKey.COURT_LAT: loc!.latitude,
        CourtKey.COURT_LNG: loc!.longitude,
        UserFirebaseModel.lastCheckin: Timestamp.now(),
        UserFirebaseModel.lastCheckout: FieldValue.delete(),
      });

      print("HAAAA$val");
      if (courtInfo[CourtKey.IS_GOLDEN] && val) {
        Get.find<UserController>().updateGoldenCheckin(
          (Get.find<UserController>().userModel.value.goldenCheckin ?? 0) + 1,
        );
        snap.collection(Collections.USER).doc(auth.currentUser!.uid).update({
          UserKey.GOLDEN_CHECK_IN: FieldValue.increment(1),
        });
      }

      Get.snackbar("Checked In", "You have checked into this court.",
          backgroundColor: appWhiteColor, borderWidth: 4, borderColor: appBlackColor, colorText: appBlackColor);
      // print(index);
      // print(withinRadius);
    }
    //Checkout Pressed
    else if (index == 0) {
      snap.collection(Collections.USER).doc(auth.currentUser!.uid).update({
        UserKey.CHECKED_IN: false,
        CourtKey.COURT_LAT: FieldValue.delete(),
        CourtKey.COURT_LNG: FieldValue.delete(),
        UserFirebaseModel.lastCheckout: Timestamp.now(),
        UserFirebaseModel.lastCheckin: FieldValue.delete(),
      });

      checkedInCourtName = '';

      Get.snackbar(TempLanguage.checkOutToastTitle, TempLanguage.checkOutToastMessage,
          backgroundColor: appWhiteColor, borderWidth: 4, borderColor: appBlackColor, colorText: appBlackColor);
    }
  }

  double getCurrentZoomLevel() {
    if (_mapController != null) {
      _mapController!.getZoomLevel().then((double zoomLevel) {
        return zoomLevel;
      });
    }
    return ZOOM_LEVEL_INITIAL;
  }

  getUser() async {
    if (FirebaseAuth.instance.currentUser != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(Collections.USER)
          .doc(FirebaseAuth.instance.currentUser?.uid ?? "")
          .get();
      userController.userModel.value = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      print(userController.userModel.value);
    }
    // UserModel currentUser = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
  }

  @override
  void initState() {
    getUser();
    // setCustomMarkerIcon();
    getCurrentLocation();
    indexValue();
    // addLocationChangeListener();
    // _checkIfWithinRadius();
    super.initState();
    // initDynamicLinks(context);
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      if (FirebaseAuth.instance.currentUser != null && userController.userModel.value.isTermsVerified == null) {
        Get.to(const TermsAndConditions(showButtons: true,));
      }
    });
  }


  // /// The deep link
  // Future<void> initDynamicLinks(BuildContext context) async {
  //   await Firebase.initializeApp();
  //   // Handle initial link when the app is first opened
  //   final PendingDynamicLinkData? initialLinkData = await FirebaseDynamicLinks.instance.getInitialLink();
  //   _handleDeepLink(context, initialLinkData?.link);
  //
  //   // Set up the listener for any dynamic links clicked while the app is in the background or foreground
  //   FirebaseDynamicLinks.instance.onLink.listen(
  //         (PendingDynamicLinkData dynamicLinkData) {
  //       _handleDeepLink(context, dynamicLinkData?.link);
  //     },
  //     onError: (error) async {
  //       developer.log('Dynamic Link Failed: ${error.toString()}');
  //     },
  //   );
  // }
  //
  // void _handleDeepLink(BuildContext context, Uri? deepLink) {
  //   if (deepLink != null) {
  //     var isPost = deepLink.pathSegments.contains('post');
  //     if (isPost) {
  //       var postId = deepLink.queryParameters['postId'];
  //       if (postId != null) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => OpenPost(postId: postId,),
  //           ),
  //         );
  //       }else{
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => ProfileScreen(),
  //           ),
  //         );
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      drawer: Drawer(
        backgroundColor: appWhiteColor,
        child: SizedBox(
          height: 300,
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: appWhiteColor,
                ),
                child: Image.asset(
                  AppAssets.LOGO_NEW,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ListTile(
                leading: const Icon(
                  Icons.contact_page,
                ),
                title: Text(TempLanguage.contactUs),
                onTap: () {
                  pushNewScreen(context, screen: const ContactUs(), withNavBar: false);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.privacy_tip,
                ),
                title: Text(TempLanguage.privacyPolicy),
                onTap: () {
                  pushNewScreen(context, screen: const PrivacyPolicy(), withNavBar: false);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.privacy_tip,
                ),
                title: Text(TempLanguage.termsAndConditions),
                onTap: () {
                  pushNewScreen(context, screen: const TermsAndConditions(), withNavBar: false);
                },
              ),
              FirebaseAuth.instance.currentUser == null
                  ? const SizedBox()
                  : userController.userModel.value.isVerified == null ||
                          userController.userModel.value.isVerified == true
                      ? const SizedBox()
                      : ListTile(
                          leading: const Icon(
                            Icons.verified,
                          ),
                          title: Text(TempLanguage.verifyProfile),
                          onTap: () async {
                            nbutils.showConfirmDialogCustom(
                              context,
                              title: 'Get Verified on Check In Hoops Today! \n- 1 Time Purchase',
                              subTitle: '',
                              dialogType: nbutils.DialogType.CONFIRMATION,
                              cancelable: false,
                              onAccept: (ctx) async {
                                Navigator.pop(ctx);
                                showLoadingIndicator(context);
                                if (userController.userModel.value.isVerified == false) {
                                  if (userController.userModel.value.customerId.isEmptyOrNull) {
                                    try {
                                      String customerId = await PaymentService.createStripeCustomer(email: userController.userModel.value.email ?? '');
                                      // await FirebaseFirestore.instance.collection(Collections.USER).doc(FirebaseAuth.instance.currentUser!.uid).update({
                                      //   UserKey.CUSTOMER_ID: customerId
                                      // });
                                      await PaymentService.initPaymentSheet(context: context, amount: 1000, customerId: customerId);
                                    } catch (e) {
                                      log(e.toString());
                                    }
                                  } else {
                                    await PaymentService.initPaymentSheet(context: context, amount: 1000, customerId: userController.userModel.value.customerId ?? '');
                                  }
                                }
                              },
                              onCancel: (ctx){
                                Navigator.pop(ctx);
                              }
                            );
                            // sendEmail(
                            //     userController.userModel.value.userName ?? "",
                            //     userController.userModel.value.email ?? "",
                            //     userController.userModel.value.homeCourt ?? "");
                          },
                        ),
              FirebaseAuth.instance.currentUser == null
                  ? const SizedBox()
                  : ListTile(
                      leading: const Icon(
                        Icons.logout_outlined,
                      ),
                      title: Text(TempLanguage.logOut),
                      onTap: () async {
                        logout(context);
                        userController.userModel.value = UserModel();
                      },
                    ),
              FirebaseAuth.instance.currentUser == null
                  ? const SizedBox()
                  : ListTile(
                      leading: const Icon(
                        Icons.delete_forever_outlined,
                      ),
                      title: Text(TempLanguage.deleteAcc),
                      onTap: () {
                        delAcc(context);
                      },
                    ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GestureDetector(
                child: currentLocation == null
                    ? Center(child: Text(TempLanguage.loading))
                    : GoogleMap(
                        mapToolbarEnabled: false,
                        zoomControlsEnabled: true,
                        zoomGesturesEnabled: true,
                        myLocationButtonEnabled: false,
                        myLocationEnabled: true,

                        // tileOverlays: ,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(currentLocation!.latitude, currentLocation!.longitude
                              // 42.3878,
                              // -71.1105
                              ),
                          zoom: ZOOM_LEVEL_INITIAL,
                        ),
                        markers: markers,
                        onMapCreated: (mapController) {
                          _mapController = mapController;
                          _googleMapController.complete(mapController);
                        },
                        onCameraMove: (CameraPosition position) {
                          int currentZoomLevel = position.zoom.toInt();
                          if (currentZoomLevel != _previousZoomLevel) {
                            // Zoom level changed
                            setHeatMapSize(currentZoomLevel);
                            // print(
                            //     'Zoom level changed: $_previousZoomLevel -> $currentZoomLevel');
                          }
                          _previousZoomLevel = currentZoomLevel;
                        },
                        heatmaps: <Heatmap>{
                            Heatmap(
                              heatmapId: const HeatmapId('test'),
                              data: heatmapPoints,
                              gradient: HeatmapGradient(
                                <HeatmapGradientColor>[
                                  // Web needs a first color with 0 alpha
                                  // if (kIsWeb)
                                  //   HeatmapGradientColor(
                                  //     Color.fromARGB(0, 0, 255, 255),
                                  //     0,
                                  //   ),
                                  HeatmapGradientColor(
                                    yellowColor,
                                    0.2,
                                  ),
                                  HeatmapGradientColor(
                                    appRedColor,
                                    0.6,
                                  ),
                                  // HeatmapGradientColor(
                                  //   Colors.green,
                                  //   0.6,
                                  // ),
                                  // HeatmapGradientColor(
                                  //   Colors.purple,
                                  //   0.8,
                                  // ),
                                  HeatmapGradientColor(
                                    appBlueColor,
                                    1,
                                  ),
                                ],
                              ),
                              maxIntensity: 1,
                              // Radius behaves differently on web and Android/iOS.
                              // For Android: According to documentation, radius should be between 10 to 50
                              radius: kIsWeb
                                  ? 10
                                  : defaultTargetPlatform == TargetPlatform.android
                                      ? heatMapRadius.value
                                      : heatMapRadius.value,
                            )
                          }),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              bottom: 10,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.84,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                _scaffoldState.currentState?.openDrawer();
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: appGreenColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.menu,
                                  color: appWhiteColor,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                courtlist.clear();
                                // Add your refresh button functionality here
                                // Get.offAll(CheckIn());
                                //....................
                                Navigator.pushAndRemoveUntil(
                                    context, MaterialPageRoute(builder: (context) => const Home()), (route) => false);
                                //...................
                                // setState(() {});
                                // Navigator.pushReplacement(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => CheckIn()),
                                // );
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: appGreenColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.refresh,
                                  color: appWhiteColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Material(
                          borderRadius: BorderRadius.circular(10),
                          elevation: 2,
                          shadowColor: greyColor,
                          child: SingleChildScrollView(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: TypeAheadField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: typeAheadController,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(
                                      left: 20,
                                      top: 10,
                                    ),
                                    filled: true,
                                    border: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    fillColor: appWhiteColor,
                                    hintText: TempLanguage.findCourts,
                                    hintStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: medium, color: greyColor),
                                    suffixIcon: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 17,
                                          width: 17,
                                          child: Image.asset(
                                            AppAssets.IOS_SEARCH_ICON,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                hideSuggestionsOnKeyboardHide: false,
                                suggestionsCallback: (pattern) async {
                                  if (currentLocation == null) {
                                    return [];
                                  }
                                  final courts = await CourtsParser().getCourtsByNameOrAddressFromCSVFile(pattern);

                                  // final placesResponse =
                                  //     await _places.searchNearbyWithRadius(
                                  //   Location(
                                  //       lat: currentLocation!.latitude,
                                  //       lng: currentLocation!.longitude),
                                  //   searchRadius, // Search radius in meters
                                  //   type: 'court',
                                  //   name: 'ball court',
                                  //   keyword: pattern,
                                  // );

                                  // return placesResponse.results;
                                  return courts;
                                },
                                itemBuilder: (context, prediction) {
                                  return ListTile(
                                    title: Text(prediction.title),
                                    subtitle: Text(prediction.address),
                                  );
                                },
                                onSuggestionSelected: (prediction) async {
                                  mounted
                                      ? setState(() {
                                          _selectedPlace = prediction.title as String;
                                        })
                                      : null;
                                  typeAheadController.text = _selectedPlace;

                                  // var placeId = prediction.placeId;
                                  // var detail = await _places
                                  //     .getDetailsByPlaceId(placeId as String);
                                  // var location =
                                  //     detail.result.geometry!.location;
                                  var lat = prediction.latitude;
                                  var lng = prediction.longitude;

                                  final GoogleMapController controller = await _googleMapController.future;
                                  controller.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: LatLng(lat, lng),
                                        zoom: 18.0,
                                      ),
                                    ),
                                  );

                                  final location = LatLng(
                                    lat,
                                    lng,
                                  );
                                  Marker marker = Marker(
                                    markerId: MarkerId(prediction.placeId),
                                    position: location,
                                    infoWindow: InfoWindow(
                                      title: prediction.title,
                                      snippet: prediction.address,
                                    ),
                                    // icon: icon,
                                    onTap: () {
                                      pushNewScreen(
                                        context,
                                        screen: PlayersView(
                                          courtLatLng: location,
                                          courtName: prediction.title,
                                          isCheckedIn: checkedInCourtName == prediction.title,
                                        ),
                                        withNavBar: false,
                                      );
                                    },
                                  );

                                  bool matched = false;
                                  for (var marker1 in markers) {
                                    if (marker1.markerId == marker.markerId) {
                                      matched = true;
                                    }
                                  }

                                  if (!matched) {
                                    markers.add(marker);
                                    addHeatedMarkers(marker);

                                    mounted ? setState(() {}) : null;
                                  }
                                },
                                transitionBuilder: (context, suggestionsBox, controller) {
                                  return suggestionsBox;
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40, bottom: 10),
                      child: fullWidthButton(index == 0 ? TempLanguage.checkIn : TempLanguage.checkOut, () {
                        if (FirebaseAuth.instance.currentUser == null) {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title:
                                        poppinsText(TempLanguage.logInForFeatures, 16, FontWeight.w500, appBlackColor),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Get.off(() => StartView(isBack: true));
                                        },
                                        child: Text(TempLanguage.logIn),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(TempLanguage.cancel),
                                      ),
                                    ],
                                  ));
                        } else {
                          withinRadius == true || index == 1
                              ? _buttonPress()
                              : Get.snackbar(TempLanguage.notAtCourtToastTitle, TempLanguage.notAtCourtToastMessage,
                                  backgroundColor: appWhiteColor,
                                  borderWidth: 4,
                                  borderColor: appBlackColor,
                                  colorText: appBlackColor);
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 150,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  setCurrentLocationOnMap();
                },
                backgroundColor: blueAccentColor,
                child: Icon(
                  Icons.gps_fixed,
                  color: appWhiteColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    // Cancel the location stream subscription
    _positionStreamSubscription?.cancel();
  }
}
