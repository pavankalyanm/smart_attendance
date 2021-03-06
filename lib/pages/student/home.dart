import 'dart:io';

import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/faceapi/pages/db/database.dart';
import 'package:smart_attendance/faceapi/pages/sign-in.dart';
import 'package:smart_attendance/faceapi/services/facenet.service.dart';
import 'package:smart_attendance/faceapi/services/ml_kit_service.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

//import 'package:flutter/rendering.dart';
import 'package:smart_attendance/pages/student/Join_Lecture/scan.dart';
import 'package:smart_attendance/pages/student/Previous_Attendance/previous_attendance.dart';
import 'package:smart_attendance/pages/student/Profile/profile.dart';
import 'package:smart_attendance/globals.dart' as globals;
import 'package:smart_attendance/services/validations.dart';
//import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:smart_attendance/pages/welcome.dart';
import 'package:smart_attendance/theme/style.dart' as style;
import 'package:smart_attendance/pages/Login/login1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';


class Student extends StatefulWidget {
  @override
  _StudentState createState() => new _StudentState();
}

class _StudentState extends State<Student> {
//  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//  String _email, _password;
//  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

//  void showInSnackBar(String value) {
//    _scaffoldKey.currentState
//        .showSnackBar(new SnackBar(content: new Text(value)));
//  }

/*  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    print("BACK BUTTON!"); // Do some stuff.
//    _showDialog(context);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage()),
    );
    return true;
  }*/
  FaceNetService _faceNetService = FaceNetService();
  MLKitService _mlKitService = MLKitService();
  DataBaseService _dataBaseService = DataBaseService();

  CameraDescription cameraDescription;
  bool loading = false;



  @override
  void initState() {
    super.initState();
    _startUp();
  }

  /// 1 Obtain a list of the available cameras on the device.
  /// 2 loads the face net model
  _startUp() async {
    _setLoading(true);

    List<CameraDescription> cameras = await availableCameras();

    /// takes the front camera
    cameraDescription = cameras.firstWhere(
          (CameraDescription camera) =>
      camera.lensDirection == CameraLensDirection.front,
    );

    // start the services
    await _faceNetService.loadModel();
    await _dataBaseService.loadDB();
    _mlKitService.initialize();

    _setLoading(false);
  }

  // shows or hides the circular progress indicator
  _setLoading(bool value) {
    setState(() {
      loading = value;
    });
  }


  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> signOut() async {
    await auth.signOut();
  }

  void _showDialog(BuildContext pageContext) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Do you want to log out?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog

            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () async {
                _scaffoldKey.currentState.showSnackBar(new SnackBar(
                  duration: new Duration(seconds: 20),
                  content: new Row(
                    children: <Widget>[
                      new CircularProgressIndicator(),
                      new Text("  Loging-out...")
                    ],
                  ),
                ));
                final SharedPreferences preferences=await SharedPreferences.getInstance();
                preferences.remove('userid');
                globals.qrCode = null;
                globals.classCode = null;
                globals.courseCode = null;
                globals.startAddingStudents = 0;
                globals.requiredStudents = 0;
                globals.post = null;
                globals.qrId = null;
                globals.attendance_id = null;
                globals.courseName = null;
                globals.courseYear = null;

                globals.studentId.clear();
                globals.studentDocumentId.clear();
                globals.attendanceDetails.clear();
                globals.extraStudentDocumentId.clear();

//for Students
                globals.id = null;
                globals.currentCollection = null;
                globals.key = "1234567890";
                globals.clas = null;
                globals.branch = null;
                globals.faculty = null;
                globals.programme = null;
                globals.sec = null;
                globals.uid = null;
                globals.name = null;
                globals.role = null;
                globals.lecturerName = null;
                globals.docId = null;

                Navigator.of(context).pop();
                Navigator.pop(pageContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  bool autovalidate = false;
  Validations validations = new Validations();

  int _selectedTab = 0;
  final _pageOptions = [
    PreviousAttendance(),
    SignIn(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    /*return new Scaffold(
      key: _scaffoldKey,
      appBar:
        new AppBar(
        title: new Text('Student Dashboard'),
    automaticallyImplyLeading: false,
      ),

      body: new ListView(
        children: <Widget>[
          new ListTile(
            title: new FlatButton(
                onPressed: () async {


    try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ScanScreen()),
      );
    }
    } on SocketException catch (_) {
    debugPrint('not connected');

    _scaffoldKey.currentState.showSnackBar(
    new SnackBar(duration: new Duration(seconds: 4), content:
    new Row(
    children: <Widget>[
    new Text("Please check your internet connection!")
    ],
    ),
    ));
    }





                },
                textColor: Colors.white70,
                color: Colors.redAccent,
                child: new Text('Join Lecture')),
          ),
          new ListTile(
            title: new FlatButton(
                onPressed: () async {



    try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PreviousAttendance()),
      );

    }
    } on SocketException catch (_) {
    debugPrint('not connected');

    _scaffoldKey.currentState.showSnackBar(
    new SnackBar(duration: new Duration(seconds: 4), content:
    new Row(
    children: <Widget>[
    new Text("Please check your internet connection!")
    ],
    ),
    ));
    }







    },
                textColor: Colors.white70,
                color: Colors.redAccent,
                child: new Text('Previous Attendance')),
          ),
          new ListTile(
            title: new FlatButton(
//                          onPressed: () {
//                            Navigator.push(context, MaterialPageRoute(
//                                builder: (context) => SecondRoute()),
//                            );
//                          },

                onPressed: () async {
    try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );


    }
    } on SocketException catch (_) {
    debugPrint('not connected');

    _scaffoldKey.currentState.showSnackBar(
    new SnackBar(duration: new Duration(seconds: 4), content:
    new Row(
    children: <Widget>[
    new Text("Please check your internet connection!")
    ],
    ),
    ));
    }

    },
                textColor: Colors.white70,
                color: Colors.redAccent,
                child: new Text('Profile')),
          )
        ],
      ),
    );
  }*/
//adding bottom nav bar

    return MaterialApp(
        theme: ThemeData(
            primarySwatch: Colors.grey,
            primaryTextTheme: TextTheme(
              title: TextStyle(color: Colors.white),
            )),
        home: Scaffold(
          key: _scaffoldKey,

          body: _pageOptions[_selectedTab],
          extendBody: true,
          bottomNavigationBar: FloatingNavbar(
            backgroundColor: Colors.indigo,

              currentIndex: _selectedTab,
              onTap: (int index)  {
                setState(() {
                    _selectedTab = index;


                });
              },
              items: [
                FloatingNavbarItem(icon: Icons.skip_previous, title: 'Attendance'),
                FloatingNavbarItem(icon: Icons.camera_alt_outlined, title: 'Scan'),
                FloatingNavbarItem(icon: Icons.settings, title: 'Settings'),

              ],
            ),
          ),
        );
  }
}
