import 'package:flutter/material.dart';

class LoadingMessage extends ChangeNotifier {
  String _message;

  String get message => _message;

  void setMessage(String message) {
    _message = message;
    notifyListeners();
  }
}
