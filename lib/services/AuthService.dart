import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<String> getCurrentUID() async{
    final FirebaseUser user = await _auth.currentUser();
    final String uid = user.uid;
    return uid;
  }
}