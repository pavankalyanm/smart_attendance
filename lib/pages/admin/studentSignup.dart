import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_attendance/pages/admin/adminview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*class studentSignup extends StatelessWidget {
  const studentSignup({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,),


        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text("ADD STUDENT",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,

                    ),),
                  /* SizedBox(height: 5,),
                  Text("ADD STUDENT",
                    style: TextStyle(
                        fontSize: 15,
                        color:Colors.grey[700]),
                  )*/

                ],
              ),
              Column(
                children: <Widget>[
                  inputFile(label: "Name"),
                  inputFile(label: "ID"),
                  inputFile(label: "Class"),
                  inputFile(label: "Email"),
                  inputFile(label: "Password", obscureText: true),
                  inputFile(label: "Confirm Password ", obscureText: true),


                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 3, left: 3),
                decoration:
                BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border(
                      bottom: BorderSide(color: Colors.black),
                      top: BorderSide(color: Colors.black),
                      left: BorderSide(color: Colors.black),
                      right: BorderSide(color: Colors.black),



                    )

                ),
                child: MaterialButton(
                  minWidth: double.infinity,
                  height: 60,
                  onPressed: () {},
                  color: Color(0xff0095FF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),

                  ),
                  child: Text(
                    "ADD", style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white,

                  ),
                  ),

                ),



              )
              /*Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Already have an account?"),
                  Text(" Login", style:TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18
                  ),
                  )
                ],
              )*/



            ],

          ),


        ),

      ),

    );
  }
}



Widget inputFile({label, obscureText = false})
{
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color:Colors.black87
        ),

      ),
      SizedBox(
        height: 5,
      ),
      TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0,
                horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.grey[400]
              ),

            ),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[400])
            )
        ),
      ),
      SizedBox(height: 10,)
    ],
  );
}*/

class studentSignup extends StatefulWidget {
  const studentSignup({Key key}) : super(key: key);

  @override
  _studentSignupState createState() => _studentSignupState();
}

class _studentSignupState extends State<studentSignup> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController  nameInputController;
  TextEditingController classInputController;
  TextEditingController idInputController;

  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  TextEditingController confirmPwdInputController;
  String role='student';
  String courseValue = 'select course';
  String branchValue = 'select branch';
  String regulationValue = 'select regulation';
  String yearValue = 'select year';

  @override
  initState() {
    nameInputController = new TextEditingController();
    classInputController = new TextEditingController();
    idInputController = new TextEditingController();
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    confirmPwdInputController = new TextEditingController();
    super.initState();
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String pwdValidator(String password) {
    if (password.isEmpty) return 'Please enter a password.';
    if (password.length < 8) return 'Password must contain minimum of 8 characters';
    if (!password.contains(RegExp(r"[a-z]"))) return 'Password must contain at least one lowercase letter';
    if (!password.contains(RegExp(r"[A-Z]"))) return 'Password must contain at least one uppercase letter';
    if (!password.contains(RegExp(r"[0-9]"))) return 'Password must contain at least one digit';
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return 'Password must contain at least one special character';
    return null;
  }

  String nameValidator(String value) {
    if (value.length < 3) {
      return "Please enter a valid name.";
    } else {
      return null;
    }
  }
  String classValidator(String value) {
    if (value.length < 3) {
      return "Please enter class.";
    } else {
      return null;
    }
  }
  String idValidator(String value) {
    if (value.length < 9) {
      return "Please enter a valid first name.";
    } else {
      return null;
    }
  }


  Future<void> registerUser() async {
    if (_registerFormKey.currentState.validate()) {
      if (pwdInputController.text ==
          confirmPwdInputController.text) {
        FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: emailInputController.text,
            password: pwdInputController.text)
            .then((currentUser) => Firestore.instance
            .collection("users")
            .document(currentUser.uid)
            .setData({
          //"uid": currentUser.uid,
          "name":  nameInputController.text,
          "class": classInputController.text,
          "id": idInputController.text,
          "role":role,
          //"email": emailInputController.text,
        })
            .then((result) => {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => admin(
                    //title:
                    // nameInputController
                    //.text +
                    //  "'s Tasks",
                    //uid: currentUser.uid,
                  )),
                  (_) => false),
          nameInputController.clear(),
          classInputController.clear(),
          idInputController.clear(),
          emailInputController.clear(),
          pwdInputController.clear(),
          confirmPwdInputController.clear()
        })
            .catchError((err) => print(err)))
            .catchError((err) => print(err));
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text("The passwords do not match"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Close"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Student"),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
                child: Form(
                  key: _registerFormKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Name*', hintText: "John"),
                        controller:  nameInputController,
                        validator: nameValidator,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Class*'),
                        controller: classInputController,
                        validator: classValidator,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Roll.no*'),//ID*
                        controller: idInputController,
                        validator:idValidator,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Email*', hintText: "john.doe@gmail.com"),
                        controller: emailInputController,
                        keyboardType: TextInputType.emailAddress,
                        validator: emailValidator,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Password*', hintText: "********"),
                        controller: pwdInputController,
                        obscureText: true,
                        validator: pwdValidator,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Confirm Password*', hintText: "********"),
                        controller: confirmPwdInputController,
                        obscureText: true,
                        validator: pwdValidator,
                      ),
                      RaisedButton(
                        child: Text("Register"),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () {
                          registerUser();
                        },
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


