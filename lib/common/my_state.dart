import 'package:flutter/material.dart';
import 'package:navy_encrypt/etc/utils.dart';

abstract class MyState<T extends StatefulWidget> extends State<T> {
  bool _isLoading = false;
  bool _isError = false;
  double _loadingValue;
  String _loadingMessage;
  String _errorMessage;

  set loadingValue(double value) => setState(() {
        _loadingValue = value;
      });

  double get loadingValue => _loadingValue;

  set isLoading(bool loading) => setState(() {
        _isLoading = loading;
        if (!_isLoading) {
          _loadingMessage = null;
          _loadingValue = null;
        }
      });

  bool get isLoading => _isLoading;

  set isError(bool error) => setState(() {
        _isError = error;
        if (!isError) errorMessage = null;
      });

  bool get isError => _isError;

  set loadingMessage(String message) => setState(() {
        _loadingMessage = message;
      });

  String get loadingMessage => _loadingMessage;

  set errorMessage(String message) => setState(() {
        _errorMessage = message;
      });

  String get errorMessage => _errorMessage;

  @override
  void initState() {
    super.initState();
    logOneLineWithBorderDouble('$runtimeType initState()');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //logOneLineWithBorderDouble('$runtimeType didChangeDependencies()');
  }

  @override
  void dispose() {
    logOneLineWithBorderDouble('$runtimeType dispose()');
    super.dispose();
  }
}
