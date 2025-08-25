import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navy_encrypt/pages/step_page.dart';

const double menuItemSpace = 12.0;
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
        _temp();
        break;
      case MenuItemType.camera:
        _temp();
        break;
      case MenuItemType.gallery:
        _temp();
        break;
      case MenuItemType.googleDrive:
        _temp();
        break;
      case MenuItemType.oneDrive:
        _temp();
        break;
    }
  }

  void _temp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StepPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double menuItemSize = (screenWidth - 4 * menuItemSpace) / 3;

    return Scaffold(
      appBar: AppBar(
        title: Text('NAVY ENCRYPT'),
      ),
      body: Container(
        color: Colors.lightBlue[50],
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MenuItem(
                  menuItemSize: menuItemSize,
                  icon: Entypo.folder,
                  text: 'เอกสาร',
                  onPress: () => _handlePressMenuItem(MenuItemType.document),
                ),
                MenuItem(
                  menuItemSize: menuItemSize,
                  icon: FontAwesome.camera,
                  text: 'กล้อง',
                  onPress: () => _handlePressMenuItem(MenuItemType.camera),
                ),
                MenuItem(
                  menuItemSize: menuItemSize,
                  icon: Ionicons.ios_images,
                  text: 'คลังภาพ',
                  onPress: () => _handlePressMenuItem(MenuItemType.gallery),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MenuItem(
                  menuItemSize: menuItemSize,
                  icon: Entypo.google_drive,
                  text: 'Google Drive',
                  onPress: () => _handlePressMenuItem(MenuItemType.googleDrive),
                ),
                MenuItem(
                  menuItemSize: menuItemSize,
                  icon: Entypo.onedrive,
                  text: 'One Drive',
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
    @required this.menuItemSize,
    @required this.icon,
    @required this.text,
    @required this.onPress,
    Key key,
  }) : super(key: key);

  final double menuItemSize;
  final IconData icon;
  final String text;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(1, 1), // changes position of shadow
            ),
          ],
        ),
        child: TextButton(
          onPressed: () {
            onPress();
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
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
                  color: Colors.grey[600], //Theme.of(context).primaryColorDark,
                ),
              ),
              Text(
                text,
                style: GoogleFonts.prompt(
                  fontSize: 15.0,
                  color: Colors.grey[800], //Theme.of(context).primaryColor,
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
