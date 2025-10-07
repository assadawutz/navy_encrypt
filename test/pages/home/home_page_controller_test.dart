import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navy_encrypt/pages/home/home_page.dart';

class _TestNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route.settings?.name != Navigator.defaultRouteName) {
      pushCount++;
    }
    super.didPush(route, previousRoute);
  }
}

void main() {
  testWidgets('image picker returning null stops loading and avoids navigation',
      (tester) async {
    final observer = _TestNavigatorObserver();
    await tester.pumpWidget(MaterialApp(
      home: HomePage(key: UniqueKey()),
      navigatorObservers: [observer],
    ));
    await tester.pumpAndSettle();

    final state = tester.state<HomePageController>(find.byType(HomePage));

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
    await tester.pumpWidget(MaterialApp(
      home: HomePage(key: UniqueKey()),
      navigatorObservers: [observer],
    ));
    await tester.pumpAndSettle();

    final state = tester.state<HomePageController>(find.byType(HomePage));

    await state.pickMediaFileForTest(
      state.context,
      ({ImageSource source}) async => null,
      ImageSource.gallery,
    );
    await tester.pump();

    expect(state.isLoading, isFalse);
    expect(observer.pushCount, 0);
  });
}
