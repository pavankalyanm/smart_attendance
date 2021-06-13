import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'adminview.dart';

class changePassword extends StatefulWidget {
  const changePassword({Key key}) : super(key: key);

  @override
  _changePasswordState createState() => _changePasswordState();
}

class _changePasswordState extends State<changePassword> {

  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController  chpwdInputController;



  @override
  initState() {
    chpwdInputController = new TextEditingController();

    super.initState();
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


  Future<void> _chpwd() async {


    if (_registerFormKey.currentState.validate()) {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();

      //Pass in the password to updatePassword.
      user.updatePassword(chpwdInputController.text).then((result)=>{

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("successful"),
            content: Text("Password changed successfully"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> admin()));

                },
                child: Text("ok"),
              ),
            ],
          ),
        ),
      }).catchError((error){
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("error"),
            content: Text("Password can't be changed" + error.toString()),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> admin()));

                },
                child: Text("ok"),
              ),
            ],
          ),
        );
        //print("Password can't be changed" + error.toString());
        //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
      });
    }}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text("Change Password"),
          backgroundColor: Colors.indigo,
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
            border: new OutlineInputBorder(

              borderRadius: new BorderRadius.circular(20.0),
              borderSide: new BorderSide(
              ),
            ),
    labelText: 'Password*', hintText: ""),
    controller:  chpwdInputController,
    validator: pwdValidator,
    ),
      SizedBox(height: 15,),
      MaterialButton(


        minWidth: 160.0,
        height: 60,
        onPressed: (){
          _chpwd();
        },
        color: Colors.indigoAccent,
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

    ],
    ),
    )))

    );
  }
}
