import 'package:flutter/material.dart';

class CloudFile {
  final String id;
  final String name;
  final String fileExtension;
  final String mimeType;
  final bool isFolder;
  final DateTime modifiedTime;
  final String size;
  final String iconLink;
  final String thumbnailLink;

  CloudFile({
    @required this.id,
    @required this.name,
    @required this.fileExtension,
    @required this.mimeType,
    @required this.isFolder,
    this.modifiedTime,
    this.size,
    this.iconLink,
    this.thumbnailLink,
  });

  @override
  String toString() => '[$mimeType] $name';
}
