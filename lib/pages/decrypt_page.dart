import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navy_encrypt/etc/constants.dart';
import 'package:page_transition/page_transition.dart';

import 'final_page.dart';

class DecryptPage extends StatefulWidget {
  @override
  _DecryptPageState createState() => _DecryptPageState();
}

class _DecryptPageState extends State<DecryptPage> {
  final _formKey = GlobalKey<FormState>();
  final _decryptPasswordController = TextEditingController();
  bool _decryptPasswordVisible = false;
  FocusNode _focusNode;

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
        title: Text('Decrypt'),
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
                      onTap: () {},
                      child: Icon(Icons.lock_open_outlined,
                          size: 80.0, color: Constants.primaryColor),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(
                        top: 16.0,
                        bottom: 8.0,
                      ),
                      child: Text('ถอดรหัส',
                          style: GoogleFonts.prompt(
                            fontSize: 20.0,
                          )),
                    ),
                    TextFormField(
                      focusNode: _focusNode,
                      controller: _decryptPasswordController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      style: GoogleFonts.prompt(fontSize: 16.0),
                      obscureText: !_decryptPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรอกรหัสผ่าน';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'กรอกรหัสผ่าน',
                        labelStyle: GoogleFonts.prompt(fontSize: 16.0),
                        errorStyle: GoogleFonts.prompt(fontSize: 14.0),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 10, 15),
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _decryptPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Constants.accentColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _decryptPasswordVisible =
                                  !_decryptPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
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
                          Text('ดำเนินการถอดรหัส',
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
    _focusNode.unfocus();

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftJoined,
        childCurrent: DecryptPage(),
        child: FinalPage(
          type: 1,
          text: 'ถอดรหัสสำเร็จ',
        ),
      ),
      /*MaterialPageRoute(
        builder: (context) => FinalPage(
          type: 1,
          text: 'ถอดรหัสสำเร็จ',
        ),
      ),*/
    );
  }
}
