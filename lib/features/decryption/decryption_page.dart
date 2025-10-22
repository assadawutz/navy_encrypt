import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/crypto_service.dart';
import '../../shared/widgets/adaptive_page_scaffold.dart';
import '../result/result_page.dart';
import '../result/result_page_args.dart';
import 'decryption_view.dart';
import 'decryption_view_win.dart';

class DecryptionPage extends StatefulWidget {
  const DecryptionPage({super.key});

  static const routeName = 'decryption';
  static const routeSegment = 'decryption';

  @override
  State<DecryptionPage> createState() => _DecryptionPageState();
}

class _DecryptionPageState extends State<DecryptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _payloadController = TextEditingController();
  final _passwordController = TextEditingController();
  final _notesController = TextEditingController();
  final _cryptoService = const CryptoService();

  bool _isProcessing = false;
  String? _lastError;

  @override
  void dispose() {
    _payloadController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWindows = Theme.of(context).platform == TargetPlatform.windows;
    final view = isWindows
        ? DecryptionViewWin(
            formKey: _formKey,
            payloadController: _payloadController,
            passwordController: _passwordController,
            notesController: _notesController,
            isProcessing: _isProcessing,
            lastError: _lastError,
            onDecrypt: _handleDecrypt,
          )
        : DecryptionView(
            formKey: _formKey,
            payloadController: _payloadController,
            passwordController: _passwordController,
            notesController: _notesController,
            isProcessing: _isProcessing,
            lastError: _lastError,
            onDecrypt: _handleDecrypt,
          );

    return AdaptivePageScaffold(
      selectedRoute: '/${DecryptionPage.routeSegment}',
      pageTitle: 'Decrypt',
      body: view,
    );
  }

  Future<void> _handleDecrypt() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _lastError = null;
    });

    try {
      final result = await _cryptoService.decryptText(
        encryptedPayload: _payloadController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      final args = ResultPageArgs(
        title: 'Decryption complete',
        details:
            'Recovered plain text:\n$result\n\nNotes: ${_notesController.text.trim().isEmpty ? '—' : _notesController.text.trim()}',
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
