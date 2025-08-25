import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:navy_encrypt/pages/step_page.dart';
import 'package:navy_encrypt/etc/constants.dart';
import 'package:navy_encrypt/pages/decrypt_page.dart';
import 'package:navy_encrypt/pages/encrypt_page.dart';
import 'package:navy_encrypt/pages/test_encryption.dart';

import 'settings_page.dart';

const double menuItemSpace = 0.0;
const double menuItemCornerRadius = 0.0;

enum MenuItemType {
  document,
  camera,
  gallery,
  googleDrive,
  oneDrive,
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _handlePressMenuItem(MenuItemType type) {
    switch (type) {
      case MenuItemType.document:
        _temp(0);
        break;
      case MenuItemType.camera:
        _temp(0);
        break;
      case MenuItemType.gallery:
        _temp(0);
        break;
      case MenuItemType.googleDrive:
        _temp(1);
        break;
      case MenuItemType.oneDrive:
        _temp(1);
        break;
    }
  }

  void _temp(int type) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => type == 0 ? EncryptPage() : DecryptPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double menuItemSize3PerRow = (screenWidth - 4 * menuItemSpace) / 3;
    double menuItemSize2PerRow = (screenWidth - 3 * menuItemSpace) / 2;

    return Scaffold(
      appBar: null,
      body: Container(
        color: Constants.primaryColor,
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Expanded(
              child: SafeArea(
                child: Stack(
                  children: [
                    Container(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TestEncryption()),
                                );
                              },
                              child: Text(
                                'NAVEC',
                                style: GoogleFonts.oswald(
                                  fontSize: 90.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              'Navy Encryption/Decryption',
                              style: GoogleFonts.oswald(
                                fontSize: 21.0,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16.0),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsPage()),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            /*Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                MenuItem(
                  menuItemSize: menuItemSize,
                  icon: Entypo.folder,
                  text: 'เอกสาร',
                  backgroundColor: Color(0x80004da6),
                  onPress: () => _handlePressMenuItem(MenuItemType.document),
                ),
              ],
            ),*/
            Text(
              'เลือกไฟล์',
              style: GoogleFonts.prompt(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MenuItem(
                  width: menuItemSize3PerRow,
                  height: menuItemSize2PerRow * 0.8,
                  icon: Entypo.folder,
                  text: 'เอกสาร',
                  backgroundColor: Color(0x80004da6),
                  onPress: () => _handlePressMenuItem(MenuItemType.document),
                ),
                MenuItem(
                  width: menuItemSize3PerRow,
                  height: menuItemSize2PerRow * 0.8,
                  icon: FontAwesome.camera,
                  text: 'กล้อง',
                  backgroundColor: Color(0x802358d9),
                  onPress: () => _handlePressMenuItem(MenuItemType.camera),
                ),
                MenuItem(
                  width: menuItemSize3PerRow,
                  height: menuItemSize2PerRow * 0.8,
                  icon: Ionicons.ios_images,
                  text: 'คลังภาพ',
                  backgroundColor: Color(0x80005aff),
                  onPress: () => _handlePressMenuItem(MenuItemType.gallery),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MenuItem(
                  width: menuItemSize2PerRow,
                  height: menuItemSize2PerRow * 0.8,
                  icon: Entypo.google_drive,
                  text: 'Google Drive',
                  backgroundColor: Color(0x80006fdc),
                  onPress: () => _handlePressMenuItem(MenuItemType.googleDrive),
                ),
                MenuItem(
                  width: menuItemSize2PerRow,
                  height: menuItemSize2PerRow * 0.8,
                  icon: Entypo.onedrive,
                  text: 'OneDrive',
                  backgroundColor: Color(0xa0004da6),
                  onPress: () => _handlePressMenuItem(MenuItemType.oneDrive),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem({
    @required this.width,
    @required this.height,
    @required this.icon,
    @required this.text,
    @required this.backgroundColor,
    @required this.onPress,
    Key key,
  }) : super(key: key);

  final double width;
  final double height;
  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            //color: Colors.blue,
            /*border: Border.all(
            width: 0.0,
            color: Colors.black.withOpacity(0.2),
          ),*/
            //borderRadius: BorderRadius.all(Radius.circular(menuItemCornerRadius)),
            /*boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(1, 1), // changes position of shadow
            ),
          ],*/
            ),
        child: TextButton(
          onPressed: () {
            onPress();
          },
          style: TextButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(menuItemCornerRadius)),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 55.0,
                child: Icon(
                  icon,
                  size: 40.0,
                  color: Colors.white, //Theme.of(context).primaryColorDark,
                ),
              ),
              Text(
                text,
                style: GoogleFonts.prompt(
                  fontSize: 15.0,
                  color: Colors.white, //Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    /*return Padding(
      padding: const EdgeInsets.all(menuItemSpace / 2),
      child: Container(
        width: menuItemSize,
        height: menuItemSize,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            width: 0.0,
            color: Colors.black.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.all(Radius.circular(menuItemCornerRadius)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(2, 2), // changes position of shadow
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (onPress != null) onPress();
            },
            borderRadius: BorderRadius.all(Radius.circular(menuItemCornerRadius)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 55.0,
                  child: Icon(
                    icon,
                    size: 40.0,
                    color: Colors.black45,
                  ),
                ),
                Text(text, style: GoogleFonts.prompt(fontSize: 15.0)),
              ],
            ),
          ),
        ),
      ),
    );*/
  }
}
