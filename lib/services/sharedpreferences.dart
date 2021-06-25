import 'package:shared_preferences/shared_preferences.dart';

class UserSimplePreferences {
  static SharedPreferences _preferences;

  static const _keyUserid = '';


  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setUserid(String username) async =>
      await _preferences.setString(_keyUserid, username);

  static String getUserid() => _preferences.getString(_keyUserid);


}