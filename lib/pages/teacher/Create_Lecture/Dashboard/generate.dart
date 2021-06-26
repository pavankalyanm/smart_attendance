import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_attendance/globals.dart' as globals;
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_attendance/widgets/dialog.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';

class GenerateScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => GenerateScreenState();
}

class GenerateScreenState extends State<GenerateScreen> {

  static const double _topSectionTopPadding = 30.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;

  GlobalKey globalKey = new GlobalKey();
  GlobalKey scr = GlobalKey();
  String _dataString = globals.qrCode;
  String _inputErrorText;
  final TextEditingController _textController =  TextEditingController();
  final sscontroller =ScreenshotController();




  @override
  Widget build(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom;
    return  Scaffold(
          appBar: AppBar(
              title: Text("Attendance Started" ,style: TextStyle(color: Colors.black),),
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              actions: <Widget>[


                // action button
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: ()async{
                    final imageFile=await sscontroller.capture();
                    saveAndshare(imageFile);
                  },
                ),



              ]),
          body:

       Screenshot(
         controller: sscontroller,
         child: Container(
           //bodyHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom;
          color: const Color(0xFFFFFFFF),
          child:  Column(
            children: <Widget>[
              Container(
                // height: _topSectionHeight,
                child:  Row(
                  //mainAxisSize: MainAxisSize.max,
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: 50,),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),

                      child:  Text("Students Should Scan the QR Code for Attendance",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,

                        ),
                      ),

                    )

                  ],
                ),
              ),
              SizedBox(
                height: 1.0,
              ),

              Center(

                // height: _topSectionHeight,
                child:  Row(
                  //mainAxisSize: MainAxisSize.max,
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height:1.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),

                      child:  Text("${globals.courseName.toUpperCase()}"+   '(${DateFormat("dd-mm-yyyy").format(DateTime.now())})',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,

                        ),
                      ),

                    )

                  ],
                ),
              ),


              Expanded(

                  child:Center(
                    child: RepaintBoundary(
                      key: scr,
                      child: QrImage(
                        data: _dataString,
                        size: 0.5 * bodyHeight,
                        onError: (ex) {
                          print("[QR] ERROR - $ex");
                          setState((){
                            _inputErrorText = "Error! Maybe your input value is too long?";
                          });
                        },
                      ),
                    ),
                  ),

              ),
            ],
          ),
      ),
       ),



    );


  }














  void saveAndshare(Uint8List bytes) async{
    await [Permission.storage].request();
    final time=new DateTime.now();
    final name='${globals.classCode}_$time';
    final Directory=await getApplicationDocumentsDirectory();
    final image=File('${Directory.path}/$name.png');
    image.writeAsBytesSync(bytes);
    await Share.shareFiles([image.path], text: '');

  }
}
