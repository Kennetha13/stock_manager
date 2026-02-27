import 'package:flutter/material.dart';

void goToPage(BuildContext context, Widget page) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => page,
    ),
  );
}