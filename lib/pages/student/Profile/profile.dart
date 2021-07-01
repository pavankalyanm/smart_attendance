//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:smart_attendance/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/pages/Login/login1.dart';
import 'package:smart_attendance/pages/student/Join_Lecture/scan.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:smart_attendance/theme/style.dart';

//import 'package:smart_attendance/components/TextFields/inputField.dart';
//import 'package:smart_attendance/components/Buttons/textButton.dart';
//import 'package:smart_attendance/components/Buttons/roundedButton.dart';
import 'package:smart_attendance/services/validations.dart';
import 'package:smart_attendance/globals.dart' as globals;
//import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:smart_attendance/pages/student/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => new _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
//  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//  String _email, _password;
//  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

//  void showInSnackBar(String value) {
//    _scaffoldKey.currentState
//        .showSnackBar(new SnackBar(content: new Text(value)));
//  }
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

 /*@override
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

  bool autovalidate = false;
  Validations validations = new Validations();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key:_scaffoldKey,
      appBar: AppBar(
        title: Container(
          //alignment: Alignment.center,
          child: Text('Settings',
              style: TextStyle(
                color: Colors.white,
              )),
        ),
        backgroundColor: Colors.indigo,
        automaticallyImplyLeading: false,
          actions: <Widget>[
            // action button
            IconButton(
              color: Colors.white,
              icon: Icon(Icons.logout),
              onPressed: () {
                _showDialog(context);
              },
            ),
          ]
      ),
      body: Column(children: [
        SizedBox(height: 20,),
      Center(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("Select Mode of the Class",style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
        ),
        ),

        Container(
          height: 60,
          width: 125,
          child: Padding(
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
                globals.isonline=state;
                print('${globals.isonline}');
              },
            ),
          ),
        )
      ],
    ),
    ),
    SizedBox(height: 20,),

    Expanded(
          child: ListView(
            children: <Widget>[
              //SizedBox(height: 40.0),
              Center(child: Text("PROFILE" , style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),)),
              Container(
                child: Card(
                  child: ListTile(
                    leading: Image.asset("assets/res/student.png"),
                    title: Text('${globals.name}'),
                    subtitle: Text('${globals.id}'),
                  ),
                ),
              ),

              //Card(child: ListTile(title: Text("Under faculty   :  ${globals.faculty}"))),
              Card(
                  child:
                      ListTile(title: Text("Class code            :  ${globals.clas}"))),
              Card(
                  child: ListTile(
                      title: Text("Academic Year     : ${globals.academicyear}"))),
              Card(
                  child: ListTile(
                      title: Text("Programme           :  ${globals.programme}"))),
              Card(
                  child: ListTile(title: Text("Branch                   :  ${globals.branch}"))),
              //Card(child: ListTile(title: Text("Section  :  ${globals.sec}"))),
              Card(
                  child: ListTile(title: Text("Student Id             :  ${globals.id}"))),
              SizedBox(height: 40.0),
            ],
          ),
        ),
        /*ElevatedButton(
          onPressed: () {
            signOut();
            // Respond to button press
          },
          child: Text('LOGOUT'),
        )*/
      ]),
    );
  }
}
