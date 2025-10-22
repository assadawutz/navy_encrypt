import 'package:flutter/material.dart';

class EncryptionViewWin extends StatelessWidget {
  const EncryptionViewWin({
    super.key,
    required this.formKey,
    required this.plainTextController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.notesController,
    required this.isProcessing,
    required this.onEncrypt,
    this.lastError,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController plainTextController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController notesController;
  final bool isProcessing;
  final VoidCallback onEncrypt;
  final String? lastError;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Encrypt data for secure transfer',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Drag & drop files or paste text below. The Windows layout unlocks advanced controls such as metadata tagging.',
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: TextFormField(
                      controller: plainTextController,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      decoration: const InputDecoration(
                        labelText: 'Plain text or JSON payload',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Provide the content you want to encrypt';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Operational notes (optional)',
                    ),
                    maxLines: 2,
                  ),
                  if (lastError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        lastError!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Credentials',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 12) {
                        return 'Use at least 12 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(labelText: 'Confirm password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm the password';
                      }
                      return null;
                    },
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: isProcessing ? null : onEncrypt,
                    icon: isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : const Icon(Icons.lock_outline),
                    label: Text(isProcessing ? 'Encrypting…' : 'Encrypt securely'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
