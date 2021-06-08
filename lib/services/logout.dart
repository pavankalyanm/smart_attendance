import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smart_attendance/globals.dart' as globals;
import 'package:smart_attendance/pages/Login/login1.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Logout {


  static FirebaseAuth auth = FirebaseAuth.instance;
  static Future<void> signOut() async {
    await auth.signOut();


  }

  static void logout(BuildContext pageContext) {
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<
        ScaffoldState>();

    // flutter defined function
    showDialog(
      //context: context,
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
                _scaffoldKey.currentState.showSnackBar(
                    new SnackBar(duration: new Duration(seconds: 20), content:
                    new Row(
                      children: <Widget>[
                        new CircularProgressIndicator(),
                        new Text("  Loging-out...")
                      ],
                    ),
                    ));

                signOut();
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

//Navigator.pop(pageContext);
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
}