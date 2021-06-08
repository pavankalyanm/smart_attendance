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
import 'package:smart_attendance/pages/student/home.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      MaterialPageRoute(builder: (context) => Student()),
    );
    return true;
  }


  bool autovalidate = false;
  Validations validations = new Validations();

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
        child: Text('Profile',
            style: TextStyle(
              color: Colors.black,
            )
        ),
      ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,),
      body:
      Column(
          children:[
            Expanded(
        child: ListView(

          children: <Widget>[

            Container(
              child: Card(
                child: ListTile(
                  leading: Image.asset("assets/res/student.png"),
                  title: Text('${globals.name}'),
                  subtitle: Text('${globals.id}'),

                ),
              ),
            ),
            SizedBox(height: 40.0),
            Center (child: Text("User Details:-")),

            //Card(child: ListTile(title: Text("Under faculty   :  ${globals.faculty}"))),
            Card(child: ListTile(title: Text("ClassCode  :  ${globals.clas}"))),
            Card(child: ListTile(title: Text("Academic Year  : ${globals.academicyear}"))),
            Card(child: ListTile(title: Text("Programme  :  ${globals.programme}"))),
            Card(child: ListTile(title: Text("Branch  :  ${globals.branch}"))),
            //Card(child: ListTile(title: Text("Section  :  ${globals.sec}"))),
            Card(child: ListTile(title: Text("Roll No  :  ${globals.id}"))),


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
