import 'dart:async';
import 'dart:io';

import 'package:icloud_storage/icloud_storage.dart';
import 'package:navy_encrypt/etc/file_util.dart';
import 'package:navy_encrypt/models/cloud_file.dart';
import 'package:navy_encrypt/pages/cloud_picker/cloud_drive.dart';
import 'package:navy_encrypt/pages/cloud_picker/cloud_picker_page.dart';
import 'package:path/path.dart' as p;

class ICloudDrive extends CloudDrive {
  static const iCloudContainerId = 'iCloud.th.mi.navy.navyEncrypt';
  final CloudPickerMode _pickerMode;
  final String _rootDirPath;
  CloudFile _currentFolder;
  File _fileToUpload;

  ICloudDrive(this._pickerMode, this._rootDirPath);

  @override
  changeFolder(CloudFile folder) {
    _currentFolder = folder;
  }

  @override
  Future<File> downloadFile(
    CloudFile cloudFile,
    Function(double) loadProgress,
  ) async {
    Completer<File> completer = Completer();
    var tempFile = await FileUtil.getTempFile(cloudFile.name);
    final iCloudStorage = await ICloudStorage.getInstance(iCloudContainerId);
    await iCloudStorage.startDownload(
      fileName: cloudFile.name,
      destinationFilePath: tempFile.path,
      onProgress: (stream) {
        stream.listen(
          (progress) {
            print('--- Download File --- progress: $progress');
            loadProgress(progress / 100);
          },
          onDone: () {
            print('--- Download File --- DONE');
            completer.complete(tempFile);
          },
          onError: (err) {
            print('--- Download File --- error: $err');
            completer.complete(null);
          },
          cancelOnError: true,
        );
      },
    );
    return completer.future;
  }

  @override
  bool get isPageLoadFinished => true;

  @override
  Future<List<CloudFile>> listFolder() async {
    if (_pickerMode == CloudPickerMode.folder) return [];

    final iCloudStorage = await ICloudStorage.getInstance(iCloudContainerId);
    final files = await iCloudStorage.listFiles();
    return files
        .map((file) => CloudFile(
              id: '',
              name: file,
              fileExtension: p.extension(file).substring(1).toLowerCase(),
              isFolder: false,
              mimeType: '',
            ))
        .toList();
  }

  @override
  CloudPickerMode get pickerMode => _pickerMode;

  @override
  Future<bool> signIn() {
    return Future.value(true);
  }

  @override
  set fileToUpload(File file) {
    _fileToUpload = file;
  }

  Future<String> _getUploadFileFullPath(CloudFile folder) async {
    DateTime now = DateTime.now();
    // String formattedDate = DateFormat('yyyy-MM-dd–kk:mm:ss:ss-').format(now);
    final dirPath =
        await '$_rootDirPath${folder.id == 'root' ? '' : folder.id}';
    // print("${formattedDate}${p.basename(_fileToUpload.path)}");
    return '$dirPath/file_${p.basename(_fileToUpload.path)}';
  }

  @override
  Future<bool> isUploadFileExist(CloudFile folder) async {
    final filePath = await _getUploadFileFullPath(folder);
    return await File(filePath).exists();
  }

  @override
  Future<bool> uploadFile(
      CloudFile folder, Function(double) loadProgress) async {
    Completer<bool> completer = Completer();
    final iCloudStorage = await ICloudStorage.getInstance(iCloudContainerId);
    iCloudStorage.startUpload(
      filePath: _fileToUpload.path,
      destinationFileName: p.basename(_fileToUpload.path),
      onProgress: (stream) {
        stream.listen(
          (progress) {
            print('--- Upload File --- progress: $progress');
            loadProgress(progress / 100);
          },
          onDone: () {
            print('--- Upload File --- DONE');
            completer.complete(true);
          },
          onError: (err) {
            print('--- Upload File --- error: $err');
            completer.complete(false);
          },
          cancelOnError: true,
        );
      },
    );
    return completer.future;
  }

  @override
  Future<bool> signInWithOAuth2() {
    return Future.value(true);
  }
}
