import 'dart:io';

import 'package:flutter/material.dart';
import 'package:navy_encrypt/etc/dimension_util.dart';

class EncryptDecryptHeader extends StatelessWidget {
  final String imagePath;
  final String title;

  const EncryptDecryptHeader({
    Key key,
    @required this.imagePath,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isWindows
        ? Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  height: !Platform.isWindows ? 56.0 : 35,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Color(0xFF626262),
                      fontSize: !Platform.isWindows ? 28.0 : 24,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: DimensionUtil.isTallScreen(context) ? 28.0 : 24.0,
                  ),
                ),
              ),
            ],
          );
  }
}
