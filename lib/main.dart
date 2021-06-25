import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:smart_attendance/services/sharedpreferences.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
//final FirebaseAuth _auth = FirebaseAuth.instance;
String uid;
Widget home;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Clean Code',
        home: AnimatedSplashScreen.withScreenFunction(
            duration: 2500,
            splash: 'assets/res/jntu.png',
            screenFunction: () async{

              final SharedPreferences preferences=await SharedPreferences.getInstance();
              uid= await preferences.getString('userid');
              if(uid==null){
                home=Login();
              }else{
                await loadDetails.load(uid);
                home=checkRole().check(uid);
              }


              return home ;
            },
            splashTransition: SplashTransition.fadeTransition,
           // pageTransitionType: PageTransitionType.scale,
            backgroundColor: Colors.blue
        )
    );
  }
}
