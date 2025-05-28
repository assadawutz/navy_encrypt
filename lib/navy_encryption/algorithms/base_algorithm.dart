import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:navy_encrypt/navy_encryption/navec.dart';

abstract class BaseAlgorithm {
  final String code;
  final String text;
  final int keyLengthInBytes;

  const BaseAlgorithm({
    @required this.code,
    @required this.text,
    @required this.keyLengthInBytes,
  });

  /*static List<EncryptionAlgorithm> get list {
    return const [
      const EncryptionAlgorithm(
        code: 'AES128',
        text: 'AES 128',
        keyLengthInBytes: 16,
      ),
      const EncryptionAlgorithm(
        code: 'AES256',
        text: 'AES 256',
        keyLengthInBytes: 32,
      ),
      const EncryptionAlgorithm(
        code: notEncryptCode,
        text: 'ไม่เข้ารหัส',
        keyLengthInBytes: null,
      ),
    ];
  }*/

  @override
  String toString() => 'EncryptionAlgorithm: [$code] $text';

  Uint8List encrypt(String password, Uint8List bytes);

  Uint8List decrypt(String password, Uint8List bytes);
}

class NotEncrypt extends BaseAlgorithm {
  NotEncrypt()
      : super(
            code: Navec.notEncryptCode,
            text: 'ไม่เข้ารหัส',
            keyLengthInBytes: null);

  @override
  Uint8List encrypt(String password, Uint8List bytes) => null;

  @override
  Uint8List decrypt(String password, Uint8List bytes) => null;
}
