import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:check_in/auth_service.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/search_location.dart';
import 'package:check_in/ui/screens/contact_us.dart';
import 'package:check_in/ui/screens/persistent_nav_bar.dart';
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
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

// import 'package:location/location.dart' ;
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../utils/CourtsParser.dart';
import 'Players.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class AddHomeCourt extends StatefulWidget {
  final isMyProfile;

  const AddHomeCourt({Key? key, bool this.isMyProfile = true})
      : super(key: key);

  @override
  State<AddHomeCourt> createState() => _AddHomeCourtState();
}

class _AddHomeCourtState extends State<AddHomeCourt>
    with SingleTickerProviderStateMixin {
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
      GoogleMapsPlaces(apiKey: Constants.API_KEY);
  String _selectedPlace = '';

  Position? currentLocation;
  final Completer<GoogleMapController> _googleMapController = Completer();
  GoogleMapController? _mapController = null;

  Set<Marker> _markers = Set<Marker>.identity();

  LatLng? _selectedLocation;

  Future<Position> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // courtNames();
    print(currentLocation?.longitude);
    setState(() {
      currentLocation = position;
      _selectedLocation =
          LatLng(currentLocation!.latitude, currentLocation!.latitude);
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
            _selectedPlace = name;
            // pushNewScreen(
            //   context,
            //   screen: PlayersView(courtLatLng: location),
            //   withNavBar: false,
            // );
          },
        );
        _markers.add(marker);
      });
      setState(() {});
    });


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

    final courts  = await CourtsParser().readAndFilterCSVFile();

    // final placesResponse = await getBasketballCourts();

    // placesResponse?.results.forEach((place) {
    courts.forEach((place) {
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
          _selectedPlace = place.title;
          // pushNewScreen(
          //   context,
          //   screen: PlayersView(courtLatLng: location),
          //   withNavBar: false,
          // );
        },
      );
      _markers.add(marker);
    });

    setState(() {
      _markers = _markers;
    });
  }


  Future<Position> setCurrentLocationOnMap() async {
    GoogleMapController googleMapController = await _googleMapController.future;

    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: ZOOM_LEVEL_INITIAL,
          target: LatLng(currentLocation!.latitude, currentLocation!.longitude),
        ),
      ),
    );
    setState(() {});

    return Future.value(currentLocation);
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

  // Future<bool> checkIfWithinRadiusAndSetUserCourtInfo() async {
  //   final placesResponse = await _places.searchNearbyWithRadius(
  //     Location(
  //       lat: currentLocation!.latitude,
  //       lng: currentLocation!.longitude,
  //     ),
  //     200,
  //     type: 'court',
  //     name: 'ball court',
  //   );
  //
  //   withinRadius = false;
  //   placesResponse.results.forEach((place) {
  //     LatLng location = LatLng(
  //       place.geometry!.location.lat,
  //       place.geometry!.location.lng,
  //     );
  //
  //     // Check if the marker is within the radius
  //     withinRadius = _checkIfWithinRadius(currentLocation!, location);
  //
  //     if (withinRadius) {
  //       loc = location;
  //       courtN = place.name;
  //       courtInfo.addAll({
  //         "courtLat": loc!.latitude,
  //         "courtLng": loc!.longitude,
  //         "courtName": courtN,
  //       });
  //     }
  //
  //     print(withinRadius);
  //
  //
  //   });
  //   return Future.value(withinRadius);
  //
  // }

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
    getCurrentLocation();
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
                  "assets/images/logo-new.png",
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
                          // mapToolbarEnabled: false,
                          zoomControlsEnabled: true,
                          zoomGesturesEnabled: true,
                          myLocationButtonEnabled: false,
                          myLocationEnabled: true,
                          // onTap: (LatLng latLng) {
                          //   setState(() {
                          //     _selectedLocation = latLng;
                          //     // _markers = {
                          //     //   // Update the markers set with the selected location
                          //     //   Marker(
                          //     //     markerId: MarkerId('selectedLocation'),
                          //     //     position: _selectedLocation!,
                          //     //   ),
                          //     // };
                          //   });
                          // },
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
                          onCameraMove: (CameraPosition position) {},
                        )),
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
                              Get.back();
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: greenColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
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
                    // fullWidthButton(index == 0 ? "CHECK IN" : "CHECK OUT", () {
                    //   // changeIndex();
                    //   // if (index == 1)
                    //   //   pushNewScreen(context,
                    //   //       screen: const PlayersView(), withNavBar: false);
                    //   // print(index);
                    //   withinRadius == true
                    //       ? _buttonPress()
                    //       : Get.snackbar("Alert", "You are not at a court.",
                    //       backgroundColor: Colors.white,
                    //       borderWidth: 4,
                    //       borderColor: Colors.black,
                    //       colorText: Colors.black);
                    // }),

                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: Visibility(
                        visible: widget.isMyProfile,
                        child: fullWidthButton("SELECT", () async {
                          var _selectedLocationName = "";

                          if (_selectedPlace.isNotEmpty) {
                            _selectedLocationName = _selectedPlace;
                          }
                          // else {
                          //   // Reverse geocode the selected location to get the address
                          //   List<geocoding.Placemark> placemarks =
                          //       await geocoding.placemarkFromCoordinates(
                          //     _selectedLocation!.latitude,
                          //     _selectedLocation!.longitude,
                          //   );
                          //
                          //   if (placemarks.isNotEmpty) {
                          //     setState(() {
                          //       _selectedLocationName = placemarks[0].name;
                          //     });
                          //   }
                          // }

                          FirebaseFirestore.instance
                              .collection("USER")
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .update({"home court": _selectedLocationName});
                          pushNewScreen(context,
                              screen: Home(), withNavBar: false);
                        }),
                      ),
                    )
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
