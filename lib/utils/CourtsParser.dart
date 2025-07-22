import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:csv/csv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../model/CourtModel.dart';

class CourtsParser {
  static final List<CourtModel> additionalLocations = [];

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/check-in-data.txt');
  }

  Future<List<CourtModel>> getCourtsFromCSVFileAndFirestore() async {
    final List<CourtModel> filteredLocations = [];

    print('Starting to get courts from CSV and Firestore');

    Position currentLocation;
    try {
      currentLocation = await getCurrentLocation();
      print('Got current location successfully');
    } catch (e) {
      print('Error getting current location: $e');
      return filteredLocations; // Return empty list if location fails
    }

    try {
      var csvString = await loadAsset();
      print('Loaded CSV file successfully, length: ${csvString.length}');

      var csvData = const CsvToListConverter().convert(csvString, eol: "\n");
      print('Parsed CSV data, found ${csvData.length} rows');

      int addedCount = 0;
      for (var i = 1; i < csvData.length; i++) {
        try {
          final location = CourtModel(
            city: csvData[i][0].toString(),
            street: csvData[i][1].toString(),
            placeId: csvData[i][2].toString(),
            latitude: double.parse(csvData[i][3].toString()),
            longitude: double.parse(csvData[i][4].toString()),
            state: csvData[i][5].toString(), // Fixed: state is column 5
            url: csvData[i][6].toString(), // Fixed: url is column 6
            address: csvData[i][7].toString(),
            title: csvData[i][8].toString(),
          );

          final court = LatLng(location.latitude, location.longitude);
          var isInRadius = checkIfWithinRadius(currentLocation, court);
          // final distance = Geodesy().distanceBetweenTwoGeoPoints(
          //   currentPosition,
          //   locationPosition,
          // );

          if (isInRadius) {
            // Distance in meters (50km = 50000m)
            filteredLocations.add(location);
            addedCount++;
          }
        } catch (e) {
          print('Error parsing CSV row $i: $e');
        }
      }
      print('Added $addedCount courts from CSV within radius');
    } catch (e) {
      print('Error processing CSV file: $e');
    }

    final snap = FirebaseFirestore.instance;

    try {
      print('Fetching additional locations from Firestore');
      await snap.collection('AdditionalLocations').get().then((querySnapshot) {
        print(
            'Found ${querySnapshot.docs.length} additional locations in Firestore');
        for (var doc in querySnapshot.docs) {
          try {
            final location = CourtModel(
              city: doc.data()['city'],
              street: doc.data()['street'],
              placeId: doc.data()['placeId'] ?? '',
              latitude: doc.data()['latitude'],
              longitude: doc.data()['longitude'],
              url: doc.data()['url'],
              state: doc.data()['state'],
              address: doc.data()['address'],
              title: doc.data()['title'],
            );

            additionalLocations.add(location);

            final court = LatLng(location.latitude, location.longitude);
            var isInRadius = checkIfWithinRadius(currentLocation, court);

            if (isInRadius) {
              // Distance in meters (50km = 50000m)
              filteredLocations.add(location);
            }
          } catch (e) {
            print('Error processing Firestore document ${doc.id}: $e');
            print(doc.toString());
          }
        }
      });
    } catch (e) {
      print('Error fetching from Firestore: $e');
    }

    print('Total courts found within radius: ${filteredLocations.length}');
    return filteredLocations;
  }

  Future<List<CourtModel>> getCourtsByNameOrAddressFromCSVFile(
      String search) async {
    final List<CourtModel> filteredLocations = [];

    try {
      final currentLocation = await getCurrentLocation();

      var csvString = await loadAsset();

      var csvData = const CsvToListConverter().convert(csvString, eol: "\n");

      for (var i = 1; i < csvData.length; i++) {
        final location = CourtModel(
          city: csvData[i][0].toString(),
          street: csvData[i][1].toString(),
          placeId: csvData[i][2].toString(),
          latitude: double.parse(csvData[i][3].toString()),
          longitude: double.parse(csvData[i][4].toString()),
          state: csvData[i][5].toString(), // Fixed: state is column 5
          url: csvData[i][6].toString(), // Fixed: url is column 6
          address: csvData[i][7].toString(),
          title: csvData[i][8].toString(),
        );

        // Filter courts based on address
        if (location.title.toLowerCase().contains(search.toLowerCase()) ||
            location.address.toLowerCase().contains(search.toLowerCase())) {
          final court = LatLng(location.latitude, location.longitude);
          var isInRadius = checkIfWithinRadius(currentLocation, court);
          if (isInRadius) {
            // Distance in meters (50km = 50000m)
            filteredLocations.add(location);
          }
        }
      }

      for (var location in additionalLocations) {
        // Filter courts based on address
        if (location.title.toLowerCase().contains(search.toLowerCase()) ||
            location.address.toLowerCase().contains(search.toLowerCase())) {
          final court = LatLng(location.latitude, location.longitude);
          var isInRadius = checkIfWithinRadius(currentLocation, court);
          if (isInRadius) {
            // Distance in meters (50km = 50000m)
            filteredLocations.add(location);
          }
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
      // print("user not in radius");
      return false;
    }
  }

  Future<Position> getCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Location permission denied: $permission');
        throw Exception('Location permission denied');
      }

      final currentLocation = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter:
              10, // Minimum distance for location updates (in meters)
        ),
      );

      print(
          'Current location: ${currentLocation.latitude}, ${currentLocation.longitude}');
      return currentLocation;
    } catch (e) {
      print('Error getting current location: $e');
      rethrow;
    }
  }
}
