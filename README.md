# Navy Encrypt

Modernised, cross-platform encryption utility targeting iOS, Android and Windows from a single Flutter codebase. The application provides responsive layouts for mobile and desktop, AES-256 encryption/decryption with PBKDF2 key derivation, and a refreshed UI for home, encryption, decryption, result and settings screens.

## Requirements

- Flutter 3.19 or newer (3.22 recommended)
- Dart 3.3 or newer
- Xcode 15 for iOS builds
- Android Studio / command line tools for Android builds
- Windows 11 SDK for desktop builds (optional)

## Getting started

```sh
flutter pub get
flutter run -d chrome # or ios, android, windows
```

The project no longer depends on FVM. Use your preferred Flutter installation, provided it meets the minimum version requirement.

## Features

- AES-256 CBC encryption with PBKDF2 (150k iterations) and HMAC integrity validation
- Friendly text-first workflows with desktop enhancements such as split panes and drag-and-drop targets
- Unified navigation using a responsive bottom navigation bar on mobile and navigation rail on desktop
- Result history screen with copy-to-clipboard helpers and export guidance
- Theme, language and accessibility toggles with instant feedback

## Project structure

```
lib/
  app.dart                # Application root, router and theming
  core/                   # Settings, routing and crypto utilities
  features/               # Home, encryption, decryption, result and settings flows
  shared/widgets/         # Responsive and adaptive UI primitives
```

## Testing

Run the Flutter test suite once dependencies are installed:

```sh
flutter test
```
