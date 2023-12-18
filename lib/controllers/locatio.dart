// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print

import 'package:check_in/core/constant/temp_language.dart';
import 'package:check_in/loc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_webservice/src/places.dart';

class LocationController extends GetxController {
  final Placemark _pickPlaceMark = Placemark();
  Placemark get pickPlaceMark => _pickPlaceMark;

  List<Prediction> _predictionList = [];

  Future<List<Prediction>> searchLocation(
      BuildContext context, String text) async {
    if (text.isNotEmpty) {
      http.Response response = await getLocationData(text);
      var data = jsonDecode(response.body.toString());
      print("my status is " + data["status"]);
      if (data['status'] == TempLanguage.ok) {
        _predictionList = [];
        data['predictions'].forEach((prediction) =>
            _predictionList.add(Prediction.fromJson(prediction)));
      } else {
        // ApiChecker.checkApi(response);
      }
    }
    return _predictionList;
  }
}
