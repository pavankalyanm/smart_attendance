import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:smart_attendance/pages/screens/teacher/generate.dart';
import 'package:smart_attendance/pages/teacher/Create_Lecture/dashboard/lecture.dart';
import 'dart:convert';

import 'package:smart_attendance/globals.dart' as globals;
import 'package:smart_attendance/services/getLocation.dart';
import 'package:xxtea/xxtea.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';
//import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:smart_attendance/pages/teacher/home.dart';

import 'package:smart_attendance/theme/style.dart' as style;
import 'package:geolocator/geolocator.dart';

class Generation extends StatefulWidget {
  @override
  _GenerationState createState() => _GenerationState();
}

class _GenerationState extends State<Generation> {
  String selectedClassCode;
  String semester;
  String periods;
//  = "Choose Class Code" ;
  String selectedCourseCode;
  final GlobalKey<FormState> _formKeyValue = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Position _currentPosition;
  String currentLocation;
  double latitude;
  double longitude;

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
      MaterialPageRoute(builder: (context) => Teacher()),
    );
    return true;
  }*/

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Do you want to generate QR code?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("No"),
              onPressed: () async {
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
                      new Text("  Loading...")
                    ],
                  ),
                ));
                Navigator.of(context).pop();
                getClassDetails();
              },
            ),
          ],
        );
      },
    );
  }

  checkingPastQrData() async {
    List extraQrDocId = [];
    final QuerySnapshot querySnapshot = await Firestore.instance
        .collection("class")
        .document(globals.classCode)
        .collection("lectureID_qrCode")
        .getDocuments();

    debugPrint(" lEngth : ${querySnapshot.documents.length}");

    if (querySnapshot.documents.length > 1) {
      for (int i = 0; i < querySnapshot.documents.length; i++) {
        extraQrDocId.insert(i, "${querySnapshot.documents[i].documentID}");
      }
      debugPrint("${extraQrDocId[0]}");

      debugPrint(" leNgth : ${extraQrDocId.length}");

      for (int i = 1; i < extraQrDocId.length; i++) {
        debugPrint(" deleting ${extraQrDocId[i]}");
        Firestore.instance
            .collection("class")
            .document("${globals.classCode}")
            .collection("lectureID_qrCode")
            .document(extraQrDocId[i])
            .delete();
      }
      createQrDocument();
    } else {
      createQrDocument();
    }
  }

  Future createQrDocument() async {
    debugPrint("i am here");

    Map<String, dynamic> qrDetail = {
      "course_code": globals.courseCode,
      "attendance_id": globals.attendance_id,
      "collection_name": "attendance",
      "class_code": globals.classCode,
      "semester":semester,
      'latitude':latitude,
      'longitude':longitude,
    };



    debugPrint("map made");
    debugPrint("classCode : ${globals.classCode}");

    DocumentReference qrId = await Firestore.instance
        .collection("class")
        .document(globals.classCode)
        .collection("lectureID_qrCode")
        .add(qrDetail);




    debugPrint("The New Document created with Id : ${qrId.documentID} ");



    globals.qrId = "${qrId.documentID}";
    globals.qrCode = xxtea.encryptToString(globals.qrId, globals.key);
    debugPrint(globals.qrCode);

    debugPrint("qr code made");
    // debugPrint(" studentid ${globals.studentId}");
    addStudents();
  }

  Future addStudents() async {
    //create doc
    /* Map<String, String> map = { "time_stamp": "${new DateTime.now()}",

    };
    DocumentReference docRef = await Firestore.instance.collection(
        "attendance").document("${globals.attendance_id}").collection(
        "attendance").add(map);
    debugPrint("The New Document created with Id : ${docRef.documentID} ");*/

    List studentId = globals.studentId;
    globals.studentDocumentId.clear();

    final QuerySnapshot querySnapshot = await Firestore.instance
        .collection("class")
        .document(globals.classCode)
        .collection("student")
        .getDocuments();
    debugPrint("${querySnapshot.documents.length}");

    for (int i = 0; i < querySnapshot.documents.length; i++) {
      DocumentSnapshot snapshot = await Firestore.instance
          .collection('class')
          .document('${globals.classCode}')
          .collection('student')
          .document('${querySnapshot.documents[i].documentID}')
          .get();
      debugPrint("Id:${snapshot.data['id']}");
      //String stu_id= snapshot.data['id'] ;

      Map<String, String> map = {
        'id': snapshot.data['id'],
        "attendance": 'absent'
//        "document" : "default"
      };
      globals.studentId.add(snapshot.data['id']);

      DocumentReference Ref = await Firestore.instance
          .collection("attendance")
          .document("${globals.attendance_id}");

          await Ref.setData({'name': '${globals.name}',
            'post':'${globals.post}'
          });
        DocumentReference docRef=await Ref
          .collection("attendance")
          .add(map);
      debugPrint("The New Document created with Id : ${docRef.documentID} ");
      globals.studentDocumentId.insert(i, "${docRef.documentID}");
      debugPrint("DocRef:${globals.studentDocumentId[i]}");

      //  Firestore.instance.collection("attendance").document("${globals.attendance_id}").collection("attendance").document("${docRef.documentID}").updateData({"document" : "${docRef.documentID}"});

    }

    debugPrint("attendance list created");
    updatePreviousLectures();
  }

  Future updatePreviousLectures() async {
    Map<String, String> map = {
      "time_stamp": "${new DateTime.now()}",
      "course_code": "${globals.courseCode}",
      "class_code": "${globals.classCode}",
      "course_name": "${globals.courseName}",
      "periods": "${globals.periods_num}"
    };

    DocumentReference docRef = await Firestore.instance
        .collection("users")
        .document("${globals.uid}")
        .collection("previous_lecture")
        .add(map);
    debugPrint("The New Document created with Id : ${docRef.documentID} ");

    debugPrint("added to previous lectures");
    globals.previousDoc = docRef.documentID;
    debugPrint("The New Document created with Id : ${globals.previousDoc} ");
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Lecture()),
    );
    // Navigator.pop(context);  here it should be ofcontext of the showdialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
//          leading: IconButton(
//              icon: Icon(
//                FontAwesomeIcons.bars,
//                color: Colors.white,
//              ),
//              onPressed: () {}),
        title: Container(
          alignment: Alignment.center,
          child: Text("Choose Class Details",
              style: TextStyle(
                color: Colors.black,
              )),
        ),
        automaticallyImplyLeading: false,
//          actions: <Widget>[
//            IconButton(
//              icon: Icon(
//                FontAwesomeIcons.coins,
//                size: 20.0,
//                color: Colors.white,
//              ),
//              onPressed: null,
//            ),
//          ],
      ),
      body: Form(
        key: _formKeyValue,
        autovalidate: true,
        child: new ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          children: <Widget>[
            SizedBox(height: 40.0),
            StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection("class").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return CircularProgressIndicator();
                  else {
                    if ((globals.requiredStudents > globals.studentId.length) ||
                        (globals.requiredStudents == 0)) {
                      globals.startAddingStudents = 1;
                    }

                    List<DropdownMenuItem> classCodes = [];
                    for (int i = 0; i < snapshot.data.documents.length; i++) {
                      DocumentSnapshot snap = snapshot.data.documents[i];
                      classCodes.add(
                        DropdownMenuItem(
                          child: Text(
                            snap.documentID,
                            style: TextStyle(color: style.primaryColor),
                          ),
                          value: "${snap.documentID}",
                        ),
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Expanded(
                            flex: 2,
                            child: new Container(
                              padding:
                                  EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
                              child: new Text("Classcode"),
                            )),

//                          Icon(FontAwesomeIcons.coins,
//                              size: 25.0, color: Color(0xff11b719)),
                        new Expanded(
                          flex: 4,
                          child: new DropdownButton(
                            items: classCodes,
                            onChanged: (classCodeValue) {
                              semester = null;
                              selectedCourseCode = null;
                              periods = null;
                              globals.studentId.clear();
                              final snackBar = SnackBar(
                                duration: new Duration(seconds: 1),
                                content: Text(
                                  'Selected Class Code is $classCodeValue',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              );
                              Scaffold.of(context).showSnackBar(snackBar);
                              setState(() {
                                selectedClassCode = classCodeValue;
                              });
                            },
                            value: selectedClassCode,
                            isExpanded: false,
                            hint: new Text(
                              "Choose Class Code",
                              style: TextStyle(color: style.primaryColor),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }),

            //adding semester dropdown
            SizedBox(height: 40.0),
            StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection("semester").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return CircularProgressIndicator();
                  else {
                    List<DropdownMenuItem> Semester = [];
                    for (int i = 0; i < snapshot.data.documents.length; i++) {
                      DocumentSnapshot snap = snapshot.data.documents[i];
                      Semester.add(
                        DropdownMenuItem(
                          child: Text(
                            snap.documentID,
                            style: TextStyle(color: style.primaryColor),
                          ),
                          value: "${snap.documentID}",
                        ),
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Expanded(
                            flex: 2,
                            child: new Container(
                              padding:
                                  EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
                              child: new Text("Semester"),
                            )),

//                          Icon(FontAwesomeIcons.coins,
//                              size: 25.0, color: Color(0xff11b719)),
                        new Expanded(
                          flex: 4,
                          child: new DropdownButton(
                            items: Semester,
                            onChanged: (semesterValue) {
                              selectedCourseCode = null;
                              periods = null;
                              final snackBar = SnackBar(
                                duration: new Duration(seconds: 1),
                                content: Text(
                                  'Selected semester is $semesterValue',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                              Scaffold.of(context).showSnackBar(snackBar);
                              setState(() {
                                semester = semesterValue;
                              });
                            },
                            value: semester,
                            isExpanded: false,
                            hint: new Text(
                              "Choose Semester",
                              style: TextStyle(color: style.primaryColor),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }),

            SizedBox(height: 40.0),
            StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection("semester")
                    .document('$semester')
                    .collection('courses')
                    .where("classcode", isEqualTo: "$selectedClassCode")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return CircularProgressIndicator();
                  else {
                    List<DropdownMenuItem> courseCodes = [];
                    for (int i = 0; i < snapshot.data.documents.length; i++) {
                      DocumentSnapshot snap = snapshot.data.documents[i];
                      courseCodes.add(
                        DropdownMenuItem(
                          child: Text(
                            snap.documentID + '(${snap.data['coursename']})',
                            style: TextStyle(color: style.primaryColor),
                          ),
                          value: "${snap.documentID}",
                        ),
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Expanded(
                            flex: 2,
                            child: new Container(
                              padding:
                                  EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
                              child: new Text("Subject"),
                            )),

//                          Icon(FontAwesomeIcons.coins,
//                              size: 25.0, color: Color(0xff11b719)),
                        new Expanded(
                          flex: 4,
                          child: new DropdownButton(
                            items: courseCodes,
                            onChanged: (courseCodeValue) {
                              periods = null;
                              final snackBar = SnackBar(
                                duration: new Duration(seconds: 1),
                                content: Text(
                                  'Selected Subject Code is $courseCodeValue',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                              Scaffold.of(context).showSnackBar(snackBar);
                              setState(() {
                                selectedCourseCode = courseCodeValue;
                              });
                            },
                            value: selectedCourseCode,
                            isExpanded: false,
                            hint: new Text(
                              "Choose Subject Code",
                              style: TextStyle(color: style.primaryColor),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }),

            //widget for periods
            SizedBox(height: 40.0),
            StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection("periods").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return CircularProgressIndicator();
                  else {
                    List<DropdownMenuItem> courseCodes = [];
                    for (int i = 0; i < snapshot.data.documents.length; i++) {
                      DocumentSnapshot snap = snapshot.data.documents[i];
                      courseCodes.add(
                        DropdownMenuItem(
                          child: Text(
                            snap.documentID,
                            style: TextStyle(color: style.primaryColor),
                          ),
                          value: "${snap.documentID}",
                        ),
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Expanded(
                            flex: 2,
                            child: new Container(
                              padding:
                                  EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
                              child: new Text("No. Of Periods"),
                            )),

//                          Icon(FontAwesomeIcons.coins,
//                              size: 25.0, color: Color(0xff11b719)),
                        new Expanded(
                          flex: 4,
                          child: new DropdownButton(
                            items: courseCodes,
                            onChanged: (periodsValue) {
                              final snackBar = SnackBar(
                                duration: new Duration(seconds: 1),
                                content: Text(
                                  'No. of Periods= $periodsValue',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                              Scaffold.of(context).showSnackBar(snackBar);
                              setState(() {
                                periods = periodsValue;
                              });
                            },
                            value: periods,
                            isExpanded: false,
                            hint: new Text(
                              "Select No. of periods",
                              style: TextStyle(color: style.primaryColor),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }),

            SizedBox(
              height: 100.0,
            ),
//              StreamBuilder<QuerySnapshot>(
//                  stream: Firestore.instance.collection(selectedClassCode).snapshots(),
//                  builder: (context, snapshot) {
//                    debugPrint("inside build but outside else if : with  class code $selectedClassCode ");
//                    if (!snapshot.hasData) {
//                      const Text("Loading.....");
//                      debugPrint("inside if   current studentId lenght : ${globals.studentId.length}");
//                      return new Container();
//                    }
//                    else if (globals.startAddingStudents ==1){
//                      debugPrint("inside else if: here length = ${snapshot.data.documents.length} : with  class code $selectedClassCode : and documents ${snapshot.data.documents}   current studentId lenght : ${globals.studentId.length}") ;
//
//
//                      for (int i = 0; i < snapshot.data.documents.length; i++) {
//                        DocumentSnapshot snap = snapshot.data.documents[i];
//                        globals.studentId.insert(i, "${snap.documentID}");
//                       debugPrint("added student $i ${snap.documentID}");
//                        debugPrint("current studentId lenght : ${globals.studentId.length}");
//                        debugPrint("current studentId var : ${globals.studentId}");
//
//                        globals.requiredStudents = snapshot.data.documents.length;
//                        globals.startAddingStudents =0;
//                      }
//                      return new Container();
//                    }
//
//                    else {
//                      debugPrint("nothing goes here : with  class code $selectedClassCode ");
//                      debugPrint("current studentId lenght : ${globals.studentId.length}");
//                      return new Container();
//                    }
//                    }),
//              SizedBox(
//                height: 10.0,
//              ),
//
            // ignore: deprecated_member_use
            ButtonTheme(
              //minWidth: ,
              // height: 100,
              child: RaisedButton(
                  color: style.primaryColor,
                  textColor: Colors.white,
                  child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text("Generate QR", style: TextStyle(fontSize: 20.0)),
                        ],
                      )),
                  onPressed: () async {
                    try {
                      final result = await InternetAddress.lookup('google.com');
                      if (result.isNotEmpty &&
                          result[0].rawAddress.isNotEmpty) {
                        if (selectedCourseCode != null &&
                            selectedClassCode != null && semester!=null && periods!=null) {
                          final QuerySnapshot querySnapshot = await Firestore
                              .instance
                              .collection("$selectedClassCode")
                              .getDocuments();

                          debugPrint(
                              " Length : ${querySnapshot.documents.length}");

                          globals.studentId.clear();

                          for (int i = 0;
                              i < querySnapshot.documents.length;
                              i++) {
                            globals.studentId.insert(
                                i, "${querySnapshot.documents[i].documentID}");
                          }

                          globals.classCode = selectedClassCode;
                          globals.courseCode = selectedCourseCode;

                          _showDialog();

//                            globals.startAddingStudents = 0;

                        } else {
                          _scaffoldKey.currentState.showSnackBar(new SnackBar(
                            duration: new Duration(seconds: 4),
                            content: new Row(
                              children: <Widget>[
                                new Text("First select from above!")
                              ],
                            ),
                          ));
                        }
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
                  }),
            )
          ],
        ),
      ),
    );
  }

  getClassDetails() async {
    debugPrint("Inside getClass func");

    DocumentSnapshot snapshot = await Firestore.instance
        .collection('class')
        .document('${globals.classCode}')
        .get();
    if (snapshot.data == null) {
      debugPrint("No data in class > classcode");
    } else {
      globals.branch = snapshot.data['branch'];
      debugPrint("See if the value of branch is set  1 : ${globals.branch}");
      globals.faculty = snapshot.data['faculty'];
      globals.programme = snapshot.data['programme'];
      globals.sec = snapshot.data['sec'];
      getCourseDetails();
    }
  }

  getCourseDetails() async {
    debugPrint("Inside getCourse func");

    DocumentSnapshot snapshot = await Firestore.instance
        .collection('semester')
        .document('$semester')
        .collection('courses')
        .document('${globals.courseCode}')
        .get();

    if (snapshot.data == null) {
      debugPrint("No data in course > coursecode");
    } else {
      globals.courseName = snapshot.data['coursename'];
      globals.courseYear = snapshot.data['semester'];
      getPeriods();
    }
  }

  getPeriods() async {
    DocumentSnapshot snapshot = await Firestore.instance
        .collection('periods')
        .document('$periods')
        .get();
    if (snapshot.data == null) {
      debugPrint("No data ");
    } else {
      globals.periods_num = '$periods' + '(${snapshot.data['time']})';

     getCurrentlocation();

    }
  }


  getCurrentlocation() async{
    await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
        .then((Position position) {

      latitude=position.latitude;
      longitude=position.longitude;


    }).catchError((e) {
      print(e);
    });
    debugPrint('$currentLocation');
    checkingPastQrData();
  }




}


