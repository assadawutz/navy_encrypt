import 'dart:io' show Platform;
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

void logOneLineWithBorderSingle(String text) {
  print('┌─${[
    for (var i = 0; i < text.length; i++) '─'
  ].reduce((value, item) => '$value$item')}─┐');
  print('│ $text │');
  print('└─${[
    for (var i = 0; i < text.length; i++) '─'
  ].reduce((value, item) => '$value$item')}─┘');
}

void logOneLineWithBorderDouble(String text) {
  print('╔═${[
    for (var i = 0; i < text.length; i++) '═'
  ].reduce((value, item) => '$value$item')}═╗');
  print('║ $text ║');
  print('╚═${[
    for (var i = 0; i < text.length; i++) '═'
  ].reduce((value, item) => '$value$item')}═╝');
}

void logWithBorder(Map<String, dynamic> logMap, int lines) {
  if (logMap == null || logMap.isEmpty) return;

  final topLeft = lines == 1 ? '┌' : '╔';
  final topRight = lines == 1 ? '┐' : '╗';
  final bottomLeft = lines == 1 ? '└' : '╚';
  final bottomRight = lines == 1 ? '┘' : '╝';
  final vertical = lines == 1 ? '│' : '║';
  final horizontal = lines == 1 ? '─' : '═';

  var logList = logMap.entries.map((e) => '${e.key}: ${e.value}').toList();
  var maxLength = logList.fold<int>(
    0,
    (previousValue, element) =>
        element.length > previousValue ? element.length : previousValue,
  );

  print('$topLeft$horizontal${[
    for (var i = 0; i < maxLength; i++) horizontal
  ].reduce((value, item) => '$value$item')}$horizontal$topRight');

  logList.forEach((item) {
    List<String> spaceList =
        [for (var i = 0; i < maxLength - item.length; i++) ' '].toList();
    var spaces = spaceList.isEmpty
        ? ''
        : spaceList.reduce((value, element) => '$value$element');

    print('$vertical $item$spaces $vertical');
  });

  print('$bottomLeft$horizontal${[
    for (var i = 0; i < maxLength; i++) horizontal
  ].reduce((value, item) => '$value$item')}$horizontal$bottomRight');
}

Size screenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

double screenHeight(BuildContext context) {
  return screenSize(context).height;
}

double screenWidth(BuildContext context) {
  return screenSize(context).width;
}

double screenRatio(BuildContext context) {
  return screenHeight(context) / screenWidth(context);
}

bool isLandscapeLayout(BuildContext context) {
  return Platform.isWindows ||
      (screenRatio(context) < 1 &&
          screenWidth(context) > 1000 &&
          screenHeight(context) > 500);
}

Future<bool> isIpad() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    IosDeviceInfo info = await deviceInfo.iosInfo;
    if (info.model.toLowerCase().contains("ipad")) {
      return true;
    }
  }

  return false;
}

class DialogActionButton {
  final String label;
  final Function onClick;

  DialogActionButton({@required this.label, @required this.onClick});
}

Future<void> showAlertDialog(
  BuildContext context,
  String title, {
  String textContent,
  Widget content,
  bool dismissible,
  List<DialogActionButton> buttonList,
}) async {
  var contentWidgetList = <Widget>[];

  if (textContent != null) {
    contentWidgetList.addAll(
      textContent
          .split('\n')
          .map<Widget>(
            (line) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                line,
                style: TextStyle(fontSize: 22.0),
              ),
            ),
          )
          .toList(),
    );
  }
  if (content != null) {
    contentWidgetList.add(content);
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: dismissible ?? true,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Text(title, style: TextStyle(fontSize: 22.0)),
        content: contentWidgetList.isNotEmpty
            ? SingleChildScrollView(
                child: ListBody(
                  children: contentWidgetList,
                ),
              )
            : null,
        actions: buttonList
            .map(
              (button) => TextButton(
                child: Text(button.label, style: TextStyle(fontSize: 22.0)),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (button.onClick != null) button.onClick();
                },
              ),
            )
            .toList(),
      );
    },
  );
}

Future<void> showOkDialog(
  BuildContext context,
  String title, {
  String textContent,
  Widget content,
  Function onClickOk,
  bool dismissible,
}) async {
  return await showAlertDialog(
    context,
    title,
    textContent: textContent,
    content: content,
    dismissible: dismissible,
    buttonList: [DialogActionButton(label: 'OK', onClick: onClickOk)],
  );
}

void dismissKeyboard(BuildContext context) {
  FocusScope.of(context).unfocus();
}

String getRandomString(int length) {
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  var _rnd = Random();

  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => _chars.codeUnitAt(
        _rnd.nextInt(_chars.length),
      ),
    ),
  );
}