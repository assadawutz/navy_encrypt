library encryption_page;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navy_encrypt/common/encrypt_decrypt_header.dart';
import 'package:navy_encrypt/common/file_details.dart';
import 'package:navy_encrypt/common/header_scaffold.dart';
import 'package:navy_encrypt/common/my_button.dart';
import 'package:navy_encrypt/common/my_container.dart';
import 'package:navy_encrypt/common/my_form_field.dart';
import 'package:navy_encrypt/common/my_state.dart';
import 'package:navy_encrypt/common/widget_view.dart';
import 'package:navy_encrypt/etc/constants.dart';
import 'package:navy_encrypt/etc/file_util.dart';
import 'package:navy_encrypt/etc/utils.dart';
import 'package:navy_encrypt/models/loading_message.dart';
import 'package:navy_encrypt/navy_encryption/algorithms/base_algorithm.dart';
import 'package:navy_encrypt/navy_encryption/navec.dart';
import 'package:navy_encrypt/navy_encryption/watermark.dart';
import 'package:navy_encrypt/pages/result/result_page.dart';
import 'package:navy_encrypt/pages/settings/settings_page.dart';
import 'package:navy_encrypt/services/api.dart';
import 'package:navy_encrypt/storage/prefs.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:navy_encrypt/services/api.dart';

part 'encryption_page_view.dart';
part 'encryption_page_view_win.dart';

class EncryptionPage extends StatefulWidget {
  static const routeName = 'encryption';

  final String filePath;

  const EncryptionPage({Key key, this.filePath}) : super(key: key);

  @override
  _EncryptionPageController createState() =>
      _EncryptionPageController(filePath);
}

class _EncryptionPageController extends MyState<EncryptionPage> {
  String _toBeEncryptedFilePath;
  final _watermarkEditingController = TextEditingController();
  final _passwordEditingController = TextEditingController();
  final _confirmPasswordEditingController = TextEditingController();
  var _passwordVisible = false;
  var _confirmPasswordVisible = false;
  var _algorithm = Navec.algorithms[2];
  WatermarkRegisterStatus _registerStatus;

  _EncryptionPageController(this._toBeEncryptedFilePath);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _updateWatermarkRegisterStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    var filePath = ModalRoute.of(context).settings.arguments as String;
    _toBeEncryptedFilePath = filePath;

    print('PATH OF FILE TO BE ENCRYPTED: $_toBeEncryptedFilePath');

    return _EncryptionPageView(this);
  }

  _handleClickPasswordEye() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  _handleClickConfirmPasswordEye() {
    setState(() {
      _confirmPasswordVisible = !_confirmPasswordVisible;
    });
  }

  Future<String> _createCopy(String filePath) async {
    final uniqueTempDirPath = (await FileUtil.createUniqueTempDir()).path;
    final newFilePath = '${uniqueTempDirPath}/${p.basename(filePath)}';
    final newFile = await File(filePath).copy(newFilePath);
    return newFile.path;
  }

  Future<void> _handleClickGoButton() async {
    if (_watermarkEditingController.text.trim().isEmpty &&
        _algorithm.code == Navec.notEncryptCode) {
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: _canWatermarkThisFileType()
            ? 'ต้องกรอกข้อความลายน้ำ และ/หรือเลือกวิธีการเข้ารหัส จึงจะสามารถดำเนินการต่อได้'
            : 'ต้องเลือกวิธีการเข้ารหัส จึงจะสามารถดำเนินการต่อได้',
      );
      return;
    }

    var password = _passwordEditingController.text;
    if (_algorithm.code != Navec.notEncryptCode && password.trim().isEmpty) {
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'ต้องกรอกรหัสผ่าน' +
            (_canWatermarkThisFileType()
                ? '\nถ้าหากต้องการใส่ลายน้ำแต่ไม่ต้องการเข้ารหัส ให้เลือก \'ไม่เข้ารหัส\''
                : ''),
      );
      return;
    }

    var confirmPassword = _confirmPasswordEditingController.text;
    if (_algorithm.code != Navec.notEncryptCode &&
        confirmPassword.trim() != password.trim()) {
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'ยืนยันรหัสผ่านไม่ถูกต้อง' +
            (_canWatermarkThisFileType()
                ? '\nกรุณายืนยันรหัสผ่านให้ถูกต้อง'
                : ''),
      );
      return;
    }

    var doWatermark = false;
    var doEncrypt = false;

    FocusScope.of(context).unfocus(); // hide keyboard
    isLoading = true;

    // copy ไฟล์ไปยัง temp dir
    File file = File(await _createCopy(_toBeEncryptedFilePath));
    print("_watermarkEditingController ${_watermarkEditingController.text}");
    var email = await MyPrefs.getEmail();
    var secret = await MyPrefs.getSecret();
    String signatureCode;

    if (_watermarkEditingController.text.isNotEmpty) {
      doWatermark = true;
      loadingMessage = 'กำลังใส่ลายน้ำ';
      // Provider.of<LoadingMessage>(context, listen: false)
      //     .setMessage('กำลังสร้างรหัสลายน้ำ 12 หลัก');

      try {
        signatureCode = await MyApi().getWatermarkSignatureCode(email, secret);
      } catch (e) {
        showOkDialog(context, e.toString());
      }

      signatureCode = _watermarkEditingController.text;
      print("signatureCode1 = ${signatureCode}");
      print("signatureCode2 = ${signatureCode}");
      // ใส่ลายน้ำ
      file = await Navec.addWatermark(
        context: context,
        filePath: file.path,
        message: _watermarkEditingController.text ?? "",
        email: email ?? "",
        signatureCode: signatureCode,
      );
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("prefs.getString('action'); ${prefs.getString('ref_code')}");
    // String uuid = prefs.getString('ref_code');
    //File encryptedOutFile;
    String uuid;
    if (_algorithm.code != Navec.notEncryptCode) {
      doEncrypt = true;

      var refCode = await MyPrefs.getRefCode();
      uuid = await MyApi().getUuid(refCode);
      print("uuid = ${uuid}");

      //loadingMessage = 'กำลังเข้ารหัส';
      Provider.of<LoadingMessage>(context, listen: false)
          .setMessage('กำลังเข้ารหัส');
      print("encryptFile ${file.path}");
      print("encryptFile ${password}");
      print("encryptFile ${_algorithm}");
      print("encryptFile ${uuid}");
      try {
        // เข้ารหัส
        file = await Navec.encryptFile(
            filePath: file.path,
            password: password ?? "",
            algo: _algorithm,
            uuid: uuid);
      } on Exception catch (e) {
        showOkDialog(
          context,
          'ผิดพลาด',
          textContent: 'เกิดข้อผิดพลาดในการเข้ารหัส: $e',
        );

        isLoading = false;
        return;
      }
    }

    try {
      String fileName = '${p.basename(file.path.split('/').last)}';
      String type = doEncrypt ? 'encryption' : 'watermark';

      final logId = await MyApi()
          .saveLog(email, fileName, uuid, signatureCode, 'create', type, secret,
              null)
          .toString();
    } catch (e) {
      showOkDialog(context, e.toString());
      isLoading = false;
      return;
    }

    isLoading = false;
// checkFile = p.extension(file.path).substring(1).toLowerCase();
    var message = doWatermark ? 'ใส่ลายน้ำ' : '';
    message =
        '$message${doEncrypt ? ((message == '' ? '' : 'และ') + 'เข้ารหัส') : ''}';
    print(
        "_fileExtension_fileExtension ${p.extension(file.path).substring(1).toLowerCase()}");
    Navigator.pushReplacementNamed(
      context,
      ResultPage.routeName,
      arguments: {
        'filePath': file.path,
        'message': '$messageสำเร็จ',
        'isEncryption':
            p.extension(file.path).substring(1).toLowerCase() == "enc"
                ? false
                : true,
        'fileEncryptPath': _toBeEncryptedFilePath,
        'signatureCode': signatureCode,
        'type': doEncrypt ? 'encryption' : 'watermark'
      },
    );
  }

  _handleChangeAlgorithm(BaseAlgorithm algo) {
    setState(() {
      _algorithm = algo;
      _passwordEditingController.clear();
      _confirmPasswordEditingController.clear();
    });
  }

  _updateWatermarkRegisterStatus() async {
    var status = await Watermark.getRegisterStatus();
    setState(() {
      _registerStatus = status;
    });
  }

  Future<bool> _hasRegisteredWatermark() async {
    return await Watermark.getRegisterStatus() ==
        WatermarkRegisterStatus.registered;
  }

  _handleClicktoSettingButton() {
    Navigator.pushNamed(
      context,
      SettingsPage.routeName,
    ).then((value) => _updateWatermarkRegisterStatus());
    ;
  }

  bool _canWatermarkThisFileType() {
    /*var extension =
        p.extension(_toBeEncryptedFilePath).substring(1).toLowerCase();*/

    return Constants.imageFileTypeList
            .where((fileType) => fileType.fileExtension == _fileExtension)
            .isNotEmpty ||
        Constants.documentFileTypeList
            .where((fileType) => fileType.fileExtension == _fileExtension)
            .isNotEmpty;
  }

  /*Future<bool> _isWatermarkEnabled() async {
    return await _hasRegisteredWatermark() && _canWatermarkThisFileType();
  }*/

  _handleResume() {
    setState(() {}); // Update watermark status when resume from settings page
  }

  String get _fileExtension =>
      p.extension(_toBeEncryptedFilePath).substring(1).toLowerCase();
}
