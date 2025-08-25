import 'dart:io';

import 'package:navy_encrypt/models/cloud_file.dart';
import 'package:navy_encrypt/pages/cloud_picker/cloud_picker_page.dart';

abstract class CloudDrive {
  CloudPickerMode get pickerMode;

  bool get isPageLoadFinished;

  set fileToUpload(File file);

  Future<bool> signIn();

  Future<bool> signInWithOAuth2();

  changeFolder(CloudFile folder);

  Future<List<CloudFile>> listFolder();

  Future<File> downloadFile(CloudFile cloudFile, Function(double) loadProgress);

  Future<bool> uploadFile(CloudFile folder, Function(double) loadProgress);

  Future<bool> isUploadFileExist(CloudFile folder);
}
