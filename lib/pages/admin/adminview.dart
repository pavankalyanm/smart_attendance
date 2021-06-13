import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_attendance/pages/Login/login1.dart';
import 'package:smart_attendance/pages/admin/changepswd.dart';
import 'package:smart_attendance/pages/admin/classCodes.dart';
import 'package:smart_attendance/pages/admin/studentSignup.dart';
import 'package:smart_attendance/pages/admin/teacherSignup.dart';
import 'package:smart_attendance/services/logout.dart' as logout;
import 'package:smart_attendance/globals.dart' as globals;
import 'package:smart_attendance/theme/style.dart' as style;
import 'package:smart_attendance/services/logout.dart';
import 'package:smart_attendance/pages/admin/courseDetails.dart';





class admin extends StatefulWidget {
  const admin({Key key}) : super(key: key);

  @override
  _adminState createState() => _adminState();
}

class _adminState extends State<admin> {


  void _showDialog(BuildContext pageContext) {
    // flutter defined function
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

               // signOut();
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

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
          title: Text("ADMIN"),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.indigo,
          actions: <Widget>[
            // action button
            IconButton(
              color: Colors.white,
              icon: Icon(Icons.logout),
              onPressed: () {
                _showDialog(context);
              },
            ),]),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: SafeArea(
          child: Container(
            // we will give media query height
            // double.infinity make it big as my parent allows
            // while MediaQuery make it big as per the screen

            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Column(
              // even space distribution
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      "Welcome",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,

                      ),

                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Hi Admin!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      ),)
                  ],
                ),
                /*Container(
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/res/jntu.png")
                      )
                  ),
                ),*/

                Column(
                  children: <Widget>[
                    // the login button
                    MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => teacherSignup()));

                      },
                      color: style.primaryColor,

                      // defining the shape
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              //color: Colors.white
                          ),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text(
                        "Add Teacher",
                        style: TextStyle(
                            color: Colors.white,

                            fontWeight: FontWeight.w600,
                            fontSize: 18
                        ),
                      ),
                    ),
                    // creating the signup button
                    SizedBox(height:20),
                    MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> studentSignup()));

                      },
                      color: style.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text(
                        "Add Student",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18
                        ),
                      ),
                    ), SizedBox(height:20),
                    MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> changePassword()));

                      },
                      color: style.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text(
                        "Change Password",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18
                        ),
                      ),
                    ),
                    SizedBox(height:20),
                    MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> courseDetails()));

                      },
                      color: style.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text(
                        "Add Subjects",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18
                        ),
                      ),
                    ),
                    SizedBox(height:20),
                    MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> classCodes()));

                      },
                      color: style.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text(
                        "Add ClassCodes",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18
                        ),
                      ),
                    )

                  ],
                )



              ],
            ),
          ),
        ),
      ),
      ),);
  }
}
