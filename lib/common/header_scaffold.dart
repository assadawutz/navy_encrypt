library header_scaffold;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:navy_encrypt/common/progress_overlay.dart';
import 'package:navy_encrypt/common/widget_view.dart';
import 'package:navy_encrypt/etc/utils.dart';
import 'package:navy_encrypt/pages/settings/settings_page.dart';

part 'header_scaffold_view.dart';

part 'header_scaffold_view_win.dart';

class HeaderScaffold extends StatelessWidget {
  final Widget header;
  final Widget body;
  final String headerAssetPath;
  final bool showBackButton;
  final bool showSettingsButton;
  final bool showProgress;
  final String progressMessage;
  final double progressValue;
  final Function onClickBackButton;
  final Function onResume;
  final Widget floatingActionButton;

  const HeaderScaffold({
    Key key,
    this.header,
    this.body,
    this.headerAssetPath,
    this.showBackButton,
    this.showSettingsButton = true,
    this.showProgress = false,
    this.progressMessage,
    this.progressValue,
    this.onClickBackButton,
    this.onResume,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => isLandscapeLayout(context)
      ? _HeaderScaffoldViewWin(this)
      : _HeaderScaffoldView(this);

  void _handleClickBackButton(BuildContext context) {
    print('BACK BUTTON CLICKED!');
    if (onClickBackButton != null) {
      onClickBackButton();
    } else {
      Navigator.pop(context);
    }
  }

  void _handleClickSettingsButton(BuildContext context) {
    print('SETTINGS BUTTON CLICKED!');
    Navigator.pushNamed(
      context,
      SettingsPage.routeName,
    ).then((_) {
      if (onResume != null) onResume();
    });
  }

  String _getHeaderImageAsset(BuildContext context) {
    double ratio = screenRatio(context);
    if (ratio >= 2.0) {
      return 'assets/images/bg_header_all.png';
    } else if (ratio >= 1.8) {
      return 'assets/images/bg_header_all_2.png';
    } else {
      return 'assets/images/bg_header_all_3.png';
    }
  }
}
