import 'dart:async';

import 'package:checkinmod/ui/screens/persistent_nav_bar.dart';
import 'package:checkinmod/ui/widgets/common_button.dart';
import 'package:checkinmod/utils/colors.dart';
import 'package:checkinmod/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

import '../../main.dart';
import '../../prov.dart';
import '../../utils/gaps.dart';

class AddHomeCourt extends StatefulWidget {
  const AddHomeCourt({Key? key}) : super(key: key);

  @override
  State<AddHomeCourt> createState() => _AddHomeCourtState();
}

class _AddHomeCourtState extends State<AddHomeCourt>
    with SingleTickerProviderStateMixin {
  // TextEditingController con = TextEditingController();
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  LocationData? currentLocation;

  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController googleController;

  Future<LocationData> getCurrentLocation() async {
    Location location = Location();
    await location.getLocation().then(
          (location) => currentLocation = location,
        );
    print(currentLocation?.longitude);
    setState(() {});
    return Future.value(currentLocation);
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provmaps = Get.put(GetxMaps());
    return provmaps.activegps == false
        ? Scaffold(
            body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'You must activate GPS to get your location',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      provmaps.getUserLocation();
                    },
                    child: const Text('try again'),
                  )
                ],
              ),
            ),
          ))
        : Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child:
                        //currentLocation == null
                        //     ? Center(child: Text("Loading...")) :
                        Stack(children: [
                      // GoogleMap(
                      //   initialCameraPosition: CameraPosition(
                      //     target: LatLng(currentLocation!.latitude!,
                      //         currentLocation!.longitude!),
                      //     zoom: 16,
                      //   ),
                      //   markers: {},
                      //   // onCameraMove: (position) async {
                      //   //   Location location = Location();
                      //   //   location = position.target as Location;
                      //   //   setState(() {

                      //   //   });
                      //   //   GoogleMapController googleMapController =
                      //   //       await _controller.future;

                      //   //   location.onLocationChanged.listen((newLoc) {
                      //   //     currentLocation = newLoc;
                      //   //     setState(() {});
                      //   //   });
                      //   // },
                      //   onMapCreated: (mapController) {
                      //     googleController = mapController;
                      //     _controller.complete(mapController);
                      //   },
                      // ),
                      GoogleMap(
                        zoomControlsEnabled: false,
                        mapType: MapType.normal,
                        markers: provmaps.markers,
                        onCameraMove: provmaps.onCameraMove,
                        initialCameraPosition: CameraPosition(
                            target: provmaps.initialPos, zoom: 18.0),
                        onMapCreated: provmaps.onCreated,
                        onCameraIdle: () async {
                          provmaps.getMoveCamera();
                        },
                      ),
                      Positioned(
                        bottom: 100,
                        right: 20,
                        child: FloatingActionButton(
                          onPressed: provmaps.getUserLocation,
                          backgroundColor: Colors.blueAccent,
                          child: const Icon(
                            Icons.gps_fixed,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.location_pin,
                          size: 50,
                          color: Colors.redAccent,
                        ),
                      ),
                    ]),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      pushNewScreen(context,
                                          screen: Home(), withNavBar: false);
                                    },
                                    child: SizedBox(
                                      height: 2.1.h,
                                      width: 2.9.w,
                                      child: Image.asset(
                                          "assets/images/Path 6.png"),
                                    ),
                                  ),
                                  poppinsText(
                                      "Add Home Court", 20, bold, blackColor),
                                  const SizedBox(
                                    width: 10,
                                  )
                                ],
                              ),
                              verticalGap(30),
                              
                              Material(
                                borderRadius: BorderRadius.circular(10),
                                elevation: 2,
                                shadowColor: Colors.grey,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: TextField(
                                    maxLines: 1,
                                    controller: provmaps.locationController,
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            left: 20, top: 15),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
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
                                            )
                                          ],
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          fullWidthButton("SELECT", () {
                            con = provmaps.locationController.text;
                            FirebaseFirestore.instance
                                .collection("USER")
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({"home court" : con});
                            pushNewScreen(context,
                                screen: Home(), withNavBar: false);
                          })
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
