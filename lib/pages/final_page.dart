import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navy_encrypt/etc/constants.dart';

class FinalPage extends StatefulWidget {
  final int type;
  final String text;

  FinalPage({@required this.type, @required this.text});

  @override
  _FinalPageState createState() => _FinalPageState();
}

class _FinalPageState extends State<FinalPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.type == 0 ? 'Watermark & Encrypt' : 'Decrypt'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalMargin,
                vertical: Constants.verticalMargin,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 80.0, color: Colors.green),
                  SizedBox(height: 8.0),
                  Text(
                    this.widget.text,
                    style: GoogleFonts.prompt(
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 30.0),
                  if (this.widget.type == 0)
                    Column(
                      children: [
                        TextButton(
                          onPressed: () {},
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
                                Flexible(
                                  child: Text(
                                    'บันทึก',
                                    style: GoogleFonts.prompt(fontSize: 16.0),
                                  ),
                                ),
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
                                    'แชร์',
                                    style: GoogleFonts.prompt(fontSize: 16.0),
                                  ),
                                ),
                                SizedBox(width: 12.0),
                                Icon(Icons.share),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (this.widget.type == 1)
                    Column(
                      children: [
                        TextButton(
                          onPressed: () {},
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
                                Flexible(
                                  child: Text(
                                    'เปิดเอกสาร',
                                    style: GoogleFonts.prompt(fontSize: 16.0),
                                  ),
                                ),
                                SizedBox(width: 12.0),
                                Icon(Icons.insert_drive_file_outlined),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextButton(
                          onPressed: () {},
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
                                Flexible(
                                  child: Text(
                                    'แชร์',
                                    style: GoogleFonts.prompt(fontSize: 16.0),
                                  ),
                                ),
                                SizedBox(width: 12.0),
                                Icon(Icons.share),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
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
                    onPressed: _handleClickBack,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chevron_left),
                          SizedBox(width: 8.0),
                          Text('ย้อนกลับ',
                              style: GoogleFonts.prompt(fontSize: 18.0)),
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

  _handleClickBack() {
    Navigator.pop(context);
  }
}
