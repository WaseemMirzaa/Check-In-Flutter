import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  Widget? title;
  bool showicon;
  Color backgroundColor;
  Color iconColor;
  List<Widget>? actions;
  CustomAppbar({
    super.key,
    this.title,
    this.actions,
    this.showicon = true,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
        leading: showicon
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios, color: iconColor),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : const SizedBox(),
        backgroundColor: backgroundColor,
        centerTitle: true,
        title: title,
        elevation: 0,
        actions: actions);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
