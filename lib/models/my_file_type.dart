import 'package:flutter/material.dart';

class MyFileType {
  final String fileExtension;
  final String mimeType;
  final IconData iconData;
  final Color iconColor;

  const MyFileType({
    @required this.fileExtension,
    @required this.mimeType,
    @required this.iconData,
    @required this.iconColor,
  });
}
