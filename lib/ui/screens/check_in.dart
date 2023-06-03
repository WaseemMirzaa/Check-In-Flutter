import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:check_in/auth_service.dart';
import 'package:check_in/modal/user_modal.dart';
import 'package:check_in/search_location.dart';
import 'package:check_in/ui/screens/contact_us.dart';
import 'package:check_in/ui/screens/player.dart';
import 'package:check_in/ui/screens/privacy_policy.dart';
import 'package:check_in/ui/screens/start.dart';
import 'package:check_in/ui/screens/terms_conditions.dart';
import 'package:check_in/ui/widgets/common_button.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_heat_map/flutter_heat_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

// import 'package:location/location.dart' ;
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Players.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({Key? key}) : super(key: key);

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> with SingleTickerProviderStateMixin {
  int? index;
  bool withinRadius = false;
  double ZOOM_LEVEL_INITIAL = 12;
  RxInt heatMapRadius = 45.obs;
  int _previousZoomLevel = 12;
  double heatmapZoomFactor = 2.5;
  int searchRadius = 30 * 1000;
  StreamSubscription<Position>? _positionStreamSubscription;

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  final auth = FirebaseAuth.instance;
  final snap = FirebaseFirestore.instance;

  DocumentReference docRef = FirebaseFirestore.instance
      .collection('USER')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  LatLng? loc;

  var courtN;
  bool? data;

  Map<String, dynamic> courtInfo = {};

  TextEditingController typeAheadController = TextEditingController();

  final _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyAWfUP79VGyEn-89MFapzNHNiYfT92zdBs');
  String _selectedPlace = '';

  Position? currentLocation;
  final Completer<GoogleMapController> _googleMapController = Completer();
  GoogleMapController? _mapController = null;

  Set<Marker> _markers = Set<Marker>.identity();

  List<WeightedLatLng> enabledPoints = <WeightedLatLng>[
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

  void setHeatMapSize(int zoomLevel) {
    heatmapZoomFactor = heatmapZoomFactor + (zoomLevel - _previousZoomLevel);
    heatMapRadius.value = (zoomLevel * (heatmapZoomFactor)).toInt();
    if (heatMapRadius.value < 50) {
      heatMapRadius.value = 50;
    }

    setState(() {});
  }

  Future indexValue() async {
    final document = FirebaseFirestore.instance
        .collection('USER')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    document.get().then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        dynamic pata = snapshot.data();
        data = pata['checkedIn'];
        print("${pata['checkedIn']}Siuuu");
        print(data);
        if (data == false) {
          index = 0;
        } else if (data == true) {
          index = 1;
        }
        setState(() {});
        print("${index} is index");
      } else {
        print('Document does not exist!');
      }
    });
  }

  changeIndex() {
    if (index == 0) {
      index = 1;
    } else {
      index = 0;
    }
    setState(() {});
    print(index);
  }

  Future<Position> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // courtNames();
    print(currentLocation?.longitude);
    setState(() {
      currentLocation = position;
      courtNames();
    });

    return Future.value(currentLocation);
  }

  Future courtNames() async {
    await snap.collection('goldenLocations').get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        double latitude = doc.data()['lat'];
        double longitude = doc.data()['lng'];
        String name = doc.data()['name'];

        LatLng location = LatLng(latitude, longitude);
        Marker marker = Marker(
          markerId: MarkerId(doc.id),
          position: location,
          infoWindow: InfoWindow(title: name),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          onTap: () {
            pushNewScreen(context,
                screen: PlayersView(courtLatLng: location), withNavBar: false);
          },
        );
        _markers.add(marker);
        addHeatedMarkers(marker);

      });
      setState(() {});
    });

    // // Get a reference to the Firestore collection
    // CollectionReference collectionRef =
    // FirebaseFirestore.instance.collection('goldenLocations');
    //
    // // Fetch the documents
    // QuerySnapshot querySnapshot = await collectionRef.get();
    //
    // // Extract the data from the documents
    // List<Map<String, dynamic>> documents = [];
    // querySnapshot.docs.forEach((doc) {
    //   documents.add(doc.data() as Map<String, dynamic>);
    // });

    // // ADDING MY LOCATION MARKER
    // if (currentLocation != null) {
    //   Marker userMarker = Marker(
    //     markerId: const MarkerId("userLocation"),
    //     position: LatLng(
    //       currentLocation!.latitude,
    //       currentLocation!.longitude,
    //     ),
    //     infoWindow: const InfoWindow(title: "Your location"),
    //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    //   );
    //   _markers.add(userMarker);
    // }
    //
    // setState(() {
    //   _markers = _markers;
    // });

    // ADDING PLACCES API COURTS LOCATION MARKER
    final placesResponse = await _places.searchNearbyWithRadius(
      Location(
        lat: currentLocation!.latitude,
        lng: currentLocation!.longitude,
      ),
      searchRadius,
      // 30000,
      type: 'court',
      name: 'ball court',
    );

    placesResponse.results.forEach((place) {
      LatLng location = LatLng(
        place.geometry!.location.lat,
        place.geometry!.location.lng,
      );

      // bool isGolden = false;
      //
      // documents.forEach((golden) {
      //   if(golden['name'] == place.name){
      //     isGolden = true;
      //   }
      // });

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
          title: place.name,
          snippet: place.vicinity,
        ),
        // icon: icon,
        onTap: () {
          pushNewScreen(
            context,
            screen: PlayersView(courtLatLng: location),
            withNavBar: false,
          );
        },
      );
      _markers.add(marker);
      addHeatedMarkers(marker);

    });

    setState(() {
      _markers = _markers;
      addLocationChangeListener();
    });
  }

  void addHeatedMarkers(Marker marker) async {
    // int intensityLevel_1 = 0;
    // int intensityLevel_2 = 10;
    // int intensityLevel_3 = 30;
    // int intensityLevel_4 = 100;

    // int playersGathering = Random().nextInt(100);
    // int playersGathering = 7;
    int playersGathering = await getUsersCountOnLocation(marker.position);

    debugPrint("Court Name:" +
        (marker.infoWindow.title ?? "") +
        " | Users Count: " +
        playersGathering.toString());

    double intensity = playersGathering * 0.1;

    WeightedLatLng point = WeightedLatLng(marker.position, weight: intensity);

    setState(() => enabledPoints.add(point));
  }

  Future<int> getUsersCountOnLocation(LatLng court) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('USER')
        .where('checkedIn', isEqualTo: true)
        .where('courtLat', isEqualTo: court.latitude)
        .where('courtLng', isEqualTo: court.longitude)
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
    setState(() {});

    return Future.value(currentLocation);
  }

  void addLocationChangeListener() {
    // Configure the location callback
    var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.best,
      distanceFilter:
          10, // Minimum distance (in meters) for location change updates
    );

    // Listen for location changes
    _positionStreamSubscription = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.best,
      distanceFilter:
          10, // Minimum distance (in meters) for location change updates
    ).listen((Position position) {
      setState(() {
        currentLocation = position;
        checkIfWithinRadiusAndSetUserCourtInfo();
      });
    });
  }

  bool _checkIfWithinRadius(Position userPos, LatLng court) {
    double distanceInMeters = Geolocator.distanceBetween(
        userPos.latitude, userPos.longitude, court.latitude, court.longitude);
    if (distanceInMeters <= 100) {
      print("user in radius");
      return true;
    } else {
      print("user not in radius");
      return false;
    }
  }

  Future<bool> checkIfWithinRadiusAndSetUserCourtInfo() async {
    withinRadius = false;
    for (Marker marker in _markers) {
      withinRadius = _checkIfWithinRadius(currentLocation!, marker.position);

      if (withinRadius) {
        loc = marker.position;
        courtN = marker.infoWindow.title;
        courtInfo.addAll({
          "courtLat": loc!.latitude,
          "courtLng": loc!.longitude,
          "courtName": courtN,
        });
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

  void _buttonPress() {
    changeIndex();

    //CheckIn Pressed
    if (index == 1) {
      setState(() {
        courtInfo['checkInTime'] =
            DateFormat('HH:mm:ss').format(DateTime.now());
      });
      snap.collection("USER").doc(auth.currentUser!.uid).update({
        "checkedCourts": FieldValue.arrayUnion([courtInfo]),
        "checkedIn": true,
        "courtLat": loc!.latitude,
        "courtLng": loc!.longitude,
      });

      Get.snackbar("Checked In", "You are in the court.",
          backgroundColor: Colors.white,
          borderWidth: 4,
          borderColor: Colors.black,
          colorText: Colors.black);
      print(index);
      // print(withinRadius);
    }
    //Checkout Pressed
    else if (index == 0) {
      snap.collection("USER").doc(auth.currentUser!.uid).update({
        "checkedIn": false,
        "courtLat": FieldValue.delete(),
        "courtLng": FieldValue.delete(),
      });

      Get.snackbar("Checked Out", "You have left the court.",
          backgroundColor: Colors.white,
          borderWidth: 4,
          borderColor: Colors.black,
          colorText: Colors.black);
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

  @override
  void initState() {
    // setCustomMarkerIcon();
    getCurrentLocation();
    indexValue();
    // addLocationChangeListener();
    // _checkIfWithinRadius();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      drawer: Drawer(
        backgroundColor: whiteColor,
        child: Container(
          height: 300,
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: whiteColor,
                ),
                child: Image.asset(
                  "assets/images/logo.jpeg",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ListTile(
                leading: const Icon(
                  Icons.contact_page,
                ),
                title: const Text('Contact Us'),
                onTap: () {
                  pushNewScreen(context,
                      screen: const ContactUs(), withNavBar: false);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.privacy_tip,
                ),
                title: const Text('Privacy Policy'),
                onTap: () {
                  pushNewScreen(context,
                      screen: const PrivacyPolicy(), withNavBar: false);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.privacy_tip,
                ),
                title: const Text('Terms And Conditions'),
                onTap: () {
                  pushNewScreen(context,
                      screen: const TermsAndConditions(), withNavBar: false);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.logout_outlined,
                ),
                title: const Text('LogOut'),
                onTap: () async {
                  logout(context);
                  userController.userModel.value = UserModel();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_forever_outlined,
                ),
                title: const Text('Delete Acc'),
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
                    ? const Center(child: Text("Loading..."))
                    : Obx(() => (GoogleMap(
                            mapToolbarEnabled: false,
                            zoomControlsEnabled: true,
                            zoomGesturesEnabled: true,
                            myLocationButtonEnabled: false,
                            myLocationEnabled: true,

                            // tileOverlays: ,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(currentLocation!.latitude,
                                  currentLocation!.longitude),
                              zoom: ZOOM_LEVEL_INITIAL,
                            ),
                            markers: _markers,
                            onMapCreated: (mapController) {
                              _mapController = mapController;
                              _googleMapController.complete(mapController);
                            },
                            onCameraMove: (CameraPosition position) {
                              int currentZoomLevel = position.zoom.toInt();
                              if (_previousZoomLevel != null &&
                                  currentZoomLevel != _previousZoomLevel) {
                                // Zoom level changed
                                setHeatMapSize(currentZoomLevel);
                                print(
                                    'Zoom level changed: $_previousZoomLevel -> $currentZoomLevel');
                              }
                              _previousZoomLevel = currentZoomLevel;
                            },
                            heatmaps: <Heatmap>{
                              Heatmap(
                                heatmapId: const HeatmapId('test'),
                                data: enabledPoints,
                                gradient: HeatmapGradient(
                                  const <HeatmapGradientColor>[
                                    // Web needs a first color with 0 alpha
                                    // if (kIsWeb)
                                    //   HeatmapGradientColor(
                                    //     Color.fromARGB(0, 0, 255, 255),
                                    //     0,
                                    //   ),
                                    HeatmapGradientColor(
                                      Colors.yellow,
                                      0.2,
                                    ),
                                    HeatmapGradientColor(
                                      Colors.red,
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
                                      Colors.blue,
                                      1,
                                    ),
                                  ],
                                ),
                                maxIntensity: 1,
                                // Radius behaves differently on web and Android/iOS.
                                // For Android: According to documentation, radius should be between 10 to 50
                                radius: kIsWeb
                                    ? 10
                                    : defaultTargetPlatform ==
                                            TargetPlatform.android
                                        ? heatMapRadius.value
                                        : heatMapRadius.value,
                              )
                            }))),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              right: 20,
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
                                  color: greenColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.menu,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                // Add your refresh button functionality here
                                // Get.offAll(CheckIn());
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CheckIn()),
                                    (route) => false);
                                // Navigator.pushReplacement(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => CheckIn()),
                                // );
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: greenColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.refresh,
                                  color: whiteColor,
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
                          shadowColor: Colors.grey,
                          child: SingleChildScrollView(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: TypeAheadField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: typeAheadController,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(
                                      left: 20,
                                      top: 15,
                                    ),
                                    filled: true,
                                    border: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    fillColor: Colors.white,
                                    hintText: "Find Courts Near You",
                                    hintStyle: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: medium,
                                        color: greyColor),
                                    suffixIcon: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 17,
                                          width: 17,
                                          child: Image.asset(
                                            "assets/images/Icon ionic-ios-search.png",
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
                                // suggestionsCallback: (pattern) async {
                                //   return await _places
                                //       .autocomplete(pattern)
                                //       .then((response) {
                                //     return response.predictions;
                                //   });
                                // },
                                // itemBuilder: (context, prediction) {
                                //   return ListTile(
                                //     title: Text(prediction.description as String),
                                //   );
                                // },
                                suggestionsCallback: (pattern) async {
                                  if (currentLocation == null) {
                                    return [];
                                  }
                                  final placesResponse =
                                      await _places.searchNearbyWithRadius(
                                    Location(
                                        lat: currentLocation!.latitude,
                                        lng: currentLocation!.longitude),
                                    searchRadius, // Search radius in meters
                                    type: 'court',
                                    name: 'ball court',
                                    keyword: pattern,
                                  );

                                  return placesResponse.results;
                                },
                                itemBuilder: (context, prediction) {
                                  return ListTile(
                                    title: Text(prediction.name),
                                    subtitle: Text(prediction.vicinity),
                                  );
                                },
                                onSuggestionSelected: (prediction) async {
                                  setState(() {
                                    _selectedPlace = prediction.name as String;
                                  });
                                  typeAheadController.text = _selectedPlace;

                                  var placeId = prediction.placeId;
                                  var detail = await _places
                                      .getDetailsByPlaceId(placeId as String);
                                  var location =
                                      detail.result.geometry!.location;
                                  var lat = location.lat;
                                  var lng = location.lng;

                                  final GoogleMapController controller =
                                      await _googleMapController.future;
                                  controller.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: LatLng(lat, lng),
                                        zoom: 18.0,
                                      ),
                                    ),
                                  );
                                },
                                transitionBuilder:
                                    (context, suggestionsBox, controller) {
                                  return suggestionsBox;
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 40, right: 40, bottom: 10),
                      child: fullWidthButton(
                          index == 0 ? "CHECK IN" : "CHECK OUT", () {
                        // changeIndex();
                        // if (index == 1)
                        //   pushNewScreen(context,
                        //       screen: const PlayersView(), withNavBar: false);
                        // print(index);
                        withinRadius == true || index == 1
                            ? _buttonPress()
                            : Get.snackbar("Alert", "You are not at a court.",
                                backgroundColor: Colors.white,
                                borderWidth: 4,
                                borderColor: Colors.black,
                                colorText: Colors.black);
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
                backgroundColor: Colors.blueAccent,
                child: const Icon(
                  Icons.gps_fixed,
                  color: Colors.white,
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
