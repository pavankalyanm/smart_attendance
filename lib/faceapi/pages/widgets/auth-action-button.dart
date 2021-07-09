import 'dart:io';

import 'package:smart_attendance/faceapi/pages/db/database.dart';
import 'package:smart_attendance/faceapi/pages/models/user.model.dart';
import 'package:smart_attendance/faceapi/pages/profile.dart';
import 'package:smart_attendance/faceapi/pages/widgets/app_button.dart';
import 'package:smart_attendance/faceapi/services/camera.service.dart';
import 'package:smart_attendance/faceapi/services/facenet.service.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendance/pages/Login/login1.dart';
import 'package:smart_attendance/pages/student/Join_Lecture/scan.dart';
import 'package:smart_attendance/pages/student/home.dart';
import '../home.dart';
import 'app_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:barcode_scan/barcode_scan.dart';
import 'package:xxtea/xxtea.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:smart_attendance/globals.dart' as globals;
import 'package:smart_attendance/widgets/dialog.dart';
import 'package:flutter/services.dart';



String docId;
Position studentLocation;
double Tlatitude;
double distance;
double Tlongitude;
bool isauth=false;
bool isSwitched=false;


class AuthActionButton extends StatefulWidget {
  AuthActionButton(this._initializeControllerFuture,
      {Key key, @required this.onPressed, @required this.isLogin, this.reload});
  final Future _initializeControllerFuture;
  final Function onPressed;
  final bool isLogin;
  final Function reload;
  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {

  String barcode = "";


  /// service injection
  final FaceNetService _faceNetService = FaceNetService();
  final DataBaseService _dataBaseService = DataBaseService();
  final CameraService _cameraService = CameraService();

  final TextEditingController _userTextEditingController =
  TextEditingController(text: '');
  final TextEditingController _passwordTextEditingController =
  TextEditingController(text: '');

  User predictedUser;

  Future _signUp(context) async {
    /// gets predicted data from facenet service (user face detected)
    List predictedData = _faceNetService.predictedData;
    String user = _userTextEditingController.text;
    String password = _passwordTextEditingController.text;

    /// creates a new user in the 'database'
    await _dataBaseService.saveData(user, password, predictedData);

    /// resets the face stored in the face net sevice
    this._faceNetService.setPredictedData(null);
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => Login()));
  }

  Future _signIn(context) async {
    // String password = _passwordTextEditingController.text;

    if (this.predictedUser.user == globals.id) {
      /*Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => Profile(
                    this.predictedUser.user,
                    imagePath: _cameraService.imagePath,
                  )));*/
      await _cameraService.dispose();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => ScanScreen(
            //cameraDescription: cameraDescription,
          ),
        ),
      );
      //checkNet();


    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Not Authorized'),
          );
        },
      );
    }
  }

  String _predictUser() {
    String userAndPass = _faceNetService.predict();
    return userAndPass ?? null;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return
      InkWell(
        onTap: () async {
          try {
            // Ensure that the camera is initialized.
            await widget._initializeControllerFuture;
            // onShot event (takes the image and predict output)
            bool faceDetected = await widget.onPressed();

            if (faceDetected) {
              if (widget.isLogin) {
                var userAndPass = _predictUser();
                if (userAndPass != null) {
                  this.predictedUser = User.fromDB(userAndPass);
                }
              }
              /*PersistentBottomSheetController bottomSheetController =
              Scaffold.of(context)
                  .showBottomSheet((context) => signSheet(context));

              bottomSheetController.closed.whenComplete(() => widget.reload());*/
              _signIn(context);
            }
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.indigo,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 1,
                offset: Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          width: MediaQuery.of(context).size.width * 0.8,
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Authenticate',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 10,
              ),
              Icon(Icons.face_unlock_rounded, color: Colors.white)
            ],
          ),
        ),
      );



  }

  signSheet(context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.isLogin && predictedUser != null
              ? Container(
            child: Text(
              'Welcome back, ' + predictedUser.user + '.',
              style: TextStyle(fontSize: 20),
            ),
          )
              : widget.isLogin
              ? Container(
              child: Text(
                'User not found 😞',
                style: TextStyle(fontSize: 20),
              ))
              : Container(),
          Container(
            child: Column(
              children: [
                !widget.isLogin
                    ? AppTextField(
                  controller: _userTextEditingController,
                  labelText: "Your Admission number",
                )
                    : Container(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser == null
                    ? Container()
                    : AppTextField(
                  controller: _passwordTextEditingController,
                  labelText: "Password",
                  isPassword: true,
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser != null
                    ? AppButton(
                  text: 'Authenticate',
                  onPressed: () async {
                    _signIn(context);
                  },
                  icon: Icon(
                    Icons.login,
                    color: Colors.white,
                  ),
                )
                    : !widget.isLogin
                    ? AppButton(
                  text: 'Add Your Face',
                  onPressed: () async {
                    await _signUp(context);
                  },
                  icon: Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  //to scan














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

  void _showDialogSuccess() async {
    // flutter defined function
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Student(
          //cameraDescription: cameraDescription,
        ),
      ),
    );
    showDialog (
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
                //Navigator.of(context).pop();

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



  //scan functions


  /*Future  scan() async {
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
      showInDialog.show(context, e);
        /*_scaffoldKey.currentState.showSnackBar(new SnackBar(
          duration: new Duration(seconds: 4),
          content: new Row(
            children: <Widget>[
              new Container(
                child: new Text("Unknown error: no such method"),
              )
            ],*/
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
  }*/

}












