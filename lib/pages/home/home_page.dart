library home_page;

import 'dart:io' show Directory, File, FileSystemEntity, FileSystemException, Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:is_first_run/is_first_run.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:navy_encrypt/common/header_scaffold.dart';
import 'package:navy_encrypt/common/my_dialog.dart';
import 'package:navy_encrypt/common/my_state.dart';
import 'package:navy_encrypt/common/widget_view.dart';
import 'package:navy_encrypt/etc/constants.dart';
import 'package:navy_encrypt/etc/dimension_util.dart';
import 'package:navy_encrypt/etc/file_util.dart';
import 'package:navy_encrypt/etc/utils.dart';
import 'package:navy_encrypt/flutter_signin_button/flutter_signin_button.dart';
import 'package:navy_encrypt/navy_encryption/navec.dart';
import 'package:navy_encrypt/pages/cloud_picker/cloud_picker_page.dart';
import 'package:navy_encrypt/pages/cloud_picker/google_drive.dart';
import 'package:navy_encrypt/pages/cloud_picker/local_drive.dart';
import 'package:navy_encrypt/pages/cloud_picker/onedrive.dart';
import 'package:navy_encrypt/pages/decryption/decryption_page.dart';
import 'package:navy_encrypt/pages/encryption/encryption_page.dart';
import 'package:navy_encrypt/pages/history/history_page.dart';
import 'package:navy_encrypt/pages/settings/settings_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

part 'home_page_view.dart';
part 'home_page_view_win.dart';

class HomePage extends StatefulWidget {
  static const routeName = 'home';
  final String filePath;

  const HomePage({@required Key key, this.filePath}) : super(key: key);

  @override
  HomePageController createState() => HomePageController(filePath);
}

class HomePageController extends MyState<HomePage> {
  static const int maxSelectableFileSizeBytes = 20 * 1024 * 1024;

  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _menuData;
  String filePath;

  HomePageController(this.filePath);

  @override
  Widget build(BuildContext context) {
    return isLandscapeLayout(context)
        ? _HomePageViewWin(this)
        : _HomePageView(this);
  }

  @override
  void initState() {
    super.initState();
    _initMenuData();
    // Future.delayed(
    //     Duration.zero, () => print('SCREEN RATIO: ${screenRatio(context)}'));

    handleIntent(filePath);
    filePath = null;

    // เปิดหน้า ตั้งค่าเมื่อเปิดใช้งานครั้งแรก
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chkFirstRun();
    });
  }

  void chkFirstRun() async {
    bool firstRun = await IsFirstRun.isFirstRun();
    if (firstRun) {
      Navigator.pushNamed(
        context,
        SettingsPage.routeName,
      );
    }
  }

  // called from main.dart
  void handleIntent(String filePath) {
    final normalizedPath = filePath?.trim();
    if (normalizedPath == null || normalizedPath.isEmpty) {
      return;
    }

    final routeToGo = _resolveRouteForFile(normalizedPath);
    Future.delayed(
      Duration.zero,
      () {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushNamed(
          context,
          routeToGo,
          arguments: normalizedPath,
        );
      },
    );
  }

  void _initMenuData() {
    _menuData = [
      {
        'image': 'assets/images/ic_document.png',
        'text': Platform.isWindows || Platform.isMacOS
            ? 'ไฟล์ในเครื่อง'
            : 'ไฟล์ในเครื่อง',
        'onClick': _pickFromFileSystem,
      },
      if (!Platform.isWindows || Platform.isMacOS)
        {
          'image': 'assets/images/ic_camera.png',
          'text': 'กล้อง',
          'onClick': _pickFromCamera,
        },
      {
        'image': 'assets/images/ic_gallery.png',
        'text': Platform.isWindows || Platform.isMacOS ? 'รูปภาพ' : 'คลังภาพ',
        'onClick': _pickFromGallery,
      },
      {
        'image': 'assets/images/ic_google_drive.png',
        'text': 'Google Drive',
        'onClick': _doPickFromGoogleDrive,
      },
      {
        'image': 'assets/images/ic_onedrive_new.png',
        'text': 'OneDrive',
        'onClick': _pickFromOneDrive,
      },
      {
        'image': 'assets/images/ic_history.png',
        'text': 'ประวัติ',
        'onClick': (BuildContext context) {
          Navigator.pushNamed(
            context,
            HistoryPage.routeName,
          );
        },
      },
    ];
  }

  _pickFromFileSystem(BuildContext context) async {
    logOneLineWithBorderDouble(await FileUtil.getImageDirPath());

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return MyDialog.buildPickerDialog(
          headerImage: Image.asset('assets/images/ic_document.png',
              width: Constants.LIST_DIALOG_HEADER_IMAGE_SIZE),
          items: [
            DialogTileData(
              label:
                  'โฟลเดอร์ของแอป${Platform.isWindows || Platform.isMacOS ? ' ' : '\n'}(App\'s Documents Folder)',
              /*image: Image.asset(
                'assets/images/ic_document.png',
                width: Constants.LIST_DIALOG_ICON_SIZE,
                height: Constants.LIST_DIALOG_ICON_SIZE,
              ),*/
              image: Icon(
                FontAwesomeIcons.solidFolderOpen,
                size: Constants.LIST_DIALOG_ICON_SIZE,
                color: Constants.LIST_DIALOG_ICON_COLOR,
              ),
              onClick: () async {
                Navigator.of(context).pop();
                Navigator.pushNamed(
                  context,
                  CloudPickerPage.routeName,
                  arguments: CloudPickerPageArg(
                      cloudDrive: LocalDrive(
                        CloudPickerMode.file,
                        (await FileUtil.getDocDir()).path,
                      ),
                      title: 'โฟลเดอร์ของแอป',
                      headerImagePath: 'assets/images/ic_document.png',
                      rootName: 'App\'s Folder'),
                );
              },
            ),
            // if (Platform.isIOS || Platform.isWindows || Platform.isMacOS)
            DialogTileData(
              label:
                  'โฟลเดอร์อื่นๆ${Platform.isWindows || Platform.isMacOS ? ' ' : '\n'}(เลือกจาก System Dialog)',
              image: Icon(
                FontAwesomeIcons.sdCard,
                size: Constants.LIST_DIALOG_ICON_SIZE,
                color: Constants.LIST_DIALOG_ICON_COLOR,
              ),
              onClick: () async {
                Navigator.of(context).pop();
                await _openSystemPicker(context);
                // Navigator.pushNamed(
                //   context,
                //   CloudPickerPage.routeName,
                //   arguments: CloudPickerPageArg(
                //       cloudDrive: LocalDrive(
                //         CloudPickerMode.file,
                //         (await FileUtil.getDir()).path,
                //       ),
                //       title: 'โฟลเดอร์ของแอป',
                //       headerImagePath: 'assets/images/ic_document.png',
                //       rootName: 'App\'s Folder'),
                // );
              },
            ),

            // if (Platform.isIOS)
            //   DialogTileData(
            //     label: 'iCloud',
            //     image: Icon(
            //       FontAwesomeIcons.cloud,
            //       size: Constants.LIST_DIALOG_ICON_SIZE,
            //       color: Constants.LIST_DIALOG_ICON_COLOR,
            //     ),
            //     onClick: () async {
            //       Navigator.of(context).pop();
            //       Navigator.pushNamed(
            //         context,
            //         CloudPickerPage.routeName,
            //         arguments: CloudPickerPageArg(
            //             cloudDrive: ICloudDrive(
            //               CloudPickerMode.file,
            //               '',
            //             ),
            //             title: 'iCloud',
            //             headerImagePath: 'assets/images/ic_icloud.png',
            //             rootName: 'iCloud'),
            //       );
            //     },
            //   ),
          ],
        );
      },
    );
  }

  Future<void> _getStoragePermission() async {
    if (Platform.isIOS) {
      bool storage = await Permission.storage.status.isGranted;
      if (storage) {
        // Awesome
      } else {
        // Crap
      }
    } else {
      bool storage = true;
      bool videos = true;
      bool photos = true;
      bool audio = true;

      // Only check for storage < Android 13
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print("androidInfo.version.sdkInt ${androidInfo.version.sdkInt}");
      if (androidInfo.version.sdkInt >= 33) {
        videos = await Permission.videos.status.isGranted;
        photos = await Permission.photos.status.isGranted;
        audio = await Permission.audio.status.isGranted;
      } else {
        storage = await Permission.storage.status.isGranted;
      }

      if (storage && videos && photos) {
        // Awesome
        print("aaaaa");
      } else {
        // Crap
        print("bbbbb");
      }
    }
  }

  _openSystemPicker2(BuildContext context) async {
    File _file;

    FilePickerResult result = await FilePicker.platform.pickFiles();

    final file = File(result.files.single.path);
    _file = file;
    setState(() {
      // print("fieleee ${_file.path}");
    });
  }

  _openSystemPicker(BuildContext context,
      {bool pickImage = false, bool pickVideo = false}) async {
    if (Platform.isAndroid == true) {
      await _getStoragePermission();
      // final permission1 = Permission.storage;
      final permission2 = Permission.photos;
      final permission3 = Permission.audio;
      final permission4 = Permission.camera;
      // if (await permission1.isDenied) {
      //   print("---photos permission---");
      //   await permission1.request();
      // }
      if (await permission2.isDenied) {
        await permission2.request();
      }
      if (await permission3.isDenied) {
        await permission3.request();
      }
      if (await permission4.isDenied) {
        await permission4.request();
      }
    }

    FilePickerCross pickedFile;

    try {
      isLoading = true;
      loadingMessage = 'กำลังแสดงไดอะล็อกสำหรับเลือกไฟล์';

      if (pickImage) {
        pickedFile = await FilePickerCross.importFromStorage(
          type: FileTypeCross.image,
        );
      } else if (pickVideo) {
        pickedFile = await FilePickerCross.importFromStorage(
          type: FileTypeCross.video,
        );
      } else {
        pickedFile = await FilePickerCross.importFromStorage(
          type: Platform.isWindows || Platform.isMacOS
              ? FileTypeCross.custom
              : FileTypeCross.any,
          fileExtension: Platform.isWindows || Platform.isMacOS
              ? Constants.selectableFileTypeList
                  .map((fileType) => fileType.fileExtension)
                  .join(', ')
              : '',
        );
      }
    } on FileSelectionCanceledError {
      _stopLoading();
      return;
    } catch (error, stackTrace) {
      logOneLineWithBorderDouble(
          'System picker failed: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      _stopLoading();
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'ไม่สามารถเลือกไฟล์ได้ กรุณาลองใหม่อีกครั้ง',
      );
      return;
    }

    if (!mounted) {
      return;
    }

    if (pickedFile == null) {
      _stopLoading();
      return;
    }

    final pickedFilePath = pickedFile.path?.trim();
    if (pickedFilePath == null || pickedFilePath.isEmpty) {
      _stopLoading();
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'ไม่สามารถอ่านไฟล์ที่เลือกได้',
      );
      return;
    }

    await _processPickedFile(pickedFilePath);
  }

  _pickFromCamera(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return MyDialog.buildPickerDialog(
            headerImage: Image.asset('assets/images/ic_camera.png',
                width: Constants.LIST_DIALOG_HEADER_IMAGE_SIZE),
            items: [
              DialogTileData(
                label: 'ถ่ายภาพนิ่ง',
                image: Icon(
                  Icons.camera_alt,
                  size: Constants.LIST_DIALOG_ICON_SIZE,
                  color: Constants.LIST_DIALOG_ICON_COLOR,
                ),
                onClick: () {
                  _pickMediaFile(
                      context, _picker.pickImage, ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              DialogTileData(
                label: 'ถ่ายวิดีโอ',
                image: Icon(
                  Icons.videocam_rounded,
                  size: Constants.LIST_DIALOG_ICON_SIZE,
                  color: Constants.LIST_DIALOG_ICON_COLOR,
                ),
                onClick: () {
                  _pickMediaFile(
                      context, _picker.pickVideo, ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ]);
      },
    );
  }

  _pickFromGallery(BuildContext context) async {
// Windows
    if (Platform.isWindows || Platform.isMacOS) {
      Navigator.pushNamed(
        context,
        CloudPickerPage.routeName,
        arguments: CloudPickerPageArg(
          cloudDrive: LocalDrive(
            CloudPickerMode.file,
            (await FileUtil.getImageDirPath()),
          ),
          title: 'รูปภาพ',
          headerImagePath: 'assets/images/ic_gallery.png',
          rootName: 'Pictures',
        ),
      );
    }
// Android, iOS
    else {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return MyDialog.buildPickerDialog(
              headerImage: Image.asset('assets/images/ic_gallery.png',
                  width: Constants.LIST_DIALOG_HEADER_IMAGE_SIZE),
              items: [
                DialogTileData(
                  label: 'เลือกรูปภาพ',
                  image: Icon(
                    Icons.image,
                    size: Constants.LIST_DIALOG_ICON_SIZE,
                    color: Constants.LIST_DIALOG_ICON_COLOR,
                  ),
                  onClick: () {
                    Navigator.pop(context);

                    Future.delayed(
                        Duration.zero,
                        () => _pickMediaFile(
                            context, _picker.pickImage, ImageSource.gallery));
                  },
                ),
                DialogTileData(
                  label: 'เลือกวิดีโอ',
                  image: Icon(
                    Icons.video_library,
                    size: Constants.LIST_DIALOG_ICON_SIZE,
                    color: Constants.LIST_DIALOG_ICON_COLOR,
                  ),
                  onClick: () {
                    Navigator.pop(context);
                    Future.delayed(
                        Duration.zero,
                        () => _pickMediaFile(
                            context, _picker.pickVideo, ImageSource.gallery));
                  },
                ),
              ]);
        },
      );
    }
  }

  _pickFromGoogleDrive(BuildContext context) async {
    showMaterialModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      builder: (bottomSheetContext) => Container(
        height: 120.0,
        child: Center(
          child: Container(
            height: 40.0,
            width: 180.0,
            child: SignInButton(
              Buttons.GoogleDark,
              padding: EdgeInsets.all(2.0),
              mini: false,
              onPressed: () {
                Navigator.pop(bottomSheetContext);
                _doPickFromGoogleDrive(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  _doPickFromGoogleDrive(BuildContext context) async {
    isLoading = true;
    loadingMessage = 'กำลังลงทะเบียนเข้าใช้งาน Google Drive';
    Future.delayed(Duration(seconds: 2), () {
      isLoading = false;
    });

    var googleDrive = GoogleDrive(CloudPickerMode.file);
    var signInSuccess = Platform.isWindows || Platform.isMacOS
        ? await googleDrive.signInWithOAuth2()
        : await googleDrive.signIn();

    if (signInSuccess) {
      Navigator.pushNamed(
        context,
        CloudPickerPage.routeName,
        arguments: CloudPickerPageArg(
            cloudDrive: googleDrive,
            title: 'Google Drive',
            headerImagePath: 'assets/images/ic_google_drive.png',
            rootName: 'Drive'),
      );
    } else {
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'ไม่สามารถลงทะเบียนเข้าใช้งาน Google Drive ได้',
      );
    }
    //isLoading = false;
  }

  _pickFromOneDrive(BuildContext context) async {
    /*if (Platform.isWindows || Platform.isMacOS) {
      var oneDrive = OneDrive(CloudPickerMode.file);
      var signInSuccess = await oneDrive.signInWithOAuth2();

      showOkDialog(context, 'SIGN IN - $signInSuccess');

      return;
    }*/

    isLoading = true;
    loadingMessage = 'กำลังลงทะเบียนเข้าใช้งาน OneDrive';
    Future.delayed(Duration(seconds: 2), () {
      isLoading = false;
    });

    var oneDrive = OneDrive(CloudPickerMode.file);
    var signInSuccess = Platform.isWindows || Platform.isMacOS
        ? await oneDrive.signInWithOAuth2()
        : await oneDrive.signIn();

    if (signInSuccess) {
      Navigator.pushNamed(
        context,
        CloudPickerPage.routeName,
        arguments: CloudPickerPageArg(
          cloudDrive: oneDrive,
          title: 'OneDrive',
          headerImagePath: 'assets/images/ic_onedrive_new.png',
          rootName: 'Drive',
        ),
      );
    } else {
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'ไม่สามารถลงทะเบียนเข้าใช้งาน OneDrive ได้',
      );
    }
    //isLoading = false;

    /*final success = await onedrive.connect();

    if (success) {
      logOneLineWithBorderDouble('YES');
      showOkDialog(context, 'สำเร็จ',
          textContent:
              'เข้าสู่ระบบด้วย Microsoft account สำเร็จ\nการเชื่อมต่อกับ OneDrive อยู่ระหว่างการพัฒนา');
      // Download files
      //final txtBytes = await onedrive.pull("/xxx/xxx.txt");

      // Upload files
      //await onedrive.push(txtBytes!, "/xxx/xxx.txt");
    } else {
      logOneLineWithBorderDouble('NO');
    }*/
  }

  _checkFileExtension(String filePath) {
    final extensionList = Constants.selectableFileTypeList
        .map((fileType) => fileType.fileExtension)
        .toList();
    //logOneLineWithBorderSingle('EXTENSION LIST: $extensionList');

    var extension = p.extension(filePath);
    if (extension.trim().isEmpty) {
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'ไฟล์ที่เลือกไม่มีนามสกุล (extension)',
      );
      return false;
    } else if (!extensionList.contains(extension.substring(1).toLowerCase())) {
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent:
            'แอปไม่รองรับการเข้ารหัสไฟล์ประเภท ${extension.substring(1).toUpperCase()}\n(ไฟล์ \'${p.basename(filePath)}\')',
      );
      return false;
    } else {
      //_test(filePath);
      return true;
    }
  }

  _pickMediaFile(BuildContext context,
      Future<XFile> Function({ImageSource source}) pickMethod,
      ImageSource source) async {
    isLoading = true;

    XFile selectedFile;
    try {
      selectedFile = await pickMethod(source: source);
    } catch (error, stackTrace) {
      logOneLineWithBorderDouble('Media pick failed: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      isLoading = false;
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'ไม่สามารถเลือกไฟล์ได้ กรุณาลองใหม่อีกครั้ง',
      );
      return;
    }

    if (!mounted) {
      return;
    }

    if (selectedFile == null) {
      _stopLoading();
      return;
    }

    String selectedFilePath;
    try {
      selectedFilePath = selectedFile.path?.trim();
    } catch (error, stackTrace) {
      logOneLineWithBorderDouble('Unable to read picked file path: '
          '$error\n$stackTrace');
      selectedFilePath = null;
    }

    if (selectedFilePath == null || selectedFilePath.isEmpty) {
      _stopLoading();
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'ไม่สามารถอ่านไฟล์ที่เลือกได้',
      );
      return;
    }

    await _processPickedFile(selectedFilePath);
  }

  @visibleForTesting
  Future<void> pickMediaFileForTest(
    BuildContext context,
    Future<XFile> Function({ImageSource source}) pickMethod,
    ImageSource source,
  ) async {
    await _pickMediaFile(context, pickMethod, source);
  }

  Future<void> _processPickedFile(String filePath) async {
    final normalizedPath = filePath?.trim();
    if (normalizedPath == null || normalizedPath.isEmpty) {
      _stopLoading();
      return;
    }

    final file = File(normalizedPath);

    try {
      final exists = await file.exists();
      if (!exists) {
        _stopLoading();
        if (!mounted) {
          return;
        }
        showOkDialog(
          context,
          'ผิดพลาด',
          textContent: 'ไม่พบไฟล์ที่เลือก',
        );
        return;
      }

      final size = await file.length();
      if (size >= maxSelectableFileSizeBytes) {
        _stopLoading();
        if (!mounted) {
          return;
        }
        showOkDialog(
          context,
          'ผิดพลาด',
          textContent: "ขนาดไฟล์ต้องไม่เกิน 20 MB",
        );
        return;
      }
    } on FileSystemException catch (error, stackTrace) {
      logOneLineWithBorderDouble('Unable to read file: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      _stopLoading();
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'ไม่สามารถอ่านไฟล์ที่เลือกได้',
      );
      return;
    }

    if (!_checkFileExtension(normalizedPath)) {
      _stopLoading();
      return;
    }

    final routeToGo = _resolveRouteForFile(normalizedPath);

    _stopLoading();

    if (!mounted) {
      return;
    }

    Navigator.pushNamed(
      context,
      routeToGo,
      arguments: normalizedPath,
    );
  }

  void _stopLoading() {
    if (!mounted) {
      return;
    }

    isLoading = false;
  }

  String _resolveRouteForFile(String filePath) {
    if (filePath == null || filePath.isEmpty) {
      return EncryptionPage.routeName;
    }

    final normalizedExtension = p.extension(filePath).toLowerCase();
    if (normalizedExtension ==
        '.${Navec.encryptedFileExtension.toLowerCase()}') {
      return DecryptionPage.routeName;
    }
    return EncryptionPage.routeName;
  }

  Future<PackageInfo> _getPackageInfo() async {
    return await PackageInfo.fromPlatform();

    /*String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;*/
  }
}
