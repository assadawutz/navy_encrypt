import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navy_encrypt/etc/file_util.dart';
import 'package:navy_encrypt/navy_encryption/algorithms/aes.dart';
import 'package:navy_encrypt/navy_encryption/navec.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProviderPlatform(this._tempDirPath);

  final String _tempDirPath;

  @override
  Future<String> getTemporaryPath() async => _tempDirPath;

  @override
  Future<String> getApplicationDocumentsPath() async => _tempDirPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Navec decrypt flow', () {
    const password = 'password123';
    final originalBytes =
        Uint8List.fromList(List<int>.generate(48, (index) => index));
    const uuid = '12345678-1234-1234-1234-123456789012';
    const originalExtension = '2data';

    setUp(() async {
      final tempDir = await Directory.systemTemp.createTemp('navec_test_');
      final previousPlatform = PathProviderPlatform.instance;
      PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
      addTearDown(() async {
        PathProviderPlatform.instance = previousPlatform;
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });
    });

    testWidgets('decrypts legacy layout files whose extension starts with 2',
        (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      await tester.runAsync(() async {
        final aes = Aes(keyLengthInBytes: 16);
        String legacyKeyText = password.trim();
        while (legacyKeyText.length < aes.keyLengthInBytes) {
          legacyKeyText = '$legacyKeyText${Navec.passwordPadChar}';
        }
        final legacyKey = enc.Key.fromUtf8(legacyKeyText);
        final legacyIv = enc.IV.fromLength(Aes.ivLength);
        final legacyEncrypter = enc.Encrypter(enc.AES(legacyKey));
        final legacyEncrypted = legacyEncrypter.encryptBytes(
          originalBytes,
          iv: legacyIv,
        );

        final extensionField = originalExtension
            .padRight(Navec.headerFileExtensionFieldLength);
        final algoField = 'AES128'.padRight(Navec.headerAlgorithmFieldLength);

        final payloadBytes = <int>[
          ...utf8.encode(Navec.headerFileSignature),
          ...utf8.encode(extensionField),
          ...utf8.encode(algoField),
          ...legacyEncrypted.bytes,
          ...utf8.encode(uuid),
        ];

        final encryptedFile = await FileUtil.createFileFromBytes(
          'legacy.enc',
          Uint8List.fromList(payloadBytes),
        );

        final result = await Navec.decryptFile(
          context: capturedContext,
          filePath: encryptedFile.path,
          password: password,
        );

        expect(result, isNotNull);
        expect(result.length, 2);

        final File decryptedFile = result.first as File;
        final String decryptedUuid = result.last as String;

        expect(decryptedUuid, uuid);
        expect(await decryptedFile.readAsBytes(), originalBytes);
        expect(p.extension(decryptedFile.path), '.${originalExtension.trim()}');
      });
    });
  });
}
