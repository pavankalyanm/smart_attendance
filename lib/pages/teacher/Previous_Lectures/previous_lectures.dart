import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_attendance/globals.dart' as globals;
import 'package:smart_attendance/pages/teacher/Create_Lecture/generation_data.dart';
//import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:smart_attendance/pages/teacher/home.dart';
import 'package:smart_attendance/widgets/dialog.dart';
import 'package:smart_attendance/widgets/snackbar.dart';

class PreviousLectures extends StatefulWidget {
  const PreviousLectures({Key key}) : super(key: key);

  @override
  PreviousLecturesState createState() => new PreviousLecturesState();
}

class PreviousLecturesState extends State<PreviousLectures> {
  PreviousLecturesState({Key key, this.user});
  final FirebaseUser user;

/*  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }*/

  bool myInterceptor(bool stopDefaultButtonEvent) {
    print("BACK BUTTON!"); // Do some stuff.
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Generation()),
    );
    return true;
  }

  String collection1 = "users";
  String collection2 = "previous_lecture";
  String uid = globals.uid;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          alignment: Alignment.center,
          child: Text('Lectures Taken',
              style: TextStyle(
                color: Colors.black,
              )),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    debugPrint("inside _buildBody");
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('$collection1')
          .document('$uid')
          .collection('$collection2')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.time_stamp),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          trailing: IconButton(
            color: Colors.black,
            icon: Icon(Icons.file_download),
            onPressed: () {
              // _showDialog(context);
            },
          ),
          onTap: () {
            //function to download file

            showInDialog.show(context, 'File Successfully download to PATH:/storage/emulated/0/data/com.saqr.android/files');
          },
          title: Text("Subject : ${record.course_code}"),
          subtitle: Text(
              "Class : ${record.class_code}                                                 Taken on ${record.time_stamp}"),
        ),
      ),
    );
  }
}

class Record {
  final String time_stamp;
  final String course_code;
  final String class_code;

  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['time_stamp'] != null),
        assert(map['course_name'] != null),
        assert(map['class_code'] != null),
        time_stamp = map['time_stamp'],
        course_code = map['course_name'],
        class_code = map['class_code'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

//  @override
//  String toString() => "Record<$lecture_number:$attendance>";
}
