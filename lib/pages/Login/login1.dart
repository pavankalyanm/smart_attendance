import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_attendance/faceapi/pages/db/database.dart';
import 'package:smart_attendance/faceapi/pages/sign-in.dart';
import 'package:smart_attendance/faceapi/pages/sign-up.dart';
import 'package:smart_attendance/faceapi/services/facenet.service.dart';
import 'package:smart_attendance/faceapi/services/ml_kit_service.dart';
import 'package:smart_attendance/pages/admin/adminview.dart';
import 'package:camera/camera.dart';


import 'package:smart_attendance/pages/student/home.dart';
import 'package:smart_attendance/pages/teacher//home.dart';
import 'package:smart_attendance/pages/welcome.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:smart_attendance/services/sharedpreferences.dart';
import 'package:smart_attendance/theme/style.dart';
import '../admin.dart';
import 'style.dart';
import 'package:smart_attendance/components/TextFields/inputField.dart';
import 'package:smart_attendance/components/Buttons/textButton.dart';
import 'package:smart_attendance/components/Buttons/roundedButton.dart';
import 'package:smart_attendance/services/validations.dart';
import 'package:smart_attendance/globals.dart' as globals;
//import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:smart_attendance/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => new _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password;
  /*CameraDescription cameraDescription;
  FaceNetService _faceNetService = FaceNetService();
  MLKitService _mlKitService = MLKitService();
  DataBaseService _dataBaseService = DataBaseService();
  bool loading = false;*/
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  /*@override
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
  }*/

/* @override
  void initState() async {
    super.initState();

    final SharedPreferences preferences= await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }*/


//  void showInSnackBar(String value) {
//    _scaffoldKey.currentState
//        .showSnackBar(new SnackBar(content: new Text(value)));
//  }

  bool autovalidate = false;
  Validations validations = new Validations();

//  void _insert() async {
//    // row to insert
//    Map<String, dynamic> row = {
//      DatabaseHelper.columnName : 'Bob',
//      DatabaseHelper.columnAge  : 23
//    };
//    final id = await dbHelper.insert(row);
//    print('inserted row id: $id');
//  }



  checkRole() async {
    debugPrint("Inside getStud func");

    DocumentSnapshot snapshot = await Firestore.instance
        .collection('users')
        .document('${globals.uid}')
        .get();
    if (snapshot.data == null) {
      debugPrint("No data in users uid");
    } else {
      if (snapshot.data['role'] == 'admin') {
        // Can be made after wards
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => admin()),
        );
      } else if (snapshot.data['role'] == 'teacher') {
        globals.name = snapshot.data['name'];
        globals.post = snapshot.data['post'];
        globals.role = snapshot.data['role'];
        globals.dept=snapshot.data['dept'];

        globals.attendance_id = snapshot.data['attendance_id'];
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Teacher()),
        );
      } else if (snapshot.data['role'] == 'student') {
        globals.clas = snapshot.data['class_code'];
        globals.name = snapshot.data['name'];
        globals.id = snapshot.data['id'];
        globals.role = snapshot.data['role'];
        globals.programme=snapshot.data['programme'];
        globals.branch=snapshot.data['branch'];
        globals.facedata=snapshot.data['facedata'];
        globals.academicyear = snapshot.data['academicyear'];
        debugPrint("${globals.uid}");
        debugPrint("Reached getStud func");
        getStud();
        debugPrint("Passes getStud func");
        final SharedPreferences preferences= await SharedPreferences.getInstance();
        preferences.setString('classcode', globals.clas);

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Student()),
        );
      } else {
        debugPrint("No data");
      }
    }
  }

  getStud() async {
    debugPrint("Inside getStud func");

    DocumentSnapshot snapshot = await Firestore.instance
        .collection('class')
        .document('${globals.clas}')
        .get();
    if (snapshot.data == null) {
      debugPrint("No data in class > classcode");
    } else {
      globals.branch = snapshot.data['branch'];
      debugPrint("See if the value of branch is set : ${globals.branch}");
      globals.faculty = snapshot.data['faculty'];
      globals.programme = snapshot.data['programme'];
      globals.sec = snapshot.data['sec'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return new Scaffold(
      //resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('LogIn'),
        backgroundColor: Colors.indigo,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    new Container(
                width: 180,
                height: 180,
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: ExactAssetImage('assets/res/jntu.png'),
                    fit: BoxFit.fitHeight,
                  ),
                  ),),
                    SizedBox(
                      height: 10,
                    ),
                    new Container(
                      child: Text(
                        "WELCOME",
                        style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    new Container(
                      child: Text(
                        "Login With the provided Institution Details",
                        style: TextStyle(fontFamily: 'poppins', fontSize: 15),
                      ),
                    ),
                    //initialValue: 'Input text',
                    SizedBox(
                      height: 30,
                    ),

                    Container(
                      width: screenSize.width / 1.2,
                      child: new TextFormField(
                        cursorColor: Colors.indigo,
                        style: TextStyle(fontSize: 20, color: Colors.indigo),
                        decoration: InputDecoration(
                          // hintText: 'Please enter your email',
                          hintStyle:
                              TextStyle(color: Colors.indigo, fontSize: 20),
                          labelText: 'Email',
                          labelStyle:
                              TextStyle(color: Colors.indigo, fontSize: 20),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  BorderSide(color: Colors.indigo[400])),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  BorderSide(color: Colors.indigo[400])),
                        ),
                        //hintText: "Email",

                        obscureText: false,
                        //textInputType: TextInputType.text,
                        //textStyle: textStyle,
                        // textFieldColor: textFieldColor,
                        //icon: Icons.mail_outline,
                        //iconColor: Colors.black,
                        //bottomMargin: 20.0,
                       // validator: validations.validateEmail,
                        onSaved: (input) => _email = input,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: screenSize.width / 1.2,
                      child: new TextFormField(
                        cursorColor: Colors.indigo,
                        style: TextStyle(fontSize: 20, color: Colors.indigo),
                        decoration: InputDecoration(
                          // hintText: 'Please enter your email',
                          hintStyle:
                              TextStyle(color: Colors.indigo, fontSize: 20),
                          labelText: 'Password',
                          labelStyle:
                              TextStyle(color: Colors.indigo, fontSize: 20),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  BorderSide(color: Colors.indigo[400])),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  BorderSide(color: Colors.indigo[400])),
                        ),
                        //hintText: "Password",
                        obscureText: true,
                        //textInputType: TextInputType.text,
                        // textStyle: textStyle,
                        //textFieldColor: textFieldColor,
                        //icon: Icons.lock_open,
                        //iconColor: Colors.black,
                        //bottomMargin: 30.0,
                        // validator: validations.validatePassword,
                        onSaved: (input) => _password = input,
                      ),
                    ),
//              TextFormField(
////                validator: (input) {
////                  if (input.isEmpty) {
////                    return 'Provide an email';
////                  }
////                },
//                decoration: InputDecoration(labelText: 'Email'),
//
//                onSaved: (input) => _email = input,
//              ),
                    SizedBox(
                      height: 30,
                    ),
                    new RoundedButton(
                      buttonName: "LOGIN",
                      onTap: checkNet,
                      width: screenSize.width / 2,
                      height: 50.0,
                      bottomMargin: 10.0,
                      borderWidth: 0.0,
                      buttonColor: primaryColor,
                    ),

                  ],
                )),
          ),
        ),
      ),
    );
  }

  void signIn() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        FirebaseUser user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);

        _scaffoldKey.currentState.showSnackBar(new SnackBar(
          duration: new Duration(seconds: 20),
          content: new Row(
            children: <Widget>[
              new CircularProgressIndicator(),
              new Text("  Loging-In...")
            ],
          ),
        ));
        globals.uid = user.uid;

        final SharedPreferences preferences= await SharedPreferences.getInstance();
        preferences.setString('userid', user.uid);


        debugPrint("printing uid   ${globals.uid}");
        checkRole();
        debugPrint("Role checking done");
      } catch (e) {
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
          duration: new Duration(seconds: 4),
          content: new Row(
            children: <Widget>[
              new Text("Invalid email id or password entered"),
            ],
          ),
        ));
        print(e.message);

//        showInSnackBar(e.message.toString());
      }
    }
  }

  Future checkNet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        signIn();
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
