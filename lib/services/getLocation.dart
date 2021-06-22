import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

Position _currentPosition;

class getLocation{

  static getCurrentlocation() async{
    await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
        .then((Position position) {

        _currentPosition = position;

    }).catchError((e) {
      print(e);
    });

    return _currentPosition;
  }

}