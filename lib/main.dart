import 'dart:async';
import 'dart:io';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navy_encrypt/etc/constants.dart';
import 'package:navy_encrypt/etc/share_intent_handler.dart';
import 'package:navy_encrypt/models/loading_message.dart';
import 'package:navy_encrypt/pages/cloud_picker/cloud_picker_page.dart';
import 'package:navy_encrypt/pages/decryption/decryption_page.dart';
import 'package:navy_encrypt/pages/encryption/encryption_page.dart';
import 'package:navy_encrypt/pages/file_viewer/file_viewer_page.dart';
import 'package:navy_encrypt/pages/history/history_page.dart';
import 'package:navy_encrypt/pages/home/home_page.dart';
import 'package:navy_encrypt/pages/result/result_page.dart';
import 'package:navy_encrypt/pages/settings/settings_page.dart';
import 'package:navy_encrypt/pages/splash/splash_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

//https://stackoverflow.com/questions/57338213/support-custom-file-extension-in-a-flutter-app-open-file-with-extension-abc-i
//https://flutter.dev/docs/get-started/flutter-for/android-devs#how-do-i-handle-incoming-intents-from-external-applications-in-flutter
//https://github.com/flutter/flutter/issues/32986

String filePathFromCli;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main(List<String> arguments) async {
  // get command-line arg in desktop app
  if (Platform.isAndroid == true || Platform.isIOS == true) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

// Ideal time to initialize
//   await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  HttpOverrides.global = new MyHttpOverrides();

  //#region Firebase

  if (arguments.isNotEmpty) {
    filePathFromCli = arguments[0];
  }

  runApp(ChangeNotifierProvider(
    create: (_) => LoadingMessage(),
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('app.channel.shared.data');
  GlobalKey<HomePageController> _keyHomePage = GlobalKey();

  ShareIntentHandler _shareIntentHandler;

  //var _showSplash = true;
  String _filePath;

  @override
  void initState() {
    super.initState();

    _filePath = filePathFromCli;

    _shareIntentHandler = ShareIntentHandler(
      onReceiveIntent: (filePath, isAppOpen) {
        Future.delayed(Duration.zero, () {
          if (isAppOpen) {
            if (_keyHomePage.currentState != null) {
              _keyHomePage.currentState.handleIntent(filePath);
            }
          } else {
            setState(() {
              _filePath = filePath;
            });
          }
        });
      },
    );
    //_getUriPath();
  }

  // ไม่ได้ใช้แล้ว ไปใช้ ReceiveSharingIntent.getTextStream(), getInitialText() แทน
  /*void _getUriPath() async {
    var uriPath = await platform.invokeMethod('getUriPath');
    if (uriPath != null) {
      print('URI PATH: $uriPath');
      final filePath = await FlutterAbsolutePath.getAbsolutePath(uriPath);
      print('FILE PATH: $filePath');

      _keySplashPage.currentState.handleViewIntent(filePath);
    }
  }*/

  @override
  void dispose() {
    _shareIntentHandler.cancelStreamSubscription();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;*/

    if (Platform.isWindows) {
      setWindowTitle('รับส่งไฟล์');
    }
    return MaterialApp(
      title: 'รับส่งไฟล์',
      theme: ThemeData(
        fontFamily: 'DBHeavent',
        primaryColor: Constants.primaryColor,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        textTheme: TextTheme(
          button: TextStyle(fontSize: 22.0),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Constants.accentColor,
            padding: EdgeInsets.all(Platform.isWindows ? 20.0 : 12.0),
          ),
        ),
        /*elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16.0),
          ),
        ),*/
        scaffoldBackgroundColor: Color(0xFFF8F8FF),
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Constants.accentColor),
      ),
      //initialRoute: SplashPage.routeName,
      /*routes: {
        SplashPage.routeName: (context) => const SplashPage(),
        HomePage.routeName: (context) => HomePage(key: _keyHomePage),
        EncryptionPage.routeName: (context) => const EncryptionPage(),
        DecryptionPage.routeName: (context) => const DecryptionPage(),
        ResultPage.routeName: (context) => const ResultPage(),
        FileViewerPage.routeName: (context) => const FileViewerPage(),
        SettingsPage.routeName: (context) => const SettingsPage(),
        CloudPickerPage.routeName: (context) => const CloudPickerPage(),
      },*/
      home: _getHome(),
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case SplashPage.routeName:
            return PageTransition(
              child: const SplashPage(),
              type: PageTransitionType.fade,
              settings: routeSettings,
            );
            break;
          case HomePage.routeName:
            return PageTransition(
              child: HomePage(key: _keyHomePage),
              type: PageTransitionType.fade,
              settings: routeSettings,
            );
            break;
          case EncryptionPage.routeName:
            return PageTransition(
              child: const EncryptionPage(),
              type: PageTransitionType.fade,
              settings: routeSettings,
            );
            break;
          case DecryptionPage.routeName:
            return PageTransition(
              child: const DecryptionPage(),
              type: PageTransitionType.fade,
              settings: routeSettings,
            );
            break;
          case ResultPage.routeName:
            return PageTransition(
              child: const ResultPage(),
              type: PageTransitionType.fade,
              settings: routeSettings,
            );
            break;
          case FileViewerPage.routeName:
            return PageTransition(
              child: const FileViewerPage(),
              type: PageTransitionType.fade,
              settings: routeSettings,
            );
            break;
          case SettingsPage.routeName:
            return PageTransition(
              child: const SettingsPage(),
              type: PageTransitionType.fade,
              settings: routeSettings,
            );
            break;
          case CloudPickerPage.routeName:
            return PageTransition(
              child: const CloudPickerPage(),
              type: PageTransitionType.fade,
              settings: routeSettings,
            );
            break;
          case HistoryPage.routeName:
            return PageTransition(
              child: const HistoryPage(),
              type: PageTransitionType.fade,
              settings: routeSettings,
            );
            break;
          default:
            return null;
        }
      },
    );
  }

  Widget _getHome() {
    Widget pageToGo;

    if (_filePath == null) {
      pageToGo = SplashPage();
    } else {
      var dotIndex = _filePath.lastIndexOf('.');
      if (dotIndex != -1 &&
          _filePath.substring(dotIndex).toLowerCase() == '.enc') {
        pageToGo = HomePage(key: _keyHomePage, filePath: _filePath);
      } else {
        pageToGo = HomePage(key: _keyHomePage, filePath: _filePath);
      }
    }

    _filePath = null;
    return pageToGo;
  }
}
