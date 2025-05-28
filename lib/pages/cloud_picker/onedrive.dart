import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:navy_encrypt/etc/constants.dart';
import 'package:navy_encrypt/etc/file_util.dart';
import 'package:navy_encrypt/models/cloud_file.dart';
import 'package:navy_encrypt/pages/cloud_picker/auth/my_oauth.dart';
import 'package:navy_encrypt/pages/cloud_picker/cloud_drive.dart';
import 'package:navy_encrypt/pages/cloud_picker/cloud_picker_page.dart';
import 'package:navy_encrypt/pages/cloud_picker/onedrive/onedrive_api.dart';
import 'package:navy_encrypt/pages/cloud_picker/onedrive/onedrive_api_oauth.dart';
import 'package:path/path.dart' as p;
import 'package:oauth2/oauth2.dart' as oauth2;

class OneDrive extends CloudDrive {
  static const callbackScheme = 'msal40e7380e-9025-41bc-95c7-e5ef1020f188';
  static const clientId = '40e7380e-9025-41bc-95c7-e5ef1020f188';
  static const String authEndpoint =
      "https://login.microsoftonline.com/common/oauth2/v2.0/authorize";
  static const String tokenEndpoint =
      "https://login.microsoftonline.com/common/oauth2/v2.0/token";
  static const String scope = 'offline_access Files.ReadWrite.All';

  final CloudPickerMode _pickerMode;
  File _fileToUpload;
  CloudFile _currentFolder;
  String _nextPageLink;
  final _oneDriveApi = OneDriveApi(
    callbackScheme: callbackScheme,
    clientID: clientId,
  );
  OneDriveApiForOAuth _oneDriveApiOAuth;

  OneDrive(this._pickerMode);

  @override
  set fileToUpload(File file) {
    _fileToUpload = file;
  }

  @override
  CloudPickerMode get pickerMode => _pickerMode;

  @override
  bool get isPageLoadFinished => _nextPageLink == null;

  @override
  Future<bool> signIn() async {
    if (!await _oneDriveApi.isConnected()) {
      var connResult = await _oneDriveApi.connect();
      return connResult;
    }
    return true;
  }

  @override
  Future<bool> signInWithOAuth2() async {
    oauth2.Client client = await MyOAuth(
      serviceName: 'onedrive',
      authEndpoint: authEndpoint,
      tokenEndpoint: tokenEndpoint,
      clientId: clientId,
      clientSecret: null,
      scope: scope,
    ).connect();

    if (client != null) {
      _oneDriveApiOAuth = OneDriveApiForOAuth(client);
      return true;
    }
    return false;
  }

  @override
  changeFolder(CloudFile folder) {
    _currentFolder = folder;
    _nextPageLink = null;
  }

  @override
  Future<List<CloudFile>> listFolder() async {
    final json = _oneDriveApiOAuth == null
        ? await _oneDriveApi.list(_currentFolder.id)
        : await _oneDriveApiOAuth.list(_currentFolder.id);
    if (json == null) return null;

    _nextPageLink = null; //json['@odata.nextLink'];
    List driveItemList = json['value'] as List;

    return driveItemList
        .map((item) {
          final id = item['id'];
          final name = item['name'];
          final extension = (p.extension(name)?.isNotEmpty ?? false)
              ? p.extension(name).substring(1)
              : '';
          final size = item['size'].toString();
          final isFolder = item['folder'] != null;
          final mimeType =
              item['file'] != null ? item['file']['mimeType'] : null;
          final lastModified = DateTime.parse(item['lastModifiedDateTime']);

          return CloudFile(
            id: id,
            name: name,
            fileExtension: extension,
            mimeType: mimeType,
            isFolder: isFolder,
            size: size,
            modifiedTime: lastModified,
          );
        })
        // filter type เอง สำหรับ onedrive
        .where(whereItemType)
        .toList();
  }

  bool whereItemType(CloudFile item) {
    return item.isFolder ||
        (_pickerMode == CloudPickerMode.file &&
            Constants.selectableExtensionList.contains(item.fileExtension));
  }

  @override
  Future<File> downloadFile(
    CloudFile cloudFile,
    Function(double) loadProgress,
  ) async {
    final fileSize = int.tryParse(cloudFile.size);
    var bytesReceived = 0;

    var completer = Completer<File>();
    List<int> dataStore = [];

    final response = Platform.isWindows
        ? await _oneDriveApiOAuth.pull(cloudFile.id)
        : await _oneDriveApi.pull(cloudFile.id);

    loadProgress(0.0);
    response.stream.listen((data) {
      //print("Data received: ${data.length}");
      if (fileSize != null) {
        bytesReceived += data.length;
        print('Data receive: $bytesReceived of $fileSize');
        loadProgress(bytesReceived / fileSize);
      }
      dataStore.insertAll(dataStore.length, data);
    }, onDone: () async {
      var saveFile = await FileUtil.createFileFromBytes(
        cloudFile.name,
        Uint8List.fromList(dataStore),
      );

      completer.complete(saveFile);
    }, onError: (error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  @override
  Future<bool> uploadFile(
    CloudFile folder,
    Function(double) loadProgress,
  ) async {
    var data = await _fileToUpload.readAsBytes();
    return _oneDriveApiOAuth == null
        ? await _oneDriveApi.push(
            data,
            folder.id,
            p.basename(_fileToUpload.path),
            loadProgress,
          )
        : await _oneDriveApiOAuth.push(
            data,
            folder.id,
            p.basename(_fileToUpload.path),
            loadProgress,
          );
  }

  @override
  Future<bool> isUploadFileExist(CloudFile folder) async {
    return await Future.value(false);
  }
}
