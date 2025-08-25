import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:navy_encrypt/etc/constants.dart';
import 'package:navy_encrypt/etc/file_util.dart';
import 'package:navy_encrypt/etc/utils.dart';
import 'package:navy_encrypt/models/cloud_file.dart';
import 'package:navy_encrypt/pages/cloud_picker/auth/my_oauth.dart';
import 'package:navy_encrypt/pages/cloud_picker/cloud_drive.dart';
import 'package:navy_encrypt/pages/cloud_picker/cloud_picker_page.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:path/path.dart' as p;

class GoogleDrive extends CloudDrive {
  static const authEndpoint = 'https://accounts.google.com/o/oauth2/v2/auth';
  static const tokenEndpoint = 'https://oauth2.googleapis.com/token';
  static const clientId =
      '786699358980-90rs6o7099l2r6plrhkvlq1u691776v7.apps.googleusercontent.com';
  static const clientSecret = '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';
  static const scope = 'https://www.googleapis.com/auth/drive';

  static const GOOGLE_FOLDER_MIME_TYPE = 'application/vnd.google-apps.folder';

  final _googleSignIn = GoogleSignIn.standard(
    scopes: [drive.DriveApi.driveScope],
    /*scopes: [
      'email',
      //'https://www.googleapis.com/auth/drive',
    ],*/
  );
  final CloudPickerMode _pickerMode;
  String _queryMimeTypes;
  drive.DriveApi _driveApi;
  CloudFile _currentFolder;
  String _nextPageToken;
  File _fileToUpload;

  GoogleDrive(this._pickerMode) {
    _queryMimeTypes = "(mimeType = '$GOOGLE_FOLDER_MIME_TYPE')";
    if (_pickerMode == CloudPickerMode.file)
      _queryMimeTypes = Constants.selectableMimeTypeList.fold(
        _queryMimeTypes,
        (previousValue, mimeType) {
          return "$previousValue or (mimeType = '$mimeType')";
        },
      );
  }

  @override
  set fileToUpload(File file) {
    _fileToUpload = file;
  }

  @override
  CloudPickerMode get pickerMode => _pickerMode;

  @override
  bool get isPageLoadFinished => _nextPageToken == null;

  @override
  Future<bool> signIn() async {
    GoogleSignInAccount account = await _googleSignIn.signIn();
    final authHeaders = await account.authHeaders; // token อยู่ใน authHeaders
    final authenticateClient = GoogleAuthClient(authHeaders);
    _driveApi = drive.DriveApi(authenticateClient);
    return true;
    return false;
  }

  @override
  Future<bool> signInWithOAuth2() async {
    oauth2.Client client = await MyOAuth(
      serviceName: 'google_drive',
      authEndpoint: authEndpoint,
      tokenEndpoint: tokenEndpoint,
      clientId: clientId,
      clientSecret: clientSecret,
      scope: scope,
    ).connect();

    _driveApi = drive.DriveApi(client);
    return true;
    return false;
  }

  @override
  changeFolder(CloudFile folder) {
    _currentFolder = folder;
    _nextPageToken = null;
  }

  @override
  Future<List<CloudFile>> listFolder() async {
    String query = "($_queryMimeTypes) and ('${_currentFolder.id}' in parents)";
    //logOneLineWithBorderSingle('QUERY: $query');

    var fieldList = [
      'id',
      'name',
      'fileExtension',
      'mimeType',
      'modifiedTime',
      'size',
      //'iconLink',
      'thumbnailLink',
    ];
    String field =
        fieldList.map((item) => 'files/$item').fold('', (previousValue, item) {
      return '$previousValue${previousValue.isEmpty ? '' : ','} $item';
    });

    Map<String, dynamic> logMap = {};
    drive.FileList fileList;
    try {
      fileList = await _driveApi.files.list(
        //corpus: 'user',
        pageToken: _nextPageToken,
        //pageSize: 10,
        $fields: field,
        q: query,
        orderBy: 'folder, modifiedTime desc, name',
      );
    } on drive.ApiRequestError catch (e) {
      print(e);
      throw Exception(e.message);
    } finally {}

    _nextPageToken = fileList.nextPageToken;

    fileList.files.forEach((file) {
      //print('[${file.mimeType}] ${file.name}');
      logMap['${file.id}'] =
          '[${file.mimeType}] ${file.name} ${file.thumbnailLink}';
    });
    logWithBorder(logMap, 1);

    //fileList.files[0]. // ถ้าอยากดูว่ามี field อะไรบ้าง
    return fileList.files
        .map(
          (file) => CloudFile(
            id: file.id,
            name: file.name,
            fileExtension: file.fileExtension,
            mimeType: file.mimeType,
            isFolder: file.mimeType == GOOGLE_FOLDER_MIME_TYPE,
            modifiedTime: file.modifiedTime,
            size: file.size,
            //iconLink: file.iconLink,
            thumbnailLink: file.thumbnailLink,
          ),
        )
        .toList();
  }

  @override
  Future<File> downloadFile(
    CloudFile cloudFile,
    Function(double) loadProgress,
  ) async {
    final fileSize = int.tryParse(cloudFile.size);
    var bytesReceived = 0;

    drive.Media media;
    media = await _driveApi.files.get(
      cloudFile.id,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    var completer = Completer<File>();
    List<int> dataStore = [];

    loadProgress(0.0);
    media.stream.listen((data) {
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

//https://developers.google.com/drive/api/v3/manage-uploads
  @override
  Future<bool> uploadFile(
    CloudFile folder,
    Function(double) loadProgress,
  ) async {
    /*final Stream<List<int>> mediaStream =
        Future.value([104, 105]).asStream().asBroadcastStream();
    var media = drive.Media(mediaStream, 2);*/

    var driveFile = drive.File();
    driveFile.name = p.basename(_fileToUpload.path);
    driveFile.parents = [folder.id];
    try {
      var result = await _driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(
          _fileToUpload.openRead(),
          _fileToUpload.lengthSync(),
        ),
      );
      print('File upload result: $result');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> isUploadFileExist(CloudFile folder) async {
    return await Future.value(false);
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = new http.Client();

  GoogleAuthClient(this._headers);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    logOneLineWithBorderSingle('HTTP send request...');

    return _client.send(request..headers.addAll(_headers));
  }
}
