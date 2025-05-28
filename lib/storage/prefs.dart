import 'package:navy_encrypt/pages/settings/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPrefs {
  static const KEY_REF_CODE = 'ref_code';
  static const KEY_EMAIL = 'email';
  static const KEY_SECRET = 'secret';
  static const KEY_WATERMARK_REGISTER_STATUS = 'watermark_register_status';
  static const KEY_OAUTH_CREDENTIALS = 'oauth_credentials';

  static Future<SharedPreferences> _getSharedPref() async {
    return await SharedPreferences.getInstance();
  }

  static Future<String> getRefCode() async {
    return (await _getSharedPref()).getString(KEY_REF_CODE);
  }

  static Future<void> setRefCode(String refCode) async {
    var sharedPref = await _getSharedPref();
    if (refCode == null) {
      await sharedPref.remove(KEY_REF_CODE);
    } else {
      await sharedPref.setString(KEY_REF_CODE, refCode);
    }
  }

  static Future<String> getEmail() async {
    return (await _getSharedPref()).getString(KEY_EMAIL);
  }

  static Future<void> setEmail(String email) async {
    var sharedPref = await _getSharedPref();
    if (email == null) {
      await sharedPref.remove(KEY_EMAIL);
    } else {
      await sharedPref.setString(KEY_EMAIL, email);
    }
  }

  static Future<String> getSecret() async {
    return (await _getSharedPref()).getString(KEY_SECRET);
  }

  static Future<void> setSecret(String secret) async {
    var sharedPref = await _getSharedPref();
    if (secret == null) {
      await sharedPref.remove(KEY_SECRET);
    } else {
      await sharedPref.setString(KEY_SECRET, secret);
    }
  }

  static Future<String> getOAuthCredentials(String serviceName) async {
    final key = '${serviceName}_${KEY_OAUTH_CREDENTIALS}';
    return (await _getSharedPref()).getString(key);
  }

  static Future<void> setOAuthCredentials(String serviceName, String credentials) async {
    final key = '${serviceName}_${KEY_OAUTH_CREDENTIALS}';

    var sharedPref = await _getSharedPref();
    if (credentials == null) {
      await sharedPref.remove(key);
    } else {
      await sharedPref.setString(key, credentials);
    }
  }
}
