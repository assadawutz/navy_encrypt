library settings_page;

import 'dart:io' show Platform;
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:navy_encrypt/common/encrypt_decrypt_header.dart';
import 'package:navy_encrypt/common/header_scaffold.dart';
import 'package:navy_encrypt/common/my_button.dart';
import 'package:navy_encrypt/common/my_container.dart';
import 'package:navy_encrypt/common/my_dialog.dart';
import 'package:navy_encrypt/common/my_form_field.dart';
import 'package:navy_encrypt/common/my_state.dart';
import 'package:navy_encrypt/common/widget_view.dart';
import 'package:navy_encrypt/etc/constants.dart';
import 'package:navy_encrypt/etc/extensions.dart';
import 'package:navy_encrypt/etc/file_util.dart';
import 'package:navy_encrypt/etc/utils.dart';
import 'package:navy_encrypt/navy_encryption/watermark.dart';
import 'package:navy_encrypt/services/api.dart';
import 'package:navy_encrypt/storage/prefs.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_page_view.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = 'settings';

  const SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageController createState() => _SettingsPageController();
}

enum WatermarkRegisterStatus { initial, waitForSecret, registered }

class _SettingsPageController extends MyState<SettingsPage> {
  final _emailEditingController = TextEditingController();
  final _nameEditingController = TextEditingController();
  final _phoneEditingController = TextEditingController();
  final _privateKeyEditingController = TextEditingController();
  WatermarkRegisterStatus _registerStatus; //WatermarkRegisterStatus.initial;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _updateWatermarkRegisterStatus();
    });
  }

  _updateWatermarkRegisterStatus() async {
    var status = await Watermark.getRegisterStatus();

    setState(() {
      _registerStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) => _SettingsPageView(this);

  int getWatermarkStatusIndex(WatermarkRegisterStatus status) =>
      WatermarkRegisterStatus.values.indexWhere((item) => item == status);

  _handleClickRequestKeyButton() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String errEmailMessage;
        String errNameMessage;
        String errPhoneMessage;

        return StatefulBuilder(builder: (context, setState) {
          return MyDialog(
            headerImage: Image.asset('assets/images/ic_register.png',
                width: Constants.LIST_DIALOG_HEADER_IMAGE_SIZE),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.0),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: [
                  //     Text(
                  //       'อีเมล',
                  //       textAlign: TextAlign.center,
                  //       style: TextStyle(
                  //           fontSize: 22.0, fontWeight: FontWeight.w500),
                  //     ),
                  //   ],
                  // ),

                  MyFormField(
                    hint: 'อีเมล',
                    label: 'กรอกอีเมลของคุณ',
                    autofocus: true,
                    multiline: false,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailEditingController,
                  ),
                  if (errEmailMessage != null)
                    Text(errEmailMessage,
                        style:
                            TextStyle(color: Colors.redAccent, fontSize: 18.0)),
                  SizedBox(height: 8.0),
                  // ชื่อ-นาสกุล
                  MyFormField(
                    hint: 'ชื่อ-นามสกุล',
                    label: 'กรอกชื่อ-นามสกุลของคุณ',
                    autofocus: false,
                    multiline: false,
                    keyboardType: TextInputType.text,
                    controller: _nameEditingController,
                  ),
                  if (errNameMessage != null)
                    Text(errNameMessage,
                        style:
                            TextStyle(color: Colors.redAccent, fontSize: 18.0)),
                  SizedBox(height: 8.0),
                  // ชื่อ-นาสกุล
                  MyFormField(
                    hint: 'เบอร์โทรศัพท์',
                    label: 'กรอกเบอร์โทรศัพท์ของคุณ',
                    autofocus: false,
                    multiline: false,
                    keyboardType: TextInputType.phone,
                    controller: _phoneEditingController,
                  ),
                  if (errPhoneMessage != null)
                    Text(errPhoneMessage,
                        style:
                            TextStyle(color: Colors.redAccent, fontSize: 18.0)),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('ยกเลิก')),
                      SizedBox(width: 8.0),
                      TextButton(
                          onPressed: () => _handleClickEmailDialogOkButton(
                                  dialogContext, (msgEmail, msgName, msgPhone) {
                                setState(() {
                                  errEmailMessage = msgEmail;
                                  errNameMessage = msgName;
                                  errPhoneMessage = msgPhone;
                                });
                              }),
                          child: Text('ตกลง')),
                    ],
                  ),
                ],
              ),
            ),
            padding: EdgeInsets.only(
              left: 16.0,
              top: 16.0,
              right: 16.0,
              bottom: 4.0,
            ),
          );
        });
      },
    );

    /*setState(() {
      _registerStatus = WatermarkRegisterStatus.waitForKey;
    });*/
  }

  _handleClickEmailDialogOkButton(BuildContext dialogContext,
      void Function(String, String, String) showError) async {
    var inputEmail = _emailEditingController.text;
    var inputName = _nameEditingController.text;
    var inputPhone = _phoneEditingController.text;

    var showEmailError = '';
    var showNameError = '';
    var showPhoneError = '';

    if (inputEmail == null ||
        !inputEmail.isValidEmail ||
        inputEmail.trim().isEmpty) {
      showEmailError = 'รูปแบบอีเมลไม่ถูกต้อง';
    }

    if (inputName == null || inputName.trim().isEmpty) {
      showNameError = 'กรุณากรอกชืิ่อ-นามสกุล';
    }

    if (inputPhone == null || inputPhone.trim().isEmpty) {
      showPhoneError = 'กรุณากรอกเบอร์โทรศัพท์';
    }

    if (showEmailError != '' || showNameError != '' || showPhoneError != '') {
      showError(showEmailError, showNameError, showPhoneError);
      return;
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceOs, deviceName, deviceId;
    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await deviceInfo.androidInfo;
      deviceOs = 'Android';
      deviceName = info.model; // e.g. "Moto G (4)"
      deviceId = info.androidId;
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await deviceInfo.iosInfo;
      deviceOs = 'iOS';
      deviceName = info.utsname.machine; // e.g. "iPod7,1"
      deviceId = info.identifierForVendor;
    } else if (Platform.isWindows) {
      WindowsDeviceInfo info = await deviceInfo.windowsInfo;
      deviceOs = 'Windows';
      deviceName = info.computerName;
    }

    showError(null, null, null);
    //dismissKeyboard(dialogContext);
    await Future.delayed(Duration(milliseconds: 100));
    Navigator.of(dialogContext).pop();

    try {
      isLoading = true;
      var refCode = getRandomString(10);
      print("refCode > ${refCode}");

      int result = await MyApi().registerWatermark(
        inputEmail,
        inputName,
        inputPhone,
        refCode,
        deviceOs,
        deviceName,
        deviceId,
      );
      print("result > ${result}");
      print("result > ${refCode}");
      await MyPrefs.setRefCode(refCode);
      await MyPrefs.setEmail(inputEmail);
      await _updateWatermarkRegisterStatus();

      showOkDialog(
        context,
        'สำเร็จ',
        textContent:
            'ระบบได้ส่งคีย์ไปยังอีเมล ${_emailEditingController.text} แล้ว โปรดตรวจสอบกล่องข้อความอีเมลของคุณ\nหมายเหตุ: การส่งเมลอาจมีความล่าช้า และผู้ให้บริการอีเมลของคุณอาจมองว่าเป็นเมลขยะ ดังนั้นโปรดตรวจสอบกล่องอีเมลขยะหากไม่พบในกล่องข้อความ',
      );
    } catch (e) {
      showOkDialog(context, 'ผิดพลาด', textContent: e.toString());
    } finally {
      isLoading = false;
    }
  }

  _handleClickSaveButton() async {
    var inputSecret = _privateKeyEditingController.text.trim();

    String msg;
    if (inputSecret.isEmpty) {
      msg = 'ต้องกรอกคีย์';
    }

    if (msg != null) {
      showOkDialog(context, 'ผิดพลาด', textContent: msg);
      return;
    }

    FocusScope.of(context).unfocus(); // hide keyboard

    var email = await MyPrefs.getEmail();
    var refCode = await MyPrefs.getRefCode();

    try {
      isLoading = true;
      int result = await MyApi().activateWatermark(email, refCode, inputSecret);

      await MyPrefs.setSecret(inputSecret);
      await _updateWatermarkRegisterStatus();
    } catch (e) {
      showOkDialog(context, 'ผิดพลาด', textContent: e.toString());
    } finally {
      isLoading = false;
    }
  }

  _handleClickCancelButton() async {
    await MyPrefs.setRefCode(null);
    await MyPrefs.setEmail(null);
    await _updateWatermarkRegisterStatus();
  }

  _handleClickLogoutButton() {
    showAlertDialog(
      context,
      'ขอคีย์ใหม่',
      textContent:
          'ต้องการยกเลิกการใช้งานแอปพลิเคชั่น\nรับส่งไฟล์ บนอุปกรณ์นี้ใช่หรือไม่?',
      content: null,
      dismissible: false,
      buttonList: [
        DialogActionButton(label: 'ไม่ใช่', onClick: null),
        DialogActionButton(
            label: 'ใช่',
            onClick: () async {
              await Watermark.logout();
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              prefs.clear();

              await _updateWatermarkRegisterStatus();
            }),
      ],
    );
  }

  _handleLaunchManual() async {
    isLoading = true;
    String docType;
    if (Platform.isAndroid) {
      docType = 'android';
    } else if (Platform.isIOS) {
      docType = 'ios';
    } else if (Platform.isWindows) {
      docType = 'windows';
    } else {
      docType = 'none';
    }

    try {
      final res = await http.get(
          Uri.parse(Constants.API_BASE_URL + '/manual?doctype=' + docType));
      print("URL ${Constants.API_BASE_URL + '/manual?doctype=' + docType}");
      print(res.statusCode);
      if (res.statusCode == 200) {
        await FileUtil.createFileFromBytes(
          'UserManual.pdf',
          res.bodyBytes,
        ).then((manual) {
          OpenFile.open(manual.path).then((result) {
            if (result.type == ResultType.noAppToOpen) {
              throw Exception('ไม่พบโปรแกรมเปิดอ่านไฟล์คู่มือ!');
            }
          });
        });
      } else {
        throw Exception('ไม่สามารถเรียกข้อมูลคู่มือได้!');
      }
    } catch (ex) {
      showOkDialog(context, 'ผิดพลาด', textContent: ex.toString());
    }

    isLoading = false;
  }
}
