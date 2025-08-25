import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:navy_encrypt/etc/constants.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _privateKeyFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _privateKeyController = TextEditingController();

  static bool _isRegisterWatermark = false;
  bool _waitPassCode = false;
  bool _isBottomSheetOpen = false;
  int _passCodeTimeout;
  Timer _timer;
  StateSetter _modalSetState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
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
                    _isRegisterWatermark = false;
                    _waitPassCode = false;
                  });
                },
                child: Icon(Icons.settings,
                    size: 80.0, color: Constants.primaryColor),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                  top: 16.0,
                  bottom: 8.0,
                ),
                child: Text('ระบบลายน้ำ',
                    style: GoogleFonts.prompt(
                      fontSize: 20.0,
                    )),
              ),
              if (_isRegisterWatermark)
                Container(
                  //alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    bottom: 8.0,
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 8.0),
                      Text(
                        'เปิดใช้งานระบบลายน้ำบนอุปกรณ์นี้แล้ว',
                        style: GoogleFonts.prompt(
                            fontSize: 14.0, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              if (!_isRegisterWatermark && !_waitPassCode)
                Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        _showBottomSheet();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Theme.of(context).primaryColor,
                        //onSurface: Colors.grey,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'ขอคีย์ สำหรับการใช้งานระบบลายน้ำ',
                                  style: GoogleFonts.prompt(fontSize: 16.0),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Icon(Icons.vpn_key),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    TextButton(
                      onPressed: () {
                        _showBottomSheet();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Theme.of(context).primaryColor,
                        //onSurface: Colors.grey,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'กรอกคีย์ (กรณีมีคีย์แล้ว)',
                                  style: GoogleFonts.prompt(fontSize: 16.0),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Icon(Icons.vpn_key),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              if (_waitPassCode)
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        bottom: 8.0,
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: Text(
                        'กรอกคีย์ (Private Key) ที่ได้รับทางอีเมล เพื่อเปิดใช้งานระบบลายน้ำบนอุปกรณ์นี้',
                        style: GoogleFonts.prompt(
                            fontSize: 14.0, color: Colors.redAccent),
                      ),
                    ),
                    Form(
                      key: _privateKeyFormKey,
                      child: TextFormField(
                        //focusNode: _focusNode,
                        controller: _privateKeyController,
                        keyboardType: TextInputType.text,
                        style: GoogleFonts.prompt(fontSize: 16.0),
                        decoration: InputDecoration(
                          labelText: 'คีย์',
                          labelStyle: GoogleFonts.prompt(fontSize: 16.0),
                          errorStyle: GoogleFonts.prompt(fontSize: 14.0),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.fromLTRB(20, 15, 10, 15),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(height: 0.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () => _handleClickCancelPrivateKey(),
                        ),
                        TextButton(
                          child: Text('OK'),
                          onPressed: () => _handleClickSubmitPrivateKey(),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
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

          /*if (_waitPassCode && _timer == null) {
            _setupTimeout();
          }*/

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
                  'กรอกอีเมลของคุณ',
                  style: GoogleFonts.prompt(
                    fontSize: 16.0,
                  ),
                ),
                if (_waitPassCode)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 24.0),
                      SizedBox(height: 24.0),
                      SizedBox(height: 24.0),
                      if (_timer.isActive)
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
      //_watermarkButtonFocusNode.requestFocus();
      Future.delayed(
          Duration(milliseconds: 500), () => _isBottomSheetOpen = false);
      //_isBottomSheetOpen = false;
    });
  }

  _handleClickSubmitEmail() {
    if (_emailFormKey.currentState.validate()) {
      setState(() {
        _waitPassCode = true;
        Navigator.of(context).pop();
      });

      /*Future.delayed(Duration(milliseconds: 400), () {
        _isBottomSheetOpen = false;
        _showBottomSheet();
      });*/
    }
  }

  _handleClickSubmitPrivateKey() {
    setState(() {
      _isRegisterWatermark = true;
      _waitPassCode = false;
    });
  }

  _handleClickCancelPrivateKey() {
    setState(() {
      _isRegisterWatermark = false;
      _waitPassCode = false;
    });
  }

  /*_setupTimeout() {
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
  }*/

  String _formatTimeCountDown(int seconds) {
    int m = _passCodeTimeout ~/ 60;
    int s = _passCodeTimeout % 60;
    return '${(m < 10 ? '0' : '') + m.toString()}:${(s < 10 ? '0' : '') + s.toString()}';
  }
}
