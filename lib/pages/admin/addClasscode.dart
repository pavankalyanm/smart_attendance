import 'package:flutter/material.dart';
import 'package:smart_attendance/widgets/snackbar.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_attendance/pages/admin/adminview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_attendance/theme/style.dart' as color;
import 'package:smart_attendance/widgets/snackbar.dart';



class addClasscode extends StatefulWidget {
  const addClasscode({Key key}) : super(key: key);

  @override
  _addClasscodeState createState() => _addClasscodeState();
}




class _addClasscodeState extends State<addClasscode> {



  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();


  TextEditingController  classcodeInputController;
  TextEditingController academicyrInputController;

  String selectedbranch;
  String selectedprogramme;

  @override
  initState() {
  classcodeInputController = new TextEditingController();

  academicyrInputController = new TextEditingController();

  super.initState();
  }



  String nameValidator(String value) {
  if (value.length < 3) {
  return "Please enter a valid name.";
  } else {
  return null;
  }
  }
  // String classValidator(String value) {
  // if (value.length < 3) {
  // return "Please enter class.";
  //} else {
  //  return null;
  // }
  //}


  void showidalog(String val) {
  showDialog(
  context: context,
  builder: (BuildContext context) {
  return AlertDialog(
  title: Text("Succesful"),
  content: Text("$val"),
  actions: <Widget>[
  FlatButton(
  child: Text("Close"),
  onPressed: () {
  classcodeInputController.clear();
  selectedbranch=null;
  academicyrInputController.clear();
  //classInputController.clear();

  Navigator.of(context).pop();
  },
  )
  ],
  );
  });
  }




  Future<void> addClasscode() async{

    Map<String, String> classcode = {
      "class_code":classcodeInputController.text,
      "Academic year": academicyrInputController.text,
      "programme": selectedprogramme,
      "branch": selectedbranch,

    };

    DocumentReference users = Firestore
        .instance
        .collection('class')
        .document("${classcodeInputController.text}");
    users
        .setData(classcode)
        .then((value) => {
      showidalog('class code added succesfully'),
    })
        .catchError((err) => showInSnackbar.showSnackbar(_scaffoldKey, "$err"));
}


  final _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key:_scaffoldKey,
        appBar: AppBar(
          title: Text("Add Classcodes"),
          backgroundColor: color.primaryColor,
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
                child: Form(
                  key: _registerFormKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 10,),
                      TextFormField(
                        decoration: InputDecoration(
                            border: new OutlineInputBorder(

                              borderRadius: new BorderRadius.circular(20.0),
                              borderSide: new BorderSide(
                              ),
                            ),
                            labelText: 'Class code*', hintText: "17001a05"),
                        controller:  classcodeInputController,
                        validator: nameValidator,
                      ),
                      SizedBox(height: 10,),
                      TextFormField(
                        decoration: InputDecoration(
                            border: new OutlineInputBorder(

                              borderRadius: new BorderRadius.circular(20.0),
                              borderSide: new BorderSide(
                              ),
                            ),
                            labelText: 'Academicyear'),
                        controller: academicyrInputController,
                        //validator: classValidator,
                      ),
                      SizedBox(height: 10,),


                      new StreamBuilder<QuerySnapshot>(
                          stream: Firestore.instance.collection('department').snapshots(),
                          builder: (context, snapshot){
                            //if (!snapshot.hasData) return const Center(
                            // child: const CupertinoActivityIndicator(),
                            // );
                            var length = snapshot.data.documents.length;
                            DocumentSnapshot ds = snapshot.data.documents[length - 1];
                            // _queryCat = snapshot.data.documents;
                            return new Container(
                              padding: EdgeInsets.only(bottom: 16.0),
                              //width: screenSize.width*0.9,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                      flex: 2,
                                      child: new Container(
                                        padding: EdgeInsets.fromLTRB(12.0,10.0,10.0,10.0),
                                        child: new Text("Branch"),
                                      )
                                  ),
                                  new Expanded(
                                    flex: 4,
                                    child:new InputDecorator(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(

                                        ),
                                        hintText: 'Choose branch',
                                        hintStyle: TextStyle(
                                          // color: Colors.black,
                                          fontSize: 16.0,
                                          //fontFamily: "OpenSans",
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      isEmpty: selectedbranch == null,
                                      child: DropdownButtonHideUnderline(
                                        child: new DropdownButton(
                                          value: selectedbranch,
                                          isDense: true,
                                          onChanged: (String newValue) {
                                            setState(() {
                                              selectedbranch = newValue;
                                              // dropDown = false;
                                              print(selectedbranch);
                                            });
                                          },
                                          items: snapshot.data.documents.map((DocumentSnapshot document) {
                                            return new DropdownMenuItem<String>(
                                                value: document.data['name'],
                                                //controller: deptInputController,
                                                child: new Container(
                                                  decoration: new BoxDecoration(
                                                    //color: Colors.black,
                                                      borderRadius: new BorderRadius.circular(20.0)
                                                  ),
                                                  height: 100.0,
                                                  padding: EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 0.0),
                                                  //color: primaryColor,
                                                  child: new Text(document.data['name']),
                                                )
                                            );
                                          }).toList(),
                                        ),

                                      ),),
                                  ),
                                ],
                              ),
                            );
                          }
                      ),
                      // SizedBox(height: 10.0),
                      new StreamBuilder<QuerySnapshot>(
                          stream: Firestore.instance.collection('programme').snapshots(),
                          builder: (context, snapshot){
                            //if (!snapshot.hasData) return const Center(
                            // child: const CupertinoActivityIndicator(),
                            // );
                            var length = snapshot.data.documents.length;
                            DocumentSnapshot ds = snapshot.data.documents[length - 1];
                            // _queryCat = snapshot.data.documents;
                            return new Container(
                              padding: EdgeInsets.only(bottom: 16.0),
                              //width: screenSize.width*0.9,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                      flex: 2,
                                      child: new Container(
                                        padding: EdgeInsets.fromLTRB(12.0,10.0,10.0,10.0),
                                        child: new Text("Programme"),
                                      )
                                  ),
                                  new Expanded(
                                    flex: 4,
                                    child:new InputDecorator(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(

                                        ),
                                        hintText: 'Choose Programme',
                                        hintStyle: TextStyle(
                                          // color: Colors.black,
                                          fontSize: 16.0,
                                          //fontFamily: "OpenSans",
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      isEmpty: selectedprogramme == null,
                                      child: DropdownButtonHideUnderline(
                                        child: new DropdownButton(
                                          value: selectedprogramme,
                                          isDense: true,
                                          onChanged: (String newValue) {
                                            setState(() {
                                              selectedprogramme = newValue;
                                              // dropDown = false;
                                              print(selectedprogramme);
                                            });
                                          },
                                          items: snapshot.data.documents.map((DocumentSnapshot document) {
                                            return new DropdownMenuItem<String>(
                                                value: document.data['name'],
                                                //controller: deptInputController,
                                                child: new Container(
                                                  decoration: new BoxDecoration(
                                                    //color: Colors.black,
                                                      borderRadius: new BorderRadius.circular(20.0)
                                                  ),
                                                  height: 100.0,
                                                  padding: EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 0.0),
                                                  //color: primaryColor,
                                                  child: new Text(document.data['name']),
                                                )
                                            );
                                          }).toList(),
                                        ),

                                      ),),
                                  ),
                                ],
                              ),
                            );
                          }
                      ),
                      // SizedBox(height: 10,),


                      SizedBox(height: 15,),
                      MaterialButton(


                        minWidth: 160.0,
                        height: 60,
                        onPressed: (){
                          addClasscode();
                        },
                        color: Colors.indigoAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child: Text(
                          "Add New Class code",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18
                          ),
                        ),
                      ),
                      /* Text("Already have an account?"),
                      FlatButton(
                        child: Text("Login here!"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )*/
                    ],
                  ),
                ))));
  }
}
