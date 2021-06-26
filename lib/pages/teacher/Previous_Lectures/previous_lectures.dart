import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_attendance/globals.dart' as globals;
import 'package:smart_attendance/pages/teacher/Create_Lecture/generation_data.dart';
//import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:smart_attendance/pages/teacher/home.dart';
import 'package:smart_attendance/widgets/dialog.dart';
import 'package:smart_attendance/widgets/snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';


class PreviousLectures extends StatefulWidget {
  const PreviousLectures({Key key}) : super(key: key);

  @override
  PreviousLecturesState createState() => new PreviousLecturesState();
}

class PreviousLecturesState extends State<PreviousLectures> {
  PreviousLecturesState({Key key, this.user});
  final FirebaseUser user;



  int progress = 0;


  ReceivePort _receivePort = ReceivePort();

  static downloadingCallback(id, status, progress) {
    ///Looking up for a send port
    SendPort sendPort = IsolateNameServer.lookupPortByName("downloading");

    ///ssending the data
    sendPort.send([id, status, progress]);
  }


  @override
  void initState() {

    super.initState();

    ///register a send port for the other isolates
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, "downloading");


    ///Listening for the data is comming other isolataes
    _receivePort.listen((message) {
      setState(() {
        progress = message[2];
      });

      print(progress);
    });


    FlutterDownloader.registerCallback(downloadingCallback);
  }






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
      key: _scaffoldKey,
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
            onPressed: () async{
              // _showDialog(context);
              print('${record.course_code}');
              final Directory  = await getExternalStorageDirectory();
              String path=Directory.path;
              await downloadFile(record.url,path).then((value) => {
                showInDialog.show(context, "File Successfully downloaded to $path")
                //showIntoast.showToast(context,"File Successfully downloaded to $path"),
              });



            },
          ),

          title: Text("Subject : ${record.course_code}"),
          subtitle: Text(
              "Class : ${record.class_code}                                                 Taken on ${record.time_stamp}"),
        ),
      ),
    );
  }
}

Future downloadFile(url , path) async {

  await [Permission.storage].request();
  try {
    final id = await FlutterDownloader.enqueue(
        url: url,
        //headers: {"auth": "test_for_sql_encoding"},
        savedDir: path,
        showNotification: true,
        openFileFromNotification: true);
  }catch(e){
    print(e);
  }
    // print('${Directory.path}');
}

class Record {
  final String time_stamp;
  final String course_code;
  final String class_code;
  final String url;

  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['time_stamp'] != null),
        assert(map['course_name'] != null),
        assert(map['class_code'] != null),
        assert(map['url']!=null),
        time_stamp = map['time_stamp'],
        course_code = map['course_name'],
        class_code = map['class_code'],
        url        =map['url'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

//  @override
//  String toString() => "Record<$lecture_number:$attendance>";
}
