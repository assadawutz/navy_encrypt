import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool get isDesktop {
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
    case TargetPlatform.macOS:
    case TargetPlatform.linux:
      return true;
    default:
      return kIsWeb && !isMobileWeb;
  }
}

bool get isMobileWeb => defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;
