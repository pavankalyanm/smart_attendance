import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_attendance/faceapi/pages/db/database.dart';
import 'package:smart_attendance/faceapi/pages/home.dart';
import 'package:smart_attendance/faceapi/pages/sign-in.dart';
import 'package:smart_attendance/faceapi/pages/sign-up.dart';
import 'package:smart_attendance/faceapi/services/facenet.service.dart';
import 'package:smart_attendance/faceapi/services/ml_kit_service.dart';
import 'package:smart_attendance/pages/student/Join_Lecture/Dashboard/lecture.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_attendance/globals.dart' as globals;
import 'package:smart_attendance/pages/teacher/Create_Lecture/generation_data.dart';
import 'package:smart_attendance/services/getLocation.dart';
import 'package:smart_attendance/widgets/dialog.dart';
import 'package:xxtea/xxtea.dart';
//import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:smart_attendance/pages/student/home.dart';

import 'package:smart_attendance/theme/style.dart' as style;
import '../../../globals.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:camera/camera.dart';

String docId;
Position studentLocation;
double Tlatitude;
double distance;
double Tlongitude;
bool isauth=false;
bool isSwitched=false;


class ScanScreen extends StatefulWidget {
  @override
  _ScanState createState() => new _ScanState();
}

class _ScanState extends State<ScanScreen> {
  String barcode = "";
  CameraDescription cameraDescription;
  bool loading = false;
  FaceNetService _faceNetService = FaceNetService();
  MLKitService _mlKitService = MLKitService();
  DataBaseService _dataBaseService = DataBaseService();
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
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Student()),
    );
    return true;
  }*/

  void _showDialogWrong() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("You Scanned wrong QR Code. Contact the Lecturer."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialogTryAgain() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Oops! try again and hold your device correctly"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                _scaffoldKey.currentState.showSnackBar(new SnackBar(
                  duration: new Duration(seconds: 4),
                  content: new Row(
                    children: <Widget>[new Text("Attendance Updated")],
                  ),
                ));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//  @override
//  initState() {
//    super.initState();
//  }

  void _showDialogSuccess() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Attendance recorded successfully"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                _scaffoldKey.currentState.showSnackBar(new SnackBar(
                  duration: new Duration(seconds: 4),
                  content: new Row(
                    children: <Widget>[new Text("Attendance added to previous lectures")],
                  ),
                ));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  Future syncToPreviousAttendance() async {
    String collection1 = "users";
    String collection2 = "previous_attendance";
    String courseCode = globals.courseCode;
    String uid = globals.uid;

    var fireStore2 = Firestore.instance;

    Map<String, String> map = {
      "time_stamp": "${new DateTime.now()}",
      "course_code": "$courseCode"
    };

    DocumentReference docRef = await fireStore2
        .collection("$collection1")
        .document("$uid")
        .collection("$collection2")
        .add(map);
    debugPrint("The New Document created with Id : ${docRef.documentID} ");

    /*Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Lecture()),
    );
     */
    _showDialogSuccess();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        /*appBar: new AppBar(
          title: new Text('Please Scan the QR CODE',
            style: TextStyle(
            color: Colors.black,
            )
          ),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),*/
        /*body: new Center(
          child: new ListView(
//            mainAxisAlignment: MainAxisAlignment.center,
//            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: RaisedButton(
                    color: style.primaryColor,
                    textColor: Colors.white,
                    splashColor: Colors.blueGrey,
                    onPressed: checkNet,
                    child: const Text('Click here to scan QR code')),
              ),
            ],
          ),
        )*/
        body: new Center(

// new Center(
//// child: new Image.asset(
//// 'images/white_snow.png',
//// width: 490.0,
//// height: 1200.0,
//// fit: BoxFit.fill,
//// ),
// ),


            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                onSwitch(),
                SizedBox(
                  height: 160,
                ),
                Container(
                  child: new Text(
                    'Click here to scan the QR Code',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  height: 100.0,
                  child: SizedBox.fromSize(
                    size: Size(100, 100), // button width and height
                    child: ClipOval(
                      child: Material(
                        color: Colors.indigo, // button color
                        child: InkWell(
                          splashColor: Color.fromRGBO(248, 177, 1, 1),
// splash color
                          onTap: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => SignIn(

                                ),
                              ),
                            );


                            // checkNet();
                          },
// button pressed
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ), // icon
                              Text(
                                "Scan",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ), // text
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ))

    );


  }

  Widget onSwitch() =>
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Select Mode of the Class",style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 20),
              child: LiteRollingSwitch(
                value: false,
                textOn: 'Online',
                textOff: 'Offline',
                colorOn: Colors.indigo,
                colorOff: Colors.indigo,
                iconOn: Icons.check,
                iconOff: Icons.power_settings_new,
                animationDuration: Duration(milliseconds: 800),
                onChanged: (bool state) {
                  isSwitched=state;
                  print('turned ${(isSwitched) ? 'online' : 'offline'}');
                },
              ),
            )
          ],
        ),
      );






  /*void _checkBiometric() async {
    // check for biometric availability
    final LocalAuthentication auth = LocalAuthentication();
    bool canCheckBiometrics = false;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      print("error biome trics $e");
    }

    print("biometric is available: $canCheckBiometrics");

    // enumerate biometric technologies
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } catch (e) {
      print("error enumerate biometrics $e");
    }

    print("following biometrics are available");
    if (availableBiometrics.isNotEmpty) {
      availableBiometrics.forEach((ab) {
        print("\ttech: $ab");
      });
    } else {
      print("no biometrics are available");
    }

    // authenticate with biometrics
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
        localizedReason: 'Touch your finger on the sensor to login',
        useErrorDialogs: true,
        stickyAuth: true,
        //androidAuthStrings:
        //AndroidAuthMessages(signInTitle: "Login to HomePage"));
      );} catch (e) {
      print("error using biometric auth: $e");
    }
    setState(() {
      isauth = authenticated ? true : false;
    });

    print("authenticated: $authenticated");
  }*/




  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();

      setState(() => this.barcode = barcode);
//      String barcode = "-Li2ZkLdyHEK8ODe0xJM";

      String decrypt_data = xxtea.decryptToString(barcode, globals.key);
      debugPrint(decrypt_data);

      debugPrint("Decripting qr code");

      /*  DocumentSnapshot snapshot = await Firestore.instance
          .collection("class")
          .document("${globals.clas}")
          .collection("lectureID_qrCode")
          .document("$decrypt_data")
          .get();
      debugPrint(snapshot.data['class_code']);*/

      try {
        DocumentSnapshot snapshot = await Firestore.instance
            .collection("class")
            .document("${globals.clas}")
            .collection("lectureID_qrCode")
            .document("$decrypt_data")
            .get();
        debugPrint(snapshot.data['class_code']);
        if (snapshot.data['class_code'] == "${globals.clas}") {
          _scaffoldKey.currentState.showSnackBar(new SnackBar(
            duration: new Duration(seconds: 20),
            content: new Row(
              children: <Widget>[
                new CircularProgressIndicator(),
                new Text(" Scanning qrcode..")
              ],
            ),
          ));

          globals.courseCode = snapshot.data['course_code'];
          globals.currentCollection = snapshot.data['collection_name'];
          globals.attendance_id = snapshot.data['attendance_id'];
          globals.sem=snapshot.data['semester'];
          Tlatitude=snapshot.data['latitude'];
          Tlongitude=snapshot.data['longitude'];
          //getCourseDetails();

          isSwitched ? getcurrentLocation() : getCourseDetails();


//          syncToPreviousAttendance();
        } else {
          debugPrint(
              "Comparing global = ${globals.clas} : snapshot = ${snapshot.data['class_code']}");
          _showDialogWrong();
        }
      } catch (e) {
        print(e);

        _showDialogWrong();
      }

//      present.updating(barcode);

    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          _scaffoldKey.currentState.showSnackBar(new SnackBar(
            duration: new Duration(seconds: 4),
            content: new Row(
              children: <Widget>[new Text("grant the camera permission!")],
            ),
          ));
        });
      } else {
        setState(() {
          _scaffoldKey.currentState.showSnackBar(new SnackBar(
            duration: new Duration(seconds: 4),
            content: new Row(
              children: <Widget>[
                new Container(
                  child: new Text("Unknown error: $e"),
                )
              ],
            ),
          ));
        });
      }
    } on FormatException {
      setState(() {
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
          duration: new Duration(seconds: 4),
          content: new Row(
            children: <Widget>[new Text("Scanning not done correctly")],
          ),
        ));
      });
    } catch (e) {
      setState(() {
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
          duration: new Duration(seconds: 4),
          content: new Row(
            children: <Widget>[
              new Container(
                child: new Text("Unknown error: no such method"),
              )
            ],
          ),
        ));
      });
    }
  }




  getcurrentLocation() async{
    await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
        .then((Position position) {

      studentLocation = position;


    }).catchError((e) {
      print(e);
    });
    debugPrint('$studentLocation');
    compareLocations();
  }


  compareLocations() async{


    //double lan = studentLocation.longitude;
    distance= await Geolocator.distanceBetween(Tlatitude,Tlongitude,studentLocation.latitude,studentLocation.longitude);
    debugPrint('$distance');
    if(distance>10.0){
      showInDialog.show(context, 'You are not in the class');
    }else {
      getCourseDetails();
    }

    //getCourseDetails();

  }

  getLecturerDetails() async {
    debugPrint("Inside getClass func");

    DocumentSnapshot snapshot = await Firestore.instance
        .collection('attendance')
        .document('${globals.attendance_id}')
        .get();
    if (snapshot.data == null) {
      debugPrint("No data in class > classcode");
    } else {
      globals.lecturerName = snapshot.data['name'];
      globals.post = snapshot.data['post'];
      findAttendanceId();
    }
  }

  getCourseDetails() async {
    debugPrint("Inside getCourse func");

    DocumentSnapshot snapshot = await Firestore.instance
        .collection('semester')
        .document('${globals.sem}').collection('courses').document('${globals.courseCode}')
        .get();
    if (snapshot.data == null) {
      debugPrint("No data in course > coursecode");
    } else {
      globals.courseName = snapshot.data['coursename'];
      globals.courseYear = snapshot.data['semester'];

      getLecturerDetails();
    }
  }

  findAttendanceId() async {
    try {
      await Firestore.instance
          .collection("attendance")
          .document("${globals.attendance_id}")
          .collection("attendance")
          .where('id', isEqualTo: "${globals.id}")
          .getDocuments()
          .then((string) {
        string.documents.forEach((doc) async => globals.docId = doc.documentID);
      });

//      debugPrint(" $docId");
//      List docId1 = docId.split(",");
//      debugPrint(" $docId1");
//      String docId2 = docId1[0];
//      debugPrint(" $docId2");
//      List docId3 = docId2.split("-");
//      debugPrint(" $docId3");
//      globals.docId = "-${docId3[1]}";
      debugPrint(" ${globals.docId}");

      markPresent();
    } catch (e) {
      print('Caught Firestore exception2');
      print(e);
      _showDialogTryAgain();
    }
  }

  markPresent() async {
    try {
      await Firestore.instance
          .collection("attendance")
          .document("${globals.attendance_id}")
          .collection("attendance")
          .document("${globals.docId}")
          .updateData({"attendance": "Present"});

      await syncToPreviousAttendance();
    } catch (e) {
      print('Caught Firestore exception3');
      print(e);
      _showDialogTryAgain();
    }
  }

  Future checkNet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

        /*await _checkBiometric();
        isauth ?
        scan():
        _checkBiometric();*/
        scan();





        debugPrint("${globals.academicyear}");
      }
    } on SocketException catch (_) {
      debugPrint('not connected');

      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        duration: new Duration(seconds: 4),
        content: new Row(
          children: <Widget>[
            new Text("Please check your internet connection!")
          ],
        ),
      ));
    }
  }
}
