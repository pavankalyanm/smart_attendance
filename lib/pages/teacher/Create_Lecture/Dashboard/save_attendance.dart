import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:smart_attendance/pages/screens/teacher/profile.dart';
//import 'package:smart_attendance/pages/screens/teacher/previous_lectures.dart';
//import 'package:smart_attendance/pages/screens/teacher/generation_data.dart';
import 'package:smart_attendance/globals.dart' as globals;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart';



import 'package:smart_attendance/services/validations.dart';
import 'package:smart_attendance/widgets/snackbar.dart';



final _scaffoldKey=GlobalKey<ScaffoldState>();

class SaveAttendance extends StatefulWidget {
  @override
  _SaveAttendanceState createState() => new _SaveAttendanceState();
}

class _SaveAttendanceState extends State<SaveAttendance> {





//  void showInSnackBar(String value) {
//    _scaffoldKey.currentState
//        .showSnackBar(new SnackBar(content: new Text(value)));
//  }

  static Future _saveAttendanceToFile() async {

    List<List<String>> data=[['${globals.classCode}''-''${globals.sem}','${globals.courseName}','${new DateTime.now()}'],['Id','Attendance']];

    for (int i = 0; i <globals.studentDocumentId.length; i++) {

      debugPrint("creating list , index : $i ");

      DocumentSnapshot snapshot= await Firestore.instance.collection("attendance").document('${globals.attendance_id}').collection("attendance").document("${globals.studentDocumentId[i]}").get();
      if (snapshot.data == null) {debugPrint("No data in student id ${globals.studentDocumentId[i]} ");}
      else{
        //globals.attendanceDetails.putIfAbsent("${snapshot.data['id']}" , ()=> "${snapshot.data['attendance']}");
        data.add(['${snapshot.data['id']}','${snapshot.data['attendance']}']);
      }


    }
    Directory appDocDir = await getExternalStorageDirectory();
    String csvData = ListToCsvConverter().convert(data);

    String file_name="${globals.classCode}_${globals.courseName}_${new DateTime.now()}.csv";
    final file = File('${appDocDir.path}/$file_name');
    //  final text = "${globals.attendanceDetails}";
    await file.writeAsString(csvData);

    final snackBar = SnackBar(
      duration: new Duration(seconds: 8),
      behavior: SnackBarBehavior.floating,
      content: Text(
        'File successfully downloaded to $file',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);

    debugPrint('saved to $file');

    // to fire store
    toFirestore.upload(file,file_name);


  }




  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      key: _scaffoldKey,
        appBar: new AppBar(
          backgroundColor: Colors.white,
          title: Container(
              alignment: Alignment.center,
              child: new Text('Download Attendance',style: TextStyle(color: Colors.black),)),
          automaticallyImplyLeading: false,
        ),
        body:  new Center(

//          new Center(
////            child: new Image.asset(
////              'images/white_snow.png',
////              width: 490.0,
////              height: 1200.0,
////              fit: BoxFit.fill,
////            ),
//          ),

            child:Column(
              children: [
                SizedBox(height: 200,),
                Container(
                  child: new Text(
                    'Click below to download Attendance',
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  height: 100.0,
                  child: SizedBox.fromSize(
                    size: Size(100, 100), // button width and height
                    child: ClipOval(
                      child: Material(
                        color: Colors.indigo, // button color
                        child: InkWell(
                          splashColor: Color.fromRGBO(248, 177, 1, 1),
                          // splash color
                          onTap: () {
                            _saveAttendanceToFile();
                          },
                          // button pressed
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.file_download,
                                color: Colors.white,
                              ), // icon
                              Text(
                                "Download",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ), // text
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )


        ));
  }


}






class toFirestore{

  static Future<void> upload(file,file_name) async{
    try {
      final storage = FirebaseStorage.instance;
      StorageReference ref = await storage
          .ref()
          .child('attendance').child('$file_name');

      final StorageUploadTask uploadTask = await ref.putFile(
          file);
      
      //debugPrint('${await ref.getDownloadURL()}');
    }catch(e){
      debugPrint("e");
    }
   }

   
}

