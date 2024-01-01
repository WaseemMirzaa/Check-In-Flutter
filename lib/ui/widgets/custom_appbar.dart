import 'package:flutter/material.dart';

import '../../utils/colors.dart';

// ignore: must_be_immutable
class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  Widget? title;
  bool showicon;
  List<Widget>? actions;
  CustomAppbar(
      {super.key,
      this.title,
      this.actions,
      this.showicon = true,
    });

  @override
  Widget build(BuildContext context) {
    return AppBar(
        leading: showicon
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: blackColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : const SizedBox(),
        backgroundColor: whiteColor,
        centerTitle: true,
        title: title,
        elevation: 0,
        actions: actions);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
