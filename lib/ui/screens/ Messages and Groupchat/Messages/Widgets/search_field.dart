// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  TextEditingController? controller;
  Function(String)? onchange;
  SearchField({super.key, this.controller, this.onchange});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(40),
      child: TextFormField(
        
        onChanged: onchange,
        controller: controller,
        decoration: InputDecoration(
            hintText: 'Search',
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(40),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(40),
            ),
            suffixIcon: const Icon(Icons.search)),
      ),
    );
  }
}
