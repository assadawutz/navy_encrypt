library test_page;

import 'package:flutter/material.dart';
import 'package:navy_encrypt/common/widget_view.dart';

part 'test_page_view.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key key}) : super(key: key);

  @override
  _TestPageController createState() => _TestPageController();
}

class _TestPageController extends State<TestPage> {
  @override
  Widget build(BuildContext context) => _TestPageView(this);
}
