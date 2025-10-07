import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navy_encrypt/pages/decryption/decryption_page.dart';
import 'package:navy_encrypt/pages/encryption/encryption_page.dart';
import 'package:navy_encrypt/pages/home/home_page.dart';

class _TestNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;
  String lastRouteName;
  Object lastArguments;

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route.settings?.name != Navigator.defaultRouteName) {
      pushCount++;
      lastRouteName = route.settings?.name;
      lastArguments = route.settings?.arguments;
    }
    super.didPush(route, previousRoute);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const methodChannel = MethodChannel('is_first_run');

  setUp(() {
    methodChannel.setMockMethodCallHandler((_) async => false);
  });

  tearDown(() {
    methodChannel.setMockMethodCallHandler(null);
  });

  Future<HomePageController> _pumpHomePage(
    WidgetTester tester,
    NavigatorObserver observer,
  ) async {
    await tester.pumpWidget(MaterialApp(
      home: HomePage(key: UniqueKey()),
      navigatorObservers: [observer],
      routes: {
        EncryptionPage.routeName: (_) => const SizedBox.shrink(),
        DecryptionPage.routeName: (_) => const SizedBox.shrink(),
      },
    ));
    await tester.pumpAndSettle();

    return tester.state<HomePageController>(find.byType(HomePage));
  }

  testWidgets('image picker returning null stops loading and avoids navigation',
      (tester) async {
    final observer = _TestNavigatorObserver();
    final state = await _pumpHomePage(tester, observer);

    await state.pickMediaFileForTest(
      state.context,
      ({ImageSource source}) async => null,
      ImageSource.camera,
    );
    await tester.pump();

    expect(state.isLoading, isFalse);
    expect(observer.pushCount, 0);
  });

  testWidgets('video picker returning null stops loading and avoids navigation',
      (tester) async {
    final observer = _TestNavigatorObserver();
    final state = await _pumpHomePage(tester, observer);

    await state.pickMediaFileForTest(
      state.context,
      ({ImageSource source}) async => null,
      ImageSource.gallery,
    );
    await tester.pump();

    expect(state.isLoading, isFalse);
    expect(observer.pushCount, 0);
  });

  testWidgets('picker throwing stops loading, shows error, and avoids navigation',
      (tester) async {
    final observer = _TestNavigatorObserver();
    final state = await _pumpHomePage(tester, observer);

    await state.pickMediaFileForTest(
      state.context,
      ({ImageSource source}) async => throw Exception('picker failed'),
      ImageSource.camera,
    );

    await tester.pump();

    expect(state.isLoading, isFalse);
    expect(observer.pushCount, 0);

    await tester.pumpAndSettle();

    expect(find.text('ไม่สามารถเลือกไฟล์ได้ กรุณาลองใหม่อีกครั้ง'),
        findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('supported media file navigates to encryption flow',
      (tester) async {
    final observer = _TestNavigatorObserver();
    final state = await _pumpHomePage(tester, observer);

    final tempDir = await Directory.systemTemp.createTemp('home_page_test');
    addTearDown(() => tempDir.delete(recursive: true));
    final imageFile = File('${tempDir.path}/sample.jpg');
    await imageFile.writeAsBytes(List<int>.filled(10, 1));

    await state.pickMediaFileForTest(
      state.context,
      ({ImageSource source}) async => XFile(imageFile.path),
      ImageSource.gallery,
    );

    await tester.pumpAndSettle();

    expect(observer.pushCount, 1);
    expect(observer.lastRouteName, EncryptionPage.routeName);
    expect(observer.lastArguments, imageFile.path);
    expect(state.isLoading, isFalse);
  });

  testWidgets('encrypted file navigates to decryption flow', (tester) async {
    final observer = _TestNavigatorObserver();
    final state = await _pumpHomePage(tester, observer);

    final tempDir = await Directory.systemTemp.createTemp('home_page_test');
    addTearDown(() => tempDir.delete(recursive: true));
    final encryptedFile = File('${tempDir.path}/secret.enc');
    await encryptedFile.writeAsBytes(List<int>.filled(10, 2));

    await state.pickMediaFileForTest(
      state.context,
      ({ImageSource source}) async => XFile(encryptedFile.path),
      ImageSource.gallery,
    );

    await tester.pumpAndSettle();

    expect(observer.pushCount, 1);
    expect(observer.lastRouteName, DecryptionPage.routeName);
    expect(observer.lastArguments, encryptedFile.path);
    expect(state.isLoading, isFalse);
  });
}
