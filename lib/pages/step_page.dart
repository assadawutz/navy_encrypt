import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:navy_encrypt/etc/constants.dart';
import 'package:navy_encrypt/etc/utils.dart';
import 'package:navy_encrypt/pages/encrypt_page.dart';

class StepPage extends StatefulWidget {
  @override
  _StepPageState createState() => _StepPageState();
}

class _StepPageState extends State<StepPage> {
  int _currentStep = 0;
  bool _doWatermark = false;
  bool _doEncrypt = false;
  StepperType stepperType = StepperType.horizontal;

  final _watermarkFormKey = GlobalKey<FormState>();
  final _encryptFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();

  //final TextEditingController _watermarkPrivateKeyController = TextEditingController();
  final TextEditingController _watermarkTextController =
      TextEditingController();
  final TextEditingController _encryptPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  int _encryptAlgorithmValue;

  //bool _watermarkPrivateKeyVisible = false;
  bool _encryptPasswordVisible = false;
  FocusNode _focusNode;

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
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        title: Text('Watermark & Encrypt'),
        //centerTitle: true,
      ),
      body: Container(
        color: Colors.lightBlueAccent[50],
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                type: stepperType,
                //physics: ClampingScrollPhysics(),
                currentStep: _currentStep,
                onStepTapped: (step) => tapped(step),
                onStepContinue: continued,
                onStepCancel: cancel,
                // controlsBuilder: (
                //   BuildContext context, {
                //   VoidCallback onStepContinue,
                //   VoidCallback onStepCancel,
                // }) {
                //   return SizedBox.shrink();
                // },
                steps: <Step>[
                  /*Step 0*/
                  Step(
                    title: Text(
                      'ใส่ลายน้ำ',
                      style: GoogleFonts.prompt(
                        fontSize: 16.0,
                        /*color: _currentStep == 0
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.bodyText1.color.withOpacity(0.3),*/
                      ),
                    ),
                    content: Column(
                      children: <Widget>[
                        _buildStepTitle('ใส่ลายน้ำ', 0),
                        if (!_isRegisterWatermark)
                          TextButton(
                            onPressed: () {
                              //_focusNode.requestFocus();
                              _showBottomSheet();
                              return;

                              showOkDialog(
                                context,
                                'กรอกอีเมลของคุณ',
                                content: Form(
                                  key: _emailFormKey,
                                  child: TextFormField(
                                    focusNode: _focusNode,
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: GoogleFonts.prompt(fontSize: 16.0),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'กรอกอีเมล';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'อีเมล',
                                      errorStyle:
                                          GoogleFonts.prompt(fontSize: 12.0),
                                    ),
                                  ),
                                ),
                                onClickOk: () {
                                  return _emailFormKey.currentState.validate();
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Theme.of(context).primaryColor,
                              //onSurface: Colors.grey,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('ลงทะเบียนเพื่อใช้งานระบบลายน้ำ',
                                      style:
                                          GoogleFonts.prompt(fontSize: 16.0)),
                                  SizedBox(width: 12.0),
                                  Icon(Icons.edit),
                                ],
                              ),
                            ),
                          ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EncryptPage()),
                            );
                          },
                          child: Text('TEST'),
                        ),
                        if (_isRegisterWatermark)
                          Container(
                            color: _doWatermark
                                ? Colors.transparent
                                : Colors.grey[200],
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Form(
                              key: _watermarkFormKey,
                              child: Column(
                                children: <Widget>[
                                  /*TextFormField(
                                    enabled: _doWatermark,
                                    controller: _watermarkPrivateKeyController,
                                    style: GoogleFonts.prompt(fontSize: 16.0),
                                    obscureText: !_watermarkPrivateKeyVisible,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'กรอก Private Key';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Private Key ของคุณ',
                                      errorStyle: GoogleFonts.prompt(fontSize: 12.0),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          _watermarkPrivateKeyVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: _doWatermark ? accentColor : Colors.grey[400],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _watermarkPrivateKeyVisible =
                                                !_watermarkPrivateKeyVisible;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 12.0,
                                  ),*/
                                  TextFormField(
                                    enabled: _doWatermark,
                                    controller: _watermarkTextController,
                                    style: GoogleFonts.prompt(fontSize: 16.0),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'กรอกข้อความลายน้ำ';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText:
                                          'ข้อความที่ต้องการใส่เป็นลายน้ำ',
                                      errorStyle:
                                          GoogleFonts.prompt(fontSize: 12.0),
                                    ),
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 36.0,
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                    // _currentStep == 0 || (_currentStep >= 0 && _doWatermark),
                    state: _getStepState(0),
                  ),

                  /*Step 1*/
                  Step(
                    title: Text(
                      'เข้ารหัส',
                      style: GoogleFonts.prompt(
                        fontSize: 16.0,
                        /*color: _currentStep == 1
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.bodyText1.color.withOpacity(0.3),*/
                      ),
                    ),
                    content: Column(
                      children: <Widget>[
                        _buildStepTitle('เข้ารหัส', 1),
                        Container(
                          color: _doEncrypt
                              ? Colors.transparent
                              : Colors.grey[200],
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Form(
                            key: _encryptFormKey,
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  enabled: _doEncrypt,
                                  controller: _encryptPasswordController,
                                  style: GoogleFonts.prompt(fontSize: 16.0),
                                  obscureText: !_encryptPasswordVisible,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'กรอกรหัสผ่าน';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'กำหนดรหัสผ่านที่ต้องการ',
                                    errorStyle:
                                        GoogleFonts.prompt(fontSize: 12.0),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        // Based on passwordVisible state choose the icon
                                        _encryptPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: _doEncrypt
                                            ? Constants.accentColor
                                            : Colors.grey[400],
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
                                SizedBox(
                                  height: 12.0,
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
                                    labelStyle:
                                        GoogleFonts.prompt(fontSize: 16.0),
                                    errorStyle:
                                        GoogleFonts.prompt(fontSize: 12.0),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      child: Text(
                                        "AES 128",
                                        style: GoogleFonts.prompt(
                                            fontSize: 16.0,
                                            color: Colors.black),
                                      ),
                                      value: 1,
                                    ),
                                    DropdownMenuItem(
                                      child: Text(
                                        "AES 192",
                                        style: GoogleFonts.prompt(
                                            fontSize: 16.0,
                                            color: Colors.black),
                                      ),
                                      value: 2,
                                    ),
                                    DropdownMenuItem(
                                      child: Text(
                                        "AES 256",
                                        style: GoogleFonts.prompt(
                                            fontSize: 16.0,
                                            color: Colors.black),
                                      ),
                                      value: 3,
                                    ),
                                  ],
                                  onChanged: _doEncrypt
                                      ? (value) {
                                          setState(() {
                                            _encryptAlgorithmValue = value;
                                          });
                                        }
                                      : null,
                                  onTap: () {
                                    print('TAP');
                                    _focusNode.requestFocus();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 1,
                    state: _getStepState(1),
                  ),

                  /*Step 2*/
                  Step(
                    title: Text(
                      'บันทึก/ส่ง',
                      style: GoogleFonts.prompt(
                        fontSize: 16.0,
                        /*color: _currentStep == 2
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.bodyText1.color.withOpacity(0.3),*/
                      ),
                    ),
                    content: Column(
                      children: <Widget>[
                        _buildStepTitle('บันทึก/ส่ง', 2),
                        Container(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Column(
                            children: <Widget>[
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  //onSurface: Colors.grey,
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('บันทึก',
                                          style: GoogleFonts.prompt(
                                              fontSize: 16.0)),
                                      SizedBox(width: 12.0),
                                      Icon(Icons.save),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  //onSurface: Colors.grey,
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('ส่ง',
                                          style: GoogleFonts.prompt(
                                              fontSize: 16.0)),
                                      SizedBox(width: 12.0),
                                      Icon(Icons.share),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    isActive: _currentStep >= 2,
                    state: _getStepState(2),
                  ),
                ],
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
                      onPressed: _currentStep > 0
                          ? () {
                              setState(() {
                                _currentStep--;
                              });
                            }
                          : null,
                      /*style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Theme.of(context).primaryColor,
                        //onClickPrevious != null ? Theme.of(context).primaryColor : Colors.grey[200],
                        //onSurface: Colors.grey,
                      ),*/
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chevron_left),
                            Text(' ก่อนหน้า ',
                                style: GoogleFonts.prompt(fontSize: 16.0)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1.0,
                    height: 30.0,
                    color: Colors.grey[400],
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: _currentStep < 2
                          ? () {
                              if (_currentStep == 0) {
                                if (!_doWatermark) {
                                  setState(() {
                                    _currentStep++;
                                  });
                                } else {
                                  if (_watermarkFormKey.currentState
                                      .validate()) {
                                    setState(() {
                                      _currentStep++;
                                    });
                                  } else {
                                    //showOkDialog(context, 'ผิดพลาด');
                                  }
                                }
                              } else if (_currentStep == 1) {
                                if (!_doWatermark && !_doEncrypt) {
                                  showOkDialog(
                                    context,
                                    'ผิดพลาด',
                                    textContent:
                                        'ไม่ได้เลือกใส่ลายน้ำ และไม่ได้เลือกเข้ารหัส\nต้องเลือกใส่ลายน้ำหรือเข้ารหัส อย่างน้อย 1 ตัวเลือก',
                                  );
                                } else if (!_doEncrypt) {
                                  setState(() {
                                    _currentStep++;
                                  });
                                } else {
                                  if (_encryptFormKey.currentState.validate()) {
                                    setState(() {
                                      _currentStep++;
                                    });
                                  } else {
                                    //showOkDialog(context, 'ผิดพลาด');
                                  }
                                }
                              }
                            }
                          : null,
                      /*style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Theme.of(context).primaryColor,
                        //onClickPrevious != null ? Theme.of(context).primaryColor : Colors.grey[200],
                        //onSurface: Colors.grey,
                      ),*/
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(' ถัดไป ',
                                style: GoogleFonts.prompt(fontSize: 16.0)),
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
      ),
      /*floatingActionButton: FloatingActionButton(
        child: Icon(Icons.list),
        onPressed: switchStepsType,
      ),*/
    );
  }

  StepState _getStepState(int step) {
    if (_currentStep == step) {
      return StepState.editing;
    } else if (_currentStep > step) {
      bool temp = step == 0 ? _doWatermark : _doEncrypt;
      return temp ? StepState.complete : StepState.indexed;
    } else {
      return StepState.disabled;
    }
  }

  Padding _buildStepTitle(String text, int step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            width: 30.0,
            height: 50.0,
            child: step < 2
                ? Checkbox(
                    value: step == 0 ? _doWatermark : _doEncrypt,
                    onChanged: (bool newValue) {
                      if (step == 0) {
                        setState(() {
                          _doWatermark = newValue;
                        });
                      } else {
                        setState(() {
                          _doEncrypt = newValue;
                        });
                      }
                    },
                  )
                : SizedBox.shrink(),
          ),
          Text(
            '${step + 1}. $text',
            style: GoogleFonts.prompt(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            width: 30.0,
          ),
        ],
      ),
    );
  }

  switchStepsType() {
    return;
    setState(() => stepperType == StepperType.vertical
        ? stepperType = StepperType.horizontal
        : stepperType = StepperType.vertical);
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    _currentStep < 2 ? setState(() => _currentStep += 1) : null;
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
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
                                  onPressed: ((item == 'submit' &&
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
                          focusNode: _focusNode,
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

class StepperControls extends StatelessWidget {
  StepperControls({
    this.onClickNext,
    this.onClickPrevious,
    this.onClickSkip,
  });

  final Function onClickNext;
  final Function onClickPrevious;
  final Function onClickSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 40.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(
              onPressed: onClickPrevious != null
                  ? () {
                      onClickPrevious();
                    }
                  : null,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: onClickPrevious != null
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                //onSurface: Colors.grey,
              ),
              child: Row(
                children: [
                  Icon(Icons.chevron_left),
                  Text(' ก่อนหน้า ', style: GoogleFonts.prompt(fontSize: 16.0)),
                ],
              ),
            ),
            TextButton(
              onPressed: onClickNext != null
                  ? () {
                      onClickNext();
                    }
                  : null,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: onClickNext != null
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                //onSurface: Colors.grey,
              ),
              child: Row(
                children: [
                  Text(' ถัดไป ', style: GoogleFonts.prompt(fontSize: 16.0)),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 12.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox.shrink(),
            onClickSkip != null
                ? TextButton(
                    onPressed: () {
                      onClickSkip();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orangeAccent,
                      //onSurface: Colors.grey,
                    ),
                    child: Row(
                      children: [
                        Text(' ข้าม ',
                            style: GoogleFonts.prompt(fontSize: 16.0)),
                        Icon(Icons.remove_circle),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}
