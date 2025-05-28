import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:navy_encrypt/navy_encryption/algorithms/base_algorithm.dart';
import 'package:navy_encrypt/navy_encryption/navec.dart';

class Aes extends BaseAlgorithm {
  final iv = enc.IV.fromLength(16);

  Aes({int keyLengthInBytes})
      : super(
            code: 'AES${keyLengthInBytes * 8}',
            text: 'AES ${keyLengthInBytes * 8}',
            keyLengthInBytes: keyLengthInBytes);

  @override
  Uint8List encrypt(String password, Uint8List bytes) {
    var encrypted = _createEncrypter(password).encryptBytes(bytes, iv: iv);
    return encrypted.bytes;
  }

  @override
  Uint8List decrypt(String password, Uint8List bytes) {
    var decrypted;
    try {
      decrypted =
          _createEncrypter(password).decryptBytes(enc.Encrypted(bytes), iv: iv);
    } catch (e) {
      print(e);
    } finally {}
    return decrypted == null ? null : Uint8List.fromList(decrypted);
  }

  enc.Encrypter _createEncrypter(String password) {
    String textKey = password.trim();
    while (textKey.length < keyLengthInBytes) {
      textKey = '$textKey${Navec.passwordPadChar}';
    }
    final key = enc.Key.fromUtf8(textKey);
    return enc.Encrypter(enc.AES(key));
  }
}
