import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:navy_encrypt/etc/constants.dart';
import 'package:navy_encrypt/etc/utils.dart';
import 'package:navy_encrypt/pages/final_page.dart';
import 'package:navy_encrypt/pages/settings_page.dart';
import 'package:page_transition/page_transition.dart';

class EncryptPage extends StatefulWidget {
  @override
  _EncryptPageState createState() => _EncryptPageState();
}

class _EncryptPageState extends State<EncryptPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _watermarkTextController = TextEditingController();
  final _encryptPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _encryptPasswordVisible = false;
  int _encryptAlgorithmValue = 1;

  FocusNode _focusNode;
  FocusNode _watermarkButtonFocusNode;
  FocusNode _watermarkTextFieldFocusNode;
  FocusNode _encryptTextFieldFocusNode;

  static bool _isRegisterWatermark = false;
  bool _waitPassCode = false;
  bool _isBottomSheetOpen = false;
  String _passCode = '';
  int _passCodeTimeout;
  Timer _timer;
  StateSetter _modalSetState;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _watermarkButtonFocusNode = FocusNode();
    _watermarkTextFieldFocusNode = FocusNode();
    _encryptTextFieldFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _watermarkButtonFocusNode.dispose();
    _watermarkTextFieldFocusNode.dispose();
    _encryptTextFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //_isRegisterWatermark = false; // TODO: read from pref

    return Scaffold(
      appBar: AppBar(
        title: Text('Watermark & Encrypt'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalMargin,
                vertical: Constants.verticalMargin,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isRegisterWatermark = !_isRegisterWatermark;
                        });
                      },
                      child: Icon(Icons.lock_outline,
                          size: 80.0, color: Constants.primaryColor),
                    ),

                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(
                        top: 16.0,
                        bottom: 8.0,
                      ),
                      child: Text('ลายน้ำ',
                          style: GoogleFonts.prompt(
                            fontSize: 20.0,
                          )),
                    ),
                    if (false && !_isRegisterWatermark)
                      TextButton(
                        focusNode: _watermarkButtonFocusNode,
                        onPressed: () {
                          _showBottomSheet();
                          _encryptTextFieldFocusNode.unfocus();
                        },
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Theme.of(context).primaryColor,
                          //onSurface: Colors.grey,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  'ลงทะเบียนเพื่อเปิดการใช้งานระบบลายน้ำบนอุปกรณ์นี้',
                                  style: GoogleFonts.prompt(fontSize: 16.0),
                                ),
                              ),
                              SizedBox(width: 12.0),
                              Icon(Icons.edit),
                            ],
                          ),
                        ),
                      ),
                    if (true || _isRegisterWatermark)
                      Container(
                        color: _isRegisterWatermark
                            ? Colors.transparent
                            : Colors.grey[200],
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: TextFormField(
                          focusNode: _watermarkTextFieldFocusNode,
                          enabled: _isRegisterWatermark,
                          controller: _watermarkTextController,
                          onChanged: (value) {
                            setState(() {});
                          },
                          style: GoogleFonts.prompt(fontSize: 16.0),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรอกข้อความลายน้ำ';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'ข้อความที่ต้องการใส่เป็นลายน้ำ',
                            labelStyle: GoogleFonts.prompt(fontSize: 16.0),
                            errorStyle: GoogleFonts.prompt(fontSize: 14.0),
                            filled: true,
                            fillColor: _isRegisterWatermark
                                ? Colors.white
                                : Colors.grey[100],
                            contentPadding: EdgeInsets.fromLTRB(20, 15, 10, 15),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                        ),
                      ),
                    if (!_isRegisterWatermark)
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 8.0,
                        ),
                        child: Text(
                          'ลงทะเบียนเพื่อเปิดใช้งานระบบลายน้ำในหน้า Settings',
                          style: GoogleFonts.prompt(
                              fontSize: 14.0, color: Colors.redAccent),
                        ),
                      ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(
                        top: 16.0,
                        bottom: 8.0,
                      ),
                      child: Text('เข้ารหัส',
                          style: GoogleFonts.prompt(
                            fontSize: 20.0,
                          )),
                    ),
                    DropdownButtonFormField(
                      focusNode: _focusNode,
                      value: _encryptAlgorithmValue,
                      //style: GoogleFonts.prompt(fontSize: 16.0),
                      validator: (value) {
                        if (value == null) {
                          return 'เลือกวิธีการเข้ารหัส';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'วิธีการเข้ารหัส (Algorithm)',
                        labelStyle: GoogleFonts.prompt(fontSize: 16.0),
                        errorStyle: GoogleFonts.prompt(fontSize: 14.0),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 10, 15),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          child: Text(
                            "ไม่เข้ารหัส",
                            style: GoogleFonts.prompt(
                                fontSize: 16.0, color: Colors.black),
                          ),
                          value: 0,
                        ),
                        DropdownMenuItem(
                          child: Text(
                            "AES 128",
                            style: GoogleFonts.prompt(
                                fontSize: 16.0, color: Colors.black),
                          ),
                          value: 1,
                        ),
                        /*DropdownMenuItem(
                          child: Text(
                            "AES 192",
                            style: GoogleFonts.prompt(fontSize: 16.0, color: Colors.black),
                          ),
                          value: 2,
                        ),*/
                        DropdownMenuItem(
                          child: Text(
                            "AES 256",
                            style: GoogleFonts.prompt(
                                fontSize: 16.0, color: Colors.black),
                          ),
                          value: 2,
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _encryptAlgorithmValue = value;
                        });
                      },
                      onTap: () {
                        print('TAP');
                        _focusNode.requestFocus();
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      focusNode: _encryptTextFieldFocusNode,
                      controller: _encryptPasswordController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      style: GoogleFonts.prompt(fontSize: 16.0),
                      obscureText: !_encryptPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรอกรหัสผ่าน';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'รหัสผ่าน',
                        labelStyle: GoogleFonts.prompt(fontSize: 16.0),
                        errorStyle: GoogleFonts.prompt(fontSize: 14.0),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 10, 15),
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _encryptPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Constants.accentColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _encryptPasswordVisible =
                                  !_encryptPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    //for (var i = 0; i < 50; i++) Text('AAA')
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 0), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _handleClickGo,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              'ดำเนินการ' +
                                  (_watermarkTextController
                                          .value.text.isNotEmpty
                                      ? 'ใส่ลายน้ำ'
                                      : '') +
                                  (_watermarkTextController
                                              .value.text.isNotEmpty &&
                                          _encryptPasswordController
                                              .value.text.isNotEmpty
                                      ? ' + '
                                      : '') +
                                  (_encryptPasswordController
                                          .value.text.isNotEmpty
                                      ? 'เข้ารหัส'
                                      : ''),
                              style: GoogleFonts.prompt(fontSize: 18.0)),
                          SizedBox(width: 8.0),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _handleClickGo() {
    _watermarkTextFieldFocusNode.unfocus();
    _encryptTextFieldFocusNode.unfocus();

    if (_watermarkTextController.value.text.isEmpty &&
        _encryptPasswordController.value.text.isEmpty) {
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent:
            'ต้องกรอกข้อความลายน้ำและ/หรือตั้งรหัสผ่านสำหรับการเข้ารหัส',
      );
      return;
    }

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftJoined,
        childCurrent: EncryptPage(),
        child: FinalPage(
          type: 0,
          text: 'ใส่ลายน้ำและเข้ารหัสสำเร็จ',
        ),
      ),
      /*MaterialPageRoute(
        builder: (context) => FinalPage(
          type: 0,
          text: 'ใส่ลายน้ำและเข้ารหัสสำเร็จ',
        ),
      ),*/
    );
  }

  _showBottomSheet() {
    if (_isBottomSheetOpen) return;

    _isBottomSheetOpen = true;
    showMaterialModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          _modalSetState = setState;

          if (_waitPassCode && _timer == null) {
            _setupTimeout();
          }

          return Container(
            padding: EdgeInsets.only(
              top: 24.0,
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _waitPassCode
                      ? 'กรอกรหัส OTP ที่ได้รับทางอีเมล'
                      : 'กรอกอีเมลของคุณ',
                  style: GoogleFonts.prompt(
                    fontSize: 16.0,
                  ),
                ),
                if (_waitPassCode)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 24.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < 6; i++)
                            Container(
                              margin: EdgeInsets.all(2.0),
                              width: 28.0,
                              height: 28.0,
                              decoration: BoxDecoration(
                                color: i < _passCode.length
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  i < _passCode.length
                                      ? _passCode.substring(i, i + 1)
                                      : '',
                                  style: GoogleFonts.prompt(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 24.0),
                      Column(
                        children: [
                          [1, 2, 3],
                          [4, 5, 6],
                          [7, 8, 9],
                          ['delete', 0, 'submit'],
                        ].map((row) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: row.map((item) {
                              return Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: OutlinedButton(
                                  child: Container(
                                    width: 50.0,
                                    height: 55.0,
                                    child: item == null
                                        ? null
                                        : Center(
                                            child: item.runtimeType == int
                                                ? Text(
                                                    item.toString(),
                                                    style: GoogleFonts.prompt(
                                                      fontSize: 24.0,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                  )
                                                : (item == 'submit'
                                                    ? Text(
                                                        'OK',
                                                        style:
                                                            GoogleFonts.prompt(
                                                          fontSize: 24.0,
                                                          color: _passCode
                                                                      .length ==
                                                                  6
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : Colors.grey
                                                                  .shade300,
                                                        ),
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .backspace_outlined,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      )),
                                          ),
                                  ),
                                  onPressed: (item == null ||
                                          (item == 'submit' &&
                                              _passCode.length != 6))
                                      ? null
                                      : () => _handleClickPassCodeButton(
                                          item, setState),
                                  style: ElevatedButton.styleFrom(
                                    side: item == null
                                        ? BorderSide.none
                                        : BorderSide(
                                            width: 0.0,
                                            color: item == 'submit' &&
                                                    _passCode.length == 6
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey.shade500,
                                          ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24.0),
                      if (_passCodeTimeout != null &&
                          _timer != null &&
                          _timer.isActive)
                        Text(
                          'เหลือเวลาอีก ${_formatTimeCountDown(_passCodeTimeout)} นาที',
                          style: GoogleFonts.prompt(fontSize: 16.0),
                        ),
                    ],
                  ),
                if (!_waitPassCode)
                  Column(
                    children: [
                      Form(
                        key: _emailFormKey,
                        child: TextFormField(
                          //focusNode: _focusNode,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.prompt(fontSize: 16.0),
                          validator: (value) {
                            Pattern pattern =
                                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                r"{0,253}[a-zA-Z0-9])?)*$";
                            RegExp regex = new RegExp(pattern);
                            if (value == null || value.isEmpty) {
                              return 'กรอกอีเมล';
                            } else if (!regex.hasMatch(value)) {
                              return 'รูปแบบอีเมลไม่ถูกต้อง';
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'อีเมล',
                            errorStyle: GoogleFonts.prompt(fontSize: 12.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          child: Text('OK'),
                          onPressed: () => _handleClickSubmitEmail(),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        });
      },
    ).whenComplete(() {
      print('+++++ BOTTOM SHEET CLOSED COMPLETELY! +++++');
      _watermarkButtonFocusNode.requestFocus();
      Future.delayed(
          Duration(milliseconds: 500), () => _isBottomSheetOpen = false);
      //_isBottomSheetOpen = false;
    });
  }

  _handleClickSubmitEmail() {
    if (_emailFormKey.currentState.validate()) {
      _waitPassCode = true;
      Navigator.of(context).pop();

      Future.delayed(Duration(milliseconds: 400), () {
        _isBottomSheetOpen = false;
        _showBottomSheet();
      });
    }
  }

  _setupTimeout() {
    _passCodeTimeout = 180;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      print('TIMER TICK');
      try {
        _modalSetState(() {
          _passCodeTimeout--;
          if (_passCodeTimeout < 0) {
            _passCode = '';
            _passCodeTimeout = 0;
            _timer.cancel();
            _timer = null;
            setState(() {
              _waitPassCode = false;
            });
          }
        });
      } catch (e) {
        _passCodeTimeout--;
        if (_passCodeTimeout < 0) {
          _passCode = '';
          _passCodeTimeout = 0;
          _timer.cancel();
          _timer = null;
          setState(() {
            _waitPassCode = false;
          });
        }
      }
    });
  }

  String _formatTimeCountDown(int seconds) {
    int m = _passCodeTimeout ~/ 60;
    int s = _passCodeTimeout % 60;
    return '${(m < 10 ? '0' : '') + m.toString()}:${(s < 10 ? '0' : '') + s.toString()}';
  }

  _handleClickPassCodeButton(dynamic item, StateSetter bottomSheetSetState) {
    if (item.runtimeType == int) {
      if (_passCode.length >= 6) return;

      bottomSheetSetState(() {
        _passCode += item.toString();
      });
    } else if (item == 'delete') {
      if (_passCode.length == 0) return;
      bottomSheetSetState(() {
        _passCode = _passCode.substring(0, _passCode.length - 1);
      });
    } else if (item == 'submit') {
      bottomSheetSetState(() {
        _passCode = '';
        _timer.cancel();
        _timer = null;
      });

      Navigator.of(context).pop();
      setState(() {
        _isRegisterWatermark = true;
      });
    }
  }
}
