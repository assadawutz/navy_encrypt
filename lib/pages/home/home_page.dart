library home_page;

import 'dart:async' show FutureOr;
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
import 'package:share_plus/share_plus.dart';

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
  List<_HomeMenuAction> _menuActions;
  List<_HomeQuickAction> _quickActions;
  String filePath;
  Future<PackageInfo> _packageInfoFuture;

  HomePageController(this.filePath);

  List<_HomeMenuAction> get menuActions {
    if (_menuActions == null) {
      return const <_HomeMenuAction>[];
    }
    return _menuActions
        .where((action) => action.isVisible)
        .toList(growable: false);
  }

  List<_HomeQuickAction> get quickActions {
    if (_quickActions == null) {
      return const <_HomeQuickAction>[];
    }
    return _quickActions
        .where((action) => action.isVisible)
        .toList(growable: false);
  }

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
    _initQuickActions();
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
    final bool isDesktopPlatform = Platform.isWindows || Platform.isMacOS;
    final bool isMobilePlatform = Platform.isAndroid || Platform.isIOS;

    _menuActions = <_HomeMenuAction>[
      _HomeMenuAction(
        assetPath: 'assets/images/ic_document.png',
        labelBuilder: () => 'ไฟล์ในเครื่อง',
        onTap: _pickFromFileSystem,
      ),
      _HomeMenuAction(
        assetPath: 'assets/images/ic_camera.png',
        labelBuilder: () => 'กล้อง',
        onTap: _pickFromCamera,
        isVisible: () => isMobilePlatform,
      ),
      _HomeMenuAction(
        assetPath: 'assets/images/ic_gallery.png',
        labelBuilder: () => isDesktopPlatform ? 'รูปภาพ' : 'คลังภาพ',
        onTap: _pickFromGallery,
      ),
      _HomeMenuAction(
        assetPath: 'assets/images/ic_google_drive.png',
        labelBuilder: () => 'Google Drive',
        onTap: _doPickFromGoogleDrive,
      ),
      _HomeMenuAction(
        assetPath: 'assets/images/ic_onedrive_new.png',
        labelBuilder: () => 'OneDrive',
        onTap: _pickFromOneDrive,
      ),
      _HomeMenuAction(
        assetPath: 'assets/images/ic_history.png',
        labelBuilder: () => 'ประวัติ',
        onTap: _openHistory,
      ),
    ];
  }

  void _initQuickActions() {
    final bool isDesktopPlatform = Platform.isWindows || Platform.isMacOS;

    _quickActions = <_HomeQuickAction>[
      _HomeQuickAction(
        icon: Icons.lock_outline,
        label: 'เข้ารหัสไฟล์',
        tooltip: 'ไปยังหน้าสำหรับเข้ารหัสไฟล์',
        onTap: (context) {
          Navigator.pushNamed(
            context,
            EncryptionPage.routeName,
          );
        },
        isVisible: () => isDesktopPlatform,
      ),
      _HomeQuickAction(
        icon: Icons.lock_open_outlined,
        label: 'ถอดรหัสไฟล์',
        tooltip: 'ไปยังหน้าสำหรับถอดรหัสไฟล์',
        onTap: (context) {
          Navigator.pushNamed(
            context,
            DecryptionPage.routeName,
          );
        },
        isVisible: () => isDesktopPlatform,
      ),
      _HomeQuickAction(
        icon: Icons.share_outlined,
        label: 'แชร์ไฟล์ในเครื่อง',
        tooltip: 'เลือกไฟล์ในเครื่องเพื่อแชร์อย่างรวดเร็ว',
        onTap: _shareLocalFile,
        isVisible: () => isDesktopPlatform,
      ),
    ];
  }

  void _openHistory(BuildContext context) {
    Navigator.pushNamed(
      context,
      HistoryPage.routeName,
    );
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

  Future<void> _openSystemPicker2(BuildContext context) async {
    final FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) {
      return;
    }

    final String selectedPath = result.files.single.path;
    if (selectedPath == null || selectedPath.trim().isEmpty) {
      return;
    }

    final File selectedFile = File(selectedPath);
    if (!mounted) {
      return;
    }

    setState(() {
      // print("fieleee ${selectedFile.path}");
    });
  }

  Future<void> _openSystemPicker(
    BuildContext context, {
    bool pickImage = false,
    bool pickVideo = false,
  }) async {
    final selectedFilePath = await _pickFileFromSystem(
      context,
      pickImage: pickImage,
      pickVideo: pickVideo,
      keepLoadingOnSuccess: true,
      loadingText: 'กำลังแสดงไดอะล็อกสำหรับเลือกไฟล์',
    );

    if (selectedFilePath == null) {
      return;
    }

    await _processPickedFile(selectedFilePath);
  }

  Future<String> _pickFileFromSystem(
    BuildContext context, {
    bool pickImage = false,
    bool pickVideo = false,
    bool keepLoadingOnSuccess = false,
    String loadingText,
  }) async {
    if (Platform.isAndroid == true) {
      await _getStoragePermission();
      final permissionPhotos = Permission.photos;
      final permissionAudio = Permission.audio;
      final permissionCamera = Permission.camera;

      if (await permissionPhotos.isDenied) {
        await permissionPhotos.request();
      }
      if (await permissionAudio.isDenied) {
        await permissionAudio.request();
      }
      if (await permissionCamera.isDenied) {
        await permissionCamera.request();
      }
    }

    FilePickerCross pickedFile;

    try {
      isLoading = true;
      loadingMessage = loadingText ?? 'กำลังเลือกไฟล์';

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
      return null;
    } catch (error, stackTrace) {
      logOneLineWithBorderDouble(
          'System picker failed: $error\n$stackTrace');
      if (!mounted) {
        return null;
      }
      _stopLoading();
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'ไม่สามารถเลือกไฟล์ได้ กรุณาลองใหม่อีกครั้ง',
      );
      return null;
    }

    if (!mounted) {
      return null;
    }

    if (pickedFile == null) {
      _stopLoading();
      return null;
    }

    final pickedFilePath = pickedFile.path?.trim();
    if (pickedFilePath == null || pickedFilePath.isEmpty) {
      _stopLoading();
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'ไม่สามารถอ่านไฟล์ที่เลือกได้',
      );
      return null;
    }

    if (!keepLoadingOnSuccess) {
      _stopLoading();
    }

    return pickedFilePath;
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

  Future<void> _doPickFromGoogleDrive(BuildContext context) async {
    if (!mounted) {
      return;
    }

    isLoading = true;
    loadingMessage = 'กำลังลงทะเบียนเข้าใช้งาน Google Drive';

    final googleDrive = GoogleDrive(CloudPickerMode.file);
    try {
      final signInSuccess = Platform.isWindows || Platform.isMacOS
          ? await googleDrive.signInWithOAuth2()
          : await googleDrive.signIn();

      if (!mounted) {
        return;
      }

      if (signInSuccess == true) {
        Navigator.pushNamed(
          context,
          CloudPickerPage.routeName,
          arguments: CloudPickerPageArg(
            cloudDrive: googleDrive,
            title: 'Google Drive',
            headerImagePath: 'assets/images/ic_google_drive.png',
            rootName: 'Drive',
          ),
        );
      } else {
        showOkDialog(
          context,
          'ผิดพลาด',
          textContent: 'ไม่สามารถลงทะเบียนเข้าใช้งาน Google Drive ได้',
        );
      }
    } catch (error, stackTrace) {
      logOneLineWithBorderDouble(
          'Failed to register Google Drive session: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'ไม่สามารถลงทะเบียนเข้าใช้งาน Google Drive ได้',
      );
    } finally {
      if (mounted) {
        isLoading = false;
      }
    }
  }

  Future<void> _pickFromOneDrive(BuildContext context) async {
    /*if (Platform.isWindows || Platform.isMacOS) {
      var oneDrive = OneDrive(CloudPickerMode.file);
      var signInSuccess = await oneDrive.signInWithOAuth2();

      showOkDialog(context, 'SIGN IN - $signInSuccess');

      return;
    }*/

    if (!mounted) {
      return;
    }

    isLoading = true;
    loadingMessage = 'กำลังลงทะเบียนเข้าใช้งาน OneDrive';

    final oneDrive = OneDrive(CloudPickerMode.file);
    try {
      final signInSuccess = Platform.isWindows || Platform.isMacOS
          ? await oneDrive.signInWithOAuth2()
          : await oneDrive.signIn();

      if (!mounted) {
        return;
      }

      if (signInSuccess == true) {
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
    } catch (error, stackTrace) {
      logOneLineWithBorderDouble(
          'Failed to register OneDrive session: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'ไม่สามารถลงทะเบียนเข้าใช้งาน OneDrive ได้',
      );
    } finally {
      if (mounted) {
        isLoading = false;
      }
    }

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
    final XFile selectedFile = await pickMethod(
      source: source,
    );

    if (selectedFile == null) {
      isLoading = false;
      return;
    }

    var size = await File(selectedFile.path).length();
    if (size >= 20000000) {
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
    loadingMessage = 'กำลังตรวจสอบไฟล์';
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

  Future<void> _shareLocalFile(BuildContext context) async {
    final selectedFilePath = await _pickFileFromSystem(
      context,
      loadingText: 'กำลังเลือกไฟล์เพื่อแชร์',
    );

    if (selectedFilePath == null) {
      return;
    }

    try {
      await Share.shareFiles(<String>[selectedFilePath]);
    } catch (error, stackTrace) {
      logOneLineWithBorderDouble(
          'Failed to open share sheet: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      showOkDialog(
        context,
        'ผิดพลาด',
        textContent: 'ไม่สามารถแชร์ไฟล์ได้ กรุณาลองใหม่อีกครั้ง',
      );
    }
  }

  void _stopLoading() {
    if (!mounted) {
      return;
    }

    isLoading = false;
    loadingMessage = '';
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
  }

  String buildVersionLabel(PackageInfo packageInfo) {
    if (packageInfo == null) {
      return '';
    }

    final String version = packageInfo.version?.trim();
    final String buildNumber = packageInfo.buildNumber?.trim();

    if (version == null || version.isEmpty) {
      return '';
    }

    if (buildNumber == null || buildNumber.isEmpty) {
      return 'เวอร์ชัน $version';
    }

    return 'เวอร์ชัน $version+$buildNumber';
  }
}

typedef _MenuActionHandler = FutureOr<void> Function(BuildContext context);

class _HomeMenuAction {
  const _HomeMenuAction({
    @required this.assetPath,
    @required this.labelBuilder,
    @required this.onTap,
    bool Function() isVisible,
  }) : _isVisiblePredicate = isVisible;

  final String assetPath;
  final String Function() labelBuilder;
  final _MenuActionHandler onTap;
  final bool Function() _isVisiblePredicate;

  bool get isVisible => _isVisiblePredicate?.call() ?? true;

  String get label => labelBuilder();
}

class _HomeQuickAction {
  const _HomeQuickAction({
    @required this.icon,
    @required this.label,
    @required this.onTap,
    this.tooltip,
    bool Function() isVisible,
  }) : _isVisiblePredicate = isVisible;

  final IconData icon;
  final String label;
  final _MenuActionHandler onTap;
  final String tooltip;
  final bool Function() _isVisiblePredicate;

  bool get isVisible => _isVisiblePredicate?.call() ?? true;
}
  Future<PackageInfo> get packageInfoFuture =>
      _packageInfoFuture ??= _getPackageInfo();

  void refreshPackageInfo() {
    _packageInfoFuture = null;
  }

