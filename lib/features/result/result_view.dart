import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'result_page_args.dart';

class ResultView extends StatelessWidget {
  const ResultView({super.key, required this.args});

  final ResultPageArgs args;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMMd().add_jm();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          args.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(dateFormat.format(args.timestamp)),
        const SizedBox(height: 16),
        SelectableText(
          args.details,
          style: const TextStyle(fontFamily: 'RobotoMono'),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () {
            final data = ClipboardData(text: args.details);
            Clipboard.setData(data);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied result to clipboard')),
            );
          },
          icon: const Icon(Icons.copy),
          label: const Text('Copy details'),
        ),
      ],
    );
  }
}
