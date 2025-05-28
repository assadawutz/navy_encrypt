library file_viewer_page;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:navy_encrypt/common/my_state.dart';
import 'package:navy_encrypt/common/widget_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

part 'file_viewer_page_view.dart';

class FileViewerPage extends StatefulWidget {
  static const routeName = 'file_viewer_page';

  const FileViewerPage({Key key}) : super(key: key);

  @override
  _FileViewerPageController createState() => _FileViewerPageController();
}

class _FileViewerPageController extends MyState<FileViewerPage> {
  String _filePath;
  List<String> _filePathList;

  @override
  Widget build(BuildContext context) {
    var arg = ModalRoute.of(context).settings.arguments;
    print(arg.runtimeType);

    if (arg is String) {
      _filePath = arg;
    } else if (arg is List<String>) {
      _filePathList = arg;
    }

    return _FileViewerPageView(this);
  }
}
