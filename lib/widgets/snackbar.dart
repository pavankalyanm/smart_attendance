import 'package:flutter/material.dart';




class showInSnackbar {


  static showSnackbar(_scaffoldKey, String msg) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
        content: new Text(msg),
        ));
  }


}