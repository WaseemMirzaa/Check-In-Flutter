

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

var courtsList = [
  'pexels-king-siberia-2277981',
  'pexels-ricardo-esquivel-1607855',
  'pexels-daniel-absi-680074',
  'pexels-tom-jackson-2891884',
  'pexels-tom-jackson-2891884',
  'pexels-king-siberia-2277981',
  'pexels-ricardo-esquivel-1607855',
  'pexels-daniel-absi-680074',
  'pexels-tom-jackson-2891884',
  'pexels-tom-jackson-2891884',
  'pexels-king-siberia-2277981',
  'pexels-ricardo-esquivel-1607855',
  'pexels-daniel-absi-680074',
  'pexels-tom-jackson-2891884',
  'pexels-tom-jackson-2891884',
  'pexels-king-siberia-2277981',
  'pexels-ricardo-esquivel-1607855',
  'pexels-daniel-absi-680074',
  'pexels-tom-jackson-2891884',
  'pexels-tom-jackson-2891884',
];

 Future<bool> showExitPopup(BuildContext? context) async {
    return await showDialog(
          context: context!,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you want to exit an App?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                //return false when click on "NO"
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                //return true when click on "Yes"
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false; //if showDialouge had returned null, then return false
  }
