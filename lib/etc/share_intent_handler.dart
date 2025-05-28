import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:navy_encrypt/etc/utils.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path/path.dart' as p;

class ShareIntentHandler {
  StreamSubscription _intentDataStreamSubscription;
  final Function(String, bool) onReceiveIntent;

  ShareIntentHandler({@required this.onReceiveIntent}) {
    init();
  }

  init() {
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> fileList) {
      logOneLineWithBorderSingle(
          'Images coming from outside the app while the app is in the memory');
      _handleFileStream(fileList, true);
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia()
        .then((List<SharedMediaFile> fileList) {
      logOneLineWithBorderSingle(
          'Images coming from outside the app while the app is closed');
      _handleFileStream(fileList, false);
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    // _intentDataStreamSubscription =
    //     ReceiveSharingIntent.getTextStream().listen((String text) async {
    //   logOneLineWithBorderSingle(
    //       'Urls/text coming from outside the app while the app is in the memory');
    //   await _handleTextStream(text, true);
    // }, onError: (err) {
    //   print("getLinkStream error: $err");
    // });

    // // For sharing or opening urls/text coming from outside the app while the app is closed
    // ReceiveSharingIntent.getInitialText().then((String text) async {
    //   logOneLineWithBorderSingle(
    //       'Urls/text coming from outside the app while the app is closed');
    //   await _handleTextStream(text, false);
    // });
  }

  void cancelStreamSubscription() {
    _intentDataStreamSubscription.cancel();
  }

  _handleFileStream(List<SharedMediaFile> fileList, bool isAppOpen) {
    final logMap = {
      'INTENT TYPE': 'RECEIVE MEDIA STREAM',
    };
    if (fileList != null && fileList.isNotEmpty) {
      var filePath = fileList[0].path; // only first file
      logMap['FILE COUNT'] = fileList.length.toString();
      logMap['1ST FILE PATH'] = filePath;

      if (filePath.contains('file:///')) {
        filePath = File.fromUri(Uri.parse(filePath)).path;
        logMap['ACTUAL FILE SYSTEM PATH'] = filePath;
      }

      if (onReceiveIntent != null) onReceiveIntent(filePath, isAppOpen);
    } else {
      logMap['FILE COUNT'] = 'fileList is null or empty!';
    }
    //_log(logMap);
    logWithBorder(logMap, 1);
  }

  _handleTextStream(String text, bool isAppOpen) async {
    final logMap = {
      'INTENT TYPE': 'RECEIVE TEXT STREAM',
    };

    var filePath = await _getFilePathFromUrl(text);
    logMap['URL/TEXT'] = text;
    logMap['FILE PATH'] = filePath;
    //_log(logMap);
    logWithBorder(logMap, 1);

    if (onReceiveIntent != null && filePath != null)
      onReceiveIntent(filePath, isAppOpen);
  }

  Future<String> _getFilePathFromUrl(String url) async {
    if (url == null || url.trim().isEmpty) return null;

    /*var file = await _convertUriToFile(url);
    if (file == null) return null;*/

    var filePath = await FlutterAbsolutePath.getAbsolutePath(url);

    String extension = p.extension(filePath).substring(1).toLowerCase();
    // If extension is not 'enc', append or change it.
    if (extension != 'enc') {
      int dotIndex = filePath.lastIndexOf('.');

      File f;
      if (dotIndex != -1) {
        f = File(filePath).renameSync('${filePath.substring(0, dotIndex)}.enc');
      } else {
        f = File(filePath).renameSync('filePath.enc');
      }

      filePath = f.path;
    }

    return filePath;
  }

  /*Future<File> _convertUriToFile(String url) async {
    try {
      Uri uri = Uri.parse(url);
      return await toFile(uri);
    } on UnsupportedError catch (e) {
      print(e.message); // Unsupported error for uri not supported
    } on IOException catch (e) {
      print(e); // IOException for system error
    } on Exception catch (e) {
      print(e); // General exception
    }
    return null;
  }*/
}
