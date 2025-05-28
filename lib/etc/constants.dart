import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:navy_encrypt/models/my_file_type.dart';

class Constants {
  // static const NAVY_API_BASE_URL = 'http://203.147.19.219';
  // static const NAVY_API_BASE_URL = 'http://192.168.1.102:3000';
  // static const NAVY_API_BASE_URL = 'http://happyandparty.com:3000';
  static const NAVY_API_BASE_URL = 'https://navenc.navy.mi.th/navy-api';

  // static const NAVY_API_BASE_URL = 'http://127.0.0.1:99';

  static const API_BASE_URL =
      NAVY_API_BASE_URL; // 'http://68.183.97.97:3001'; //droplet
  //static const API_BASE_URL = 'http://192.168.1.4:3001';
  //static const API_BASE_URL = 'http://10.0.2.2:3001';
  static const API_CONVERT_DOC_TO_IMAGE_URL =
      '$NAVY_API_BASE_URL/convert_to_image';

  static const Color primaryColor = Color(0xff000080);
  static const Color test = Color(0xff000080);
  static const Color accentColor = primaryColor; //Color(0xff0000cc);
  static const double horizontalMargin = 20.0;
  static const double verticalMargin = 20.0;
  static const String baseAssetPath = 'assets/';
  static const String baseImagePath = '$baseAssetPath/images';

  static const String encryptionPageTitle = 'ลายน้ำ และการเข้ารหัส';
  static const String decryptionPageTitle = 'การถอดรหัส';
  static const String settingsPageTitle = 'ตั้งค่า';
  static const String watermarkSettingsPageTitle = 'ตั้งค่าระบบลายน้ำ';
  static const String HistoryPageTitle = 'ประวัติการใช้งาน';

  static const LIST_DIALOG_HEADER_IMAGE_SIZE = 40.0;
  static const LIST_DIALOG_ICON_SIZE = 40.0;
  static const LIST_DIALOG_ICON_COLOR = Color(0xFF3EC2FF);

  // ใส่ลายน้ำได้ แต่ต้องแปลงเป็นรูปภาพก่อน
  // 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'
  static const List<MyFileType> documentFileTypeList = [
    const MyFileType(
      fileExtension: 'pdf',
      mimeType: 'application/pdf',
      iconData: FontAwesomeIcons.filePdf,
      iconColor: Colors.redAccent,
    ),
  ];

  // ใส่ลายน้ำได้ทันที
  // 'gif', 'png', 'jpg', 'jpeg'
  static const List<MyFileType> imageFileTypeList = [
    const MyFileType(
      fileExtension: 'gif',
      mimeType: 'image/gif',
      iconData: FontAwesomeIcons.fileImage,
      iconColor: Colors.blueGrey,
    ),
    const MyFileType(
      fileExtension: 'png',
      mimeType: 'image/png',
      iconData: FontAwesomeIcons.fileImage,
      iconColor: Colors.blueGrey,
    ),
    const MyFileType(
      fileExtension: 'jpg',
      mimeType: 'image/jpeg',
      iconData: FontAwesomeIcons.fileImage,
      iconColor: Colors.blueGrey,
    ),
    const MyFileType(
      fileExtension: 'jpeg',
      mimeType: 'image/jpeg',
      iconData: FontAwesomeIcons.fileImage,
      iconColor: Colors.blueGrey,
    ),
  ];

  // ใส่ลายน้ำไม่ได้
  // 'mp4', 'mpeg', 'mov'
  static const List<MyFileType> videoFileTypeList = [
    const MyFileType(
      fileExtension: 'mp4',
      mimeType: 'video/mp4',
      iconData: FontAwesomeIcons.fileVideo,
      iconColor: Colors.blueGrey,
    ),
    const MyFileType(
      fileExtension: 'mpeg',
      mimeType: 'video/mpeg',
      iconData: FontAwesomeIcons.fileVideo,
      iconColor: Colors.blueGrey,
    ),
    const MyFileType(
      fileExtension: 'mov',
      mimeType: 'video/quicktime',
      iconData: FontAwesomeIcons.fileVideo,
      iconColor: Colors.blueGrey,
    ),
    const MyFileType(
      fileExtension: 'doc',
      mimeType: 'application/msword',
      iconData: FontAwesomeIcons.fileWord,
      iconColor: Colors.blue,
    ),
    const MyFileType(
      fileExtension: 'docx',
      mimeType:
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      iconData: FontAwesomeIcons.fileWord,
      iconColor: Colors.blue,
    ),
    const MyFileType(
      fileExtension: 'xls',
      mimeType: 'application/vnd.ms-excel',
      iconData: FontAwesomeIcons.fileExcel,
      iconColor: Colors.green,
    ),
    const MyFileType(
      fileExtension: 'xlsx',
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      iconData: FontAwesomeIcons.fileExcel,
      iconColor: Colors.green,
    ),
    const MyFileType(
      fileExtension: 'ppt',
      mimeType: 'application/vnd.ms-powerpoint',
      iconData: FontAwesomeIcons.filePowerpoint,
      iconColor: Colors.orange,
    ),
    const MyFileType(
      fileExtension: 'pptx',
      mimeType:
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      iconData: FontAwesomeIcons.filePowerpoint,
      iconColor: Colors.orange,
    ),
    const MyFileType(
      fileExtension: 'txt',
      mimeType: 'text/plain',
      iconData: FontAwesomeIcons.fileAlt,
      iconColor: Colors.blueGrey,
    ),
  ];

  // ใส่ลายน้ำไม่ได้
  // 'mp3', 'wav', 'ogg
  static const List<MyFileType> audioFileTypeList = [
    const MyFileType(
      fileExtension: 'mp3',
      mimeType: 'audio/mpeg',
      iconData: FontAwesomeIcons.fileAudio,
      iconColor: Colors.blueGrey,
    ),
    const MyFileType(
      fileExtension: 'wav',
      mimeType: 'audio/wav',
      iconData: FontAwesomeIcons.fileAudio,
      iconColor: Colors.blueGrey,
    ),
    const MyFileType(
      fileExtension: 'ogg',
      mimeType: 'audio/ogg',
      iconData: FontAwesomeIcons.fileAudio,
      iconColor: Colors.blueGrey,
    ),
  ];

  // ใส่ลายน้ำไม่ได้
  static const List<MyFileType> etcFileTypeList = [
    const MyFileType(
      fileExtension: 'zip',
      mimeType: 'application/zip',
      iconData: FontAwesomeIcons.fileArchive,
      iconColor: Colors.brown,
    ),
  ];

  static const List<MyFileType> navecFileTypeList = [
    const MyFileType(
      fileExtension: 'enc',
      mimeType: 'application/octet-stream',
      iconData: FontAwesomeIcons.lock,
      iconColor: Colors.blueGrey,
    ),
  ];

  static const List<MyFileType> selectableFileTypeList = [
    ...documentFileTypeList,
    ...imageFileTypeList,
    ...videoFileTypeList,
    ...audioFileTypeList,
    ...navecFileTypeList,
    ...etcFileTypeList,
  ];

  static const unSupportedFileType = MyFileType(
    fileExtension: '',
    mimeType: '',
    iconData: FontAwesomeIcons.solidFile,
    iconColor: Colors.redAccent,
  );

  static const List<MyFileType> allFileTypeList = [
    ...selectableFileTypeList,
    //...archiveFileTypeList,
  ];

  static List<String> get selectableMimeTypeList =>
      selectableFileTypeList.map((fileType) => fileType.mimeType).toList();

  static List<String> get selectableExtensionList =>
      selectableFileTypeList.map((fileType) => fileType.fileExtension).toList();
}
