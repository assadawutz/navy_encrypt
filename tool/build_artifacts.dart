import 'dart:io';

import 'package:args/args.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag(
      'apk',
      help: 'Build the Android APK (release).',
      defaultsTo: false,
    )
    ..addFlag(
      'appbundle',
      help: 'Build the Android App Bundle (release).',
      defaultsTo: false,
    )
    ..addFlag(
      'ipa',
      help: 'Build the iOS IPA (release).',
      defaultsTo: false,
    )
    ..addOption(
      'build-name',
      help: 'Overrides the build name (e.g. 3.0.4).',
    )
    ..addOption(
      'build-number',
      help: 'Overrides the build number (e.g. 8).',
    )
    ..addOption(
      'export-method',
      help: 'iOS export method (ad-hoc, app-store, development, enterprise).',
      defaultsTo: 'ad-hoc',
    )
    ..addOption(
      'flavor',
      help: 'Optional Flutter flavor name to build.',
    )
    ..addMultiOption(
      'dart-define',
      help: 'Key=value pairs forwarded to flutter build as --dart-define.',
    )
    ..addFlag(
      'ipa-no-codesign',
      help: 'Pass --no-codesign when building the IPA.',
      negatable: false,
    )
    ..addFlag(
      'verbose',
      help: 'Enable verbose output when invoking flutter.',
      negatable: false,
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show usage information.',
      negatable: false,
    );

  final ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } on FormatException catch (error) {
    _printUsage(parser, error.message);
    exitCode = 64; // EX_USAGE
    return;
  }

  if (argResults['help'] as bool) {
    _printUsage(parser);
    return;
  }

  final targets = <_BuildTarget>[];
  final requestedTargets = <String, bool>{
    'apk': argResults['apk'] as bool,
    'appbundle': argResults['appbundle'] as bool,
    'ipa': argResults['ipa'] as bool,
  };

  final anyExplicit = requestedTargets.values.any((value) => value);

  if (!anyExplicit) {
    targets
      ..add(_BuildTarget.apk)
      ..add(_BuildTarget.ipa);
  } else {
    if (requestedTargets['apk']!) {
      targets.add(_BuildTarget.apk);
    }
    if (requestedTargets['appbundle']!) {
      targets.add(_BuildTarget.appBundle);
    }
    if (requestedTargets['ipa']!) {
      targets.add(_BuildTarget.ipa);
    }
  }

  if (targets.isEmpty) {
    stdout.writeln('No build targets selected.');
    _printUsage(parser);
    exitCode = 64;
    return;
  }

  final flutter = await _FlutterInvoker.detect();

  final buildName = argResults['build-name'] as String?;
  final buildNumber = argResults['build-number'] as String?;
  final exportMethod = argResults['export-method'] as String?;
  final flavor = argResults['flavor'] as String?;
  final dartDefines = argResults['dart-define'] as List<String>;
  final verbose = argResults['verbose'] as bool;
  final ipaNoCodesign = argResults['ipa-no-codesign'] as bool;

  for (final target in targets) {
    final args = <String>['build', target.command];

    if (!target.supportsDebug) {
      args.add('--release');
    }

    if (buildName != null && buildName.isNotEmpty) {
      args..add('--build-name')..add(buildName);
    }
    if (buildNumber != null && buildNumber.isNotEmpty) {
      args..add('--build-number')..add(buildNumber);
    }
    if (flavor != null && flavor.isNotEmpty) {
      args..add('--flavor')..add(flavor);
    }
    for (final define in dartDefines) {
      args..add('--dart-define')..add(define);
    }
    if (verbose) {
      args.add('--verbose');
    }

    switch (target) {
      case _BuildTarget.apk:
        break;
      case _BuildTarget.appBundle:
        break;
      case _BuildTarget.ipa:
        if (ipaNoCodesign) {
          args.add('--no-codesign');
        }
        if (exportMethod != null && exportMethod.isNotEmpty) {
          args..add('--export-method')..add(exportMethod);
        }
        break;
    }

    stdout.writeln('➡️  Running: ${flutter.describe(args)}');
    final exitCode = await flutter.run(args);
    if (exitCode != 0) {
      stderr.writeln(
        '❌ ${target.description} failed with exit code $exitCode. Stopping.',
      );
      exit(exitCode);
    }
  }

  stdout.writeln('✅ All requested builds completed successfully.');
}

void _printUsage(ArgParser parser, [String? error]) {
  if (error != null) {
    stderr.writeln(error);
  }
  stdout
    ..writeln('Usage: dart run tool/build_artifacts.dart [options]')
    ..writeln(parser.usage)
    ..writeln()
    ..writeln('Examples:')
    ..writeln(
      '  dart run tool/build_artifacts.dart --apk --appbundle --build-name 3.0.4 --build-number 8',
    )
    ..writeln(
      '  dart run tool/build_artifacts.dart --ipa --export-method app-store',
    )
    ..writeln(
      '  dart run tool/build_artifacts.dart --apk --ipa --dart-define ENV=prod',
    );
}

enum _BuildTarget {
  apk('apk', 'Android APK'),
  appBundle('appbundle', 'Android App Bundle'),
  ipa('ipa', 'iOS IPA');

  const _BuildTarget(this.command, this.description);

  final String command;
  final String description;

  bool get supportsDebug => false;
}

class _FlutterInvoker {
  _FlutterInvoker(this.executable, this.prefixArgs);

  final String executable;
  final List<String> prefixArgs;

  static Future<_FlutterInvoker> detect() async {
    final candidates = <_FlutterInvoker>[
      _FlutterInvoker(_platformAwareExecutable('fvm'), ['flutter']),
      _FlutterInvoker(_platformAwareExecutable('flutter'), const []),
    ];

    for (final candidate in candidates) {
      if (await candidate._isUsable()) {
        return candidate;
      }
    }
    throw StateError(
      'Neither FVM nor the Flutter CLI could be found in the current PATH.\n'
      'Install FVM (https://fvm.app) or ensure flutter is available before rerunning.',
    );
  }

  Future<int> run(List<String> args) async {
    final process = await Process.start(
      executable,
      [...prefixArgs, ...args],
      runInShell: Platform.isWindows,
    );
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    return process.exitCode;
  }

  String describe(List<String> args) {
    final command = <String>[executable, ...prefixArgs, ...args];
    return command.join(' ');
  }

  Future<bool> _isUsable() async {
    try {
      final result = await Process.run(
        executable,
        [...prefixArgs, '--version'],
        runInShell: Platform.isWindows,
      );
      return result.exitCode == 0;
    } on ProcessException {
      return false;
    }
  }
}

String _platformAwareExecutable(String base) {
  if (Platform.isWindows) {
    if (base == 'flutter') {
      return 'flutter.bat';
    }
    if (base == 'fvm') {
      return 'fvm.bat';
    }
  }
  return base;
}
