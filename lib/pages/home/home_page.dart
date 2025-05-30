library home_page;

import 'dart:io' show Directory, File, FileSystemEntity, Platform;

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

    if (filePath != null) {
      handleIntent(filePath);
      filePath = null;
    }

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
    var dotIndex = filePath.lastIndexOf('.');
    var routeToGo = (dotIndex != -1 &&
            filePath.substring(dotIndex).toLowerCase() ==
                '.${Navec.encryptedFileExtension}')
        ? DecryptionPage.routeName
        : EncryptionPage.routeName;
    Future.delayed(
      Duration.zero,
      () {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushNamed(
          context,
          routeToGo,
          arguments: filePath,
        );
      },
    );
  }

  void _initMenuData() {
    _menuData = [
      {
        'image': 'assets/images/ic_document.png',
        'text': Platform.isWindows ? 'ไฟล์ในเครื่อง' : 'ไฟล์ในเครื่อง',
        'onClick': _pickFromFileSystem,
      },
      if (!Platform.isWindows)
        {
          'image': 'assets/images/ic_camera.png',
          'text': 'กล้อง',
          'onClick': _pickFromCamera,
        },
      {
        'image': 'assets/images/ic_gallery.png',
        'text': Platform.isWindows ? 'รูปภาพ' : 'คลังภาพ',
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
                  'โฟลเดอร์ของแอป${Platform.isWindows ? ' ' : '\n'}(App\'s Documents Folder)',
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
            // if (Platform.isIOS || Platform.isWindows)
            DialogTileData(
              label:
                  'โฟลเดอร์อื่นๆ${Platform.isWindows ? ' ' : '\n'}(เลือกจาก System Dialog)',
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

  _openSystemPicker2(BuildContext context,
      {bool pickImage = false, bool pickVideo = false}) async {
    File _file;

    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = File(result.files.single.path);
      _file = file;
      setState(() {
        // print("fieleee ${_file.path}");
      });
    } else {
      // User canceled the picker
      // You can show snackbar or fluttertoast
      // here like this to show warning to user
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select file'),
      ));
    }
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
          type: Platform.isWindows ? FileTypeCross.custom : FileTypeCross.any,
          fileExtension: Platform.isWindows
              ? Constants.selectableFileTypeList
                  .map((fileType) => fileType.fileExtension)
                  .fold('',
                      (previousValue, element) => '$previousValue, $element')
                  .substring(1)
                  .trim()
              : '',
        );
      }
    } on FileSelectionCanceledError catch (e) {
      // debugPrint('User ยกเลิกการเลือกไฟล์: ${e.toString()}');
      showOkDialog(context, 'User ยกเลิกการเลือกไฟล์:',
          textContent: e.toString());
    } catch (e) {
    } finally {
      isLoading = false;
    }

    if (pickedFile != null) {
      var size = await pickedFile.length;

      if (size >= 20000000) {
        setState(() {
          showOkDialog(context, 'ผิดพลาด',
              textContent: "ขนาดไฟล์ต้องไม่เกิน 20 MB");
        });
      } else {
        var filePath = pickedFile.path;
        isLoading = true;

        if (_checkFileExtension(filePath)) {
          var routeToGo = EncryptionPage.routeName;
          if (p.extension(filePath).substring(1) == 'enc') {
            routeToGo = DecryptionPage.routeName;
          }

          Navigator.pushNamed(
            context,
            routeToGo,
            arguments: filePath,
          );
        }

        isLoading = false;
      }
    }
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
    if (Platform.isWindows) {
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
    var signInSuccess = Platform.isWindows
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
    /*if (Platform.isWindows) {
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
    var signInSuccess = Platform.isWindows
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
    if (extension == null || extension.trim().isEmpty) {
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

  _pickMediaFile(
      BuildContext context, Function pickMethod, ImageSource source) async {
    isLoading = true;
    final XFile selectedFile = await pickMethod(
      source: source,
    );
    var size = await File(selectedFile.path).length();
    if (size >= 20000000) {
      isLoading = false;

      setState(() {
        isLoading = false;

        showOkDialog(context, 'ผิดพลาด',
            textContent: "ขนาดไฟล์ต้องไม่เกิน 20 MB");
      });
    } else {
      if (selectedFile != null && _checkFileExtension(selectedFile.path)) {
        Future.delayed(Duration(milliseconds: 500), () {
          isLoading = false;

          Navigator.pushNamed(
            context,
            EncryptionPage.routeName,
            arguments: selectedFile.path,
          );
        });
      } else {
        // User cancel selecting file OR error
        isLoading = false;
      }
    }
  }

  Future<PackageInfo> _getPackageInfo() async {
    return await PackageInfo.fromPlatform();

    /*String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;*/
  }
}
