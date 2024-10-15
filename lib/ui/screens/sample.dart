// ignore_for_file: library_private_types_in_public_api

import 'package:check_in/core/constant/temp_language.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({Key? key}) : super(key: key);

  @override
  _MyNavigationBarState createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    Text(TempLanguage.homePage,
        style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text(TempLanguage.searchPage,
        style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text(TempLanguage.searchPage,
        style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Flutter BottomNavigationBar Example'),
          backgroundColor: lightGreenColor),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                label: "f",
                icon: const Icon(Icons.home),
                backgroundColor: lightGreenColor),
            BottomNavigationBarItem(
                label: "f",
                icon: const Icon(Icons.search),
                backgroundColor: yellowColor),
            BottomNavigationBarItem(
              label: "f",
              icon: const Icon(Icons.person),
              backgroundColor: appBlueColor,
            ),
          ],
          type: BottomNavigationBarType.shifting,
          currentIndex: _selectedIndex,
          selectedItemColor: appBlackColor,
          iconSize: 40,
          onTap: _onItemTapped,
          elevation: 5),
    );
  }
}
