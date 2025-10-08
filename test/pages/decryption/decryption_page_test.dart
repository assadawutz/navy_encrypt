import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navy_encrypt/common/header_scaffold.dart';
import 'package:navy_encrypt/navy_encryption/navec.dart';
import 'package:navy_encrypt/pages/decryption/decryption_page.dart';
import 'package:navy_encrypt/storage/prefs.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DecryptionPage', () {
    Directory tempDir;
    File encryptedFile;
    const correctPassword = 'correct-password';
    const uuid = '12345678-1234-1234-1234-123456789012';

    setUp(() async {
      await SharedPreferences.setMockInitialValues({
        MyPrefs.KEY_EMAIL: 'tester@example.com',
        MyPrefs.KEY_SECRET: 'secret',
      });

      tempDir ??= await Directory.systemTemp.createTemp('navec_test');

      if (encryptedFile == null) {
        final plainBytes = Uint8List.fromList(utf8.encode('Sample content'));
        final aes128 = Navec.algorithms
            .firstWhere((algo) => algo.code == 'AES128');
        final encryptedBytes = aes128.encrypt(correctPassword, plainBytes);

        final header = <int>[
          ...utf8.encode(Navec.headerFileSignature),
          ...utf8.encode(
            'txt'.padRight(Navec.headerFileExtensionFieldLength),
          ),
          ...utf8.encode(
            aes128.code.padRight(Navec.headerAlgorithmFieldLength),
          ),
          ...encryptedBytes,
          ...utf8.encode(uuid),
        ];

        encryptedFile = await File(p.join(tempDir.path, 'sample.enc'))
            .writeAsBytes(header, flush: true);
      }
    });

    tearDownAll(() async {
      if (encryptedFile != null && await encryptedFile.exists()) {
        await encryptedFile.delete();
      }
      if (tempDir != null && await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    testWidgets('shows error dialog when password is incorrect',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        initialRoute: DecryptionPage.routeName,
        onGenerateRoute: (settings) {
          if (settings.name == DecryptionPage.routeName) {
            return MaterialPageRoute(
              settings: RouteSettings(
                name: settings.name,
                arguments: encryptedFile.path,
              ),
              builder: (_) => DecryptionPage(),
            );
          }
          return null;
        },
      ));

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'wrong-password');
      await tester.tap(find.text('ดำเนินการ'));

      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('รหัสผ่านไม่ถูกต้อง หรือเกิดข้อผิดพลาดในการถอดรหัส'),
        findsOneWidget,
      );

      final headerScaffold = tester.widget<HeaderScaffold>(
        find.byType(HeaderScaffold),
      );
      expect(headerScaffold.showProgress, isFalse);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });
  });
}
