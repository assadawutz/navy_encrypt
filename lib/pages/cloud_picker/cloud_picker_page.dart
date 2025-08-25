library drive_list_page;

import 'dart:async';
import 'dart:convert';
import 'dart:io' show File, Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:navy_encrypt/common/encrypt_decrypt_header.dart';
import 'package:navy_encrypt/common/header_scaffold.dart';
import 'package:navy_encrypt/common/my_button.dart';
import 'package:navy_encrypt/common/my_dialog.dart';
import 'package:navy_encrypt/common/my_stack.dart';
import 'package:navy_encrypt/common/my_state.dart';
import 'package:navy_encrypt/common/widget_view.dart';
import 'package:navy_encrypt/etc/constants.dart';
import 'package:navy_encrypt/etc/file_size.dart';
import 'package:navy_encrypt/etc/thai_date.dart';
import 'package:navy_encrypt/etc/utils.dart';
import 'package:navy_encrypt/helpers/measure_size.dart';
import 'package:navy_encrypt/models/cloud_file.dart';
import 'package:navy_encrypt/models/user.dart';
import 'package:navy_encrypt/navy_encryption/navec.dart';
import 'package:navy_encrypt/pages/cloud_picker/cloud_drive.dart';
import 'package:navy_encrypt/pages/cloud_picker/google_drive.dart';
import 'package:navy_encrypt/pages/cloud_picker/local_drive.dart';
import 'package:navy_encrypt/pages/decryption/decryption_page.dart';
import 'package:navy_encrypt/pages/encryption/encryption_page.dart';
import 'package:navy_encrypt/services/api.dart';
import 'package:navy_encrypt/storage/prefs.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

// import 'package:share_plus/share_plus.dart';

part 'cloud_picker_page_view.dart';

enum CloudPickerMode { file, folder }

class CloudPickerPageArg {
  final CloudDrive cloudDrive;
  final String title;
  final String headerImagePath;
  final String rootName;

  CloudPickerPageArg({
    @required this.cloudDrive,
    @required this.title,
    @required this.headerImagePath,
    @required this.rootName,
  });
}

class CloudPickerPage extends StatefulWidget {
  static const routeName = 'drive_list_page';

  const CloudPickerPage({Key key}) : super(key: key);

  @override
  _CloudPickerPageController createState() => _CloudPickerPageController();
}

class _CloudPickerPageController extends MyState<CloudPickerPage> {
  final List<CloudFile> _fileList = [];
  final _folderIdStack = MyStack<CloudFile>();
  String _rootName;
  CloudDrive _cloudDrive;
  String _title;
  String _headerImagePath;
  File _uploadFile;
  Size _fileItemSize;
  List<User> _shareSelected;
  final _multiSelectKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    _shareSelected = [];
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var arg = ModalRoute.of(context).settings.arguments as CloudPickerPageArg;
    _cloudDrive = arg.cloudDrive;
    _title = arg.title;
    _headerImagePath = arg.headerImagePath;
    _rootName = arg.rootName;

    _changeFolder(CloudFile(
      id: 'root',
      name: _rootName,
      fileExtension: '',
      mimeType: GoogleDrive.GOOGLE_FOLDER_MIME_TYPE,
      //todo: กรณี onedrive
      isFolder: true,
    ));
  }

  _changeFolder(CloudFile folder, {bool addToStack = true}) {
    setState(() {
      _fileList.clear();
      if (addToStack) _folderIdStack.push(folder);
      _cloudDrive.changeFolder(folder);
      _listFolder();
    });
  }

  _listFolder() async {
    isLoading = true;
    loadingMessage = 'กำลังดึงข้อมูลรายการไฟล์';
    isError = false;

    try {
      var cloudFileList = await _cloudDrive.listFolder();
      setState(() {
        _fileList.addAll(cloudFileList);
      });
    } catch (e) {
      errorMessage = 'เกิดข้อผิดพลาดในการอ่านข้อมูลจาก $_title\n$e';
      isError = true;
      print(e);
    } finally {
      isLoading = false;
    }
  }

  set uploadFile(File file) {
    _uploadFile = file;
  }

  // Return true to cancel the notification bubbling.
  // Return false (or null) to allow the notification to continue to be
  // dispatched to further ancestors.
  bool _handleScrollNotification(ScrollNotification scrollInfo) {
    if (!isLoading &&
        scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
        !_cloudDrive.isPageLoadFinished) {
      _listFolder();
      return true;
    }
    return false;
  }

  Icon _getIcon(CloudFile file) {
    if (file.isFolder) {
      return Icon(FontAwesomeIcons.solidFolder, color: Colors.yellow.shade600);
    }

    var fileType = Constants.selectableFileTypeList.firstWhereOrNull(
        (fileType) =>
            fileType.fileExtension.toLowerCase() ==
            file.fileExtension.toLowerCase());
    if (fileType != null) {
      return Icon(fileType.iconData, color: fileType.iconColor);
    } else {
      return Icon(
        Constants.unSupportedFileType.iconData,
        color: Constants.unSupportedFileType.iconColor,
      );
    }
  }

  Future<void> _handleClickFileItem(CloudFile cloudFile) async {
    if (cloudFile.isFolder) {
      _changeFolder(cloudFile);
    } else {
      try {
        isLoading = true;
        loadingMessage = 'กำลังดาวน์โหลดไฟล์';
        var file = await _cloudDrive.downloadFile(cloudFile, (value) {
          loadingValue = value;
          int percent = (value * 100).toInt();
          loadingMessage =
              'กำลังดาวน์โหลดไฟล์' + (percent != null ? '\n$percent%' : '');
        });

        var size = await file.length();
        if (size >= 20000000) {
          isLoading = false;

          setState(() {
            isLoading = false;

            showOkDialog(context, 'ผิดพลาด',
                textContent: "ขนาดไฟล์ต้องไม่เกิน 20 MB");
          });
        } else {
          var fileSize = await file.length();
          var fSize = FileSize(fileSize);
          var displayFileSize = fSize.getDisplaySize();
          var displayFileByteSize = fSize.getDisplayByteSize();

          logOneLineWithBorderSingle(
              '$_title file download success. File saved at ${file.path}, $displayFileSize ($displayFileByteSize bytes)');

          logOneLineWithBorderDouble(
              'File extension: ${cloudFile.fileExtension}');

          Navigator.pushReplacementNamed(
            context,
            cloudFile.fileExtension.toLowerCase() ==
                    Navec.encryptedFileExtension.toLowerCase()
                ? DecryptionPage.routeName
                : EncryptionPage.routeName,
            arguments: file.path,
          );
        }
      } catch (error) {
        showOkDialog(
          context,
          'ผิดพลาด',
          textContent: 'เกิดข้อผิดพลาดในการดาวน์โหลดไฟล์จาก $_title\n$error',
        );
      } finally {
        isLoading = false;
      }
    }
  }

  Future<void> _handleLongClickFileItem(CloudFile cloudFile) async {
    if (!(_cloudDrive is LocalDrive)) {
      return;
    }

    var isEncFile = false;
    if (cloudFile.fileExtension.toLowerCase() == Navec.encryptedFileExtension) {
      isEncFile = true;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        var icon = _getIcon(cloudFile);
        return MyDialog.buildPickerDialog(
          /*headerImage: Image.asset('assets/images/ic_gallery.png',
                width: Constants.LIST_DIALOG_HEADER_IMAGE_SIZE),*/
          headerImage: Icon(icon.icon, color: icon.color, size: 36.0),
          title: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
            child: Text(
              '${cloudFile.name}',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          items: [
            DialogTileData(
              label: '${isEncFile ? 'ถอดรหัส' : 'ใส่ลายน้ำ/เข้ารหัส'}',
              image: Icon(
                isEncFile ? FontAwesomeIcons.lockOpen : FontAwesomeIcons.lock,
                size: Constants.LIST_DIALOG_ICON_SIZE,
                color: Constants.LIST_DIALOG_ICON_COLOR,
              ),
              onClick: () {
                Navigator.of(context).pop();
                _handleClickFileItem(cloudFile);
              },
            ),
            DialogTileData(
              label: 'แชร์',
              image: Icon(
                FontAwesomeIcons.shareAlt,
                size: Constants.LIST_DIALOG_ICON_SIZE,
                color: Constants.LIST_DIALOG_ICON_COLOR,
              ),
              onClick: () async {
                var file = await _cloudDrive.downloadFile(cloudFile, null);
                Navigator.of(context).pop();

                if ('${p.extension(file.path)}' == '.enc') {
                  await _pickEmailShare(file.path);
                } else {
                  _handleClickShareButton(file.path);
                }
              },
            ),
            DialogTileData(
              label: 'ลบ',
              image: Icon(
                FontAwesomeIcons.solidTrashAlt,
                size: Constants.LIST_DIALOG_ICON_SIZE,
                color: Constants.LIST_DIALOG_ICON_COLOR,
              ),
              onClick: () {
                showAlertDialog(
                  context,
                  'DELETE FILE',
                  textContent: 'ต้องการลบไฟล์นี้?',
                  buttonList: [
                    DialogActionButton(label: 'ยกเลิก', onClick: null),
                    DialogActionButton(
                      label: 'ใช่',
                      onClick: () async {
                        var file =
                            await _cloudDrive.downloadFile(cloudFile, null);
                        try {
                          await file.delete();
                        } catch (e) {
                          print(e);
                        }
                        await _handleClickRefreshButton();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _handleClickDeviceBackButton() async {
    logOneLineWithBorderSingle('WILL POP');

    _folderIdStack.pop();
    if (_folderIdStack.length > 0) {
      _changeFolder(_folderIdStack.peak, addToStack: false);
      return await Future.value(false);
    } else {
      return await Future.value(true);
    }
  }

  void _handleClickBreadcrumbItem(CloudFile folder) {
    var f = _folderIdStack.popTo(folder);
    _changeFolder(f, addToStack: false);
  }

  Future<void> _handleClickRefreshButton() async {
    if ((Platform.isWindows && await _cloudDrive.signInWithOAuth2()) ||
        (!Platform.isWindows && await _cloudDrive.signIn())) {
      _changeFolder(_folderIdStack.peak, addToStack: false);
    }
  }

  Future<void> _handleClickSaveButton() async {
    // print("_folderIdStack ${_folderIdStack.peak.name}");
    // if (await _cloudDrive.isUploadFileExist(_folderIdStack.peak)) {
    //   showAlertDialog(
    //     context,
    //     'OVERWRITE',
    //     textContent: 'มีไฟล์ชื่อนี้อยู่แล้ว ต้องการเขียนทับหรือไม่?',
    //     buttonList: [
    //       DialogActionButton(label: 'ยกเลิก', onClick: null),
    //       DialogActionButton(
    //         label: 'บันทึก',
    //         onClick: () async {
    //           await _doSaveFile();
    //         },
    //       ),
    //     ],
    //   );
    // } else {
    await _doSaveFile();
    // }
  }

  _doSaveFile() async {
    isLoading = true;
    loadingMessage = 'กำลังบันทึกไฟล์';
    var uploadSuccess =
        await _cloudDrive.uploadFile(_folderIdStack.peak, (value) {
      loadingValue = value;
      int percent = (value * 100).toInt();
      loadingMessage =
          'กำลังบันทึกไฟล์' + (percent != null ? '\n$percent%' : '');
    });
    if (uploadSuccess) {
      showOkDialog(
        context,
        'สำเร็จ',
        textContent: 'บันทึกไฟล์สำเร็จ',
        dismissible: false,
        onClickOk: () => Navigator.of(context).pop(),
      );
    } else {
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'เกิดข้อผิดพลาดในการบันทึกไฟล์',
      );
    }
    isLoading = false;
  }

  _handleFileItemSizeChange(Size size) {
    setState(() {
      _fileItemSize = size;
    });
  }

  _handleClickShareButton(String filePath) async {
    if (await isIpad()) {
      Share.shareFiles(
        [filePath],
        sharePositionOrigin: Rect.fromLTWH(
          0,
          0,
          screenWidth(context),
          screenHeight(context) / 2,
        ),
      );
    } else {
      Share.shareFiles([filePath]);
    }
  }

  Future _pickEmailShare(String filePath) async {
    isLoading = true;
    final _contacts = await MyApi().getUser();
    final email = await MyPrefs.getEmail();
    _contacts.removeWhere((item) => item.email == email);
    isLoading = false;

    setState(() {
      // _shareSelected = [];
    });

    final _items = _contacts
        .map((contacts) => MultiSelectItem<User>(
            contacts, (contacts.name + '\n' + contacts.email)))
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return MyDialog(
            headerImage: Image.asset('assets/images/ic_contact.png',
                width: Constants.LIST_DIALOG_HEADER_IMAGE_SIZE),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 32.0),
                  Text(
                    'เลือกอีเมลที่อนุญาตให้ถอดรหัส',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 12.0),
                  // เลือกรายการอีเมล
                  MultiSelectDialogField<User>(
                    key: _multiSelectKey,
                    items: _items,
                    title: Text(
                      "รายการทั้งหมด",
                    ),
                    searchable: true,
                    dialogHeight: MediaQuery.of(context).size.height * 0.6,
                    dialogWidth: MediaQuery.of(context).size.width * 0.8,
                    selectedColor: Color(0xFF3EC2FF),
                    decoration: BoxDecoration(
                      color: Color(0xFF3EC2FF).withOpacity(0.1),
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                      border: Border.all(
                        color: Color(0xFF3EC2FF),
                        width: 1,
                      ),
                    ),
                    buttonIcon: Icon(
                      Icons.contacts,
                      color: Color(0xFF3EC2FF),
                    ),
                    buttonText: Text(
                      "อีเมล",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    confirmText: Text("ตกลง",
                        style: TextStyle(
                            color: Color.fromARGB(255, 31, 150, 205))),
                    cancelText: Text("ปิด",
                        style: TextStyle(
                            color: Color.fromARGB(255, 136, 136, 136))),
                    chipDisplay: MultiSelectChipDisplay.none(
                      disabled: true,
                    ),
                    itemsTextStyle: TextStyle(
                      fontSize: 20,
                      fontFamily: 'DBHeavent',
                    ),
                    selectedItemsTextStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      fontFamily: 'DBHeavent',
                    ),
                    searchTextStyle: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                      fontFamily: 'DBHeavent',
                    ),
                    onConfirm: (results) {
                      setState(() {
                        _shareSelected = results;
                      });
                      _multiSelectKey.currentState.validate();
                    },
                  ),
                  SizedBox(height: 12.0),
                  // buildMailShareSelect(),
                  if (_shareSelected.length > 0)
                    Container(
                        child: Column(children: [
                      SizedBox(height: 6.0),
                      Text(
                        'รายการอีเมลที่เลือก',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.w500),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                          border: Border.all(
                            color: Color(0xFF3EC2FF),
                            width: 1,
                          ),
                        ),
                        constraints: BoxConstraints(
                            minWidth: double.infinity, maxHeight: 250),
                        child: Scrollbar(
                            child: ListView.builder(
                          padding: EdgeInsets.all(0.0),
                          shrinkWrap: true,
                          itemCount: _shareSelected.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              contentPadding: EdgeInsets.only(
                                  left: 8, top: 0, bottom: 0, right: 0),
                              title: Text(_shareSelected[index].name,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'DBHeavent',
                                  )),
                              subtitle: Text(
                                _shareSelected[index].email,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'DBHeavent',
                                ),
                              ),
                              trailing: IconButton(
                                padding: const EdgeInsets.all(0.0),
                                icon: Icon(Icons.remove_circle,
                                    color: Color(0xFF3EC2FF)),
                                onPressed: () {
                                  setState(() {
                                    _shareSelected
                                        .remove(_shareSelected[index]);
                                  });
                                  _multiSelectKey.currentState.validate();
                                },
                              ),
                              dense: true,
                            );
                          },
                        )),
                      ),
                      SizedBox(height: 6.0),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _shareSelected.length.toString() + ' รายการ',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 22.0),
                          )),
                    ])),

                  OverflowBar(
                    alignment: MainAxisAlignment.end,
                    // spacing: spacing,
                    overflowAlignment: OverflowBarAlignment.end,
                    overflowDirection: VerticalDirection.down,
                    overflowSpacing: 0,
                    children: <Widget>[
                      TextButton(
                        child: Text("ปิด",
                            style: TextStyle(
                                color: Color.fromARGB(255, 136, 136, 136))),
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                      ),
                      TextButton(
                        child: Text("ตกลง",
                            style: TextStyle(
                                color: Color.fromARGB(255, 31, 150, 205))),
                        onPressed: () async {
                          if (_shareSelected.length > 0) {
                            //SAVE LOG
                            try {
                              String uuid;
                              try {
                                var fileBytes =
                                    await File(filePath).readAsBytes();
                                uuid = utf8
                                    .decode(fileBytes.sublist(
                                      (fileBytes.length -
                                          Navec.headerUUIDFieldLength),
                                    ))
                                    .trim();
                              } catch (err) {}

                              var email = await MyPrefs.getEmail();
                              var secret = await MyPrefs.getSecret();
                              String fileName = '${p.basename(filePath)}';
                              List<int> shareUserId = [];
                              _shareSelected.forEach(
                                  (User user) => shareUserId.add(user.id));

                              final logId = await MyApi().saveLog(
                                  email,
                                  fileName,
                                  uuid,
                                  null,
                                  'share',
                                  'encryption',
                                  secret,
                                  shareUserId);
                            } catch (e) {
                              showOkDialog(context, e.toString());
                              isLoading = false;
                              return;
                            }
                            // END SAVE LOG
                            _handleClickShareButton(filePath);
                            Navigator.pop(context, false);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            padding: EdgeInsets.only(
              left: 16.0,
              top: 16.0,
              right: 16.0,
              bottom: 0.0,
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) => _CloudPickerPageView(this);
}
