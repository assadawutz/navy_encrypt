import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Hosts the logic that ensures Firebase is configured for the current platform
/// before the main application starts running.  The original bootstrap logic
/// lived directly inside `main.dart` and executed unconditionally which caused
/// crashes on platforms that do not yet ship with Firebase configuration files
/// (for example the Windows build).  The helper methods below centralise the
/// behaviour and make the decisions more explicit which allows the desktop
/// workflow to function again.
Future<void> configureFirebase() async {
  if (kIsWeb) {
    await _initializeFirebaseApp();
    await _configureAuthEmulatorIfNeeded();
    return;
  }

  if (_supportsFirebaseOnIo()) {
    await _initializeFirebaseApp();
    await _configureAuthEmulatorIfNeeded();
  }
}

bool _supportsFirebaseOnIo() {
  return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
}

Future<void> _initializeFirebaseApp() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}

Future<void> _configureAuthEmulatorIfNeeded() async {
  if (!_shouldUseAuthEmulator() || Firebase.apps.isEmpty) {
    return;
  }

  try {
    await FirebaseAuth.instance.useAuthEmulator(_emulatorHost, _emulatorPort);
  } on FirebaseAuthException catch (error) {
    debugPrint('Failed to connect to Firebase Auth emulator: ${error.message}');
  } on PlatformException catch (error) {
    debugPrint('Failed to connect to Firebase Auth emulator: ${error.message}');
  }
}

bool _shouldUseAuthEmulator() {
  if (kReleaseMode) {
    return false;
  }

  return const bool.fromEnvironment('USE_FIREBASE_AUTH_EMULATOR', defaultValue: true);
}

const String _emulatorHost = 'localhost';
const int _emulatorPort = 9099;
