class ResultPageArgs {
  const ResultPageArgs({
    required this.title,
    required this.details,
    required this.timestamp,
  });

  factory ResultPageArgs.empty() => ResultPageArgs(
        title: 'No results yet',
        details: 'Run an encryption or decryption job to see the output here.',
        timestamp: DateTime.now(),
      );

  final String title;
  final String details;
  final DateTime timestamp;
}
