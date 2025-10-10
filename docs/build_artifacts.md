# Building Android and iOS Artifacts

This guide describes how to create signed Android APKs and iOS IPAs for the
**navy_encrypt** Flutter application. All commands assume you are using
[FVM](https://fvm.app/) to ensure the pinned Flutter 3.3.8 toolchain and the
OpenJDK 17 runtime described in the project README. If you prefer to let CI
produce unsigned artifacts for you, jump to [Automated GitHub builds](#automated-github-builds).

> **Important:** The containers used in this repository's CI do not include the
> Android SDK, Xcode, or the Apple code-signing toolchain. You must run the
> commands below on a workstation that has the required vendor tooling
> installed. IPA generation specifically requires macOS with Xcode 14 or newer.

## Prerequisites

1. Install FVM and fetch the pinned Flutter SDK:

   ```sh
   pub global activate fvm
   fvm install
   ```

2. Use FVM for all Flutter/Dart commands in this project:

   ```sh
   fvm flutter pub get
   ```

3. Configure signing assets:
   - **Android:** Provide a release `key.properties` file and keystore. The
     template location is `android/key.properties`. Update `storePassword`,
     `keyPassword`, `keyAlias`, and `storeFile` to match your keystore.
   - **iOS:** Ensure you have a valid Apple developer account, signing
     certificate, and provisioning profile installed in Xcode. Update the
     bundle identifier in `ios/Runner.xcodeproj` if necessary.

## Building a Release APK

1. From the repository root run:

   ```sh
   fvm flutter build apk --release
   ```

2. The unsigned release APK is created at:

   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

3. If you need an Android App Bundle (AAB) for the Play Store, run:

   ```sh
   fvm flutter build appbundle --release
   ```

4. Commit the generated artifacts only if they are intended for distribution.
   Large binaries should generally be attached to release assets rather than
   stored in Git.

## Building a Release IPA

> These steps require macOS with Xcode and CocoaPods installed. They cannot be
> executed in standard Linux containers.

1. Install iOS dependencies:

   ```sh
   cd ios
   pod install
   cd ..
   ```

2. Build the IPA:

   ```sh
   fvm flutter build ipa --release --export-method ad-hoc
   ```

   Adjust the `--export-method` to `app-store`, `development`, or `enterprise`
   as needed for your distribution target.

3. The resulting IPA appears at:

   ```
   build/ios/ipa/Runner.ipa
   ```

4. Verify the archive in Xcode's Organizer before distributing. Upload the IPA
   through Transporter or Xcode for TestFlight/App Store delivery.

## Versioning and Git Workflow

- Update `pubspec.yaml` with a new `version:` before building distribution
  artifacts.
- Tag the commit that produced the release build, for example:

  ```sh
  git tag -a v1.2.3 -m "Release v1.2.3"
  git push origin v1.2.3
  ```

- Store large APK/IPA files outside the main branch when possible—use GitHub
  Releases or an artifact storage service to keep the repository lightweight.

## Automated GitHub builds

The repository ships with a [`Build Mobile Artifacts`](../.github/workflows/release_artifacts.yml)
workflow that targets both Android and iOS on every push to the `main` branch
and on manual dispatches.

1. Navigate to **Actions ▸ Build Mobile Artifacts** in GitHub and run the
   workflow (or inspect the latest run triggered by a `main` push).
2. Each run installs Flutter 3.3.8 on a `macos-latest` runner, resolves pods,
   and builds:
   - `app-release.apk` via `flutter build apk --release`
   - `Runner.ipa` via `flutter build ipa --release --no-codesign`
3. Download the resulting unsigned binaries from the run summary under the
   **Artifacts** section (`navy-encrypt-apk` and `navy-encrypt-ipa`).

Because the workflow disables code signing, you must still re-sign the IPA with
your Apple credentials before distributing it outside of internal testing.

