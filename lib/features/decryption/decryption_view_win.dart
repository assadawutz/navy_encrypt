import 'package:flutter/material.dart';

class DecryptionViewWin extends StatelessWidget {
  const DecryptionViewWin({
    super.key,
    required this.formKey,
    required this.payloadController,
    required this.passwordController,
    required this.notesController,
    required this.isProcessing,
    required this.onDecrypt,
    this.lastError,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController payloadController;
  final TextEditingController passwordController;
  final TextEditingController notesController;
  final bool isProcessing;
  final VoidCallback onDecrypt;
  final String? lastError;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Decrypt payload',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextFormField(
                      controller: payloadController,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      decoration: const InputDecoration(
                        labelText: 'Encrypted payload',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Paste the payload you received';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes (optional)'),
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
                        return 'Password required';
                      }
                      return null;
                    },
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: isProcessing ? null : onDecrypt,
                    icon: isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : const Icon(Icons.lock_open_outlined),
                    label: Text(isProcessing ? 'Decrypting…' : 'Decrypt securely'),
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
