import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/crypto_service.dart';
import '../../shared/widgets/adaptive_page_scaffold.dart';
import '../result/result_page.dart';
import '../result/result_page_args.dart';
import 'encryption_view.dart';
import 'encryption_view_win.dart';

class EncryptionPage extends StatefulWidget {
  const EncryptionPage({super.key});

  static const routeName = 'encryption';
  static const routeSegment = 'encryption';

  @override
  State<EncryptionPage> createState() => _EncryptionPageState();
}

class _EncryptionPageState extends State<EncryptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _notesController = TextEditingController();
  final _cryptoService = const CryptoService();

  bool _isProcessing = false;
  String? _lastError;

  @override
  void dispose() {
    _inputController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWindows = Theme.of(context).platform == TargetPlatform.windows;
    final view = isWindows
        ? EncryptionViewWin(
            formKey: _formKey,
            plainTextController: _inputController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            notesController: _notesController,
            isProcessing: _isProcessing,
            lastError: _lastError,
            onEncrypt: _handleEncrypt,
          )
        : EncryptionView(
            formKey: _formKey,
            plainTextController: _inputController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            notesController: _notesController,
            isProcessing: _isProcessing,
            lastError: _lastError,
            onEncrypt: _handleEncrypt,
          );

    return AdaptivePageScaffold(
      selectedRoute: '/${EncryptionPage.routeSegment}',
      pageTitle: 'Encrypt',
      body: view,
    );
  }

  Future<void> _handleEncrypt() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _lastError = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _lastError = null;
    });

    try {
      final result = await _cryptoService.encryptText(
        plainText: _inputController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      final args = ResultPageArgs(
        title: 'Encryption complete',
        details:
            'Encrypted payload:\n${result.payload}\n\nSalt: ${result.meta.salt}\nIterations: ${result.meta.iterations}\nNotes: ${_notesController.text.trim().isEmpty ? '—' : _notesController.text.trim()}',
        timestamp: DateTime.now(),
      );

      context.go(
        '/${ResultPage.routeSegment}',
        extra: args,
      );
    } on CryptoException catch (error) {
      setState(() {
        _lastError = error.message;
      });
    } catch (error) {
      setState(() {
        _lastError = 'Unexpected error: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
