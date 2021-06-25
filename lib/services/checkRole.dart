import 'package:flutter/material.dart';
import 'package:smart_attendance/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart'

;
import 'package:smart_attendance/pages/Login/login1.dart';
import 'package:smart_attendance/pages/admin/adminview.dart';
import 'package:smart_attendance/pages/student/home.dart';
import 'package:smart_attendance/pages/teacher/home.dart';


class checkRole{

  check(String uid) {

   Widget firstwidget;
    debugPrint("Inside getStud func");
    debugPrint('${globals.role}');

    if (globals.role == null) {
      firstwidget=Login();
    } else {


      if (globals.role== 'admin') {
      firstwidget=admin();

      } else if (globals.role == 'teacher') {

        firstwidget=Teacher();

      } else if (globals.role== 'student') {

        debugPrint("Reached getStud func");

        debugPrint("Passes getStud func");
        firstwidget=Student();

      } else {
        debugPrint("No data");
      }
    }
    return firstwidget;
  }


}

class loadDetails{

  static load(String uid) async{
DocumentSnapshot snapshot = await Firestore.instance
    .collection('users')
    .document('$uid')
    .get();
//debugPrint(snapshot.data['role']);

if (snapshot.data == null) {

} else {
if (snapshot.data['role'] == 'admin') {

  globals.role = snapshot.data['role'];

} else if (snapshot.data['role'] == 'teacher') {
globals.name = snapshot.data['name'];
globals.post = snapshot.data['post'];
globals.role = snapshot.data['role'];
globals.dept=snapshot.data['dept'];
globals.attendance_id = snapshot.data['attendance_id'];


} else if (snapshot.data['role'] == 'student') {
globals.clas = snapshot.data['class'];
globals.name = snapshot.data['name'];
globals.id = snapshot.data['id'];
globals.role = snapshot.data['role'];
globals.academicyear = snapshot.data['academicyear'];
globals.programme = snapshot.data['programme'];
globals.branch = snapshot.data['branch'];
debugPrint("Reached getStud func");

debugPrint("Passes getStud func");


} else {
debugPrint("No data");
}
}
}
}