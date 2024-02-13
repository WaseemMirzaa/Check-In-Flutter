// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'package:check_in/auth_service.dart';
import 'package:check_in/core/constant/app_assets.dart';
import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/model/user_modal.dart';
import 'package:check_in/ui/screens/contact_us.dart';
import 'package:check_in/ui/screens/persistent_nav_bar.dart';
import 'package:check_in/ui/screens/privacy_policy.dart';
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
import '../../constants.dart';
import '../../core/constant/constant.dart';
import '../../utils/CourtsParser.dart';

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
  final int _previousZoomLevel = 12;
  double heatmapZoomFactor = 2.5;
  int searchRadius = 30 * 1000;

  StreamSubscription<Position>? _positionStreamSubscription;

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  final auth = FirebaseAuth.instance;
  final snap = FirebaseFirestore.instance;

  DocumentReference docRef = FirebaseFirestore.instance
      .collection(Collections.USER)
      .doc(FirebaseAuth.instance.currentUser!.uid);

  LatLng? loc;

  var courtN;
  bool? data;

  Map<String, dynamic> courtInfo = {};

  TextEditingController typeAheadController = TextEditingController();

  final _places = GoogleMapsPlaces(apiKey: Constants.API_KEY);
  String _selectedPlace = '';

  Position? currentLocation;
  final Completer<GoogleMapController> _googleMapController = Completer();
  GoogleMapController? _mapController;

  Set<Marker> markers = Set<Marker>.identity();

  LatLng? _selectedLocation;

  Future<Position> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // courtNames();
    print(currentLocation?.longitude);
    if (mounted) {
      setState(() {
        currentLocation = position;
        _selectedLocation =
            LatLng(currentLocation!.latitude, currentLocation!.latitude);
        courtNames();
      });
    }

    return Future.value(currentLocation);
  }

  Future courtNames() async {
    await snap
        .collection(Collections.GOLDEN_LOCATIONS)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        double latitude = doc.data()[CourtKey.LAT];
        double longitude = doc.data()[CourtKey.LNG];
        String name = doc.data()[CourtKey.NAME];

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
        markers.add(marker);
      }
      if (mounted) setState(() {});
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
          _selectedPlace = place.title;
          // pushNewScreen(
          //   context,
          //   screen: PlayersView(courtLatLng: location),
          //   withNavBar: false,
          // );
        },
      );
      markers.add(marker);
    }

    if (mounted) {
      setState(() {
        markers = markers;
      });
    }
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
    if (mounted) setState(() {});

    return Future.value(currentLocation);
  }

  bool _checkIfWithinRadius(Position userPos, LatLng court) {
    double distanceInMeters = Geolocator.distanceBetween(
        userPos.latitude, userPos.longitude, court.latitude, court.longitude);
    if (distanceInMeters <= 100) {
      print("user in radius");
      return true;
    } else {
      // print("user not in radius");
      return false;
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
    getCurrentLocation();
    super.initState();
  }

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
                  pushNewScreen(context,
                      screen: const ContactUs(), withNavBar: false);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.privacy_tip,
                ),
                title: Text(TempLanguage.privacyPolicy),
                onTap: () {
                  pushNewScreen(context,
                      screen: const PrivacyPolicy(), withNavBar: false);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.privacy_tip,
                ),
                title: Text(TempLanguage.termsAndConditions),
                onTap: () {
                  pushNewScreen(context,
                      screen: const TermsAndConditions(), withNavBar: false);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.logout_outlined,
                ),
                title: Text(TempLanguage.logOut),
                onTap: () async {
                  logout(context);
                  userController.userModel.value = UserModel();
                },
              ),
              ListTile(
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
                          // mapToolbarEnabled: false,
                          zoomControlsEnabled: true,
                          zoomGesturesEnabled: true,
                          myLocationButtonEnabled: false,
                          myLocationEnabled: true,
                          // onTap: (LatLng latLng) {
                          //   setState(() {
                          //     _selectedLocation = latLng;
                          //     // markers = {
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
                          markers: markers,
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
                                color: appGreenColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: appWhiteColor,
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
                                      top: 15,
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
                                  final courts = await CourtsParser()
                                      .getCourtsByNameOrAddressFromCSVFile(
                                          pattern);

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
                                  if (mounted) {
                                    setState(() {
                                      _selectedPlace =
                                          prediction.title as String;
                                    });
                                  }
                                  typeAheadController.text = _selectedPlace;

                                  // var placeId = prediction.placeId;
                                  // var detail = await _places
                                  //     .getDetailsByPlaceId(placeId as String);
                                  // var location =
                                  //     detail.result.geometry!.location;
                                  var lat = prediction.latitude;
                                  var lng = prediction.longitude;

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
                                      _selectedPlace = prediction.title;
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
                                    if (mounted) setState(() {});
                                  }
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
                        child: fullWidthButton(TempLanguage.select, () async {
                          var selectedLocationName = "";

                          if (_selectedPlace.isNotEmpty) {
                            selectedLocationName = _selectedPlace;
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
                          userController.userModel.value.homeCourt =
                              selectedLocationName;
                          FirebaseFirestore.instance
                              .collection(Collections.USER)
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .update(
                                  {UserKey.HOME_COURT: selectedLocationName});
                          pushNewScreen(context,
                              screen: const Home(), withNavBar: false);
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
