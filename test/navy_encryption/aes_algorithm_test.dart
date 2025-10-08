import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_test/flutter_test.dart';
import 'package:navy_encrypt/navy_encryption/algorithms/aes.dart';
import 'package:navy_encrypt/navy_encryption/navec.dart';

void main() {
  group('AES algorithm', () {
    const password = 'password123';
    final sampleBytes = Uint8List.fromList(List<int>.generate(64, (i) => i));

    test('uses a random IV for each encryption', () {
      final aes = Aes(keyLengthInBytes: 16);
      final first = aes.encrypt(password, sampleBytes);
      final second = aes.encrypt(password, sampleBytes);

      expect(first, isNot(equals(second)));
      expect(first.length, greaterThan(Aes.ivLength));

      final firstIv = Uint8List.fromList(first.sublist(0, Aes.ivLength));
      final firstCipher = Uint8List.fromList(first.sublist(Aes.ivLength));

      final decrypted = aes.decrypt(password, firstCipher, iv: firstIv);
      expect(decrypted, equals(sampleBytes));
    });

    test('can decrypt legacy payloads that were stored without an IV', () {
      final aes = Aes(keyLengthInBytes: 16);

      String keyText = password.trim();
      while (keyText.length < aes.keyLengthInBytes) {
        keyText = '$keyText${Navec.passwordPadChar}';
      }

      final legacyKey = enc.Key.fromUtf8(keyText);
      final legacyIv = enc.IV.fromLength(Aes.ivLength);
      final legacyEncrypter = enc.Encrypter(enc.AES(legacyKey));
      final legacyEncrypted = legacyEncrypter.encryptBytes(
        sampleBytes,
        iv: legacyIv,
      );

      final decrypted = aes.decrypt(
        password,
        Uint8List.fromList(legacyEncrypted.bytes),
      );

      expect(decrypted, equals(sampleBytes));
    });
  });
}
