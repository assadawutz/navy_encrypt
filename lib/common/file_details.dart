import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:navy_encrypt/etc/constants.dart';
import 'package:navy_encrypt/etc/file_size.dart';
import 'package:navy_encrypt/etc/file_util.dart';
import 'package:navy_encrypt/models/my_file_type.dart';
import 'package:navy_encrypt/pages/file_viewer/file_viewer_page.dart';
import 'package:path/path.dart' as p;

import 'my_form_field.dart';

// แก้ปัญหากรณีไฟล์ไม่มีนามสกุล : https://stackoverflow.com/questions/62361613/how-to-get-type-of-file

class FileDetails extends StatelessWidget {
  /*static const imageFileExtensionList = ['JPG', 'JPEG', 'PNG', 'GIF'];
  static const videoFileExtensionList = ['MP4', 'MOV'];
  static const wordFileExtensionList = ['DOC', 'DOCX'];
  static const excelFileExtensionList = ['XLS', 'XLSX'];
  static const powerpointFileExtensionList = ['PPT', 'PPTX'];
  static const pdfFileExtensionList = ['PDF'];
  static const zipFileExtensionList = ['ZIP'];*/

  FileDetails({
    Key key,
    @required this.filePath,
  })  : fileExtension = p.extension(filePath).substring(1).toLowerCase(),
        super(key: key) {
    // clear แคชรูปภาพ เพราะการใส่ลายน้ำให้กับรูปภาพจะ save ทับไฟล์เดิม
    // ซึ่งถ้าไม่ clear แคช จะแสดงภาพเดิมก่อนใส่ลายน้ำ
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  final String filePath;
  final String fileExtension;
  String _uniqueTempDirPath;

  @override
  Widget build(BuildContext context) {
    // print("BuildContext ${filePath}");
    // print("BuildContext ${fileExtension}");
    return FutureBuilder(
        future: _preparePreviewImages(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            );
          } else {
            return Column(
              children: [
                Tooltip(
                  message: 'ไฟล์ ${filePath.replaceAll('/', '\\')}',
                  textStyle: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontFamily: GoogleFonts.firaCode().fontFamily,
                  ),
                  verticalOffset: 58.0,
                  child: MyFormField(
                    padding: const EdgeInsets.all(0.0),
                    shadow: BoxShadow(
                      offset: Offset(1.0, 2.0),
                      blurRadius: 3.0,
                      spreadRadius: 1.0,
                      color: Colors.black.withOpacity(0.1),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleClick(context),
                        child: Row(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _getFileThumbnail(),
                            SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (Platform.isWindows)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          //'ประเภทไฟล์ : ${fileExtension.toUpperCase()}',
                                          p.basename(filePath),
                                          overflow: TextOverflow.fade,
                                          maxLines: 1,
                                          softWrap: false,
                                          style: TextStyle(
                                            fontSize: 22.0,
                                            height: 1.0,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(FontAwesomeIcons.solidFolder,
                                                size: 18.0,
                                                color: Color(0xFFFFC818)),
                                            SizedBox(width: 4.0),
                                            Expanded(
                                              child: Text(
                                                p.dirname(filePath),
                                                overflow: TextOverflow.fade,
                                                maxLines: 1,
                                                softWrap: false,
                                                style:
                                                    TextStyle(fontSize: 18.0),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  if (!Platform.isWindows)
                                    Text(
                                      //'ประเภทไฟล์ : ${fileExtension.toUpperCase()}',
                                      p.basename(filePath),
                                      overflow: TextOverflow.fade,
                                      maxLines: 2,
                                      softWrap: false,
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        height: 0.9,
                                      ),
                                    ),
                                  SizedBox(height: 4.0),
                                  FutureBuilder(
                                    future: File(filePath).length(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<int> snapshot) {
                                      if (snapshot.data == null)
                                        return SizedBox(
                                          width: 14.0,
                                          height: 14.0,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.0),
                                        );

                                      final size = snapshot.data;
                                      final fileSize = FileSize(size);

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'ขนาด : ${fileSize.getDisplaySize()}',
                                                style:
                                                    TextStyle(fontSize: 20.0),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 8.0),
                                                width: 14.0,
                                                height: 14.0,
                                                decoration: BoxDecoration(
                                                  color: fileSize.getColor(),
                                                  border: Border.all(
                                                      color: Color(0xFFA8A8A8)),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '(${FileSize(size).getDisplayByteSize()} bytes)',
                                            style: GoogleFonts.inconsolata(
                                              fontSize: 14.0,
                                              height: 1.1,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isType(Constants.imageFileTypeList) ||
                    fileExtension.toLowerCase() == 'zip')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '${Platform.isWindows ? 'คลิก' : 'แตะ'}เพื่อดูภาพ',
                          style: TextStyle(
                              fontSize: 19.0, color: Colors.green.shade800),
                        ),
                      ),
                    ],
                  ),
                // if (!kReleaseMode && fileExtension == 'enc')
                //   Padding(
                //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                //     child: Text(
                //       filePath,
                //       style: GoogleFonts.firaCode(
                //           fontSize: 12.0, color: Colors.redAccent.shade400),
                //     ),
                //   ),
              ],
            );
          }
        });
  }

  _handleClick(BuildContext context) {
    if (_isType(Constants.imageFileTypeList)) {
      Navigator.pushNamed(
        context,
        FileViewerPage.routeName,
        arguments: filePath,
      );
    } else if (fileExtension.toLowerCase() == 'zip') {
      var filePathList = Directory(
              _uniqueTempDirPath /*p.join(p.dirname(filePath), 'images')*/)
          .listSync()
          .map((file) => file.path)
          .toList();

      Navigator.pushNamed(
        context,
        FileViewerPage.routeName,
        arguments: filePathList,
      );
    }
  }

  Widget _getFileThumbnail() {
    print("BuildContext ${filePath}");
    print("BuildContext ${fileExtension}");
    // var parts = filePath.split('/');
    // print("imageFileTypeList ${Constants.imageFileTypeList}");

    var imageSize = Platform.isWindows ? 110.0 : 100.0;
    var iconSize = 64.0;

    if (_isType(Constants.imageFileTypeList)) {
      try {
        Image img = Image.file(
          File(filePath),
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
        );
        return img;
      } catch (e) {
        return Container(
          width: imageSize,
          height: imageSize,
          child: Icon(
            LineIcons.lock,
            size: 72.0,
            color: Color(0xFF999999),
          ),
        );
      }
    } else {
      var fileType = Constants.allFileTypeList.firstWhereOrNull(
        (fileType) => fileType.fileExtension == fileExtension,
      );

      IconData iconData = Constants.unSupportedFileType.iconData;
      Color iconColor = Constants.unSupportedFileType.iconColor;

      if (fileType != null) {
        iconData = fileType.iconData;
        iconColor = fileType.iconColor;
      }

      /*if (fileExtension == 'ENC') {
        iconData = LineIcons.lock;
        iconSize = 72.0;
      } else if (videoFileExtensionList.contains(fileExtension)) {
        iconData = FontAwesomeIcons.fileVideo;
      } else if (wordFileExtensionList.contains(fileExtension)) {
        iconData = FontAwesomeIcons.fileWord;
      } else if (excelFileExtensionList.contains(fileExtension)) {
        iconData = FontAwesomeIcons.fileExcel;
      } else if (powerpointFileExtensionList.contains(fileExtension)) {
        iconData = FontAwesomeIcons.filePowerpoint;
      } else if (pdfFileExtensionList.contains(fileExtension)) {
        iconData = FontAwesomeIcons.filePdf;
      } else if (zipFileExtensionList.contains(fileExtension)) {
        iconData = FontAwesomeIcons.fileArchive;
      }*/

      return Container(
        width: imageSize,
        height: imageSize,
        child: Icon(
          iconData,
          size: iconSize,
          color: iconColor,
        ),
      );
    }
  }

  bool _isType(List<MyFileType> fileTypeList) {
    // print("fileTypeList ${fileTypeList[0].fileExtension}");
    // print("fileTypeList ${fileTypeList[1].fileExtension}");
    // print("fileTypeList ${fileTypeList[2].fileExtension}");
    // print("fileTypeList ${fileTypeList[3].fileExtension}");
    return fileTypeList
            .where((fileType) => fileType.fileExtension == fileExtension)
            .length >
        0;
  }

  Future<bool> _preparePreviewImages() async {
    if (fileExtension == 'zip') {
      _uniqueTempDirPath = (await FileUtil.createUniqueTempDir()).path;
      File(filePath).copySync('$_uniqueTempDirPath/images.zip');
      FileUtil.unzip(dirPath: _uniqueTempDirPath, filename: 'images.zip');
    }
    return true;
  }
}
