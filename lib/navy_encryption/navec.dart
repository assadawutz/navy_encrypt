import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:navy_encrypt/etc/constants.dart';
import 'package:navy_encrypt/etc/file_util.dart';
import 'package:navy_encrypt/etc/utils.dart';
import 'package:navy_encrypt/models/loading_message.dart';
import 'package:navy_encrypt/navy_encryption/algorithms/aes.dart';
import 'package:navy_encrypt/navy_encryption/algorithms/base_algorithm.dart';
// import 'package:navy_encrypt/navy_encryption/algorithms/test.dart';
import 'package:navy_encrypt/navy_encryption/watermark.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

class Navec {
  static const headerFileSignature = 'NAVEC';
  static const headerFileExtensionFieldLength = 5;
  static const headerAlgorithmFieldLength = 10;
  static const encryptedFileExtension = 'enc';
  static const passwordPadChar = '.';
  static const notEncryptCode = '';
  static const headerUUIDFieldLength = 36;

  static final algorithms = <BaseAlgorithm>[
    // Test(),
    Aes(keyLengthInBytes: 16), // AES 128
    Aes(keyLengthInBytes: 32), // AES 256
    NotEncrypt(), // ไม่เข้ารหัส
  ];

  // static Future<File> encryptFile({
  //   @required String filePath,
  //   @required String password,
  //   @required BaseAlgorithm algo,
  //   @required String uuid,
  // }) async {
  //   const space = ' ';
  //
  //   var bytes = await File(filePath).readAsBytes();
  //   var encryptedBytes = algo.encrypt(password, bytes);
  //
  //   // final key = enc.Key.fromSecureRandom(32);
  //   // // final key = enc.Key.fromUtf8(password);
  //   // final iv = IV.fromLength(16);
  //   //
  //   // final encrypter = Encrypter(AES(key));
  //   //
  //   // final encrypted = encrypter.encrypt(password, iv: iv);
  //   // final decrypted = encrypter.decrypt(encrypted, iv: iv);
  //   // final decrypted2 = encrypter.decryptBytes(encrypted, iv: iv);
  //
  //   // print(decrypted);
  //   // print(encrypted.base64);
  //   // print("decrypteddecrypteddecrypted ${decrypted}");
  //   // print("decrypteddecrypteddecrypted ${decrypted2}");
  //
  //   var logMap = <String, dynamic>{
  //     'Operation': 'Encryption',
  //     'Input file path': filePath,
  //     'Password': password,
  //     'Algorithm': algo.code,
  //     'UUID': uuid,
  //   };
  //
  //   // นามสกุลเดิมของไฟล์ เพิ่มช่องว่างต่อท้ายให้ครบตามขนาดฟีลด์
  //   var fileExtension = p.extension(filePath).substring(1);
  //   while (fileExtension.length < Navec.headerFileExtensionFieldLength) {
  //     fileExtension = '$fileExtension$space';
  //   }
  //
  //   // algo ที่ใช้เข้ารหัส เพิ่มช่องว่างต่อท้ายให้ครบตามขนาดฟีลด์
  //   var algoCode = algo.code;
  //   while (algoCode.length < Navec.headerAlgorithmFieldLength) {
  //     algoCode = '$algoCode$space';
  //   }
  //
  //   List<int> encryptedBytesWithHeader = [
  //     ...utf8.encode(Navec.headerFileSignature), // header
  //     ...utf8.encode(fileExtension), // old extension, padding with space(s)
  //     ...utf8.encode(algoCode), // algo code, padding with space(s)
  //     ...encryptedBytes, // encrypted bytes
  //     ...utf8.encode(uuid),
  //   ];
  //
  //   var outFilename =
  //       '${p.basenameWithoutExtension(filePath)}.${Navec.encryptedFileExtension}';
  //   logMap['Encrypted file name'] = outFilename;
  //
  //   File outFile = await FileUtil.createFileFromBytes(
  //     outFilename,
  //     Uint8List.fromList(encryptedBytesWithHeader),
  //   );
  //   logMap['Encrypted file path'] = outFile.path;
  //
  //   logWithBorder(logMap, 2);
  //
  //   return outFile;
  // }

  static Future<File> encryptFile({
    @required String filePath,
    @required String password,
    @required BaseAlgorithm algo,
    @required String uuid,
  }) async {
    const space = ' ';

    var bytes = await File(filePath).readAsBytes();
    var encryptedBytes = algo.encrypt(password, bytes);

    var logMap = <String, dynamic>{
      'Operation': 'Encryption',
      'Input file path': filePath,
      'Password': password,
      'Algorithm': algo.code,
      'UUID': uuid,
    };

    // นามสกุลเดิมของไฟล์ เพิ่มช่องว่างต่อท้ายให้ครบตามขนาดฟีลด์
    var fileExtension = p.extension(filePath).substring(1);
    while (fileExtension.length < Navec.headerFileExtensionFieldLength) {
      fileExtension = '$fileExtension$space';
    }

    // algo ที่ใช้เข้ารหัส เพิ่มช่องว่างต่อท้ายให้ครบตามขนาดฟีลด์
    var algoCode = algo.code;
    while (algoCode.length < Navec.headerAlgorithmFieldLength) {
      algoCode = '$algoCode$space';
    }

    List<int> encryptedBytesWithHeader = [
      ...utf8.encode(Navec.headerFileSignature), // header
      ...utf8.encode(fileExtension), // old extension, padding with space(s)
      ...utf8.encode(algoCode), // algo code, padding with space(s)
      ...encryptedBytes, // encrypted bytes
      ...utf8.encode(uuid),
    ];

    var outFilename =
        '${p.basenameWithoutExtension(filePath)}.${Navec.encryptedFileExtension}';
    logMap['Encrypted file name'] = outFilename;

    File outFile = await FileUtil.createFileFromBytes(
      outFilename,
      Uint8List.fromList(encryptedBytesWithHeader),
    );
    logMap['Encrypted file path'] = outFile.path;

    logWithBorder(logMap, 2);

    return outFile;
  }
  // END encryptFile

  // static Future<List> decryptFile({
  //   @required BuildContext context,
  //   @required String filePath,
  //   @required String password,
  // }) async {
  //   var fileBytes = await File(filePath).readAsBytes();
  //
  //   var extensionFieldBeginIndex = Navec.headerFileSignature.length;
  //   var algorithmFieldBeginIndex =
  //       extensionFieldBeginIndex + Navec.headerFileExtensionFieldLength;
  //   var contentBeginIndex =
  //       algorithmFieldBeginIndex + Navec.headerAlgorithmFieldLength;
  //
  //   var logMap = <String, dynamic>{
  //     'Operation': 'Decryption',
  //     'Input file path': filePath,
  //     'Password': password,
  //   };
  //
  //   var fileSignature =
  //       utf8.decode(fileBytes.sublist(0, Navec.headerFileSignature.length));
  //   logMap['File signature'] = fileSignature;
  //
  //   var fileExtension = utf8
  //       .decode(fileBytes.sublist(
  //         extensionFieldBeginIndex,
  //         algorithmFieldBeginIndex,
  //       ))
  //       .trim();
  //   logMap['File extension (old)'] = fileExtension;
  //
  //   var algoCode = utf8
  //       .decode(fileBytes.sublist(
  //         algorithmFieldBeginIndex,
  //         contentBeginIndex,
  //       ))
  //       .trim();
  //   logMap['Algorithm'] = algoCode;
  //
  //   var contentEndIndex = fileBytes.length;
  //   String uuid;
  //   try {
  //     uuid = utf8
  //         .decode(fileBytes.sublist(
  //           (fileBytes.length - headerUUIDFieldLength),
  //         ))
  //         .trim();
  //
  //     logMap['UUID'] = uuid;
  //     contentEndIndex = contentEndIndex - headerUUIDFieldLength;
  //   } catch (err) {}
  //
  //   logWithBorder(logMap, 2);
  //
  //   var algo = Navec.algorithms.firstWhere(
  //     (algo) => algo.code == algoCode,
  //     orElse: () => null,
  //   );
  //
  //   File outFile;
  //   if (algo == null) {
  //     showOkDialog(
  //       context,
  //       'ผิดพลาด',
  //       textContent: 'ไฟล์ถูกเข้ารหัสด้วย Algorithm ที่แอปนี้ไม่รองรับ',
  //     );
  //   } else {
  //     // var decryptedBytes = algo.decrypt(
  //     //     password, fileBytes.sublist(contentBeginIndex, contentEndIndex));
  //     //
  //
  //     final key = enc.Key.fromSecureRandom(32);
  //     // final key = enc.Key.fr(password);
  //     final iv = IV.fromLength(16);
  //
  //     final encrypter = Encrypter(AES(key));
  //
  //     final encrypted = encrypter.encrypt(password, iv: iv);
  //     // final decrypted = encrypter.decrypt(encrypted, iv: iv);
  //     final decrypted2 = encrypter.decryptBytes(encrypted, iv: iv);
  //
  //     // print(decrypted);
  //     // print(encrypted);
  //     // print("decrypteddecrypteddecrypted ${decrypted}");
  //     print("decrypteddecrypteddecrypted ${decrypted2}");
  //     if (decrypted2 == null) {
  //       showOkDialog(
  //         context,
  //         'ผิดพลาด',
  //         textContent: 'รหัสผ่านไม่ถูกต้อง หรือเกิดข้อผิดพลาดในการถอดรหัส',
  //       );
  //     } else {
  //       var outFilename =
  //           '${p.basenameWithoutExtension(filePath)}.$fileExtension';
  //       logMap['Decrypted file name'] = outFilename;
  //
  //       outFile = await FileUtil.createFileFromBytes(
  //         outFilename,
  //         Uint8List.fromList(decrypted2),
  //       );
  //       logMap['Decrypted file path'] = outFile.path;
  //     }
  //   }
  //
  //   logWithBorder(logMap, 2);
  //   return [outFile, uuid];
  // }
  // // END decryptFile

  static Future<List> decryptFile({
    @required BuildContext context,
    @required String filePath,
    @required String password,
  }) async {
    var fileBytes = await File(filePath).readAsBytes();

    var extensionFieldBeginIndex = Navec.headerFileSignature.length;
    var algorithmFieldBeginIndex =
        extensionFieldBeginIndex + Navec.headerFileExtensionFieldLength;
    var contentBeginIndex =
        algorithmFieldBeginIndex + Navec.headerAlgorithmFieldLength;

    var logMap = <String, dynamic>{
      'Operation': 'Decryption',
      'Input file path': filePath,
      'Password': password,
    };

    var fileSignature =
        utf8.decode(fileBytes.sublist(0, Navec.headerFileSignature.length));
    logMap['File signature'] = fileSignature;

    var fileExtension = utf8
        .decode(fileBytes.sublist(
          extensionFieldBeginIndex,
          algorithmFieldBeginIndex,
        ))
        .trim();
    logMap['File extension (old)'] = fileExtension;

    var algoCode = utf8
        .decode(fileBytes.sublist(
          algorithmFieldBeginIndex,
          contentBeginIndex,
        ))
        .trim();
    logMap['Algorithm'] = algoCode;

    var contentEndIndex = fileBytes.length;
    String uuid;
    try {
      uuid = utf8
          .decode(fileBytes.sublist(
            (fileBytes.length - headerUUIDFieldLength),
          ))
          .trim();

      logMap['UUID'] = uuid;
      contentEndIndex = contentEndIndex - headerUUIDFieldLength;
    } catch (err) {}

    logWithBorder(logMap, 2);

    var algo = Navec.algorithms.firstWhere(
      (algo) => algo.code == algoCode,
      orElse: () => null,
    );

    File outFile;
    if (algo == null) {
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'ไฟล์ถูกเข้ารหัสด้วย Algorithm ที่แอปนี้ไม่รองรับ',
      );
    } else {
      var fileBytes = await File(filePath).readAsBytes();

      var decryptedBytes = algo.decrypt(
          password, fileBytes.sublist(contentBeginIndex, contentEndIndex));
      //
      //
      //
      if (decryptedBytes == null) {
        showOkDialog(
          context,
          'ผิดพลาด',
          textContent: 'รหัสผ่านไม่ถูกต้อง หรือเกิดข้อผิดพลาดในการถอดรหัส',
        );
      } else {
        var outFilename =
            '${p.basenameWithoutExtension(filePath)}.$fileExtension';
        logMap['Decrypted file name'] = outFilename;

        outFile = await FileUtil.createFileFromBytes(
          outFilename,
          Uint8List.fromList(decryptedBytes),
        );
        logMap['Decrypted file path'] = outFile.path;
      }
    }

    logWithBorder(logMap, 2);
    return [outFile, uuid];
  }
  // END decryptFile

  static Future<File> addWatermark({
    @required BuildContext context,
    @required String filePath,
    @required String message,
    @required String email,
    @required String signatureCode,
  }) async {
    String extension = p.extension(filePath).substring(1).toLowerCase();
    File outFile;
    var wm = Watermark(
      message: message,
      email: email,
      signatureCode: signatureCode,
    );

    // ใส่ลายน้ำได้ แต่ต้องแปลงเป็นรูปภาพก่อน
    if (Constants.documentFileTypeList
        .where((fileType) => fileType.fileExtension == extension)
        .isNotEmpty) {
      try {
        outFile = await wm.convertDocumentToImage(context, filePath);
      } catch (e) {
        showOkDialog(context, 'ผิดพลาด', textContent: e.toString());
      }
    }
    // ใส่ลายน้ำได้ทันที
    else if (Constants.imageFileTypeList
        .where((fileType) => fileType.fileExtension == extension)
        .isNotEmpty) {
      Provider.of<LoadingMessage>(context, listen: false)
          .setMessage('กำลังวาดลายน้ำลงในรูปภาพ');
      outFile = await wm.addWatermark(context, filePath);
    }
    // ใส่ลายน้ำไม่ได้
    else {
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'แอปไม่รองรับการใส่ลายน้ำให้กับไฟล์ประเภท $extension',
      );
    }

    return outFile;
  }

  static bool checkUniqueAlgoCode() {
    var codeList = <String>[];
    var isUnique = true;

    algorithms.forEach((algo) {
      if (codeList.contains(algo.code)) {
        isUnique = false;
      } else {
        codeList.add(algo.code);
      }
    });
    return isUnique;
  }
}
