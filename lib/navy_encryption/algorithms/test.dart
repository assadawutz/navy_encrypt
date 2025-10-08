import 'dart:typed_data';

import 'package:navy_encrypt/navy_encryption/algorithms/base_algorithm.dart';

class Test extends BaseAlgorithm {
  Test() : super(code: 'TEST', text: 'TEST', keyLengthInBytes: 16);

  @override
  Uint8List encrypt(String password, Uint8List bytes) {
    var list = List<int>.from(bytes);
    return Uint8List.fromList(list.map((byte) {
      return byte == 255 ? 0 : byte + 1;
    }).toList());
  }

  @override
  Uint8List decrypt(String password, Uint8List bytes, {Uint8List iv}) {
    var list = List<int>.from(bytes);
    return Uint8List.fromList(list.map((byte) {
      return byte == 0 ? 255 : byte - 1;
    }).toList());
  }
}
