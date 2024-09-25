import 'package:check_in/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future messageDeleteDialog({Function()? onTap}) {
  return Get.dialog(AlertDialog(
    title: Text(
      'Delete Chat',
      style: TextStyle(fontWeight: FontWeight.w600, color: appBlackColor),
    ),
    content: Text('Are you sure you want to delete all chat messages?',
        style: TextStyle(fontWeight: FontWeight.w400, color: appBlackColor, fontSize: 14)),
    actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('No')),
      TextButton(onPressed: onTap, child: const Text('Yes'))
    ],
  ));
}

Future blockContact({Function()? onTap}) {
  return Get.dialog(AlertDialog(
    title: Text(
      'Block Chat',
      style: TextStyle(fontWeight: FontWeight.w600, color: appBlackColor),
    ),
    content: Text('Are you sure you want to block chat?',
        style: TextStyle(fontWeight: FontWeight.w400, color: appBlackColor, fontSize: 14)),
    actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('No')),
      TextButton(onPressed: onTap, child: const Text('Yes'))
    ],
  ));
}


Future unblockContact({Function()? onTap}) {
  return Get.dialog(AlertDialog(
    title: Text(
      'Unblock Chat',
      style: TextStyle(fontWeight: FontWeight.w600, color: appBlackColor),
    ),
    content: Text('Are you sure you want to unblock chat?',
        style: TextStyle(fontWeight: FontWeight.w400, color: appBlackColor, fontSize: 14)),
    actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('No')),
      TextButton(onPressed: onTap, child: const Text('Yes'))
    ],
  ));
}