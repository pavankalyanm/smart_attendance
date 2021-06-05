import 'package:smart_attendance/pages/Login/login1.dart';
import 'package:smart_attendance/pages/admin/adminview.dart';
import 'package:smart_attendance/pages/teacher/home.dart';
import 'package:smart_attendance/pages/welcome.dart';
import 'package:flutter/material.dart';
//import 'package:smart_attendance/globals.dart' as globals;
import 'package:smart_attendance/globals.dart' as globals;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_attendance/services/checkRole.dart';
import 'package:smart_attendance/services/AuthService.dart';

//import 'package:splashscreen/splashscreen.dart';
import 'package:flutter_splash/flutter_splash.dart';
import 'package:animated_splash/animated_splash.dart';

//final FirebaseAuth _auth = FirebaseAuth.instance;
String uid;






 /*@override
  Widget build(BuildContext context) {

   // debugPrint("${inputData()}");
    void getid(String foo) {
      uid = foo;
    }

    AuthService().getCurrentUID().then((value) => getid(value));


    loadDetails.load(uid);

   // Widget _home = checkRole().check(uid);


    return MaterialApp(
      title: 'Smart Attendance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      //user(_currentUser);
      home: checkRole().check(uid) ,
    );
  }
}*/



//import 'package:flutter/material.dart';
//import 'package:flutter_splash/flutter_splash.dart';

void main() {
  Function duringSplash = () {
    void getid(String foo) {
      uid = foo;
    }

    AuthService().getCurrentUID().then((value) => getid(value));


    loadDetails.load(uid);
    return 1;
  };

  Map<int, Widget> op = {1: Home(), };

  runApp(MaterialApp(
    home: AnimatedSplash(
      imagePath: 'assets/res/jntu.png',
      home: Home(),
      customFunction: duringSplash,
      duration: 2500,
      type: AnimatedSplashType.BackgroundProcess,
      outputAndHome: op,
    ),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return checkRole().check(uid);
  }
}
