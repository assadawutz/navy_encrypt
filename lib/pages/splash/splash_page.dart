library splash_page;

import 'dart:async';
import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navy_encrypt/common/background_scaffold.dart';
import 'package:navy_encrypt/common/my_button.dart';
import 'package:navy_encrypt/common/my_state.dart';
import 'package:navy_encrypt/common/widget_view.dart';
import 'package:navy_encrypt/etc/utils.dart';
import 'package:navy_encrypt/main.dart';
import 'package:navy_encrypt/pages/decryption/decryption_page.dart';
import 'package:navy_encrypt/pages/encryption/encryption_page.dart';
import 'package:navy_encrypt/pages/home/home_page.dart';

part 'splash_page_view.dart';

class SplashPage extends StatefulWidget {
  static const routeName = 'splash';

  const SplashPage({Key key}) : super(key: key);

  @override
  SplashPageController createState() => SplashPageController();
}

class SplashPageController extends MyState<SplashPage> {
  Timer _timer;

  @override
  void initState() {
    super.initState();
    print('>>> SplashPageController initState()');

    try {
      if (Platform.isWindows) DesktopWindow.setFullScreen(true);
    } catch (e) {
      print(e);
    }

    /*Future.delayed(
      Duration(seconds: 5),
          () => Navigator.pushReplacementNamed(
        context,
        HomePage.routeName,
      ),
    );

    return;*/

    if (Platform.isWindows) {
      //showOkDialog(context, filePathFromCli ?? 'NULL');
    } else {
      _timer = Timer(Duration(seconds: 3), () {
        if (mounted) {
          _goHome();
        }
      });
    }
  }

  _goHome() {
    Navigator.pushReplacementNamed(
      context,
      HomePage.routeName,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('>>> SplashPageController didChangeDependencies()');
    //print('>>>>>> sharedFileList: ${this.widget.sharedFileList}');
  }

  /*void handleIntent(String filePath) {
    if (_timer != null) _timer.cancel();

    var dotIndex = filePath.lastIndexOf('.');

    if (dotIndex != -1 &&
        filePath.substring(dotIndex).toLowerCase() == '.enc') {
      // decrypt
      Future.delayed(
        Duration.zero,
        () => Navigator.pushReplacementNamed(
          context,
          DecryptionPage.routeName,
          arguments: filePath,
        ),
      );
    } else {
      // encrypt
      Future.delayed(
        Duration.zero,
        () => Navigator.pushReplacementNamed(
          context,
          EncryptionPage.routeName,
          arguments: filePath,
        ),
      );
    }
  }*/

  /*void handleViewIntent(String filePath) {
    if (_timer != null) _timer.cancel();

    if (filePath == null) return;

    String extension = p.extension(filePath).substring(1).toLowerCase();
    if (extension != 'enc') {
      int dotIndex = filePath.lastIndexOf('.');

      File f;
      if (dotIndex != -1) {
        f = File(filePath).renameSync('${filePath.substring(0, dotIndex)}.enc');
      } else {
        f = File(filePath).renameSync('filePath.enc');
      }

      filePath = f.path;
      print('FILE PATH AFTER RENAMING: ${f.path}');
    }

    Future.delayed(
      Duration.zero,
      () => Navigator.pushReplacementNamed(
        context,
        DecryptionPage.routeName,
        arguments: filePath,
      ),
    );
  }*/

  /*void handleShareIntent(List<SharedMediaFile> sharedFileList) {
    print('>>> SplashPageController handleShareIntent()');
    print('>>>>>> sharedFileList: $sharedFileList');

    if (_timer != null) _timer.cancel();

    if (sharedFileList.isNotEmpty) {
      var path = sharedFileList[0].path;
      var dotIndex = path.lastIndexOf('.');

      if (dotIndex != -1 && path.substring(dotIndex) == '.enc') {
        // decrypt
        Future.delayed(
          Duration.zero,
          () => Navigator.pushReplacementNamed(
            context,
            DecryptionPage.routeName,
            arguments: path,
          ),
        );
      } else {
        // encrypt
        Future.delayed(
          Duration.zero,
          () => Navigator.pushReplacementNamed(
            context,
            EncryptionPage.routeName,
            arguments: path,
          ),
        );
      }
    } else {
      print('sharedFileList IS EMPTY !!!!!');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    //https://stackoverflow.com/questions/49418332/flutter-how-to-prevent-device-orientation-changes-and-force-portrait
    if ((screenWidth(context) > 500 && screenHeight(context) > 1000) ||
        (screenWidth(context) > 1000 && screenHeight(context) > 500)) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

    print(
        'SCREEN SIZE: ${screenWidth(context)} x ${screenHeight(context)} DIP');
    return _SplashPageView(this);
  }
}
