library decryption_page;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:navy_encrypt/common/encrypt_decrypt_header.dart';
import 'package:navy_encrypt/common/file_details.dart';
import 'package:navy_encrypt/common/header_scaffold.dart';
import 'package:navy_encrypt/common/my_button.dart';
import 'package:navy_encrypt/common/my_container.dart';
import 'package:navy_encrypt/common/my_form_field.dart';
import 'package:navy_encrypt/common/my_state.dart';
import 'package:navy_encrypt/common/widget_view.dart';
import 'package:navy_encrypt/etc/constants.dart';
import 'package:navy_encrypt/etc/utils.dart';
import 'package:navy_encrypt/navy_encryption/navec.dart';
import 'package:navy_encrypt/navy_encryption/watermark.dart';
import 'package:navy_encrypt/pages/settings/settings_page.dart';
import 'package:navy_encrypt/storage/prefs.dart';
import 'package:path/path.dart' as p;

import '../../common/my_dialog.dart';
import '../../services/api.dart';
import '../result/result_page.dart';

part 'decryption_page_view.dart';
part 'decryption_page_view_win.dart';

class DecryptionPage extends StatefulWidget {
  static const routeName = 'decryption';
  final String filePath;

  const DecryptionPage({Key key, this.filePath}) : super(key: key);

  @override
  _DecryptionPageController createState() =>
      _DecryptionPageController(filePath);
}

class _DecryptionPageController extends MyState<DecryptionPage> {
  String _toBeDecryptedFilePath;
  final _passwordEditingController = TextEditingController();
  var _passwordVisible = false;
  Uint8List _decryptedBytes;
  WatermarkRegisterStatus _registerStatus;

  _DecryptionPageController(this._toBeDecryptedFilePath);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _updateWatermarkRegisterStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final dynamic arguments = route == null ? null : route.settings.arguments;

    String filePath;
    if (arguments is String && arguments.trim().isNotEmpty) {
      filePath = arguments.trim();
    } else if (widget.filePath != null && widget.filePath.trim().isNotEmpty) {
      filePath = widget.filePath.trim();
    }

    if (filePath != null && filePath.isNotEmpty) {
      _toBeDecryptedFilePath = filePath;
    }

    print('PATH OF FILE TO BE DECRYPTED: $_toBeDecryptedFilePath');

    return _DecryptionPageView(this);
  }

  _handleClickPasswordEye() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  _updateWatermarkRegisterStatus() async {
    var status = await Watermark.getRegisterStatus();
    setState(() {
      _registerStatus = status;
    });
  }

  _handleClicktoSettingButton() {
    Navigator.pushNamed(
      context,
      SettingsPage.routeName,
    ).then((value) => _updateWatermarkRegisterStatus());
    ;
  }

  Future<void> _handleClickGoButton() async {
    if (!hasSelectedFile) {
      showOkDialog(context, 'กรุณาเลือกไฟล์ที่ต้องการถอดรหัสก่อน');
      return;
    }

    var password = _passwordEditingController.text;
    if (password.trim().isEmpty) {
      showOkDialog(context, 'ต้องกรอกรหัสผ่าน');
      return;
    }

    isLoading = true;
    List decryptData;
    File outFile;
    String uuid;
    var email = await MyPrefs.getEmail();
    var secret = await MyPrefs.getSecret();
    try {
      decryptData = await Navec.decryptFile(
        context: context,
        filePath: _toBeDecryptedFilePath,
        password: password,
      );

      if (decryptData == null) {
        isLoading = false;
        return;
      }

      outFile = decryptData[0];
      uuid = decryptData[1];

      if (outFile == null) {
        isLoading = false;
        return;
      }
    } on Exception catch (e) {
      isLoading = false;
      showOkDialog(context, 'เกิดข้อผิดพลาดในการถอดรหัส: $e');
      return;
    }
    String getLog;

    try {
      final statusCheckDecrypt = await MyApi().getCheckDecrypt(email, uuid);
      if (!statusCheckDecrypt) {
        showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, setState) {
                return MyDialog(
                  headerImage: Image.asset('assets/images/ic_unauthorized.png',
                      width: Constants.LIST_DIALOG_HEADER_IMAGE_SIZE),
                  body: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 32.0),
                            Text(
                              'คุณไม่มีสิทธิ์ในการเข้าถึงไฟล์นี้!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 22.0, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 22.0),
                            OverflowBar(
                              alignment: MainAxisAlignment.end,
                              // spacing: spacing,
                              overflowAlignment: OverflowBarAlignment.end,
                              overflowDirection: VerticalDirection.down,
                              overflowSpacing: 0,
                              children: <Widget>[
                                TextButton(
                                  child: Text("ตกลง",
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 31, 150, 205))),
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                ),
                              ],
                            )
                          ])),
                );
              });
            });

        isLoading = false;
        return;
      }
    } on Exception {
      showOkDialog(context, 'เกิดข้อผิดพลาดในการตรวจสอบสิทธิ์!');
    }

    try {
      String fileName = '${p.basename(_toBeDecryptedFilePath)}';
      int logId = await MyApi().saveLog(
          email, fileName, uuid, null, 'view', "encryption", secret, null);
      getLog = logId.toString();
    } catch (e) {
      showOkDialog(context, e.toString());
      isLoading = false;
      return;
    }

    isLoading = false;

    final processedFilePath = outFile.path;
    final isEncryptedFile = p.extension(processedFilePath).toLowerCase() ==
        '.${Navec.encryptedFileExtension}';

    Navigator.pushReplacementNamed(
      context,
      ResultPage.routeName,
      arguments: {
        'filePath': processedFilePath,
        'processedFilePath': processedFilePath,
        'message': 'ถอดรหัสสำเร็จ',
        'isEncryptedFile': isEncryptedFile,
        'userID': getLog,
        'originalInputPath': _toBeDecryptedFilePath,
        'signatureCode': null,
        'type': 'encryption'
      },
    );
  }

  bool get hasSelectedFile =>
      _toBeDecryptedFilePath != null &&
      _toBeDecryptedFilePath.trim().isNotEmpty;
}
