import 'dart:async';
import 'package:checkinmod/auth_service.dart';
import 'package:checkinmod/modal/user_modal.dart';
import 'package:checkinmod/search_location.dart';
import 'package:checkinmod/ui/screens/contact_us.dart';
import 'package:checkinmod/ui/screens/player.dart';
import 'package:checkinmod/ui/screens/privacy_policy.dart';
import 'package:checkinmod/ui/screens/start.dart';
import 'package:checkinmod/ui/screens/terms_conditions.dart';
import 'package:checkinmod/ui/widgets/common_button.dart';
import 'package:checkinmod/utils/colors.dart';
import 'package:checkinmod/utils/styles.dart';
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

class CheckIn extends StatefulWidget {
  const CheckIn({Key? key}) : super(key: key);

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> with SingleTickerProviderStateMixin {
  int? index;
  bool withinRadius = false;

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  final auth = FirebaseAuth.instance;
  final snap = FirebaseFirestore.instance;

  DocumentReference docRef = FirebaseFirestore.instance
      .collection('USER')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  static const LatLng court1 = LatLng(33.6296, 73.1123);
  static const LatLng court2 = LatLng(33.713335, 73.061926);
  LatLng? loc;

  var courtN;
  bool? data;

  Map<String, dynamic> courtInfo = {};

  TextEditingController typeAheadController = TextEditingController();

  final _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyAWfUP79VGyEn-89MFapzNHNiYfT92zdBs');
  String _selectedPlace = '';

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

  Position? currentLocation;
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController googleController;

  Set<Marker> _markers = Set<Marker>.identity();

  Future<Position> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    courtNames();
    print(currentLocation?.longitude);
    setState(() {
      currentLocation = position;
    });
    // GoogleMapController googleMapController = await _controller.future;

    // location.onLocationChanged.listen((newLoc) {
    //   currentLocation = newLoc;

    //   googleMapController.animateCamera(
    //     CameraUpdate.newCameraPosition(
    //       CameraPosition(
    //         zoom: 16,
    //         target: LatLng(newLoc.latitude!, newLoc.longitude!),
    //       ),
    //     ),
    //   );
    //   setState(() {});
    // }
    // );

    return Future.value(currentLocation);
  }

  Future courtNames() async {
    //  await snap.collection('goldenLocations').get().then((querySnapshot) {
    //   querySnapshot.docs.forEach((doc) {
    //     double latitude = doc.data()['latitude'];
    //     double longitude = doc.data()['longitude'];
    //     LatLng location = LatLng(latitude, longitude);
    //     if (withinRadius == false) {
    //       withinRadius =
    //           _checkIfWithinRadius(currentLocation as Position, location);
    //       if (withinRadius == true) {
    //         loc = location;
    //         courtN = doc.id;
    //         courtInfo.addAll({
    //           "courtLat": loc!.latitude,
    //           "courtLng": loc!.longitude,
    //           "courtName": courtN,
    //         });
    //       }
    //       print(loc!.latitude);
    //     }
    //     print(withinRadius);
    //     Marker marker = Marker(
    //       markerId: MarkerId(doc.id),
    //       position: location,
    //       infoWindow: InfoWindow(title: doc.id),
    //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    //       onTap: () {
    //         pushNewScreen(context,
    //             screen: PlayersView(courtLatLng: location), withNavBar: false);
    //       },
    //     );
    //     _markers.add(marker);
    //   });

    // });

    // await snap.collection('courtLocations').get().then((querySnapshot) {
    //   querySnapshot.docs.forEach((doc) {
    //     double latitude = doc.data()['latitude'];
    //     double longitude = doc.data()['longitude'];
    //     LatLng location = LatLng(latitude, longitude);
    //     if (withinRadius == false) {
    //       withinRadius =
    //           _checkIfWithinRadius(currentLocation as Position, location);
    //       if (withinRadius == true) {
    //         loc = location;
    //         courtN = doc.id;
    //         courtInfo.addAll({
    //           "courtLat": loc!.latitude,
    //           "courtLng": loc!.longitude,
    //           "courtName": courtN,
    //         });
    //       }
    //       print(loc!.latitude);
    //     }
    //     print(withinRadius);
    //     Marker marker = Marker(
    //       markerId: MarkerId(doc.id),
    //       position: location,
    //       infoWindow: InfoWindow(title: doc.id),
    //       onTap: () {
    //         pushNewScreen(context,
    //             screen: PlayersView(courtLatLng: location), withNavBar: false);
    //       },
    //     );
    //     _markers.add(marker);
    //   });

    //   if (currentLocation != null) {
    //     Marker userMarker = Marker(
    //       markerId: const MarkerId("userLocation"),
    //       position: LatLng(
    //         currentLocation!.latitude,
    //         currentLocation!.longitude,
    //       ),
    //       infoWindow: const InfoWindow(title: "Your location"),
    //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    //     );
    //     _markers.add(userMarker);
    //   }

    //   setState(() {
    //     _markers = _markers;
    //   });
    // });
    await snap.collection('goldenLocations').get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        double latitude = doc.data()['latitude'];
        double longitude = doc.data()['longitude'];
        LatLng location = LatLng(latitude, longitude);
        Marker marker = Marker(
          markerId: MarkerId(doc.id),
          position: location,
          infoWindow: InfoWindow(title: doc.id),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          onTap: () {
            pushNewScreen(context,
                screen: PlayersView(courtLatLng: location), withNavBar: false);
          },
        );
        _markers.add(marker);
      });
      setState(() {});
    });

    if (currentLocation != null) {
      Marker userMarker = Marker(
        markerId: const MarkerId("userLocation"),
        position: LatLng(
          currentLocation!.latitude,
          currentLocation!.longitude,
        ),
        infoWindow: const InfoWindow(title: "Your location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      _markers.add(userMarker);
    }

    setState(() {
      _markers = _markers;
    });

    final placesResponse = await _places.searchNearbyWithRadius(
      Location(
        lat: currentLocation!.latitude,
        lng: currentLocation!.longitude,
      ),
      100000,
      type: 'court',
      name: 'ball court',
    );

    placesResponse.results.forEach((place) {
      LatLng location = LatLng(
        place.geometry!.location.lat,
        place.geometry!.location.lng,
      );

      // Check if the marker is within the radius
      bool withinRadius = _checkIfWithinRadius(currentLocation!, location);

      if (withinRadius) {
        loc = location;
        courtN = place.name;
        courtInfo.addAll({
          "courtLat": loc!.latitude,
          "courtLng": loc!.longitude,
          "courtName": courtN,
        });
      }

      print(withinRadius);
      Marker marker = Marker(
        markerId: MarkerId(place.placeId),
        position: location,
        infoWindow: InfoWindow(
          title: place.name,
          snippet: place.vicinity,
        ),
        onTap: () {
          pushNewScreen(
            context,
            screen: PlayersView(courtLatLng: location),
            withNavBar: false,
          );
        },
      );
      _markers.add(marker);
    });

    setState(() {
      _markers = _markers;
    });
  }

  Future<Position> goCurrentLoc() async {
    GoogleMapController googleMapController = await _controller.future;

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

  bool _checkIfWithinRadius(Position user, LatLng court) {
    double distanceInMeters = Geolocator.distanceBetween(
        user.latitude, user.longitude, court.latitude, court.longitude);
    if (distanceInMeters <= 100) {
      print("user in radius");
      return true;
    } else {
      print("user not in radius");
      return false;
    }
  }

  void _buttonPress() {
    changeIndex();
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

      print(index);
      // print(withinRadius);
    } else if (index == 0) {
      snap.collection("USER").doc(auth.currentUser!.uid).update({
        "checkedIn": false,
        "courtLat": FieldValue.delete(),
        "courtLng": FieldValue.delete(),
      });
    }
  }

  // void _updateLocation() {
  //   bool withinRadius = _checkIfWithinRadius();
  //   FirebaseFirestore.instance
  //       .collection("USER")
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .update({});
  // }

  // void setCustomMarkerIcon() {
  //   BitmapDescriptor.fromAssetImage(
  //           ImageConfiguration.empty, "assets/images/Icon feather-edit-2.png")
  //       .then(
  //     (icon) => sourceIcon = icon,
  //   );
  //   BitmapDescriptor.fromAssetImage(
  //           ImageConfiguration.empty, "assets/images/Icon feather-edit-2.png")
  //       .then(
  //     (icon) => destinationIcon = icon,
  //   );
  //   BitmapDescriptor.fromAssetImage(
  //           ImageConfiguration.empty, "assets/images/Icon feather-map-pin.png")
  //       .then(
  //     (icon) => currentLocationIcon = icon,
  //   );
  //   setState(() {});
  // }

  @override
  void initState() {
    // setCustomMarkerIcon();
    getCurrentLocation();
    indexValue();
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
                    : GoogleMap(
                        mapToolbarEnabled: false,
                        zoomControlsEnabled: false,
                        compassEnabled: false,
                        // tileOverlays: ,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(currentLocation!.latitude,
                              currentLocation!.longitude),
                          zoom: 16,
                        ),
                        markers: _markers,
                        // {
                        //   Marker(
                        //     markerId: const MarkerId("current location"),
                        //     icon: currentLocationIcon,
                        //     position: LatLng(currentLocation!.latitude,
                        //         currentLocation!.longitude),
                        //   ),
                        //   Marker(
                        //     markerId: const MarkerId("source"),
                        //     icon: sourceIcon,
                        //     position: court1,
                        //   ),
                        //   Marker(
                        //     markerId: const MarkerId("destination"),
                        //     icon: destinationIcon,
                        //     position: court2,
                        //   ),
                        // },
                        onMapCreated: (mapController) {
                          googleController = mapController;
                          _controller.complete(mapController);
                        },
                      ),
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
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
                                    50000, // Search radius in meters
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
                                      await _controller.future;
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
                    fullWidthButton(index == 0 ? "CHECK IN" : "CHECK OUT", () {
                      // changeIndex();
                      // if (index == 1)
                      //   pushNewScreen(context,
                      //       screen: const PlayersView(), withNavBar: false);
                      // print(index);
                      withinRadius == true
                          ? _buttonPress()
                          : Get.snackbar("Error", "Reach court to checkin",
                              backgroundColor: Colors.green,
                              borderWidth: 4,
                              borderColor: Colors.black);
                    }),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  goCurrentLoc();
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
}
