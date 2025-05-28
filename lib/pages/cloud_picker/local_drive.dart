import 'dart:io';

import 'package:intl/intl.dart';
import 'package:navy_encrypt/etc/utils.dart';
import 'package:navy_encrypt/models/cloud_file.dart';
import 'package:navy_encrypt/pages/cloud_picker/cloud_drive.dart';
import 'package:navy_encrypt/pages/cloud_picker/cloud_picker_page.dart';
import 'package:path/path.dart' as p;

class LocalDrive extends CloudDrive {
  final CloudPickerMode _pickerMode;
  final String _rootDirPath;
  CloudFile _currentFolder;
  File _fileToUpload;

  LocalDrive(this._pickerMode, this._rootDirPath);

  @override
  changeFolder(CloudFile folder) {
    _currentFolder = folder;
  }

  @override
  Future<File> downloadFile(
    CloudFile cloudFile,
    Function(double) loadProgress,
  ) async {
    var fullPath = '$_rootDirPath${cloudFile.id}';
    return File(fullPath);
  }

  @override
  bool get isPageLoadFinished => true;

  @override
  Future<List<CloudFile>> listFolder() async {
    String dirPath =
        '$_rootDirPath${_currentFolder.id == 'root' ? '' : _currentFolder.id}';

    var entityList = await Directory(dirPath).list().toList();
    List<CloudFile> list = [];

    for (var entity in entityList) {
      var fullPath = entity.path;
      var isFolder = await FileSystemEntity.isDirectory(fullPath);
      if (_pickerMode == CloudPickerMode.folder && !isFolder) continue;

      var fileExtension = '';
      if (p.extension(fullPath) != null &&
          p.extension(fullPath).trim().isNotEmpty) {
        fileExtension = p.extension(fullPath).substring(1).toLowerCase();
      }

      list.add(CloudFile(
        // id จะเก็บ relative path เมื่อเทียบกับ root doc
        id: fullPath.replaceFirst(_rootDirPath, ''),
        name: p.basename(fullPath),
        fileExtension: fileExtension,
        isFolder: isFolder,
        mimeType: '',
        modifiedTime: (await entity.stat()).modified,
        size: (await entity.stat()).size.toString(),
      ));
    }

    Map<String, dynamic> logMap = {};
    list.forEach((file) {
      logMap[file.id] = file.name;
    });
    logWithBorder(logMap, 2);

    return list;

    /*entityList.forEach((entity) async {
      var fullPath = entity.path;
      list.add(CloudFile(
        id: fullPath,
        name: p.basename(fullPath),
        fileExtension: p.extension(fullPath).substring(1).toLowerCase(),
        isFolder: await FileSystemEntity.isDirectory(entity.path),
        mimeType: '',
        modifiedTime: (await entity.stat()).modified,
        size: (await entity.stat()).size.toString(),
      ));
    });*/
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
    String formattedDate = DateFormat('yyyy-MM-dd–kk:mm:ss:ss-').format(now);
    final dirPath =
        await '$_rootDirPath${folder.id == 'root' ? '' : folder.id}';
    print("${formattedDate}${p.basename(_fileToUpload.path)}");
    return '$dirPath/${formattedDate}${p.basename(_fileToUpload.path)}';
  }

  @override
  Future<bool> isUploadFileExist(CloudFile folder) async {
    final filePath = await _getUploadFileFullPath(folder);
    return await File(filePath).exists();
  }

  @override
  Future<bool> uploadFile(
      CloudFile folder, Function(double) loadProgress) async {
    final filePath = await _getUploadFileFullPath(folder);

    try {
      await _fileToUpload.copy(filePath);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> signInWithOAuth2() {
    return Future.value(true);
  }
}
