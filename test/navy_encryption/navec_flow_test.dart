import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navy_encrypt/navy_encryption/algorithms/aes.dart';
import 'package:navy_encrypt/navy_encryption/navec.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this._tempDir);

  final Directory _tempDir;

  @override
  Future<String> getTemporaryPath() async => _tempDir.path;

  @override
  Future<String> getApplicationDocumentsPath() async => _tempDir.path;

  @override
  Future<String> getApplicationSupportPath() async => _tempDir.path;

  @override
  Future<String> getLibraryPath() async => _tempDir.path;

  @override
  Future<String> getApplicationCachePath() async => _tempDir.path;

  @override
  Future<String> getExternalStoragePath() async => _tempDir.path;

  @override
  Future<List<String>> getExternalCachePaths() async => <String>[_tempDir.path];

  @override
  Future<List<String>> getExternalStoragePaths({StorageDirectory type}) async =>
      <String>[_tempDir.path];

  @override
  Future<String> getDownloadsPath() async => _tempDir.path;
}

Future<BuildContext> _pumpTestContext(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) {
        return const SizedBox.shrink();
      },
    ),
  ));

  return tester.element(find.byType(SizedBox));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Directory tempRoot;
  PathProviderPlatform originalPlatform;

  setUpAll(() async {
    tempRoot = await Directory.systemTemp.createTemp('navec_flow_test');
    originalPlatform = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempRoot);
  });

  tearDownAll(() async {
    PathProviderPlatform.instance = originalPlatform;
    if (tempRoot != null && await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  testWidgets('encryptFile embeds metadata and decryptFile restores content',
      (tester) async {
    const password = 'correct horse battery staple';
    const uuid = '00000000-0000-0000-0000-000000000001';

    final BuildContext context = await _pumpTestContext(tester);

    final plainBytes = Uint8List.fromList(utf8.encode('Sensitive payload'));
    final sourceFile = await File(p.join(tempRoot.path, 'sample.txt'))
        .writeAsBytes(plainBytes, flush: true);

    final algo = Navec.algorithms.firstWhere((item) => item.code == 'AES256');
    final encryptedFile = await Navec.encryptFile(
      filePath: sourceFile.path,
      password: password,
      algo: algo,
      uuid: uuid,
    );

    addTearDown(() async {
      if (await encryptedFile.exists()) {
        await encryptedFile.delete();
      }
      if (await sourceFile.exists()) {
        await sourceFile.delete();
      }
    });

    expect(p.extension(encryptedFile.path), '.${Navec.encryptedFileExtension}');

    final encryptedBytes = await encryptedFile.readAsBytes();
    expect(
      utf8.decode(
        encryptedBytes.sublist(0, Navec.headerFileSignature.length),
      ),
      Navec.headerFileSignature,
    );

    final versionOffset = Navec.headerFileSignature.length;
    expect(
      utf8.decode(
        encryptedBytes.sublist(
          versionOffset,
          versionOffset + Navec.headerVersion.length,
        ),
      ),
      Navec.headerVersion,
    );

    final ivOffset = versionOffset +
        Navec.headerVersion.length +
        Navec.headerFileExtensionFieldLength +
        Navec.headerAlgorithmFieldLength;
    final ivBytes = encryptedBytes.sublist(ivOffset, ivOffset + Aes.ivLength);
    expect(ivBytes.length, Aes.ivLength);

    final uuidBytes = utf8.encode(uuid);
    final uuidSlice = encryptedBytes.sublist(
      encryptedBytes.length - uuidBytes.length,
    );
    expect(utf8.decode(uuidSlice), uuid);

    final result = await Navec.decryptFile(
      context: context,
      filePath: encryptedFile.path,
      password: password,
    );

    expect(result, isNotNull);
    final File outputFile = result[0] as File;
    addTearDown(() async {
      if (await outputFile.exists()) {
        await outputFile.delete();
      }
    });
    final String recoveredUuid = result[1] as String;

    expect(recoveredUuid, uuid);
    final outputBytes = await outputFile.readAsBytes();
    expect(outputBytes, plainBytes);
  });

  testWidgets('encryptFile randomizes IV for subsequent AES operations',
      (tester) async {
    const password = 'correct horse battery staple';
    const uuid = '00000000-0000-0000-0000-000000000002';

    final BuildContext context = await _pumpTestContext(tester);

    final plainBytes = Uint8List.fromList(utf8.encode('Sensitive payload'));
    final sourceFile = await File(p.join(tempRoot.path, 'sample_iv.txt'))
        .writeAsBytes(plainBytes, flush: true);
    addTearDown(() async {
      if (await sourceFile.exists()) {
        await sourceFile.delete();
      }
    });

    final algo = Navec.algorithms.firstWhere((item) => item.code == 'AES256');

    final encryptedFileFirst = await Navec.encryptFile(
      filePath: sourceFile.path,
      password: password,
      algo: algo,
      uuid: uuid,
    );
    final firstBytes = await encryptedFileFirst.readAsBytes();

    final encryptedFileSecond = await Navec.encryptFile(
      filePath: sourceFile.path,
      password: password,
      algo: algo,
      uuid: uuid,
    );
    addTearDown(() async {
      if (await encryptedFileSecond.exists()) {
        await encryptedFileSecond.delete();
      }
    });
    final secondBytes = await encryptedFileSecond.readAsBytes();

    expect(firstBytes, isNot(secondBytes));

    final ivOffset = Navec.headerFileSignature.length +
        Navec.headerVersion.length +
        Navec.headerFileExtensionFieldLength +
        Navec.headerAlgorithmFieldLength;

    final firstIv = firstBytes.sublist(ivOffset, ivOffset + Aes.ivLength);
    final secondIv = secondBytes.sublist(ivOffset, ivOffset + Aes.ivLength);
    expect(firstIv, isNot(secondIv));

    // Ensure the latest encrypted artifact still decrypts successfully.
    final result = await Navec.decryptFile(
      context: context,
      filePath: encryptedFileSecond.path,
      password: password,
    );
    final File outputFile = result[0] as File;
    addTearDown(() async {
      if (await outputFile.exists()) {
        await outputFile.delete();
      }
    });
    final outputBytes = await outputFile.readAsBytes();
    expect(outputBytes, plainBytes);
  });

  testWidgets('decryptFile supports legacy AES payloads without version info',
      (tester) async {
    const password = 'correct horse battery staple';
    const uuid = '00000000-0000-0000-0000-000000000003';

    final BuildContext context = await _pumpTestContext(tester);

    final plainBytes = Uint8List.fromList(utf8.encode('Legacy payload'));
    final sourceFile = await File(p.join(tempRoot.path, 'legacy.txt'))
        .writeAsBytes(plainBytes, flush: true);

    final aesAlgo =
        Navec.algorithms.firstWhere((item) => item.code == 'AES256') as Aes;

    String textKey = password.trim();
    while (textKey.length < aesAlgo.keyLengthInBytes) {
      textKey = '$textKey${Navec.passwordPadChar}';
    }
    final key = enc.Key.fromUtf8(textKey);
    final encrypter = enc.Encrypter(enc.AES(key));
    final zeroIv = enc.IV.fromLength(Aes.ivLength);
    final legacyCipher =
        encrypter.encryptBytes(plainBytes, iv: zeroIv).bytes; // CBC default

    final headerBytes = <int>[
      ...utf8.encode(Navec.headerFileSignature),
      ...utf8
          .encode(p.extension(sourceFile.path).substring(1).padRight(Navec.headerFileExtensionFieldLength)),
      ...utf8.encode(aesAlgo.code.padRight(Navec.headerAlgorithmFieldLength)),
      ...legacyCipher,
      ...utf8.encode(uuid),
    ];

    final legacyFile = await File(p.join(tempRoot.path, 'legacy.enc'))
        .writeAsBytes(headerBytes, flush: true);
    addTearDown(() async {
      if (await legacyFile.exists()) {
        await legacyFile.delete();
      }
      if (await sourceFile.exists()) {
        await sourceFile.delete();
      }
    });

    final result = await Navec.decryptFile(
      context: context,
      filePath: legacyFile.path,
      password: password,
    );

    expect(result, isNotNull);
    final File outputFile = result[0] as File;
    addTearDown(() async {
      if (await outputFile.exists()) {
        await outputFile.delete();
      }
    });
    final outputBytes = await outputFile.readAsBytes();
    expect(outputBytes, plainBytes);
    expect(result[1], uuid);
  });
}
