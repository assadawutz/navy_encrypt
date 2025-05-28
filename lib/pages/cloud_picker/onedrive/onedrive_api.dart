library flutter_onedrive;

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:navy_encrypt/etc/utils.dart';
import 'dart:convert' show jsonDecode;

import 'token.dart';

class OneDriveApi {
// https://docs.microsoft.com/en-us/onedrive/developer/rest-api/getting-started/graph-oauth?view=odsp-graph-online
  static const String authHost = "login.microsoftonline.com";
  static const String authEndpoint = "/common/oauth2/v2.0/authorize";
  static const String apiEndpoint = "https://graph.microsoft.com/v1.0/";
  static const String tokenEndpoint =
      "https://$authHost/common/oauth2/v2.0/token";
  static const String errCANCELED = "CANCELED";

  ITokenManager _tokenManager;
  String redirectURL;
  final String scope;
  final String clientID;
  final String callbackScheme;
  final String state;

  OneDriveApi({
    @required this.clientID,
    @required this.callbackScheme,
    this.scope = "offline_access Files.ReadWrite.All",
    this.state = "OneDriveState",
    ITokenManager tokenManager,
  }) {
    redirectURL = "$callbackScheme://auth";
    _tokenManager = tokenManager ??
        DefaultTokenManager(
          tokenEndpoint: tokenEndpoint,
          clientID: clientID,
          redirectURL: redirectURL,
          scope: scope,
        );
  }

  Future<bool> isConnected() async {
    final accessToken = await _tokenManager.getAccessToken();
    return (accessToken?.isNotEmpty) ?? false;
  }

  Future<bool> connect() async {
// Construct the url
    final authUrl = Uri.https(authHost, authEndpoint, {
      'response_type': 'code',
      'client_id': clientID,
      'redirect_uri': redirectURL,
      'scope': scope,
      'state': state,
    });

// open browser to authorize endpoint
    try {
      final result = await FlutterWebAuth.authenticate(
          url: authUrl.toString(), callbackUrlScheme: callbackScheme);

      logOneLineWithBorderSingle('RESULT: $result');

// get code
      final code = Uri.parse(result).queryParameters['code'];

      logOneLineWithBorderSingle('CODE: $code');

// use code to exchange token
      final resp = await http.post(Uri.parse(tokenEndpoint), body: {
        'client_id': clientID,
        'redirect_uri': redirectURL,
        'grant_type': 'authorization_code',
        'code': code,
      });

// Response
      if (resp.statusCode == 200) {
        await _tokenManager.saveTokenResp(resp);
        return true;
      }
    } on PlatformException catch (err) {
      if (err.code != errCANCELED) {
        debugPrint("# OneDrive -> connect: $err");
      }
    }

    return false;
  }

  Future<void> disconnect() async {
    await _tokenManager.clearStoredToken();
  }

  Future<Map<String, dynamic>> list(String folderId) async {
    final accessToken = await _tokenManager.getAccessToken();
    if (accessToken == null) {
      return null;
    }

    final path = folderId == 'root' ? folderId : 'items/$folderId';
    final url = Uri.parse("${apiEndpoint}me/drive/$path/children");

    try {
      final resp = await http.get(
        url,
        headers: {"Authorization": "Bearer $accessToken"},
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return json.decode(resp.body);
      } else if (resp.statusCode == 404) {
        return null;
      }

      debugPrint(
          "# OneDrive -> list: ${resp.statusCode}\n# Body: ${resp.body}");
    } catch (err) {
      debugPrint("# OneDrive -> list: $err");
    }

    return null;
  }

  Future<http.StreamedResponse> pull(String fileId) async {
    final accessToken = await _tokenManager.getAccessToken();
    if (accessToken == null) {
      return null;
    }

    final url = Uri.parse("${apiEndpoint}me/drive/items/$fileId/content");
    final request = new http.Request(
      'GET',
      url,
    );
    request.headers.addAll({"Authorization": "Bearer $accessToken"});
    return http.Client().send(request);

    /*final accessToken = await _tokenManager.getAccessToken();
    if (accessToken == null) {
      return Uint8List(0);
    }

    final url = Uri.parse("${apiEndpoint}me/drive/items/$fileId/content");
    try {
      final resp = await http.get(
        url,
        headers: {"Authorization": "Bearer $accessToken"},
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return resp.bodyBytes;
      } else if (resp.statusCode == 404) {
        return Uint8List(0);
      }

      debugPrint(
          "# OneDrive -> pull: ${resp.statusCode}\n# Body: ${resp.body}");
    } catch (err) {
      debugPrint("# OneDrive -> pull: $err");
    }

    return null;*/
  }

  Future<bool> push(
    Uint8List bytes,
    String folderId,
    String filename,
    Function(double) loadProgress,
  ) async {
    final accessToken = await _tokenManager.getAccessToken();
    if (accessToken == null) {
      // No access token
      return false;
    }

    final path = folderId == 'root' ? folderId : 'items/$folderId';

    try {
      const int pageSize = 327680; //1024 * 1024; // page size
      final int maxPage =
          (bytes.length / pageSize.toDouble()).ceil(); // total pages

// create upload session
// https://docs.microsoft.com/en-us/onedrive/developer/rest-api/api/driveitem_createuploadsession?view=odsp-graph-online
      var now = DateTime.now();
      var url = Uri.parse(
          "$apiEndpoint/me/drive/$path:/$filename:/createUploadSession");
      var resp = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $accessToken",
        },
        body: {
          "@microsoft.graph.conflictBehavior": "rename",
          "name": filename,
        },
      );
      debugPrint(
          "# Push Create Session: ${DateTime.now().difference(now).inMilliseconds} ms");

      if (resp.statusCode == 200) {
        // create session success
        final Map<String, dynamic> respJson = jsonDecode(resp.body);
        final String uploadUrl = respJson["uploadUrl"];
        url = Uri.parse(uploadUrl);

// use upload url to upload
        for (var pageIndex = 0; pageIndex < maxPage; pageIndex++) {
          now = DateTime.now();
          final int start = pageIndex * pageSize;
          int end = start + pageSize;
          if (end > bytes.length) {
            end = bytes.length; // cannot exceed max length
          }
          final range = "bytes $start-${end - 1}/${bytes.length}";
          final pageData = bytes.getRange(start, end).toList();
          final contentLength = pageData.length.toString();

          logOneLineWithBorderSingle('Content-Length: $contentLength');
          logOneLineWithBorderSingle('Content-Range: $range');

          final headers = {
            "Authorization": "Bearer $accessToken",
            "Content-Length": contentLength,
            "Content-Range": range,
          };

          resp = await http.put(
            url,
            headers: headers,
            body: pageData,
          );

          loadProgress((pageIndex + 1) / maxPage);

          debugPrint(
              "# Push Upload [${pageIndex + 1}/$maxPage]: ${DateTime.now().difference(now).inMilliseconds} ms, start: $start, end: $end, contentLength: $contentLength, range: $range");

          if (resp.statusCode == 202) {
            // haven't finish, continue
            continue;
          } else if (resp.statusCode == 200 || resp.statusCode == 201) {
            // upload finished
            return true;
          } else {
            // has issue
            break;
          }
        }
      }

      debugPrint("# Upload response: ${resp.statusCode}\n# Body: ${resp.body}");
    } catch (err) {
      debugPrint("# Upload error: $err");
    }

    return false;
  }
}
