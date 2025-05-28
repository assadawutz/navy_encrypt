import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:navy_encrypt/etc/constants.dart';
import 'package:navy_encrypt/models/api_result.dart';
import 'package:navy_encrypt/models/log.dart';
import 'package:navy_encrypt/models/share_log.dart';
import 'package:navy_encrypt/models/user.dart';

class MyApi {
  static const END_POINT_REGISTER_WATERMARK = 'watermark/register';
  static const END_POINT_ACTIVATE_WATERMARK = 'watermark/activate';
  static const END_POINT_WATERMARK_SIGNATURE = 'watermark/signature';
  static const END_POINT_WATERMARK_SAVELOG = 'watermark/save_log';
  static const END_POINT_WATERMARK_USER = 'watermark/user';
  static const END_POINT_WATERMARK_UUID = 'watermark/uuid';
  static const END_POINT_WATERMARK_CHECKDECRYPT = 'watermark/check_decrypt';
  static const END_POINT_WATERMARK_LOG = 'watermark/log';
  static const END_POINT_WATERMARK_SHARELOG = 'watermark/share_log';

  Future<int> registerWatermark(
    String email,
    String name,
    String phone,
    String refCode,
    String deviceOs,
    String deviceName,
    String deviceId,
  ) async {
    Map<String, dynamic> params = {};
    params['email'] = email;
    params['name'] = name;
    params['phone'] = phone;
    params['refCode'] = refCode;
    params['deviceOs'] = deviceOs;
    params['deviceName'] = deviceName;
    params['deviceId'] = deviceId;
    try {
      print(
          "END_POINT_REGISTER_WATERMARK > ${END_POINT_REGISTER_WATERMARK} ${params}");
      return await _submit(END_POINT_REGISTER_WATERMARK, params);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<int> activateWatermark(
      String email, String refCode, String secret) async {
    Map<String, dynamic> params = {};
    params['email'] = email;
    params['refCode'] = refCode;
    params['secret'] = secret;
    try {
      return await _submit(END_POINT_ACTIVATE_WATERMARK, params);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<String> getWatermarkSignatureCode(String email, String secret) async {
    Map<String, dynamic> params = {};
    params['email'] = email;
    params['secret'] = secret;
    try {
      print("getWatermarkSignatureCode ${END_POINT_WATERMARK_SIGNATURE}");
      print("getWatermarkSignatureCode ${params}");
      return await _fetch(END_POINT_WATERMARK_SIGNATURE, params);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<int> saveLog(
      String email,
      String fileName,
      String uuid,
      String signatureCode,
      String action,
      String type,
      String viewerSecret,
      List<int> shareList) async {
    Map<String, dynamic> params = {};
    params['email'] = email;
    params['fileName'] = fileName;
    params['uuid'] = uuid;
    params['signatureCode'] = signatureCode;
    params['action'] = action;
    params['type'] = type;
    params['viewerSecret'] = viewerSecret;
    params['shareList'] = shareList;

    try {
      return await _submit(END_POINT_WATERMARK_SAVELOG, params);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<List<User>> getUser() async {
    try {
      final List<User> listAddress = [];
      var result = await _fetch(END_POINT_WATERMARK_USER, null);
      listAddress.addAll(userFromJsonArry(json.encode(result)));

      return listAddress;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<String> getUuid(String refCode) async {
    Map<String, dynamic> params = {};
    params['ref_code'] = refCode;

    print(END_POINT_WATERMARK_UUID);
    print(params);
    try {
      return await _fetch(END_POINT_WATERMARK_UUID, params);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<bool> getCheckDecrypt(String email, String uuid) async {
    Map<String, dynamic> params = {};
    params['email'] = email;
    params['uuid'] = uuid;
    try {
      return await _fetch(END_POINT_WATERMARK_CHECKDECRYPT, params);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<List<Log>> getLog(String email) async {
    Map<String, dynamic> params = {};
    params['email'] = email;

    try {
      final List<Log> log = [];
      var result = await _fetch(END_POINT_WATERMARK_LOG, params);
      log.addAll(logFromJsonArry(json.encode(result)));
      return log;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<List<ShareLog>> getShareLog(int id) async {
    Map<String, dynamic> params = {};
    params['id'] = id.toString();

    try {
      final List<ShareLog> shareLog = [];
      var result = await _fetch(END_POINT_WATERMARK_SHARELOG, params);
      shareLog.addAll(shareLogFromJsonArry(json.encode(result)));
      return shareLog;
    } catch (e) {
      print(e);
      throw e;
    }
  }
}

Future<dynamic> _submit(String endPoint, Map<String, dynamic> params) async {
  var url = Uri.parse('${Constants.API_BASE_URL}/$endPoint');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode(params),
  );
  print("URL = ${url}");
  print("Res = ${response.body}");
  print("params = ${params}");

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonBody = json.decode(response.body);
    print('RESPONSE BODY: $jsonBody');

    var result = ApiResult.fromJson(jsonBody);

    if (result.status == 'ok') {
      return result.data;
      // return 1;
    } else {
      throw result.message;
    }
  } else {
    throw response.body;
  }
}

Future<dynamic> _fetch(
    String endPoint, Map<String, dynamic> queryParams) async {
  String queryString = Uri(queryParameters: queryParams).query;
  var url = Uri.parse('${Constants.API_BASE_URL}/$endPoint?$queryString');
  final response = await http.get(url);
  print('${Constants.API_BASE_URL}/$endPoint?$queryString: $response');
  print("response.statusCode ${response.statusCode}");
  print("response.body ${response.body}");
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonBody = json.decode(response.body);
    print('RESPONSE BODY: $jsonBody');

    var result = ApiResult.fromJson(jsonBody);

    if (result.status == 'ok') {
      return result.data;
    } else {
      throw result.message;
    }
  } else {
    throw response.body;
  }
}
