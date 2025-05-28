import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:navy_encrypt/etc/utils.dart';
import 'package:path_provider/path_provider.dart';

class TestEncryption extends StatefulWidget {
  @override
  _TestEncryptionState createState() => _TestEncryptionState();
}

class _TestEncryptionState extends State<TestEncryption> {
  Future<File> _createFileInTempDir() async {
    final file = await getTempFile('120m.txt');

    // Write the file.
    return file.writeAsString(getTextOfSize(120000000));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        title: Text('Test Encryption & Decryption'),
        //centerTitle: true,
      ),
      body: Container(
        color: Colors.yellowAccent[100],
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MyButton(
              text: 'CREATE FILE IN TEMP DIR',
              onClick: _createFileInTempDir,
            ),
            SizedBox(
              height: 16.0,
            ),
            MyButton(
              text: 'ENCRYPT',
              onClick: () async {
                File inFile = await getTempFile('120m.txt');
                Uint8List bytes = inFile.readAsBytesSync();
                print(bytes.length);
                enc.Encrypted encryptedData = encrypt(bytes);
                File outFile = await getTempFile('120m.navec');
                outFile.writeAsBytes(encryptedData.bytes);
              },
            ),
            SizedBox(
              height: 16.0,
            ),
            MyButton(
              text: 'DECRYPT',
              onClick: () async {
                try {
                  File inFile = await getTempFile('120m.navec');
                  Uint8List bytes = inFile.readAsBytesSync();
                  print(bytes.length);
                  Uint8List decryptedData = decrypt(bytes);
                  File outFile = await getTempFile('120m.navdc');
                  outFile.writeAsBytes(decryptedData);
                } on OutOfMemoryError catch(e) {
                  showOkDialog(context, 'ERROR', textContent: 'หน่วยความจำไม่พอ (Out of Memory)');
                } catch (e) {
                  showOkDialog(context, 'ERROR', textContent: e.toString());
                }
              },
            ),
            Text('hahaha'),
          ],
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  MyButton({
    @required this.text,
    this.onClick,
    this.textColor = Colors.white,
    this.backgroundColor,
  });

  final String text;
  final Color textColor;
  final Color backgroundColor;
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onClick != null ? onClick() : null,
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(14.0),
        primary: textColor,
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        //onSurface: Colors.grey,
      ),
      child: Text(text),
    );
  }
}

Future<String> getTempDir() async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> getTempFile(String name) async {
  final path = await getTempDir();
  return File('$path/$name');
}

const dot10 = '..........';
const dot100 = dot10 + dot10 + dot10 + dot10 + dot10 + dot10 + dot10 + dot10 + dot10 + dot10;
const dot1000 =
    dot100 + dot100 + dot100 + dot100 + dot100 + dot100 + dot100 + dot100 + dot100 + dot100;
const dot10000 = dot1000 +
    dot1000 +
    dot1000 +
    dot1000 +
    dot1000 +
    dot1000 +
    dot1000 +
    dot1000 +
    dot1000 +
    dot1000;
const dot100000 = dot10000 +
    dot10000 +
    dot10000 +
    dot10000 +
    dot10000 +
    dot10000 +
    dot10000 +
    dot10000 +
    dot10000 +
    dot10000;
const dot1000000 = dot100000 +
    dot100000 +
    dot100000 +
    dot100000 +
    dot100000 +
    dot100000 +
    dot100000 +
    dot100000 +
    dot100000 +
    dot100000;

String getTextOfSize(int size) {
  String temp = '';
  for (var i = 0; i < size / 1000000; i++) {
    temp += dot1000000;
  }
  return temp;
}

enc.Encrypted encrypt(Uint8List bytes) {
  var formatter = NumberFormat('#,###,000');

  //final key = enc.Key.fromUtf8('my 32 length key................');
  final key = enc.Key.fromUtf8('my 16 length key');
  print(
      'The length of key is ${key.bytes.length} bytes (${key.bytes.length * 8} bits - AES ${key.bytes.length * 8})');
  final iv = enc.IV.fromLength(16);
  //print('IV is ${iv.base64}');

  final encrypter = enc.Encrypter(enc.AES(key));

  int start = DateTime.now().millisecondsSinceEpoch;
  //final encrypted = encrypter.encrypt(plainText, iv: iv);
  final enc.Encrypted encryptedByte = encrypter.encryptBytes(bytes, iv: iv);
  print('The size of encrypted data is ${formatter.format(encryptedByte.bytes.length)} bytes');
  print('Encryption time: ${(DateTime.now().millisecondsSinceEpoch - start) / 1000} seconds');

  return encryptedByte;
}

Uint8List decrypt(Uint8List bytes) {
  var formatter = NumberFormat('#,###,000');

  //final key = enc.Key.fromUtf8('my 32 length key................');
  final key = enc.Key.fromUtf8('my 16 length key');
  print(
      'The length of key is ${key.bytes.length} bytes (${key.bytes.length * 8} bits - AES ${key.bytes.length * 8})');
  final iv = enc.IV.fromLength(16);
  //print('IV is ${iv.base64}');

  final encrypter = enc.Encrypter(enc.AES(key));

  int start = DateTime.now().millisecondsSinceEpoch;

  final decrypted = encrypter.decryptBytes(enc.Encrypted(bytes), iv: iv);
  //final decryptedByte = encrypter.decryptBytes(encryptedByte, iv: iv);
  print('Decryption time: ${(DateTime.now().millisecondsSinceEpoch - start) / 1000} seconds');
  return Uint8List.fromList(decrypted);
}

void _testEncryption() {
  var formatter = NumberFormat('#,###,000');

  //final key = enc.Key.fromUtf8('my 32 length key................');
  final key = enc.Key.fromUtf8('my 16 length key');
  print(
      'The length of key is ${key.bytes.length} bytes (${key.bytes.length * 8} bits - AES ${key.bytes.length * 8})');
  final iv = enc.IV.fromLength(16);
  //print('IV is ${iv.base64}');

  final encrypter = enc.Encrypter(enc.AES(key));

  String plainText = getTextOfSize(10000000);
  /*for (var i = 0; i < 23; i++) {
      plainText += plainText;
    }*/
  print('The size of data is ${formatter.format(plainText.length)} bytes');
  //List<int> bytes = utf8.encode(plainText);
  //print('The length of plainText is ${formatter.format(bytes.length)} bytes');
  //return;

  int start = DateTime.now().millisecondsSinceEpoch;
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  //final enc.Encrypted encryptedByte = encrypter.encryptBytes(bytes, iv: iv);
  print('The size of encrypted data is ${formatter.format(encrypted.bytes.length)} bytes');
  print('Encryption time: ${(DateTime.now().millisecondsSinceEpoch - start) / 1000} seconds');

  start = DateTime.now().millisecondsSinceEpoch;
  final decrypted = encrypter.decrypt(encrypted, iv: iv);
  //final decryptedByte = encrypter.decryptBytes(encryptedByte, iv: iv);
  print('Decryption time: ${(DateTime.now().millisecondsSinceEpoch - start) / 1000} seconds');

  //print(decrypted);
  //print(encrypted.base64);
  //print(decryptedByte);
  //print(encryptedByte.base64);
  print('-------------------------------------------');
}
