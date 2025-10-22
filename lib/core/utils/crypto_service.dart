import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/api.dart' show KeyDerivator, KeyParameter, Pbkdf2Parameters;
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/macs/hmac.dart';

class CryptoService {
  const CryptoService();

  static const _iterations = 150000;
  static const _keyLength = 32;

  Future<CryptoResult> encryptText({
    required String plainText,
    required String password,
  }) async {
    final salt = _randomBytes(16);
    final key = _deriveKey(password, salt);
    final iv = encrypt.IV.fromSecureRandom(16);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(
        encrypt.Key(Uint8List.fromList(key)),
        mode: encrypt.AESMode.cbc,
        padding: 'PKCS7',
      ),
    );

    final cipher = encrypter.encrypt(plainText, iv: iv);
    final mac = _calculateMac(cipher.bytes, key, iv.bytes, salt);

    final payload = {
      'version': 1,
      'cipherText': base64Encode(cipher.bytes),
      'iv': base64Encode(iv.bytes),
      'salt': base64Encode(salt),
      'mac': base64Encode(mac),
      'iterations': _iterations,
    };

    return CryptoResult(
      payload: base64Encode(utf8.encode(jsonEncode(payload))),
      meta: CryptoMetadata(
        salt: base64Encode(salt),
        iterations: _iterations,
      ),
    );
  }

  Future<String> decryptText({
    required String encryptedPayload,
    required String password,
  }) async {
    final decoded = utf8.decode(base64Decode(encryptedPayload));
    final Map<String, dynamic> payload = jsonDecode(decoded);
    final salt = base64Decode(payload['salt'] as String);
    final key = _deriveKey(password, salt);
    final iv = encrypt.IV(base64Decode(payload['iv'] as String));
    final cipherBytes = base64Decode(payload['cipherText'] as String);
    final expectedMac = base64Decode(payload['mac'] as String);
    final calculatedMac = _calculateMac(cipherBytes, key, iv.bytes, salt);

    if (!_constantTimeListEquals(expectedMac, calculatedMac)) {
      throw const CryptoException(
        'Integrity verification failed. Wrong password or payload corrupted.',
      );
    }

    final encrypter = encrypt.Encrypter(
      encrypt.AES(
        encrypt.Key(Uint8List.fromList(key)),
        mode: encrypt.AESMode.cbc,
        padding: 'PKCS7',
      ),
    );
    final encryptedValue = encrypt.Encrypted(cipherBytes);
    return encrypter.decrypt(encryptedValue, iv: iv);
  }

  List<int> _deriveKey(String password, List<int> salt) {
    final params = Pbkdf2Parameters(Uint8List.fromList(salt), _iterations, _keyLength);
    final derivator = KeyDerivator('SHA-256/HMAC/PBKDF2');
    derivator.init(params);
    final key = derivator.process(Uint8List.fromList(utf8.encode(password)));
    return key;
  }

  List<int> _calculateMac(List<int> cipherBytes, List<int> key, List<int> iv, List<int> salt) {
    final hmac = HMac(SHA256Digest(), 64)
      ..init(KeyParameter(Uint8List.fromList(key)));
    hmac.update(iv, 0, iv.length);
    hmac.update(salt, 0, salt.length);
    hmac.update(cipherBytes, 0, cipherBytes.length);
    final out = Uint8List(hmac.macSize);
    hmac.doFinal(out, 0);
    return out;
  }

  List<int> _randomBytes(int length) {
    final secure = Random.secure();
    return List<int>.generate(length, (_) => secure.nextInt(256));
  }

  bool _constantTimeListEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}

class CryptoResult {
  const CryptoResult({required this.payload, required this.meta});

  final String payload;
  final CryptoMetadata meta;
}

class CryptoMetadata {
  const CryptoMetadata({required this.salt, required this.iterations});

  final String salt;
  final int iterations;
}

class CryptoException implements Exception {
  const CryptoException(this.message);

  final String message;

  @override
  String toString() => message;
}
