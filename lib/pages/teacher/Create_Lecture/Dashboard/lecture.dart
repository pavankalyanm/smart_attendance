import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendance/pages/teacher/Create_Lecture/dashboard/info.dart';
import 'package:smart_attendance/pages/teacher/Create_Lecture/dashboard/attendance.dart';
import 'package:smart_attendance/pages/teacher/Create_Lecture/dashboard/generate.dart';
//import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:smart_attendance/pages/teacher/home.dart';
import 'package:smart_attendance/globals.dart' as globals;

import 'package:smart_attendance/pages/teacher/Create_Lecture/dashboard/save_attendance.dart';

import 'package:smart_attendance/theme/style.dart' as style;
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';

class Lecture extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LectureState();
  }
}

class LectureState extends State<Lecture> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

/*  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }*/

  bool myInterceptor(bool stopDefaultButtonEvent) {
    print("BACK BUTTON!"); // Do some stuff.
    _showDialog(context);
    return true;
  }

  void _showDialog(BuildContext pageContext) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Make sure You downloaded the Attendance?"),
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
                      new Text("  Signing-In...")
                    ],
                  ),
                ));

                await Firestore.instance
                    .collection("class")
                    .document("${globals.classCode}")
                    .collection("lectureID_qrCode")
                    .document("${globals.qrId}")
                    .delete();

                for (int i = 0; i < globals.studentDocumentId.length; i++) {
                  await Firestore.instance
                      .collection("attendance")
                      .document("${globals.attendance_id}")
                      .collection("attendance")
                      .document(globals.studentDocumentId[i])
                      .delete();
                  print("delete${globals.studentDocumentId[i]}");
                }

//                Firestore.instance.collection('attendance').document("${globals.attendance_id}").collection("attendance").getDocuments().then((snapshot) {
//                  for (DocumentSnapshot ds in snapshot.documents){
//                    ds.reference.delete();
//                  }});
//
//
//                Map<String, String> map ={ "id" : "Enrollment No.",
//                  "attendance" : "Present / Absent"
//
//                };
//
//                DocumentReference docRef = await Firestore.instance.collection("attendance").document("${globals.attendance_id}").collection("attendance").add(map);
//                debugPrint("The New Document created with Id : ${docRef.documentID} ");
//
//
                Navigator.of(context).pop();
//                Navigator.of(context).pop();
                Navigator.pop(pageContext);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Teacher()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  int _selectedTab = 0;
  final _pageOptions = [
    GenerateScreen(),
    Info(),
    Attendance(),
    SaveAttendance(),
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            primarySwatch: Colors.grey,
            primaryTextTheme: TextTheme(
              title: TextStyle(color: Colors.white),
            )),
        home: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              title: Text("Click Icon to stop attendance"),
              automaticallyImplyLeading: false,
              backgroundColor: style.primaryColor,
              actions: <Widget>[
                // action button
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    _showDialog(context);
                  },
                ),
              ]),
          body: _pageOptions[_selectedTab],
          bottomNavigationBar: new Theme(
            data: Theme.of(context).copyWith(
                // sets the background color of the `BottomNavigationBar`
                canvasColor: style.primaryColor,
                // sets the active color of the `BottomNavigationBar` if `Brightness` is light
                primaryColor: Colors.black,
                textTheme: Theme.of(context)
                    .textTheme
                    .copyWith(caption: new TextStyle(color: Colors.yellow))),
            child: FloatingNavbar(
              backgroundColor: Colors.indigo,

              currentIndex: _selectedTab,
              onTap: (int index)  {
                setState(() {
                  _selectedTab = index;


                });
              },
              items: [
                FloatingNavbarItem(icon: Icons.home_outlined, title: 'QR'),
                FloatingNavbarItem(icon: Icons.category_outlined, title: 'Info'),
                FloatingNavbarItem(icon: Icons.search, title: 'Live'),
                FloatingNavbarItem(icon: Icons.download_outlined, title: 'Download'),

              ],
            ),
          ),
        ));
  }
}
