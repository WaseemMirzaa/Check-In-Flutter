import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

Widget loaderView({Color? loaderColor = greenColor}) {
  return Center(
      child: CircularProgressIndicator(
    color: loaderColor,
  ));
}
