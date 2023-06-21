import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:csv/csv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../model/CourtModel.dart';

class CourtsParser {
  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/check-in-data.txt');
  }
  Future<List<CourtModel>> getCourtsFromCSVFile() async {
    final List<CourtModel> filteredLocations = [];

    try {
      final currentLocation = await getCurrentLocation();
      final currentPosition = LatLng(
            currentLocation.latitude,
            currentLocation.longitude,
          );

      var csvString = await loadAsset();

      var csvData = CsvToListConverter().convert(csvString);


      for (var i = 1; i < csvData.length; i++) {
            final location = CourtModel(
              city: csvData[i][0].toString(),
              street: csvData[i][1].toString(),
              placeId: csvData[i][2].toString(),
              latitude: double.parse(csvData[i][3].toString()),
              longitude: double.parse(csvData[i][4].toString()),
              url: csvData[i][5].toString(),
              state: csvData[i][6].toString(),
              address: csvData[i][7].toString(),
              title: csvData[i][8].toString(),
            );

            final court = LatLng(location.latitude, location.longitude);
            var isInRadius = checkIfWithinRadius(currentLocation, court);
            // final distance = Geodesy().distanceBetweenTwoGeoPoints(
            //   currentPosition,
            //   locationPosition,
            // );

            if (isInRadius) { // Distance in meters (50km = 50000m)
              filteredLocations.add(location);
            }
          }
    } catch (e) {
      print(e);
    }

    return filteredLocations;
  }

  Future<List<CourtModel>> getCourtsByNameOrAddressFromCSVFile(String search) async {
    final List<CourtModel> filteredLocations = [];

    try {
      final currentLocation = await getCurrentLocation();
      final currentPosition = LatLng(
        currentLocation.latitude,
        currentLocation.longitude,
      );

      var csvString = await loadAsset();

      var csvData = CsvToListConverter().convert(csvString);


      for (var i = 1; i < csvData.length; i++) {
        final location = CourtModel(
          city: csvData[i][0].toString(),
          street: csvData[i][1].toString(),
          placeId: csvData[i][2].toString(),
          latitude: double.parse(csvData[i][3].toString()),
          longitude: double.parse(csvData[i][4].toString()),
          url: csvData[i][5].toString(),
          state: csvData[i][6].toString(),
          address: csvData[i][7].toString(),
          title: csvData[i][8].toString(),
        );

        final court = LatLng(location.latitude, location.longitude);

        // Filter courts based on address
        if (location.title.toLowerCase().contains(search.toLowerCase()) || location.address.toLowerCase().contains(search.toLowerCase())) {
          filteredLocations.add(location);

        }

      }
    } catch (e) {
      print(e);
    }

    return filteredLocations;
  }


  bool checkIfWithinRadius(Position userPos, LatLng court) {
    double distanceInMeters = Geolocator.distanceBetween(
        userPos.latitude, userPos.longitude, court.latitude, court.longitude);
    if (distanceInMeters <= 50000) {
      print("user in radius");
      return true;
    } else {
      print("user not in radius");
      return false;
    }
  }

  Future<Position> getCurrentLocation() async {
    final geolocator = Geolocator();
    final locationOptions = LocationOptions(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10, // Minimum distance for location updates (in meters)
    );

    final permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      throw Exception('Location permission denied');
    }

    final currentLocation = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    return currentLocation;
  }
}
