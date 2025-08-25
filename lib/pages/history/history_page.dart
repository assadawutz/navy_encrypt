library history_page;

import 'dart:io' show Platform;

import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:navy_encrypt/common/encrypt_decrypt_header.dart';
import 'package:navy_encrypt/common/header_scaffold.dart';
import 'package:navy_encrypt/common/my_button.dart';
import 'package:navy_encrypt/common/my_container.dart';
import 'package:navy_encrypt/common/my_dialog.dart';
import 'package:navy_encrypt/common/my_form_field.dart';
import 'package:navy_encrypt/common/my_state.dart';
import 'package:navy_encrypt/common/widget_view.dart';
import 'package:navy_encrypt/etc/constants.dart';
import 'package:navy_encrypt/etc/thai_date.dart';
import 'package:navy_encrypt/models/log.dart';
import 'package:navy_encrypt/models/share_log.dart';
import 'package:navy_encrypt/navy_encryption/watermark.dart';
import 'package:navy_encrypt/pages/settings/settings_page.dart';
import 'package:navy_encrypt/services/api.dart';
import 'package:navy_encrypt/storage/prefs.dart';

part 'history_page_view.dart';

class HistoryPage extends StatefulWidget {
  static const routeName = 'history';

  const HistoryPage({Key key}) : super(key: key);

  @override
  _HistoryPageController createState() => _HistoryPageController();
}

class _HistoryPageController extends MyState<HistoryPage> {
  WatermarkRegisterStatus _registerStatus; //WatermarkRegisterStatus.initial;
  List<ShareLog> _shareLog;
  Map<int, List<ShareLog>> _shareLogGroup;
  final _searchEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _updateWatermarkRegisterStatus();
    });
  }

  _updateWatermarkRegisterStatus() async {
    var status = await Watermark.getRegisterStatus();
    setState(() {
      _registerStatus = status;
    });
  }

  _handleClicktoSettingButton() {
    Navigator.pushNamed(
      context,
      SettingsPage.routeName,
    ).then((value) => _updateWatermarkRegisterStatus());
  }

  Future<List<Log>> _getLog() async {
    final email = await MyPrefs.getEmail();
    final log = await MyApi().getLog(email);

    List<Log> logFilter = log
        .where((ele) => ele.fileName.contains(_searchEditingController.text))
        .toList();
    return logFilter;

    return log;
  }

  _getShareLog(logId) async {
    isLoading = true;
    List<ShareLog> shareLog = await MyApi().getShareLog(logId);
    final shareLogGroup = shareLog.groupListsBy((m) => m.id);

    isLoading = false;
    setState(() {
      // _shareLog = shareLog;
      _shareLogGroup = shareLogGroup;
    });

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return MyDialog(
              headerImage: Image.asset('assets/images/ic_history.png',
                  width: Constants.LIST_DIALOG_HEADER_IMAGE_SIZE),
              body: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 32.0),
                        Text(
                          'ประวัติการอนุญาต',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22.0, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 6.0),
                        Text(
                          shareLog[0].fileName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 22.0,
                              color: Color.fromARGB(255, 112, 145, 172)),
                        ),
                        SizedBox(height: 12.0),
                        if (_shareLogGroup.length > 0)
                          Container(
                              child: Scrollbar(
                                  child: ListView.builder(
                            padding: EdgeInsets.all(0.0),
                            shrinkWrap: true,
                            itemCount: _shareLogGroup.length,
                            itemBuilder: (BuildContext context, int index) {
                              var thaiDateTime = _shareLogGroup.values
                                          .toList()[index][0]
                                          .createdAt !=
                                      null
                                  ? ThaiDateTime(_shareLogGroup.values
                                      .toList()[index][0]
                                      .createdAt
                                      .toLocal())
                                  : null;

                              var senderName = _shareLogGroup.values
                                  .toList()[index][0]
                                  .sendName;

                              return Column(children: [
                                ListTile(
                                  contentPadding: EdgeInsets.only(
                                      left: 0, top: 0, bottom: 0, right: 0),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${thaiDateTime.formatDate()},  ${thaiDateTime.formatTime()}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 22,
                                          )),
                                      Text(
                                        'ผู้อนุญาต: ${senderName ?? ''}',
                                        style: TextStyle(
                                          fontSize: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: getShareReceive(
                                      _shareLogGroup.values.toList()[index],
                                      context),
                                  dense: true,
                                ),
                                if ((_shareLogGroup.length - 1) > index)
                                  Divider()
                              ]);
                            },
                          ))),
                        Text(
                          '${_shareLogGroup.length} รายการ',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                        OverflowBar(
                            alignment: MainAxisAlignment.end,
                            // spacing: spacing,
                            overflowAlignment: OverflowBarAlignment.end,
                            overflowDirection: VerticalDirection.down,
                            overflowSpacing: 0,
                            children: <Widget>[
                              TextButton(
                                child: Text("ตกลง",
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 31, 150, 205))),
                                onPressed: () {
                                  Navigator.pop(context, false);
                                  // Navigator.pushReplacementNamed(
                                  //   context,
                                  //   ResultPage.routeName,
                                  //   arguments: {
                                  //     'filePath': _shareLogGroup.values
                                  //         .toList()[0][0]
                                  //         .fileName,
                                  //     'message': 'ถอดรหัสสำเร็จ',
                                  //     'isEncryption': false,
                                  //     'fileEncryptPath': _shareLogGroup.values
                                  //         .toList()[0][0]
                                  //         .fileName,
                                  //     'signatureCode': null,
                                  //     'type': 'encryption'
                                  //   },
                                  // );
                                },
                              )
                            ])
                      ])),
              padding: EdgeInsets.only(
                left: 16.0,
                top: 16.0,
                right: 16.0,
                bottom: 0.0,
              ),
            );
          });
        });
  }

  Widget getShareReceive(List<ShareLog> data, BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
            data.length,
            (index) => Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                    ),
                    Icon(
                      FontAwesomeIcons.userAlt,
                      size: 15,
                    ),
                    Text('  ${data[index].receiveName}',
                        style: TextStyle(
                          fontSize: 22,
                        ))
                  ],
                )));
  }

  String _showLogAction(String action, String type) {
    switch (action) {
      case 'create':
        return type == 'encryption' ? 'เข้ารหัส' : 'ใส่ลายน้ำ';
        break;
      case 'view':
        return 'ถอดรหัส';
        break;
      case 'share':
        return 'อนุญาตถอดรหัส';
        break;
      default:
        return '-';
    }
  }

  Icon _getIcon(String action, String type) {
    switch (action) {
      case 'create':
        return type == 'encryption'
            ? Icon(
                FontAwesomeIcons.lock,
                color: Color.fromARGB(255, 247, 156, 149),
              )
            : Icon(FontAwesomeIcons.stamp);
        break;
      case 'view':
        return Icon(
          FontAwesomeIcons.unlock,
          color: Color.fromARGB(255, 108, 139, 109),
        );
        break;
      case 'share':
        return Icon(FontAwesomeIcons.userAlt,
            color: Color.fromARGB(255, 112, 145, 172));
        break;
      default:
        return Icon(FontAwesomeIcons.minus);
    }
  }

  @override
  Widget build(BuildContext context) => _HistoryPageView(this);

  int getWatermarkStatusIndex(WatermarkRegisterStatus status) =>
      WatermarkRegisterStatus.values.indexWhere((item) => item == status);
}
