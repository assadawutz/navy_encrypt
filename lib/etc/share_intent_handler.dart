import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:navy_encrypt/etc/utils.dart';
import 'package:path/path.dart' as p;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareIntentHandler {
  StreamSubscription<List<SharedMediaFile>> _intentDataStreamSubscription;
  StreamSubscription<String> _intentTextStreamSubscription;
  final Function(String, bool) onReceiveIntent;

  ShareIntentHandler({@required this.onReceiveIntent}) {
    init();
  }

  bool get _supportsSharingIntent => Platform.isAndroid || Platform.isIOS;

  void init() {
    if (!_supportsSharingIntent) {
      logOneLineWithBorderSingle(
          'Share intents are not supported on this platform.');
      return;
    }

    try {
      // For sharing images coming from outside the app while the app is in the memory
      _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
          .listen((List<SharedMediaFile> fileList) {
        logOneLineWithBorderSingle(
            'Images coming from outside the app while the app is in the memory');
        _handleFileStream(fileList, true);
      }, onError: (err) {
        logOneLineWithBorderSingle('getIntentDataStream error: $err');
      });
    } on MissingPluginException catch (error) {
      logOneLineWithBorderSingle('getMediaStream missing plugin: $error');
    } catch (error) {
      logOneLineWithBorderSingle('getMediaStream error: $error');
    }

    // For sharing images coming from outside the app while the app is closed
    try {
      ReceiveSharingIntent.getInitialMedia()
          .then((List<SharedMediaFile> fileList) {
        logOneLineWithBorderSingle(
            'Images coming from outside the app while the app is closed');
        final handled = _handleFileStream(fileList, false);
        if (handled) {
          ReceiveSharingIntent.reset();
        }
      }).catchError((error) {
        logOneLineWithBorderSingle('getInitialMedia error: $error');
      });
    } on MissingPluginException catch (error) {
      logOneLineWithBorderSingle('getInitialMedia missing plugin: $error');
    } catch (error) {
      logOneLineWithBorderSingle('getInitialMedia error: $error');
    }

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    try {
      _intentTextStreamSubscription = ReceiveSharingIntent.getTextStream()
          .listen((String text) {
        logOneLineWithBorderSingle(
            'Urls/text coming from outside the app while the app is in the memory');
        unawaited(_handleTextStream(text, true));
      }, onError: (err) {
        logOneLineWithBorderSingle('getLinkStream error: $err');
      });
    } on MissingPluginException catch (error) {
      logOneLineWithBorderSingle('getTextStream missing plugin: $error');
    } catch (error) {
      logOneLineWithBorderSingle('getTextStream error: $error');
    }

    // For sharing or opening urls/text coming from outside the app while the app is closed
    try {
      ReceiveSharingIntent.getInitialText().then((String text) async {
        logOneLineWithBorderSingle(
            'Urls/text coming from outside the app while the app is closed');
        final handled = await _handleTextStream(text, false);
        if (handled) {
          ReceiveSharingIntent.reset();
        }
      }).catchError((error) {
        logOneLineWithBorderSingle('getInitialText error: $error');
      });
    } on MissingPluginException catch (error) {
      logOneLineWithBorderSingle('getInitialText missing plugin: $error');
    } catch (error) {
      logOneLineWithBorderSingle('getInitialText error: $error');
    }
  }

  void cancelStreamSubscription() {
    _intentDataStreamSubscription?.cancel();
    _intentDataStreamSubscription = null;

    _intentTextStreamSubscription?.cancel();
    _intentTextStreamSubscription = null;
  }

  bool _handleFileStream(List<SharedMediaFile> fileList, bool isAppOpen) {
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

      onReceiveIntent(filePath, isAppOpen);
      logWithBorder(logMap, 1);
      return true;
    } else {
      logMap['FILE COUNT'] = 'fileList is null or empty!';
    }
    //_log(logMap);
    logWithBorder(logMap, 1);
    return false;
  }

  Future<bool> _handleTextStream(String text, bool isAppOpen) async {
    final logMap = {
      'INTENT TYPE': 'RECEIVE TEXT STREAM',
    };

    if (text == null || text.trim().isEmpty) {
      logMap['URL/TEXT'] = 'Empty text received';
      logWithBorder(logMap, 1);
      return false;
    }

    var filePath = await _getFilePathFromUrl(text);
    logMap['URL/TEXT'] = text;
    logMap['FILE PATH'] = filePath;
    //_log(logMap);
    logWithBorder(logMap, 1);

    if (filePath == null || filePath.isEmpty) {
      return false;
    }

    onReceiveIntent(filePath, isAppOpen);
    return true;
  }

  Future<String> _getFilePathFromUrl(String url) async {
    if (url.trim().isEmpty) return null;

    /*var file = await _convertUriToFile(url);
    if (file == null) return null;*/

    String filePath;
    try {
      filePath = await FlutterAbsolutePath.getAbsolutePath(url);
    } catch (error) {
      logOneLineWithBorderSingle(
          'getAbsolutePath error while resolving shared text: $error');
      return null;
    }

    final originalFile = File(filePath);
    if (!await originalFile.exists()) {
      logOneLineWithBorderSingle(
          'Shared file could not be found at resolved path: $filePath');
      return null;
    }

    final extensionWithDot = p.extension(filePath);
    final hasExtension = extensionWithDot.isNotEmpty;
    final extension = hasExtension
        ? extensionWithDot.replaceFirst('.', '').toLowerCase()
        : '';

    // If extension is not 'enc', create a copied file with '.enc' extension
    // instead of renaming the original file.
    if (extension != 'enc') {
      final directory = originalFile.parent.path;
      final baseName = hasExtension
          ? p.basenameWithoutExtension(filePath)
          : p.basename(filePath);
      final encFilePath = p.join(directory, '$baseName.enc');

      try {
        final encFile = await originalFile.copy(encFilePath);
        filePath = encFile.path;
      } on FileSystemException catch (error) {
        logOneLineWithBorderSingle(
            'Failed to create .enc copy for shared file: ${error.message}');
        return null;
      } catch (error) {
        logOneLineWithBorderSingle(
            'Unexpected error while creating .enc copy: $error');
        return null;
      }
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
