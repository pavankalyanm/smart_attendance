import 'package:flutter/material.dart';


showSnackBar(String value) {
  SnackBar(
    duration: new Duration(seconds: 5),
    behavior: SnackBarBehavior.floating,
    content: Text(
      '$value',
      style: TextStyle(color: Colors.white),
    ),
  );
}