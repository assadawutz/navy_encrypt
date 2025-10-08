import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:navy_encrypt/navy_encryption/algorithms/base_algorithm.dart';
import 'package:navy_encrypt/navy_encryption/navec.dart';

class Aes extends BaseAlgorithm {
  static const int ivLength = 16;

  Aes({int keyLengthInBytes})
      : super(
            code: 'AES${keyLengthInBytes * 8}',
            text: 'AES ${keyLengthInBytes * 8}',
            keyLengthInBytes: keyLengthInBytes);

  @override
  Uint8List encrypt(String password, Uint8List bytes) {
    final iv = enc.IV.fromSecureRandom(ivLength);
    final encrypted =
        _createEncrypter(password).encryptBytes(bytes, iv: iv).bytes;
    return Uint8List.fromList([...iv.bytes, ...encrypted]);
  }

  @override
  Uint8List decrypt(String password, Uint8List bytes, {Uint8List iv}) {
    if (iv != null && iv.length != ivLength) {
      print('Invalid IV length for AES decryption.');
      return null;
    }

    List<int> decrypted;
    try {
      final usedIv = iv == null
          ? enc.IV.fromLength(ivLength)
          : enc.IV(iv);
      decrypted = _createEncrypter(password)
          .decryptBytes(enc.Encrypted(bytes), iv: usedIv);
    } catch (e) {
      print(e);
    }
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
