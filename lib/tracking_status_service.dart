import 'package:flutter/material.dart';

import 'core/constant/temp_language.dart';

class TrackingStatusService{


  static Future<void> showCustomTrackingDialog(BuildContext context) async =>
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(TempLanguage.dearUser),
          content: Text(
            TempLanguage.alertContentText,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(TempLanguage.continueButton),
            ),
          ],
        ),
      );

}