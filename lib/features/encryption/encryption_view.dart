import 'package:flutter/material.dart';

class EncryptionView extends StatelessWidget {
  const EncryptionView({
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Encrypt data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Paste text or type directly. Files can be processed on desktop using the Windows layout.',
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: plainTextController,
              minLines: 6,
              maxLines: 12,
              decoration: const InputDecoration(
                labelText: 'Plain text',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide text to encrypt';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password required';
                      }
                      if (value.length < 8) {
                        return 'Use at least 8 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(labelText: 'Confirm password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm your password';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            if (lastError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  lastError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            FilledButton.icon(
              onPressed: isProcessing ? null : onEncrypt,
              icon: isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock),
              label: Text(isProcessing ? 'Encrypting…' : 'Encrypt now'),
            ),
          ],
        ),
      ),
    );
  }
}
