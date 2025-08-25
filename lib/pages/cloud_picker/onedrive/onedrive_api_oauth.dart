library flutter_onedrive;

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;

class OneDriveApiForOAuth {
  static const String apiEndpoint = "https://graph.microsoft.com/v1.0/";
  final oauth2.Client _client;

  OneDriveApiForOAuth(this._client);

  Future<Map<String, dynamic>> list(String folderId) async {
    final path = folderId == 'root' ? folderId : 'items/$folderId';
    final url = Uri.parse("${apiEndpoint}me/drive/$path/children");

    try {
      final resp = await _client.get(url);

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
    final url = Uri.parse("${apiEndpoint}me/drive/items/$fileId/content");

    final request = new http.Request('GET', url);
    return _client.send(request);

    /*final url = Uri.parse("${apiEndpoint}me/drive/items/$fileId/content");

    try {
      final resp = await _client.get(url);

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
      var resp = await _client.post(
        url,
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

          final headers = {
            "Content-Length": contentLength,
            "Content-Range": range,
          };

          resp = await _client.put(
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
