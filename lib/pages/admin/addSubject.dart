import 'package:flutter/material.dart';
import 'package:smart_attendance/widgets/snackbar.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_attendance/pages/admin/adminview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_attendance/theme/style.dart' as color;
import 'package:smart_attendance/widgets/snackbar.dart';

class courseDetails extends StatefulWidget {
  @override
  _courseDetailsState createState() => _courseDetailsState();
}

class _courseDetailsState extends State<courseDetails> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();


  TextEditingController  coursecodeInputController;
  TextEditingController coursenameInputController;

  String selectedsem;
  String selectedclasscode;


  @override
  initState() {
    coursecodeInputController= new TextEditingController();

    coursenameInputController = new TextEditingController();

    super.initState();
  }
  void showidalog(String val) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Succesfull"),
            content: Text("$val"),
            actions: <Widget>[
              FlatButton(
                child: Text("Close"),
                onPressed: () {
                  coursecodeInputController.clear();
                  coursenameInputController.clear();
                  //classInputController.clear();

                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }


  Future<void> addCoursecode() async{

    Map<String, String> coursecode = {
      "coursecode":coursecodeInputController.text,
      "coursename": coursenameInputController.text,
      "semester": selectedsem,
      "classcode": selectedclasscode,

    };
  DocumentReference subject = Firestore
      .instance
      .collection('semester')
      .document("$selectedsem").collection('courses').document("${coursecodeInputController.text}");
      subject
          .setData(coursecode)
      .then((value) => {
  showidalog('subject added succesfully'),
      //showInSnackbar.showSnackbar(_scaffoldKey, "added"),
  })
      .catchError((err) => showInSnackbar.showSnackbar(_scaffoldKey, "$err"));//_scaffoldKey.currentState.showSnackBar(showSnackBar('$err').SnackBar));
}


final _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget build(BuildContext context) {
    return Scaffold(
        key:_scaffoldKey,
        appBar: AppBar(
          title: Text("Add Subject"),
          backgroundColor: color.primaryColor,
        ),
        body: Container(
        padding: const EdgeInsets.all(20.0),
    child: SingleChildScrollView(
    child: Form(
    key: _registerFormKey,
    child: Column(
    children: <Widget>[
      SizedBox(height: 40.0),
      StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("class").snapshots(),
          builder: (context, snapshot) {
            //if (!snapshot.hasData)
              //return CircularProgressIndicator();
            //else {
             // if ((globals.requiredStudents > globals.studentId.length) ||
                 // (globals.requiredStudents == 0)) {
               // globals.startAddingStudents = 1;
             // }

              List<DropdownMenuItem> classCodes = [];
              for (int i = 0; i < snapshot.data.documents.length; i++) {
                DocumentSnapshot snap = snapshot.data.documents[i];
                classCodes.add(
                  DropdownMenuItem(
                    child: Text(
                      snap.documentID,
                     // style: TextStyle(color: style.primaryColor),
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
                       // globals.studentId.clear();
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
                          selectedclasscode= classCodeValue;
                          debugPrint('$selectedclasscode');
                        });
                      },
                      value: selectedclasscode,
                      isExpanded: false,
                      hint: new Text(
                        "Choose Class Code",
                       // style: TextStyle(color: style.primaryColor),
                      ),
                    ),
                  ),
                ],
              );
            }
          ),

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
                      //style: TextStyle(color: style.primaryColor),
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
                        final snackBar = SnackBar(
                          duration: new Duration(seconds: 1),
                          content: Text(
                            'Selected semester is $semesterValue',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                        setState(() {
                          selectedsem= semesterValue;
                        });
                      },
                      value: selectedsem,
                      isExpanded: false,
                      hint: new Text(
                        "Choose Semester",
                       // style: TextStyle(color: style.primaryColor),
                      ),
                    ),
                  ),
                ],
              );
            }
          }),
      TextFormField(
        decoration: InputDecoration(
            border: new OutlineInputBorder(

              borderRadius: new BorderRadius.circular(20.0),
              borderSide: new BorderSide(
              ),
            ),
            labelText: 'Subjectname'),
        controller: coursenameInputController,
      ),
      SizedBox(height: 15,),
      TextFormField(
        decoration: InputDecoration(
            border: new OutlineInputBorder(

              borderRadius: new BorderRadius.circular(20.0),
              borderSide: new BorderSide(
              ),
            ),
            labelText: 'Subjectcode'),
        controller: coursecodeInputController,
      ),
      SizedBox(height: 15,),
      MaterialButton(


        minWidth: 160.0,
        height: 60,
        onPressed: (){
          addCoursecode();
        },
        color: Colors.indigoAccent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
        ),
        child: Text(
          "Add More Subjects",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18
          ),
        ),
      ),
    ],
    ),
    ))));
  }
}


