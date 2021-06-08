//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:smart_attendance/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendance/pages/Login/login1.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:smart_attendance/theme/style.dart';

//import 'package:smart_attendance/components/TextFields/inputField.dart';
//import 'package:smart_attendance/components/Buttons/textButton.dart';
//import 'package:smart_attendance/components/Buttons/roundedButton.dart';
import 'package:smart_attendance/services/validations.dart';
import 'package:smart_attendance/globals.dart' as globals;
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:smart_attendance/pages/teacher/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_attendance/theme/style.dart' as style;

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



  bool autovalidate = false;
  Validations validations = new Validations();

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> signOut() async {
    await auth.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );

  }

@override
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
  }



  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        appBar: AppBar(backgroundColor: Colors.white,
          title: Container(
            alignment: Alignment.center,
            child: Text('Profile',
                style: TextStyle(
                  color: Colors.black,)
            ),
          ),
          automaticallyImplyLeading: false,),
        body:
        Column(

          children: [
        Expanded(
           child: ListView(
              children: <Widget>[
                Card(
                  child: ListTile(
                    leading: FlutterLogo(size: 56.0),
                    title: Text('${globals.name}'),
                    subtitle: Text('${globals.post}'),

                  ),
                ),
                SizedBox(height: 40.0),
                Center (child: Text("Details")),

                Card(child: ListTile(title: Text("Designation   :  ${globals.post}"))),

              ],
            ),

        ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(style.primaryColor),
              ),
              onPressed: () {

                signOut();
                // Respond to button press
              },
              child: Text('LOGOUT',style: TextStyle(color: Colors.white),),
            )
          ],
        ),
    );
  }


}
