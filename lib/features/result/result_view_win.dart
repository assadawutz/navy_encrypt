import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'result_page_args.dart';

class ResultViewWin extends StatelessWidget {
  const ResultViewWin({super.key, required this.args});

  final ResultPageArgs args;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMMd().add_jm();
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            args.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(dateFormat.format(args.timestamp)),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: SelectableText(
                args.details,
                style: const TextStyle(fontFamily: 'RobotoMono'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              FilledButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: args.details));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied result to clipboard')),
                  );
                },
                icon: const Icon(Icons.copy_all),
                label: const Text('Copy details'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Export guidance'),
                      content: const Text(
                        'To export results on Windows, use Ctrl+C or right-click to copy, '
                        'then paste into your preferred tool. Printing and PDF export will arrive soon.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.file_open),
                label: const Text('Export help'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
